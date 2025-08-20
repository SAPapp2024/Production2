const admin = require('firebase-admin');

admin.initializeApp({
  credential: admin.credential.applicationDefault(),
  projectId: '<YOUR_PROJECT_ID>', // helps avoid project mismatch
});

(async () => {
  try {
    const cols = await admin.firestore().listCollections();
    console.log('OK collections:', cols.length);
    process.exit(0);
  } catch (e) {
    console.error('ERROR:', e.message);
    process.exit(1);
  }
})();
