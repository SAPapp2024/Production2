import * as admin from "firebase-admin";

async function backfillSamples() {
  // init
  if (admin.apps.length === 0) {
    admin.initializeApp({ credential: admin.credential.applicationDefault() });
  }
  const db = admin.firestore();

  const snap = await db.collection('samples').get();
  console.log('Scanning', snap.size, 'samples...');
  let batch = db.batch();
  let count = 0;

  for (const doc of snap.docs) {
    const data = doc.data() || {};
    const updates: Record<string, any> = {};

    // 1) userUid mirror from userReference
    const userRef = data['userReference'];
    if (userRef && !data['userUid']) {
      try {
        updates['userUid'] = (userRef as admin.firestore.DocumentReference).id;
      } catch { /* ignore */ }
    }

    // 2) createdDateTs: ensure a real timestamp for ordering
    // If createdDate is missing or clearly a date-only, write a high-fidelity timestamp.
    // We'll prefer the doc.createTime (server-side creation) if available.
    const hasCreatedDate = data['createdDate'] instanceof admin.firestore.Timestamp;
    const looksLikeMidnight =
      hasCreatedDate &&
      (data['createdDate'] as admin.firestore.Timestamp).toDate().getHours() === 0 &&
      (data['createdDate'] as admin.firestore.Timestamp).toDate().getMinutes() === 0 &&
      (data['createdDate'] as admin.firestore.Timestamp).toDate().getSeconds() === 0;

    if (!hasCreatedDate || looksLikeMidnight) {
      // Use the document's server createTime if available; fallback to updateTime; else now.
      const fallback =
        (doc.createTime ?? doc.updateTime ??
         admin.firestore.Timestamp.now()) as admin.firestore.Timestamp;
      updates['createdDate'] = fallback; // set a real timestamp for ordering
      // Keep original day field if you rely on it:
      if (!data['createdDateDMY'] && hasCreatedDate) {
        updates['createdDateDMY'] = data['createdDate'];
      }
    }

    if (Object.keys(updates).length) {
      batch.update(doc.ref, updates);
      count++;
      if (count % 400 === 0) {
        await batch.commit();
        console.log('Committed', count);
        batch = db.batch();
      }
    }
  }

  if (count % 400) {
    await batch.commit();
  }
  console.log('Backfilled', count, 'documents.');
}

backfillSamples().catch(e => {
  console.error(e);
  process.exit(1);
});
