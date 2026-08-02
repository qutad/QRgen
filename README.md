# QR Generator

A Material 3 Flutter app for generating and exporting QR codes on desktop, mobile, and web.

## Features

- Generate QR codes from URLs, email addresses, phone numbers, or plain text.
- Choose QR size: Small, Medium, or Large.
- Select error correction level: Low, Medium, High, or Max.
- Pick from multiple foreground colors.
- Preview the generated QR code before exporting.
- Export QR codes as PNG files.
- Persist the latest input and QR options locally with `shared_preferences`.
- Uses adaptive desktop window sizing on macOS, Windows, and Linux.

## Tech Stack

- Flutter
- Dart
- Material 3
- Riverpod
- `qr_flutter`
- `shared_preferences`
- `path_provider`
- `window_manager`

## Getting Started

### Prerequisites

Install Flutter and make sure your environment is ready:

```bash
flutter doctor
Install Dependencies
flutter pub get
Run the App
flutter run
```
To run on a specific platform:
```
flutter run -d macos
flutter run -d windows
flutter run -d linux
flutter run -d chrome
```
Usage
1. Enter a URL, email address, phone number, or plain text.
2. Select the QR size.
3. Choose the error correction level.
4. Pick a QR foreground color.
5. Click Generate.
6. Click Export PNG to save the QR code.
Export Behavior
- On desktop and mobile, exported PNG files are saved to the application documents directory.
- On web, exporting triggers a browser download.
- Exported files use timestamped names like:
qr-code-2026-06-26T12-30-00-000.png
Development
Analyze Code
flutter analyze

Run Tests:
```
flutter test
Format Code
dart format .
Build
```
Web
```flutter build web```
macOS
```flutter build macos```
Windows
```flutter build windows```
Linux
```flutter build linux```
Project Structure:
```
lib/
  app.dart
  main.dart
  core/
    theme/
    utils/
    widgets/
  features/
    qr_generator/
      qr_controller.dart
      qr_exporter.dart
      qr_screen.dart
      qr_service.dart
```

      
License:
MIT License.
