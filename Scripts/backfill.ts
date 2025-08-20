// Scripts/backfill.ts
import * as fs from 'fs';
import * as admin from 'firebase-admin';
import { GoogleAuth } from 'google-auth-library';

function getCredential(): admin.credential.Credential {
  // Option A: service-account JSON provided via secret (raw or base64)
  const saEnv = process.env.FIREBASE_SERVICE_ACCOUNT || process.env.FIREBASE_SERVICE_ACCOUNT_BASE64;
  if (saEnv) {
    const jsonStr = saEnv.trim().startsWith('{') ? saEnv : Buffer.from(saEnv, 'base64').toString('utf8');
    return admin.credential.cert(JSON.parse(jsonStr) as admin.ServiceAccount);
  }

  // Option B: GitHub WIF external_account file (from auth@v2)
  const extPath = process.env.GOOGLE_GHA_CREDS_PATH || process.env.GOOGLE_APPLICATION_CREDENTIALS;
  if (extPath && fs.existsSync(extPath)) {
    const scopes = ['https://www.googleapis.com/auth/datastore']; // minimal scope for Firestore
    // Point GoogleAuth at the external_account file, then clear env so Admin won't parse it directly.
    const auth = new GoogleAuth({ keyFilename: extPath, scopes });
    delete process.env.GOOGLE_APPLICATION_CREDENTIALS;
    delete process.env.GOOGLE_GHA_CREDS_PATH;

    return {
      getAccessToken: async () => {
        const client = await auth.getClient();
        const tok = await client.getAccessToken();
        const access_token = typeof tok === 'string' ? tok : (tok as any)?.token;
        if (!access_token) throw new Error('Unable to obtain access token from WIF credentials');
        return { access_token, expires_in: 3600 };
      },
    } as unknown as admin.credential.Credential;
  }

  // Option C: local dev (gcloud ADC)
  return admin.credential.applicationDefault();
}

function getProjectId(): string | undefined {
  const direct =
    process.env.GCP_PROJECT ||
    process.env.GOOGLE_CLOUD_PROJECT ||
    process.env.GCLOUD_PROJECT ||
    process.env.FIREBASE_CONFIG?.match(/"projectId":"([^"]+)"/)?.[1];
  if (direct) return direct;

  const p = process.env.GOOGLE_APPLICATION_CREDENTIALS;
  if (p && fs.existsSync(p)) {
    try {
      const obj = JSON.parse(fs.readFileSync(p, 'utf8'));
      return (obj.project_id || obj.quota_project_id) as string | undefined;
    } catch {}
  }
  return undefined;
}

const projectId = getProjectId();
console.log('Project:', projectId ?? '(none)');

admin.initializeApp({ credential: getCredential(), projectId });

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
