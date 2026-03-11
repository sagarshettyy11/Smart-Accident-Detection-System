import os
import time
import threading
from collections import deque
from datetime import datetime

import cv2
import geocoder
import pyttsx3
import speech_recognition as sr
import firebase_admin
from firebase_admin import credentials, storage, firestore
from flask import Flask, jsonify, request
from flask_cors import CORS

from supabase import create_client
from twilio.rest import Client
from ultralytics import YOLO
from dotenv import load_dotenv


# ================= LOAD ENV =================
load_dotenv()
TWILIO_SID = os.getenv("TWILIO_SID")
TWILIO_AUTH = os.getenv("TWILIO_AUTH_TOKEN")
TWILIO_NUMBER = os.getenv("TWILIO_NUMBER")
ALERT_NUMBER = os.getenv("ALERT_NUMBER")
twilio = Client(TWILIO_SID, TWILIO_AUTH)

FIREBASE_BUCKET = os.getenv("FIREBASE_BUCKET")
FIREBASE_KEY = os.getenv("FIREBASE_KEY")

cred = credentials.Certificate(FIREBASE_KEY)
firebase_admin.initialize_app(cred, {
    "storageBucket": FIREBASE_BUCKET
})
db = firestore.client()

# ================= CLIENTS =================
app = Flask(__name__)
CORS(app)
recognizer = sr.Recognizer()
speech_lock = threading.Lock()
monitoring_active = False
FRAME_BUFFER_SECONDS = 10
DEFAULT_FPS = 20
YOLO_FRAME_SKIP = 3
ZONE_OVERLAP_THRESHOLD = 0.45

# ================= SPEECH =================
def speak(text):
    def run():
        with speech_lock:
            engine = pyttsx3.init()
            engine.say(text)
            engine.runAndWait()
    threading.Thread(target=run, daemon=True).start()


# ================= LOCATION =================
def get_location():
    try:
        g = geocoder.ip("me")
        if g.ok:
            return g.latlng
    except:
        pass
    return None, None

# ================= SMS =================
def send_sms(body):
    try:
        message = twilio.messages.create(
            body=body,
            from_=TWILIO_NUMBER,
            to=ALERT_NUMBER
        )
        print("SMS SENT:", message.sid)
    except Exception as e:
        print("SMS FAILED:", e)

# ================= VIDEO SAVE =================
def save_video(frames, fps, size, path):
    fourcc = cv2.VideoWriter_fourcc(*"mp4v")
    out = cv2.VideoWriter(path, fourcc, fps, size)
    for f in frames:
        out.write(f)
    out.release()

# ================= SUPABASE =================
def upload_video_to_firebase(video_path, user_id):
    try:
        bucket = storage.bucket()
        filename = os.path.basename(video_path)
        blob = bucket.blob(f"users/{user_id}/accidents/{filename}")
        blob.upload_from_filename(video_path)
        blob.make_public()
        return blob.public_url
    except Exception as e:
        print("Upload failed:", e)
        return None
    
# ================= OVERLAP =================
# ================= OVERLAP =================
def overlap(boxA, boxB):
    xA = max(boxA[0], boxB[0])
    yA = max(boxA[1], boxB[1])
    xB = min(boxA[2], boxB[2])
    yB = min(boxA[3], boxB[3])
    interArea = max(0, xB - xA) * max(0, yB - yA)
    if interArea == 0:
        return 0
    boxAArea = (boxA[2]-boxA[0])*(boxA[3]-boxA[1])
    boxBArea = (boxB[2]-boxB[0])*(boxB[3]-boxB[1])
    return interArea / min(boxAArea, boxBArea)

def center(box):
    return ((box[0] + box[2]) // 2, (box[1] + box[3]) // 2)

# ================= ACCIDENT CONFIRMATION =================
def confirm_accident(frames, fps, size, user_id):
    speak("Accident detected. Are you safe?")
    time.sleep(3)
    try:
        with sr.Microphone() as mic:
            recognizer.adjust_for_ambient_noise(mic)
            audio = recognizer.listen(mic, timeout=6)
            text = recognizer.recognize_google(audio).lower()
            print("Driver said:", text)
            if "yes" in text or "safe" in text:
                speak("Okay. Monitoring continues.")
                return
    except Exception as e:
        print("Voice detection failed:", e)
    speak("No response detected. Sending emergency alert.")
    lat, lon = get_location()
    location = f"https://maps.google.com?q={lat},{lon}"
    filename = f"accident_{int(time.time())}.mp4"
    save_video(frames, fps, size, filename)

# ================Upload video to Firebase===================
    video_url = upload_video_to_firebase(filename, user_id)
    alert_data = {
        "user_id": user_id,
        "location": location,
        "video": video_url,
        "timestamp": firestore.SERVER_TIMESTAMP
    }
    db.collection("users") \
    .document(user_id) \
    .collection("accidents") \
    .add(alert_data)
    print("ACCIDENT ALERT SENT TO FIRESTORE")

# ================= DETECTION LOOP =================
def detection_loop(user_id):
    global monitoring_active
    model = YOLO("yolov8n.pt")
    cap = cv2.VideoCapture(0)
    if not cap.isOpened():
        print("Camera error")
        monitoring_active = False
        return
    fps = cap.get(cv2.CAP_PROP_FPS) or DEFAULT_FPS
    w = int(cap.get(3))
    h = int(cap.get(4))
    frame_buffer = deque(maxlen=int(FRAME_BUFFER_SECONDS * fps))
    zone = (w//3, h//2, w*2//3, h)
    frame_id = 0
    last_alert = 0
    cooldown = 10
    while monitoring_active:
        ret, frame = cap.read()
        if not ret:
            continue
        frame_buffer.append(frame.copy())
        frame_id += 1

# Show camera window always
        cv2.imshow("SADAR Accident Detection", frame)

        if cv2.waitKey(1) & 0xFF == ord("q"):
            break

# Skip YOLO processing for some frames
        if frame_id % YOLO_FRAME_SKIP != 0:
            continue
        results = model(frame)
        vehicles = []
        for box in results[0].boxes:
            cls = int(box.cls[0])
            if cls in [2,3,5,7]:
                x1,y1,x2,y2 = map(int, box.xyxy[0])
                vehicles.append((x1,y1,x2,y2))
        if len(vehicles) < 2:
            continue
        for i in range(len(vehicles)):
            for j in range(i + 1, len(vehicles)):
                v1 = vehicles[i]
                v2 = vehicles[j]
                collision = overlap(v1, v2)
                c1 = center(v1)
                c2 = center(v2)
                distance = ((c1[0]-c2[0])**2 + (c1[1]-c2[1])**2) ** 0.5
                if collision > 0.25 or distance < 80:
                
                    if time.time() - last_alert > cooldown:
                        print("Possible vehicle collision detected")

                        # 10 seconds BEFORE accident
                        before_frames = list(frame_buffer)[-int(10*fps):]

                        # 10 seconds AFTER accident
                        after_frames = []
                        start_time = time.time()

                        while time.time() - start_time < 10:
                            ret2, frame2 = cap.read()
                            if ret2:
                                after_frames.append(frame2)

                        all_frames = before_frames + after_frames

                        confirm_accident(
                            all_frames,
                            fps,
                            (w, h),
                            user_id
                        )

                        last_alert = time.time()
        cv2.rectangle(frame,(zone[0],zone[1]),(zone[2],zone[3]),(0,255,0),2)
        cv2.imshow("SADAR Accident Detection", frame)
        if cv2.waitKey(1) & 0xFF == ord("q"):
            break
    cap.release()
    cv2.destroyAllWindows()
    monitoring_active = False


# ================= ROUTES =================
@app.route('/')
def home():
    return jsonify({
        "status": "Server running",
        "service": "SADAR Accident Detection API"
    })


@app.route('/start-monitoring', methods=['POST'])
def start_monitoring():
    global monitoring_active
    if monitoring_active:
        return jsonify({"message": "Monitoring already running"})
    speak("Accident detection started. Drive safely.")
    data = request.get_json()
    if not data or "user_id" not in data:
        return jsonify({"error": "user_id required"}), 400
    user_id = data["user_id"]
    monitoring_active = True
    threading.Thread(
        target=detection_loop,
        args=(user_id,),
        daemon=True
    ).start()
    return jsonify({"message": "Monitoring started"})

@app.route('/stop-monitoring', methods=['POST'])
def stop_monitoring():
    global monitoring_active
    monitoring_active = False
    speak("Accident monitoring stopped.")
    return jsonify({"message": "Monitoring stopped"})

# ================= MAIN =================
if __name__ == "__main__":
    app.run(
        host="0.0.0.0",
        port=5000,
        debug=True,
        use_reloader=False
    )