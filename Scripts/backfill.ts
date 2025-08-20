// Scripts/backfill.ts
import * as fs from 'fs';
import * as admin from 'firebase-admin';

const saEnv = process.env.FIREBASE_SERVICE_ACCOUNT || process.env.FIREBASE_SERVICE_ACCOUNT_BASE64;
const gac = process.env.GOOGLE_APPLICATION_CREDENTIALS;

function getCredential(): admin.credential.Credential {
  // If a service-account JSON is provided via env (raw or base64), use it
  if (saEnv) {
    const jsonStr = saEnv.trim().startsWith('{')
      ? saEnv
      : Buffer.from(saEnv, 'base64').toString('utf8');
    const keyObj = JSON.parse(jsonStr);
    return admin.credential.cert(keyObj as admin.ServiceAccount);
  }

  // If GAC points to a file (e.g. set by google-github-actions/auth), use ADC
  if (gac && fs.existsSync(gac)) {
    return admin.credential.applicationDefault();
  }

  // Fallback to ADC (WIF or gcloud on runners/dev machines)
  return admin.credential.applicationDefault();
}

function getProjectId(): string | undefined {
  return (
    process.env.GCP_PROJECT ||
    process.env.GOOGLE_CLOUD_PROJECT ||
    process.env.FIREBASE_CONFIG?.match(/"projectId":"([^"]+)"/)?.[1]
  );
}

admin.initializeApp({
  credential: getCredential(),
  projectId: getProjectId(),
});

(async () => {
  try {
    const cols = await admin.firestore().listCollections();
    console.log('OK collections:', cols.length);
    process.exit(0);
  } catch (e: any) {
    console.error('ERROR:', e?.message || e);
    process.exit(1);
  }
})();
