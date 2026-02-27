# Maternal & Child Health Tracker 🤱👶

A comprehensive Flutter-based companion designed to guide mothers through every stage of pregnancy and early parenthood. This app integrates modern technology with health tracking to ensure a safe and informed journey.

## ✨ Key Features

- **🛡️ Emergency Map & SOS**: Real-time GPS location sharing with emergency contacts (Doctors, Hospitals, Family). Includes a one-tap SOS button and nearest hospital locator.
- **📅 Hospital Scheduling**: Keep track of prenatal checkups and vaccination schedules with ease.
- **🤖 AI Health Assistant**: Integrated LLM chat (Gemini) for instant answers to common health concerns.
- **🌱 Weekly Development Tracking**: Detailed insights into maternal changes and fetal development.
- **🧠 Mood & Milestone Tracking**: Tools to monitor emotional well-being and capture precious developmental milestones.
- **🤸 Exercise & Wellness**: Curated exercise routines specifically designed for different stages of pregnancy.
- **🏺 Cultural Wisdom**: Integrating traditional health practices and wisdom for a holistic approach.

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev/) (v3.10.3+)
- **Backend**: [Firebase](https://firebase.google.com/) (Authentication, Cloud Firestore, Storage)
- **Maps**: [Google Maps Flutter](https://pub.dev/packages/google_maps_flutter)
- **AI Integration**: Google Gemini (via HTTP API)
- **Utilities**:
  - `geolocator`: GPS & Location services
  - `intl`: Localization and Date/Time formatting
  - `another_telephony`: Background SMS/Call services for SOS
  - `speech_to_text` & `flutter_tts`: Accessibility and voice interaction

## 🚀 Getting Started

### Prerequisites

- Flutter SDK installed on your machine.
- A Firebase project setup with `google-services.json` (Android) and `GoogleService-Info.plist` (iOS).
- A Google Maps API Key.

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/catharva632/maternal_fix.git
   cd maternal_fix
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the app**:
   ```bash
   flutter run
   ```

## 📂 Project Structure

- `lib/views/`: UI screens organized by feature area (Auth, Dashboard, Emergency, etc.).
- `lib/controllers/`: Business logic and state management.
- `lib/models/`: Data structures for health records, users, and schedules.
- `lib/widgets/`: Reusable UI components.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request or open an issue for any bugs or feature requests.

---
*Created with care for mothers everywhere.*
