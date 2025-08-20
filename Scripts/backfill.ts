// Scripts/backfill.ts
import * as fs from 'fs';
import * as admin from 'firebase-admin';

function getCredential(): admin.credential.Credential {
  // 1) If you store the whole service account JSON in a secret (plain JSON or base64)
  const saEnv =
    process.env.FIREBASE_SERVICE_ACCOUNT ||
    process.env.FIREBASE_SERVICE_ACCOUNT_BASE64;

  if (saEnv) {
    const jsonStr = saEnv.trim().startsWith('{')
      ? saEnv
      : Buffer.from(saEnv, 'base64').toString('utf8');
    const keyObj = JSON.parse(jsonStr);
    return admin.credential.cert(keyObj as admin.ServiceAccount);
  }

  // 2) If GOOGLE_APPLICATION_CREDENTIALS points to a key file or WIF token file
  const gac = process.env.GOOGLE_APPLICATION_CREDENTIALS;
  if (gac && fs.existsSync(gac)) {
    return admin.credential.applicationDefault();
  }

  // 3) Fall back to ADC (e.g., Workload Identity Federation) if set by the environment
  return admin.credential.applicationDefault();
}

function getProjectId(): string | undefined {
  return (
    process.env.GCP_PROJECT ||
    process.env.GOOGLE_CLOUD_PROJECT ||
    // If FIREBASE_CONFIG is present (from Firebase Hosting/Functions), try to extract projectId
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
