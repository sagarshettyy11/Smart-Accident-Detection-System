# 🚗 Smart Accident Detection and Automated Emergency Response System

> A real-time vehicle accident detection system powered by Computer Vision, Flutter, and Python Flask — designed to protect drivers and automatically alert emergency contacts when an accident is detected.

---

## 📌 Project Overview

The **Smart Accident Detection and Automated Emergency Response System (SADAR)** is an intelligent safety platform that continuously monitors the road through the vehicle's dashcam. Using YOLOv8-based object detection, it analyses the live video feed for signs of a collision.

When a potential accident is detected, the system initiates a confirmation dialogue with the driver. If the driver does not confirm their safety within a set time, the system automatically dispatches an emergency SMS containing the driver's GPS coordinates and a dashcam clip to the registered emergency contact — without requiring any manual intervention.

---

## ✨ Features

| Feature | Description |
|---|---|
| 🎥 **Dashcam Monitoring** | Activates the camera on demand from the mobile dashboard |
| 🤖 **Real-Time Accident Detection** | YOLOv8 model detects vehicle collisions as they happen |
| 🗣️ **Driver Safety Confirmation** | Voice-based prompt asks the driver if they are safe after a detected impact |
| 📍 **GPS Location Sharing** | Automatically captures and shares the driver's live GPS coordinates |
| 📲 **Automated Emergency Alert** | Sends SMS with location + dashcam clip to the emergency contact via Twilio |
| 📱 **Mobile Dashboard** | Flutter app lets users start/stop monitoring and manage emergency contacts |
| 🔐 **User Authentication** | Secure login and profile management via Firebase Auth and Firestore |

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| **Mobile Frontend** | Flutter (Dart) |
| **Backend Server** | Python Flask |
| **Computer Vision** | OpenCV + YOLOv8 (Ultralytics) |
| **Authentication & Database** | Firebase Auth + Cloud Firestore |
| **Video Storage** | Supabase Storage |
| **Emergency Alerts** | Twilio SMS API |
| **Speech Recognition** | Google Speech Recognition (`speech_recognition`) |
| **Text-to-Speech** | `pyttsx3` |
| **Geolocation** | `geocoder` (IP-based fallback) |

---

## 📁 Project Structure

```
Smart-Accident-Detection-System/
│
├── backend/                        # Python Flask backend
│   ├── app.py                      # Main server: routes, detection loop, alert logic
│   ├── requirements.txt            # Python dependencies
│   ├── .env                        # Environment variables (not committed)
│   ├── yolov8n.pt                  # Pre-trained YOLOv8 model weights
│   ├── templates/
│   │   └── location.html           # Browser page for GPS sharing
│   └── venv/                       # Python virtual environment (not committed)
│
├── sadar/                          # Flutter mobile application
│   ├── lib/
│   │   ├── main.dart               # App entry point
│   │   ├── screens/
│   │   │   ├── dashboard.dart      # Main dashboard with monitoring control
│   │   │   ├── emergency_screen.dart
│   │   │   └── profile_screen.dart
│   │   ├── services/
│   │   │   ├── monitoring_service.dart   # Flask API calls
│   │   │   ├── firestore_service.dart    # Firestore CRUD
│   │   │   ├── firebase_auth_service.dart
│   │   │   └── profile_service.dart
│   │   └── pages/
│   ├── pubspec.yaml                # Flutter dependencies
│   └── .env                        # Flutter environment config (not committed)
│
├── .gitignore
└── README.md
```

---

## ⚙️ How the System Works

```
User taps "Start Monitoring" on app
        │
        ▼
Flutter sends POST /start-monitoring → Flask server
        │
        ▼
Flask starts camera (OpenCV) + YOLOv8 detection loop in background thread
        │
        ▼
    ┌───────────────────────┐
    │  Frame-by-frame loop  │
    │  · Read camera frame  │
    │  · Run YOLO model     │
    │  · Check for vehicle  │
    │    collision overlap  │
    └───────────┬───────────┘
                │ Collision detected?
                ▼
    Speaks: "Accident detected. Are you safe?"
                │
        ┌───────┴────────┐
        │                │
    Driver says         No response
    "Yes / Safe"        or not safe
        │                │
        ▼                ▼
  Resume monitoring   Send emergency SMS via Twilio:
                       · Driver name, car, license
                       · GPS location (Google Maps link)
                       · Dashcam clip (uploaded to Supabase)
```

---

## 🚀 Installation Guide

### Prerequisites
- Flutter SDK ≥ 3.11
- Python ≥ 3.9
- A webcam / laptop camera (for testing)
- Firebase project with Firestore and Authentication enabled
- Supabase project with a storage bucket named `accident_videos`
- Twilio account with an SMS-capable number

---

### 1. Clone the Repository

```bash
git clone https://github.com/sagarshettyy11/Smart-Accident-Detection-System.git
cd Smart-Accident-Detection-System
```

---

### 2. Backend Setup

```bash
cd backend

# Create and activate virtual environment
python -m venv venv
venv\Scripts\activate        # Windows
# source venv/bin/activate   # macOS / Linux

# Install dependencies
pip install -r requirements.txt

# Create your environment file
copy .env.example .env       # then fill in your credentials
```

**`.env` file format:**

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-supabase-anon-key
SUPABASE_BUCKET=accident_videos
```

```bash
# Start the server
python app.py
# Server runs at http://0.0.0.0:5000
```

---

### 3. Flutter Frontend Setup

```bash
cd sadar

# Install Flutter dependencies
flutter pub get

# Run the app (ensure a device or emulator is connected)
flutter run
```

> **Emulator note:** The Flutter app uses `http://10.0.2.2:5000` to reach the Flask server from an Android emulator. For a physical device on the same WiFi, update `_baseUrl` in `lib/services/monitoring_service.dart` to your machine's local IP address (e.g. `http://192.168.1.x:5000`).

---

## 📖 How to Use the App

### 1. Sign Up / Log In
Create an account using your email and password. Your profile details (name, vehicle info) are stored in Firestore.

### 2. Add an Emergency Contact
Navigate to the **Emergency** tab and add the phone number of the person to be notified in case of an accident.

### 3. Start Monitoring
On the **Dashboard**, tap the **"Start Monitoring"** button.
- The button turns **green** and the label changes to **"Monitoring Vehicle"**.
- The Flask backend activates the camera and begins processing frames.

### 4. Accident Detection (Automatic)
The system runs in the background. If a collision pattern is detected:
- A voice prompt asks: *"Accident detected. Are you safe?"*
- Say **"Yes"** to dismiss the alert and resume monitoring.
- If there is **no response**, an emergency SMS is sent automatically.

### 5. Stop Monitoring
Tap the green button again to stop monitoring. The camera feed and detection loop shut down.

---

## 🔮 Future Improvements

- **Hardware Integration** — Replace laptop webcam with a dedicated dashcam module (e.g. Raspberry Pi Camera)
- **Raspberry Pi Deployment** — Port the backend to run on a Raspberry Pi mounted in the vehicle
- **Improved AI Model** — Fine-tune YOLOv8 on real accident datasets for higher precision
- **Accelerometer Fusion** — Combine camera data with IMU/gyroscope sensors to reduce false positives
- **Emergency Services Integration** — Automatically contact police / ambulance via emergency APIs
- **Offline Mode** — Cache alerts locally and send when connectivity is restored
- **Multi-Vehicle Support** — Manage multiple vehicles from a single account
- **Dashboard Analytics** — Trip history, incident logs, and safety score

---

## 🤝 Contributing

Pull requests are welcome! For major changes, please open an issue first to discuss what you would like to change.

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).

---

<div align="center">
  Built with ❤️ for road safety
</div>