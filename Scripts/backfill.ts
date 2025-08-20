// Scripts/backfill.ts
import * as fs from 'fs';
import * as admin from 'firebase-admin';
import { GoogleAuth } from 'google-auth-library';

function getCredential(): admin.credential.Credential {
  // 1) Service-account JSON via env (raw or base64)
  const saEnv = process.env.FIREBASE_SERVICE_ACCOUNT || process.env.FIREBASE_SERVICE_ACCOUNT_BASE64;
  if (saEnv) {
    const jsonStr = saEnv.trim().startsWith('{') ? saEnv : Buffer.from(saEnv, 'base64').toString('utf8');
    return admin.credential.cert(JSON.parse(jsonStr) as admin.ServiceAccount);
  }

  // 2) GitHub WIF path present → use google-auth-library to mint tokens
  //    (Works with the external_account file created by google-github-actions/auth@v2)
  if (process.env.GOOGLE_GHA_CREDS_PATH || process.env.GOOGLE_APPLICATION_CREDENTIALS) {
    const scopes = ['https://www.googleapis.com/auth/datastore']; // minimal scope for Firestore
    const auth = new GoogleAuth({ scopes });

    // Firebase Admin accepts any object implementing getAccessToken()
    return {
      getAccessToken: async () => {
        const client = await auth.getClient();
        const tok = await client.getAccessToken();
        const access_token = typeof tok === 'string' ? tok : (tok as any)?.token;
        if (!access_token) throw new Error('Unable to obtain access token from WIF credentials');
        // expires_in is advisory; Admin will refresh when needed
        return { access_token, expires_in: 3600 };
      },
    } as unknown as admin.credential.Credential;
  }

  // 3) Fallback to ADC (gcloud/dev box)
  return admin.credential.applicationDefault();
}

function getProjectId(): string | undefined {
  return (
    process.env.GCP_PROJECT ||
    process.env.GOOGLE_CLOUD_PROJECT ||
    process.env.GCLOUD_PROJECT ||
    process.env.FIREBASE_CONFIG?.match(/"projectId":"([^"]+)"/)?.[1] ||
    // Try reading project_id from the WIF/ADC file if present
    (() => {
      const p = process.env.GOOGLE_APPLICATION_CREDENTIALS;
      if (p && fs.existsSync(p)) {
        try {
          const obj = JSON.parse(fs.readFileSync(p, 'utf8'));
          return (obj.project_id || obj.quota_project_id) as string | undefined;
        } catch {}
      }
      return undefined;
    })()
  );
}

const projectId = getProjectId();
admin.initializeApp({ credential: getCredential(), projectId });

(async () => {
  try {
    const cols = await admin.firestore().listCollections();
    console.log('OK collections:', cols.length, 'project:', projectId ?? '(none)');
    process.exit(0);
  } catch (e: any) {
    console.error('ERROR:', e?.message || e);
    process.exit(1);
  }
})();
