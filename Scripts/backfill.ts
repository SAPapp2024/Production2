// Scripts/backfill.ts
import * as fs from 'fs';
import * as admin from 'firebase-admin';

function getCredential(): admin.credential.Credential {
  const saEnv = process.env.FIREBASE_SERVICE_ACCOUNT || process.env.FIREBASE_SERVICE_ACCOUNT_BASE64;
  if (saEnv) {
    const jsonStr = saEnv.trim().startsWith('{') ? saEnv : Buffer.from(saEnv, 'base64').toString('utf8');
    return admin.credential.cert(JSON.parse(jsonStr) as admin.ServiceAccount);
  }
  const gac = process.env.GOOGLE_APPLICATION_CREDENTIALS;
  if (gac && fs.existsSync(gac)) return admin.credential.applicationDefault();
  return admin.credential.applicationDefault();
}

function getProjectId(): string | undefined {
  return (
    process.env.GCP_PROJECT ||
    process.env.GOOGLE_CLOUD_PROJECT ||
    process.env.FIREBASE_CONFIG?.match(/"projectId":"([^"]+)"/)?.[1]
  );
}

admin.initializeApp({ credential: getCredential(), projectId: getProjectId() });

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
