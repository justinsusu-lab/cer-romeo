# flutter_application_romeo

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Deploy to Firebase Hosting and connect domain `testcer-romeo.it`

Prerequisites: Flutter SDK, Node.js 20+, and Firebase CLI installed and authenticated.

Steps:

1. Install functions dependencies:
	- `cd functions && npm i`
2. Build Flutter web:
	- `flutter build web`
3. Deploy hosting and functions:
	- `cd .. && npx firebase deploy --only hosting,functions`
4. Add custom domain in Firebase Console -> Hosting -> Connect custom domain -> `testcer-romeo.it` and `www.testcer-romeo.it`, then add the provided DNS A/AAAA records.

### ESP32 endpoints

- Health check: `GET https://testcer-romeo.it/api/health`
- Ingest data: `POST https://testcer-romeo.it/api/ingest`
  - Headers: `Content-Type: application/json` and optionally `x-api-key: <INGEST_KEY>` if configured
  - Body example: `{ "deviceId": "esp32-1", "value": 42 }`
