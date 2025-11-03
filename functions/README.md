# Romeo Functions

HTTP function `api` deployed in region `europe-west1` exposes:

- GET /api/health -> returns { ok: true, ts }
- POST /api/ingest -> accepts JSON from ESP32: { deviceId, ...payload }

CORS allows your domain testcer-romeo.it and localhost for local testing.

## Deploy

1. Install Firebase CLI and login
2. From the project root, install deps in functions:
   - `cd functions && npm i`
3. Build Flutter web
   - `flutter build web`
4. Deploy hosting + functions
   - `cd .. && npx firebase deploy --only hosting,functions`

## ESP32 example

POST https://<your-domain>/api/ingest with JSON body, `Content-Type: application/json`.
