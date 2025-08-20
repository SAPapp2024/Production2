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

ffunction getProjectId(): string | undefined {
   // 1) Obvious envs first
   const direct =
     process.env.GCP_PROJECT ||
     process.env.GOOGLE_CLOUD_PROJECT ||
     process.env.GCLOUD_PROJECT ||
     process.env.FIREBASE_CONFIG?.match(/"projectId":"([^"]+)"/)?.[1];
   if (direct) return direct;

   // 2) If SA JSON provided via env, read project_id
   const saEnv = process.env.FIREBASE_SERVICE_ACCOUNT || process.env.FIREBASE_SERVICE_ACCOUNT_BASE64;
   if (saEnv) {
     try {
       const jsonStr = saEnv.trim().startsWith('{')
         ? saEnv
         : Buffer.from(saEnv, 'base64').toString('utf8');
       const key = JSON.parse(jsonStr);
       if (key.project_id) return key.project_id as string;
     } catch {}
   }

   // 3) If ADC path points to a JSON file, try project_id/quota_project_id
   const gac = process.env.GOOGLE_APPLICATION_CREDENTIALS;
   if (gac && fs.existsSync(gac)) {
     try {
       const raw = fs.readFileSync(gac, 'utf8');
       const obj = JSON.parse(raw);
       return (obj.project_id || obj.quota_project_id) as string | undefined;
     } catch {}
   }

   // Let initializeApp throw if still undefined (will surface the same error)
   return undefined;
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
