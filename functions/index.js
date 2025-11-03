import * as functions from 'firebase-functions';
import admin from 'firebase-admin';
import express from 'express';
import cors from 'cors';

admin.initializeApp();

const app = express();

const allowedOrigins = [
  'http://localhost:5000',
  'http://localhost:8080',
  'http://localhost:5173',
  'http://www.testcer-romeo.it',
  'https://www.testcer-romeo.it',
  'http://testcer-romeo.it',
  'https://testcer-romeo.it'
];

app.use(cors({ origin: (origin, cb) => cb(null, !origin || allowedOrigins.includes(origin)), credentials: true }));
app.use(express.json());

app.get('/health', (req, res) => {
  res.json({ ok: true, ts: Date.now() });
});

app.post('/ingest', async (req, res) => {
  // Placeholder for ESP32 data ingestion
  // Example expected body: { deviceId: 'esp32-1', value: 42 }
  const { deviceId, ...data } = req.body || {};
  if (!deviceId) {
    return res.status(400).json({ error: 'deviceId required' });
  }
  // Optional API key enforcement: set env INGEST_KEY to require header x-api-key
  const requiredKey = process.env.INGEST_KEY || null;
  if (requiredKey) {
    const key = req.headers['x-api-key'];
    if (!key || key !== requiredKey) {
      return res.status(401).json({ error: 'unauthorized' });
    }
  }
  try {
    // Example: write to Firestore under /devices/{deviceId}/ingest/{ts}
    const db = admin.firestore();
    const ts = Date.now();
    await db.collection('devices').doc(deviceId).collection('ingest').doc(String(ts)).set({ ts, ...data });
    return res.json({ stored: true, ts });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ error: 'internal_error' });
  }
});

export const api = functions.region('europe-west1').https.onRequest(app);
