import os
import time
import threading
from collections import deque
from datetime import datetime, timezone
import cv2
import geocoder
import pyttsx3
import speech_recognition as sr
from flask import Flask, jsonify, request, render_template
from flask_cors import CORS
from supabase import create_client
from twilio.rest import Client as TwilioClient
from ultralytics import YOLO
from dotenv import load_dotenv

# ================== Load Environment ==================
load_dotenv(dotenv_path=os.path.join(os.path.dirname(__file__), ".env"))

# ================== Credentials ==================
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_ANON_KEY = os.getenv("SUPABASE_ANON_KEY")
SUPABASE_BUCKET = os.getenv("SUPABASE_BUCKET", "accident_videos")

TWILIO_SID = os.getenv("TWILIO_SID")
TWILIO_AUTH_TOKEN = os.getenv("TWILIO_AUTH_TOKEN")
TWILIO_NUMBER = os.getenv("TWILIO_NUMBER")
TO_NUMBER = os.getenv("TO_NUMBER")
EMERGENCY_NUMBER = os.getenv("EMERGENCY_NUMBER")


# ================== Clients ==================
supabase = create_client(SUPABASE_URL, SUPABASE_ANON_KEY)
twilio_client = TwilioClient(TWILIO_SID, TWILIO_AUTH_TOKEN)

# ================== Flask App ==================
app = Flask(__name__)
CORS(app)  # Allow cross-origin requests from Flutter / emulator

# ================== Globals ==================
speech_lock = threading.Lock()
recognizer = sr.Recognizer()
FRAME_BUFFER_SECONDS = 12
DEFAULT_FPS = 20.0

# Monitoring control flag
monitoring_active = False

ZONE_OVERLAP_THRESHOLD = 0.45
ZONE_WIDTH_PERCENT = 0.4
ZONE_HEIGHT_PERCENT = 0.4

# Browser location
last_known_location = {"lat": None, "lon": None, "ts": None}

# ================== Browser Location Routes ==================

@app.route('/share_location')
def share_location_page():
    """Renders page for user to share laptop GPS location."""
    return render_template("location.html")

@app.route('/share_location', methods=['POST'])
def update_browser_location():
    """Receive location from browser (JS)."""
    data = request.get_json()
    lat, lon = data.get('lat'), data.get('lon')
    if lat and lon:
        last_known_location.update({
            "lat": float(lat),
            "lon": float(lon),
            "ts": datetime.now(timezone.utc).isoformat()
        })
        print(f"📍 Updated browser location: {lat}, {lon}")
        return jsonify({"message": "✅ Location updated", "lat": lat, "lon": lon})
    return jsonify({"error": "❌ Invalid location data"}), 400

def get_location():
    """Return the most accurate location available."""
    if last_known_location["lat"] and last_known_location["lon"]:
        return last_known_location["lat"], last_known_location["lon"]
    try:
        g = geocoder.ip('me', timeout=5)
        if g.ok:
            return g.latlng
    except Exception as e:
        print("⚠️ Geocoder fallback error:", e)
    return None, None

# ================== Helper Functions ==================

def speak(text):
    def _speak():
        with speech_lock:
            engine = pyttsx3.init()
            engine.say(text)
            engine.runAndWait()
            try:
                engine.stop()
            except:
                pass
    threading.Thread(target=_speak, daemon=True).start()

def send_alert_sms(body, to_number, media_urls=None):
    try:
        if to_number and not to_number.startswith("+91") and len(to_number) == 10:
            to_number = "+91" + to_number
        kwargs = {"body": body, "from_": TWILIO_NUMBER, "to": to_number}
        if media_urls:
            kwargs["media_url"] = media_urls
        message = twilio_client.messages.create(**kwargs)
        print("✅ SMS Sent:", message.sid)
        return message
    except Exception as e:
        print("❌ SMS Failed:", e)
        return None

def overlap_ratio(boxA, boxB):
    xA = max(boxA[0], boxB[0])
    yA = max(boxA[1], boxB[1])
    xB = min(boxA[2], boxB[2])
    yB = min(boxA[3], boxB[3])
    interArea = max(0, xB - xA) * max(0, yB - yA)
    if interArea == 0:
        return 0.0
    boxAArea = (boxA[2]-boxA[0])*(boxA[3]-boxA[1])
    boxBArea = (boxB[2]-boxB[0])*(boxB[3]-boxB[1])
    return interArea / float(min(boxAArea, boxBArea))

def save_last_seconds_clip(frames, fps, frame_size, path):
    if not frames:
        return False
    fourcc = cv2.VideoWriter_fourcc(*'mp4v')
    out = cv2.VideoWriter(path, fourcc, fps, frame_size)
    for f in frames:
        out.write(f)
    out.release()
    return True

def upload_to_supabase(local_path, bucket=SUPABASE_BUCKET):
    try:
        filename = os.path.basename(local_path)
        remote_path = f"accidents/{int(time.time())}_{filename}"
        with open(local_path, "rb") as f:
            supabase.storage.from_(bucket).upload(remote_path, f, {"content-type": "video/mp4", "upsert": "true"})
        signed = supabase.storage.from_(bucket).create_signed_url(remote_path, 24*3600)
        if isinstance(signed, dict):
            url = signed.get("signedURL") or signed.get("signed_url")
            if url:
                return url
        host = SUPABASE_URL.replace("https://", "").strip("/")
        return f"https://{host}/storage/v1/object/public/{bucket}/{remote_path}"
    except Exception as e:
        print("❌ Supabase upload failed:", e)
        return None

def get_user_profile(user_id):
    try:
        res = supabase.from_("profiles").select("*").eq("user_id", user_id).execute()
        if res.data:
            return res.data[0]
    except Exception as e:
        print("❌ Supabase profile fetch failed:", e)
    return {}

# ================== Accident Detection ==================
def run_accident_detection(user_id):
    global monitoring_active
    print(f"🚗 Accident detection started for {user_id}")
    speak("Accident detection started.")
    model = YOLO("yolov8n.pt")

    # On Windows, MSMF (Microsoft Media Foundation) is the most reliable backend.
    # Try MSMF first on each index, then fall back to DSHOW.
    cap = None
    backends = [cv2.CAP_MSMF, cv2.CAP_DSHOW, cv2.CAP_ANY]
    for cam_index in [0, 1]:
        for backend in backends:
            _cap = cv2.VideoCapture(cam_index, backend)
            if _cap.isOpened():
                cap = _cap
                print(f"📷 Camera opened — index={cam_index}, backend={backend}")
                break
            _cap.release()
        if cap is not None:
            break

    if cap is None:
        print("❌ No accessible camera found on this machine.")
        monitoring_active = False
        return

    fps = float(cap.get(cv2.CAP_PROP_FPS) or DEFAULT_FPS)
    w, h = int(cap.get(3)), int(cap.get(4))
    frame_buffer = deque(maxlen=int(FRAME_BUFFER_SECONDS * fps))
    last_alert, cooldown = 0, 5

    zone_w, zone_h = int(w*ZONE_WIDTH_PERCENT), int(h*ZONE_HEIGHT_PERCENT)
    our_car_zone = (w//2 - zone_w//2, h-zone_h-10, w//2 + zone_w//2, h-10)

    while monitoring_active:
        ret, frame = cap.read()
        if not ret:
            continue
        frame_buffer.append(frame.copy())
        results = model(frame)
        annotated = results[0].plot()
        vehicles = []

        for box in results[0].boxes:
            cls, conf = int(box.cls[0]), float(box.conf[0])
            x1, y1, x2, y2 = map(int, box.xyxy[0])
            if cls in [2,3,5,7] and conf > 0.5:
                vehicles.append((x1,y1,x2,y2))
                cv2.rectangle(annotated,(x1,y1),(x2,y2),(255,0,0),2)

        cv2.rectangle(annotated,(our_car_zone[0],our_car_zone[1]),
                      (our_car_zone[2],our_car_zone[3]),(0,255,0),2)
        cv2.putText(annotated,"OUR CAR ZONE",(our_car_zone[0],our_car_zone[1]-10),
                    cv2.FONT_HERSHEY_SIMPLEX,0.6,(0,255,0),2)

        for car in vehicles:
            overlap = overlap_ratio(car, our_car_zone)
            if overlap > ZONE_OVERLAP_THRESHOLD and time.time() - last_alert > cooldown:
                print("💥 Collision detected! overlap=", overlap)
                handle_accident_confirmation(frame_buffer, fps, (w,h), user_id)
                last_alert = time.time()
                break

        cv2.imshow("Accident Detection", annotated)
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break
        # Also stop if flag cleared via /stop-monitoring
        if not monitoring_active:
            break

    monitoring_active = False
    cap.release()
    cv2.destroyAllWindows()
    print("\U0001f6d1 Accident detection stopped.")

# ================== Confirmation Flow ==================
def handle_accident_confirmation(frames, fps, size, user_id):
    try:
        speak("Accident detected. Are you safe?")
        print("🗣 Asking driver...")

        time.sleep(3)
        heard_yes = False
        with sr.Microphone() as mic:
            recognizer.adjust_for_ambient_noise(mic, duration=1.5)
            try:
                audio = recognizer.listen(mic, timeout=8, phrase_time_limit=6)
                text = recognizer.recognize_google(audio, language="en-IN").lower()
                print("🗨 Recognized:", text)
                if any(w in text for w in ["yes","yeah","ok","okay","safe","fine"]):
                    heard_yes = True
            except Exception as e:
                print("🎤 Error:", e)

        if heard_yes:
            speak("Thank you. Resuming monitoring.")
            return

        speak("No response detected. Sending emergency alert.")
        print("🚨 Sending alert...")

        lat, lon = get_location()
        loc_url = f"https://www.google.com/maps?q={lat},{lon}" if lat and lon else "Location unavailable"

        out_path = os.path.join(os.getcwd(), f"accident_{datetime.now(timezone.utc).strftime('%Y%m%d_%H%M%S')}.mp4")
        save_last_seconds_clip(list(frames)[-int(10*fps):], fps, size, out_path)
        video_url = upload_to_supabase(out_path)

        driver = get_user_profile(user_id)
        owner = driver.get("owner_name","Unknown")
        car = driver.get("car_model","Unknown")
        lic = driver.get("license_number","Unknown")
        rc = driver.get("rc_number","Unknown")
        contact = driver.get("contact_number","Unknown")
        emergency = EMERGENCY_NUMBER or TO_NUMBER


        msg1 = f"🚨 Accident Detected!\nOwner: {owner}\nCar: {car}\nLicense: {lic}\nRC: {rc}\nContact: {contact}"
        msg2 = f"📍 Location: {loc_url}"
        msg3 = f"🎥 Video: {video_url if video_url else 'Not available'}"

        for i, body in enumerate([msg1, msg2, msg3], start=1):
            print(f"SMS Part {i}:\n{body}")
            send_alert_sms(body, emergency)
            time.sleep(2)

    except Exception as e:
        print("❌ Error in confirmation:", e)

# ================== Flask Routes ==================
@app.route('/')
def home():
    return jsonify({"status": "Server running!", "hint": "Visit /share_location to set location."})


@app.route('/start-monitoring', methods=['POST', 'OPTIONS'])
def start_monitoring():
    """Flutter-friendly endpoint to start accident detection."""
    global monitoring_active
    if monitoring_active:
        return jsonify({"message": "Monitoring already running"}), 200
    data = request.get_json(silent=True) or {}
    user_id = data.get("user_id", "default_user")
    monitoring_active = True
    threading.Thread(
        target=run_accident_detection, args=(user_id,), daemon=True
    ).start()
    return jsonify({"message": "Monitoring started", "user_id": user_id}), 200


@app.route('/stop-monitoring', methods=['POST', 'OPTIONS'])
def stop_monitoring():
    """Flutter-friendly endpoint to stop accident detection."""
    global monitoring_active
    monitoring_active = False
    return jsonify({"message": "Monitoring stopped"}), 200


@app.route('/start_accident_detection', methods=['POST'])
def start_detection():
    """Legacy endpoint kept for backward compatibility."""
    global monitoring_active
    data = request.get_json() or request.form
    user_id = data.get("user_id")
    if not user_id:
        return jsonify({"error": "user_id required"}), 400
    if not monitoring_active:
        monitoring_active = True
        threading.Thread(
            target=run_accident_detection, args=(user_id,), daemon=True
        ).start()
    return jsonify({"message": "Accident detection started", "user_id": user_id}), 200


if __name__ == '__main__':
    # use_reloader=False is critical — the Flask reloader spawns a child process
    # which kills background threads (camera loop) and leaves the camera handle
    # locked, causing "Camera not accessible" on the next monitoring attempt.
    app.run(host='0.0.0.0', port=5000, debug=True, use_reloader=False)
