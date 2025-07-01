
# QR Code Scanner App

A powerful and modern QR Code Scanner built with Flutter.  
Scan QR codes using your device camera, view the scanned content, and perform contextual actions such as opening links, sending emails, making calls, and more.


## ✨ Features

- **Real-time QR code scanning** using your device camera
- **Automatic content detection:** URLs, phone numbers, emails, SMS, WiFi, and plain text
- **Smart actions:** Open links, call numbers, send emails/SMS, copy or share content
- **Scan history:** View and search your previous scans
- **Modern UI:** Material 3 design, light & dark themes
- **Permission handling:** Friendly dialogs for camera access
- **Works offline:** No internet required for scanning

## 🚀 Getting Started

### Prerequisites

- [Flutter](https://flutter.dev/docs/get-started/install) (version 3.0 or higher recommended)
- Android or iOS device/emulator

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/qr_code_scanner_app.git
   cd qr_code_scanner_app
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

## 📂 Project Structure

```
lib/
├── constants/          # App constants and colors
├── models/             # Data models
├── screens/            # UI screens
├── services/           # Business logic and integrations
├── utils/              # Utility functions and themes
├── widgets/            # Reusable UI components
└── main.dart           # App entry point
```

## 🛠️ Configuration

### Android

- Ensure the following permissions are in your `android/app/src/main/AndroidManifest.xml`:
  ```xml
  
  
  ```
- Minimum SDK: `minSdkVersion 21` in `android/app/build.gradle`

### iOS

- Add camera permission to your `ios/Runner/Info.plist`:
  ```xml
  NSCameraUsageDescription
  This app uses the camera to scan QR codes.
  ```

## 📦 Dependencies

- [mobile_scanner](https://pub.dev/packages/mobile_scanner)
- [url_launcher](https://pub.dev/packages/url_launcher)
- [permission_handler](https://pub.dev/packages/permission_handler)
- [share_plus](https://pub.dev/packages/share_plus)
- [shared_preferences](https://pub.dev/packages/shared_preferences)


## 📄 License

This project is licensed under the [MIT License](LICENSE).

## 🙏 Acknowledgements

- [Flutter](https://flutter.dev/)
- [Google ML Kit](https://developers.google.com/ml-kit/vision/barcode-scanning)
- Community contributors
