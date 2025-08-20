// Scripts/backfill.ts
import * as admin from "firebase-admin";

function extractUid(userRef: any): string | null {
  // Works for DocumentReference and string "/users/<uid>"
  try {
    if (userRef && typeof userRef === "object" && "id" in userRef) {
      return (userRef as admin.firestore.DocumentReference).id || null;
    }
    if (typeof userRef === "string") {
      const m = userRef.match(/\/users\/([^/]+)/);
      return m ? m[1] : null;
    }
  } catch {}
  return null;
}

async function backfillSamples() {
  // init (ADC or SA JSON via FIREBASE_SERVICE_ACCOUNT)
  if (admin.apps.length === 0) {
    const sa = process.env.FIREBASE_SERVICE_ACCOUNT;
    if (sa && sa.trim().startsWith("{")) {
      admin.initializeApp({
        credential: admin.credential.cert(JSON.parse(sa)),
        projectId: process.env.GCP_PROJECT,
      });
    } else {
      admin.initializeApp({
        credential: admin.credential.applicationDefault(),
        projectId: process.env.GCP_PROJECT,
      });
    }
  }
  const db = admin.firestore();

  // NOTE: loads all docs; fine for small/medium sets. For huge sets, do pagination.
  const snap = await db.collection("samples").get();
  console.log("Scanning", snap.size, "samples...");
  let batch = db.batch();
  let count = 0;

  for (const doc of snap.docs) {
    const data = doc.data() || {};
    const updates: Record<string, any> = {};

    // 1) userUid mirror from userReference (string or DocumentReference)
    if (!data["userUid"]) {
      const uid = extractUid(data["userReference"]);
      if (uid) updates["userUid"] = uid;
    }

    // 2) createdDate: ensure a real timestamp (not just midnight date)
    const ts = data["createdDate"];
    const isTimestamp = ts instanceof admin.firestore.Timestamp;
    const looksMidnight =
      isTimestamp &&
      ts.toDate().getHours() === 0 &&
      ts.toDate().getMinutes() === 0 &&
      ts.toDate().getSeconds() === 0;

    if (!isTimestamp || looksMidnight) {
      // Prefer server createTime if available; else updateTime; else now
      const fallback =
        ((doc as any).createTime ??
          (doc as any).updateTime ??
          admin.firestore.Timestamp.now()) as admin.firestore.Timestamp;

      updates["createdDate"] = fallback;

      // Preserve original date-only in a side field if you had logic depending on it
      if (isTimestamp && !data["createdDateDMY"]) {
        updates["createdDateDMY"] = ts;
      }
    }

    if (Object.keys(updates).length) {
      batch.update(doc.ref, updates);
      count++;
      if (count % 400 === 0) {
        await batch.commit();
        console.log("Committed", count);
        batch = db.batch();
      }
    }
  }

  if (count % 400) {
    await batch.commit();
  }
  console.log("Backfilled", count, "documents.");
}

backfillSamples().catch((e) => {
  console.error(e);
  process.exit(1);
});
