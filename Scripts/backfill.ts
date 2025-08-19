import * as admin from "firebase-admin";
import { FieldPath, Timestamp } from "firebase-admin/firestore";

// Single init: use ADC (picked up from GOOGLE_APPLICATION_CREDENTIALS)
if (admin.apps.length === 0) {
  admin.initializeApp({
    credential: gac && fs.existsSync(gac)
      ? admin.credential.cert(JSON.parse(fs.readFileSync(gac, "utf8")))
      : admin.credential.applicationDefault(),
    // storageBucket: "agro-k-c5da2.appspot.com", // uncomment if you use Storage ops
  });
}

const db = admin.firestore();

// Config via env vars
const COLLECTION = process.env.COLLECTION || "samples";
const DRY_RUN = (process.env.DRY_RUN || "false").toLowerCase() === "true";
const LIMIT = Number(process.env.LIMIT || "0"); // 0 = no cap
const PAGE_SIZE = Number(process.env.PAGE_SIZE || "400"); // <= 500 recommended
const BATCH_SIZE = 400;

function looksLikeMidnight(ts: Timestamp | undefined) {
  if (!ts) return true;
  const d = ts.toDate();
  return d.getHours() === 0 && d.getMinutes() === 0 && d.getSeconds() === 0;
}

async function processPage(
  startAfterId?: string,
  remaining?: number
): Promise<{ lastId?: string; processed: number; updated: number }> {
  let q = db
    .collection(COLLECTION)
    .orderBy(FieldPath.documentId())
    .limit(remaining && remaining > 0 ? Math.min(PAGE_SIZE, remaining) : PAGE_SIZE);

  if (startAfterId) q = q.startAfter(startAfterId);

  const snap = await q.get();
  if (snap.empty) return { processed: 0, updated: 0 };

  let batch = db.batch();
  let enqueued = 0;
  let processed = 0;
  let updated = 0;
  let lastId: string | undefined;

  for (const doc of snap.docs) {
    processed++;
    lastId = doc.id;
    const data = doc.data() || {};
    const updates: Record<string, any> = {};

    // 1) userUid ← userReference.id (if missing)
    const userRef = data["userReference"];
    if (!data["userUid"] && userRef && typeof userRef.id === "string") {
      updates["userUid"] = userRef.id;
    }

    // 2) createdDate ← real timestamp (if missing OR date-only midnight)
    const created = data["createdDate"] as Timestamp | undefined;
    const hasTimestamp = created instanceof Timestamp;

    if (!hasTimestamp || looksLikeMidnight(created)) {
      const fallback =
        (doc.createTime as Timestamp) ||
        (doc.updateTime as Timestamp) ||
        Timestamp.now();

      updates["createdDate"] = fallback;
      if (hasTimestamp && !data["createdDateDMY"]) {
        // Optional: keep legacy date-only value
        updates["createdDateDMY"] = created;
      }
    }

    if (Object.keys(updates).length > 0) {
      updated++;
      if (DRY_RUN) {
        console.log(`[DRY_RUN] ${doc.id}`, updates);
      } else {
        batch.update(doc.ref, updates);
        enqueued++;
        if (enqueued % BATCH_SIZE === 0) {
          await batch.commit();
          console.log(`Committed ${enqueued} updates in this page...`);
          batch = db.batch();
        }
      }
    }

    if (LIMIT && processed >= (remaining || LIMIT)) break;
  }

  if (!DRY_RUN && enqueued % BATCH_SIZE !== 0) {
    await batch.commit();
  }

  return { lastId, processed, updated };
}

async function main() {
  console.log(
    `Starting backfill on '${COLLECTION}' | DRY_RUN=${DRY_RUN} | LIMIT=${LIMIT || "none"}`
  );

  let totalProcessed = 0;
  let totalUpdated = 0;
  let lastId: string | undefined = undefined;
  let remaining = LIMIT || undefined;

  while (true) {
    const { lastId: newLast, processed, updated } = await processPage(lastId, remaining);
    if (processed === 0) break;

    totalProcessed += processed;
    totalUpdated += updated;
    lastId = newLast;

    if (remaining) {
      remaining -= processed;
      if (remaining <= 0) break;
    }

    console.log(
      `Page done. processed=${processed}, updated=${updated}, totalProcessed=${totalProcessed}, totalUpdated=${totalUpdated}`
    );
  }

  console.log(`✅ Finished. totalProcessed=${totalProcessed}, totalUpdated=${totalUpdated}`);
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
