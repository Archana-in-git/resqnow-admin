const admin = require("firebase-admin");
admin.initializeApp();
const db = admin.firestore();

async function checkSuspended() {
  try {
    console.log("Fetching users with suspended status...");
    const snapshot = await db
      .collection("users")
      .where("accountStatus", "==", "suspended")
      .get();

    console.log("Suspended users found: " + snapshot.size);
    snapshot.forEach((doc) => {
      const data = doc.data();
      console.log("  - UID: " + doc.id);
      console.log("    Email: " + data.email);
      console.log("    Status: " + data.accountStatus);
    });

    // Also check blocked_emails collection
    console.log("\n\nFetching blocked_emails collection...");
    const blockedSnapshot = await db.collection("blocked_emails").get();
    console.log("Blocked emails found: " + blockedSnapshot.size);
    blockedSnapshot.forEach((doc) => {
      console.log("  - Email: " + doc.id);
      console.log("    Data:", JSON.stringify(doc.data(), null, 2));
    });

    await admin.app().delete();
    process.exit(0);
  } catch (err) {
    console.error("Error:", err.message);
    await admin.app().delete();
    process.exit(1);
  }
}

checkSuspended();
