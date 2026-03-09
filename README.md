# 🚗 Smart Accident Detection and Automated Emergency Response System

> A real-time vehicle accident detection system powered by Computer Vision, Flutter, and Python Flask — designed to protect drivers and automatically alert emergency contacts when an accident is detected.

---

## 📌 Project Overview

The **Smart Accident Detection and Automated Emergency Response System (SADAR)** is an intelligent safety platform that continuously monitors the road through the vehicle's dashcam. Using YOLOv8-based object detection, it analyses the live video feed for signs of a collision.

When a potential accident is detected, the system initiates a voice confirmation dialogue with the driver. If the driver does not confirm their safety within a set time, the system automatically dispatches an emergency SMS containing the driver's GPS coordinates and a dashcam video clip to the registered emergency contact — without requiring any manual intervention.

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
| ☁️ **Cloud Video Upload** | Accident dashcam clips uploaded to Firebase Storage and shared via SMS |

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| **Mobile Frontend** | Flutter (Dart) |
| **Backend Server** | Python Flask |
| **Computer Vision** | OpenCV + YOLOv8 (Ultralytics) |
| **Authentication & Database** | Firebase Auth + Cloud Firestore |
| **Video Storage** | Firebase Storage |
| **Emergency Alerts** | Twilio SMS API |
| **Speech Recognition** | Google Speech Recognition (`SpeechRecognition` + `pyaudio`) |
| **Text-to-Speech** | `pyttsx3` |
| **Geolocation** | `geocoder` (IP-based) |
| **Environment Config** | `python-dotenv` |

---

## 📁 Project Structure

```
Smart-Accident-Detection-System/
│
├── backend/                        # Python Flask backend
│   ├── app.py                      # Main server: routes, detection loop, alert logic
│   ├── requirements.txt            # Python dependencies
│   ├── .env                        # Environment variables (NOT committed to Git)
│   ├── .env.example                # Template for environment variables
│   ├── firebase_key.json           # Firebase service account key (NOT committed to Git)
│   ├── yolov8n.pt                  # Pre-trained YOLOv8 nano model weights
│   ├── templates/
│   │   └── location.html           # Browser page for GPS sharing
│   └── venv/                       # Python virtual environment (NOT committed to Git)
│
├── sadar/                          # Flutter mobile application
│   ├── lib/
│   │   ├── main.dart               # App entry point, Firebase initialization
│   │   ├── screens/
│   │   │   ├── dashboard.dart      # Main dashboard with monitoring control
│   │   │   ├── emergency_screen.dart
│   │   │   └── profile_screen.dart
│   │   ├── services/
│   │   │   ├── monitoring_service.dart    # Flask API calls
│   │   │   ├── firestore_service.dart     # Firestore CRUD operations
│   │   │   ├── firebase_auth_service.dart # Firebase Auth wrapper
│   │   │   ├── contacts_service.dart      # Emergency contacts management
│   │   │   └── profile_service.dart
│   │   └── pages/
│   │       ├── login_page.dart
│   │       └── signup_page.dart
│   ├── android/app/google-services.json   # Firebase Android config (NOT committed to Git)
│   ├── pubspec.yaml                # Flutter dependencies
│   └── .env                        # Flutter environment config (NOT committed to Git)
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
Flutter sends POST /start-monitoring → Flask server (with user_id)
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
    "Yes / Safe"        within 6 seconds
        │                │
        ▼                ▼
  Resume monitoring   · Saves 20s dashcam clip (10s before + 10s after)
                      · Uploads video to Firebase Storage
                      · Gets GPS location
                      · Sends SMS via Twilio with location + video link
```

---

## 🚀 Installation & Setup Guide

### Prerequisites

Before you begin, make sure you have the following ready:

- **Python ≥ 3.9**
- **Flutter SDK ≥ 3.11**
- A **webcam / laptop camera** (for testing)
- A **Firebase project** with:
  - Cloud Firestore enabled
  - Firebase Authentication enabled (Email/Password)
  - Firebase Storage enabled
  - A service account key (`firebase_key.json`) downloaded
  - `google-services.json` for Android downloaded
- A **Twilio account** with:
  - Account SID and Auth Token
  - An SMS-capable Twilio phone number
- A **Supabase project** (used for user authentication in the Flutter app)
  - Project URL and anon key

---

### Step 1 — Clone the Repository

```bash
git clone https://github.com/sagarshettyy11/Smart-Accident-Detection-System.git
cd Smart-Accident-Detection-System
```

---

### Step 2 — Backend Setup (Python Flask)

#### 2a. Create and activate a virtual environment

```bash
cd backend

# Create virtual environment
python -m venv venv

# Activate — Windows
venv\Scripts\activate

# Activate — macOS / Linux
# source venv/bin/activate
```

#### 2b. Install dependencies

```bash
pip install -r requirements.txt
```

> **Note on PyAudio (Windows):** If `pyaudio` fails to install on Windows, install it via a prebuilt wheel:
> ```bash
> pip install pipwin
> pipwin install pyaudio
> ```

#### 2c. Add your Firebase service account key

Download your Firebase project's **service account key** from:
> Firebase Console → Project Settings → Service Accounts → Generate New Private Key

Save this file as:
```
backend/firebase_key.json
```

> ⚠️ This file contains sensitive credentials. It is listed in `.gitignore` and must **never** be committed to Git.

#### 2d. Create your `.env` file

Copy the example file and fill in your credentials:

```bash
# Windows
copy .env.example .env

# macOS / Linux
cp .env.example .env
```

Edit `.env` with your actual values:

```env
# ─── Twilio (SMS Alerts) ───────────────────────────────
# Get from: https://console.twilio.com
TWILIO_SID=ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
TWILIO_AUTH_TOKEN=your_twilio_auth_token
TWILIO_NUMBER=+1xxxxxxxxxx
ALERT_NUMBER=+91xxxxxxxxxx

# ─── Firebase Storage ──────────────────────────────────
# FIREBASE_BUCKET: found in Firebase Console → Storage → your-bucket-name
FIREBASE_BUCKET=your-project-id.appspot.com
# FIREBASE_KEY: path to your downloaded service account JSON file
FIREBASE_KEY=firebase_key.json
```

#### 2e. Run the backend server

```bash
python app.py
```

The server will start at **`http://0.0.0.0:5000`**.

You should see:
```
 * Running on http://0.0.0.0:5000
 * Debug mode: on
```

---

### Step 3 — Flutter Frontend Setup

#### 3a. Place Firebase config file

Download your `google-services.json` from:
> Firebase Console → Project Settings → Your Apps → Android App → Download `google-services.json`

Place it at:
```
sadar/android/app/google-services.json
```

> ⚠️ This file is listed in `.gitignore` and must **never** be committed to Git.

#### 3b. Configure Flutter environment

Create the Flutter `.env` file:

```bash
# From project root
cd sadar
```

Create a file called `.env` in the `sadar/` directory with your Supabase credentials (used for Flutter auth):

```env
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_ANON_KEY=your_supabase_anon_key_here
```

#### 3c. Install Flutter dependencies

```bash
flutter pub get
```

#### 3d. Configure the backend URL

Open `lib/services/monitoring_service.dart` and update `_baseUrl` to match your backend:

| Device | URL to use |
|---|---|
| Android Emulator | `http://10.0.2.2:5000` |
| Physical device (same WiFi) | `http://192.168.x.x:5000` (your machine's local IP) |
| iOS Simulator | `http://localhost:5000` |

#### 3e. Run the Flutter app

Ensure a device or emulator is connected, then:

```bash
flutter run
```

---

## 📖 How to Use the App

### 1. Sign Up / Log In
Create an account using your email and password. Your profile details (name, vehicle info) are stored in Firestore.

### 2. Add an Emergency Contact
Navigate to the **Emergency** tab and add the phone number of the person to be notified in case of an accident.

### 3. Start Monitoring
On the **Dashboard**, tap the **"Start Monitoring"** button.
- The button turns **green** and the label changes to **"Monitoring Vehicle"**.
- The Flask backend activates the camera and begins processing frames with YOLOv8.

### 4. Accident Detection (Automatic)
The system runs in the background. If a collision pattern is detected:
- A voice prompt asks: *"Accident detected. Are you safe?"*
- Say **"Yes"** or **"Safe"** to dismiss the alert and resume monitoring.
- If there is **no response within 6 seconds**, an emergency SMS is automatically sent with the GPS location and a dashcam video link.

### 5. Stop Monitoring
Tap the green button again to stop monitoring. The camera feed and detection loop shut down gracefully.

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