# QR Generator

A Flutter desktop/mobile QR code generator built with Material 3, Riverpod, `qr_flutter`, and `shared_preferences`.

## Features

- Generate QR codes from URLs, email addresses, phone numbers, or plain text.
- Choose QR size, error correction level, and foreground color.
- Persist the last selected options locally.
- Export the generated QR code as a PNG file.
- GitHub Actions workflow for formatting, analysis, and tests.

## Getting Started

```bash
flutter pub get
flutter run
```

## Export

Use the `Export PNG` button after generating a QR code. On desktop/mobile, the file is saved to the app documents directory.

## License

MIT
