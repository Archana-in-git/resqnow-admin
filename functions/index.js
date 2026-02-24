const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { setGlobalOptions } = require("firebase-functions/v2");
const admin = require("firebase-admin");

admin.initializeApp();
setGlobalOptions({ maxInstances: 10, region: "us-central1" });

const db = admin.firestore();

function requireAdmin(request) {
  if (!request.auth?.uid) {
    throw new HttpsError("unauthenticated", "Authentication required.");
  }

  const uid = request.auth.uid;
  return db
    .collection("users")
    .doc(uid)
    .get()
    .then((doc) => {
      if (!doc.exists || doc.data()?.role !== "admin") {
        throw new HttpsError("permission-denied", "Admin access required.");
      }

      return uid;
    });
}

async function deleteByField(collection, field, value) {
  const snapshot = await db
    .collection(collection)
    .where(field, "==", value)
    .get();
  if (snapshot.empty) return 0;

  const batch = db.batch();
  snapshot.docs.forEach((doc) => batch.delete(doc.ref));
  await batch.commit();
  return snapshot.size;
}

async function deleteKnownUserData(uid) {
  const deletedCounts = {
    donorsByDocId: 0,
    donorsByUserId: 0,
    callRequestsByUserId: 0,
    callRequestsByRequesterId: 0,
    callRequestsByDonorId: 0,
    notifications: 0,
    sessions: 0,
  };

  const donorRef = db.collection("donors").doc(uid);
  const donorDoc = await donorRef.get();
  if (donorDoc.exists) {
    await donorRef.delete();
    deletedCounts.donorsByDocId = 1;
  }

  deletedCounts.donorsByUserId = await deleteByField("donors", "userId", uid);
  deletedCounts.callRequestsByUserId = await deleteByField(
    "call_requests",
    "userId",
    uid
  );
  deletedCounts.callRequestsByRequesterId = await deleteByField(
    "call_requests",
    "requesterId",
    uid
  );
  deletedCounts.callRequestsByDonorId = await deleteByField(
    "call_requests",
    "donorId",
    uid
  );
  deletedCounts.notifications = await deleteByField(
    "notifications",
    "userId",
    uid
  );
  deletedCounts.sessions = await deleteByField("user_sessions", "userId", uid);

  return deletedCounts;
}

exports.suspendUserAccount = onCall(async (request) => {
  try {
    await requireAdmin(request);

    const uid = request.data?.uid;
    const reason = (request.data?.reason || "").toString().trim();

    if (!uid || typeof uid !== "string") {
      throw new HttpsError(
        "invalid-argument",
        "A valid target uid is required."
      );
    }

    const userRef = db.collection("users").doc(uid);
    const userDoc = await userRef.get();
    if (!userDoc.exists) {
      throw new HttpsError("not-found", "Target user does not exist.");
    }

    const email = (userDoc.data()?.email || "").toString().toLowerCase();

    await userRef.set(
      {
        accountStatus: "suspended",
        isBlocked: true,
        suspendedAt: admin.firestore.FieldValue.serverTimestamp(),
        suspensionReason:
          reason || "Suspended by admin for suspicious activity",
        accessDeniedMessage:
          "Login denied: your account is currently suspended for suspicious activity. Contact support if this is a mistake.",
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true }
    );

    // Add email to blocked_emails collection
    if (email && email.length > 0) {
      await db
        .collection("blocked_emails")
        .doc(email)
        .set(
          {
            email: email,
            uid: uid,
            blockedAt: admin.firestore.FieldValue.serverTimestamp(),
            reason: reason || "Suspended by admin for suspicious activity",
            blockedBy: request.auth.uid,
            status: "suspended",
          },
          { merge: true }
        );
    }

    try {
      await admin.auth().revokeRefreshTokens(uid);
    } catch (error) {
      if (error?.code !== "auth/user-not-found") {
        throw error;
      }
    }

    return {
      success: true,
      uid,
      email,
      status: "suspended",
    };
  } catch (error) {
    if (error instanceof HttpsError) {
      throw error;
    }

    console.error("suspendUserAccount failed", {
      code: error?.code,
      message: error?.message,
      stack: error?.stack,
    });

    throw new HttpsError("internal", "Suspend failed due to a server error.", {
      code: error?.code || "unknown",
      message: error?.message || "Unknown error",
    });
  }
});

exports.reactivateUserAccount = onCall(async (request) => {
  try {
    await requireAdmin(request);

    const uid = request.data?.uid;
    if (!uid || typeof uid !== "string") {
      throw new HttpsError(
        "invalid-argument",
        "A valid target uid is required."
      );
    }

    const userRef = db.collection("users").doc(uid);
    const userDoc = await userRef.get();
    if (!userDoc.exists) {
      throw new HttpsError("not-found", "Target user does not exist.");
    }

    const email = (userDoc.data()?.email || "").toString().toLowerCase();

    await userRef.set(
      {
        accountStatus: "active",
        isBlocked: false,
        suspendedAt: admin.firestore.FieldValue.delete(),
        suspensionReason: admin.firestore.FieldValue.delete(),
        accessDeniedMessage: admin.firestore.FieldValue.delete(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true }
    );

    // Remove email from blocked_emails collection
    if (email && email.length > 0) {
      await db.collection("blocked_emails").doc(email).delete();
    }

    return {
      success: true,
      uid,
      email,
      status: "active",
    };
  } catch (error) {
    if (error instanceof HttpsError) {
      throw error;
    }

    console.error("reactivateUserAccount failed", {
      code: error?.code,
      message: error?.message,
      stack: error?.stack,
    });

    throw new HttpsError(
      "internal",
      "Reactivation failed due to a server error.",
      {
        code: error?.code || "unknown",
        message: error?.message || "Unknown error",
      }
    );
  }
});

exports.deleteUserAccountCompletely = onCall(async (request) => {
  await requireAdmin(request);

  const uid = request.data?.uid;
  if (!uid || typeof uid !== "string") {
    throw new HttpsError("invalid-argument", "A valid target uid is required.");
  }

  const userRef = db.collection("users").doc(uid);
  const userDoc = await userRef.get();
  if (!userDoc.exists) {
    throw new HttpsError("not-found", "Target user does not exist.");
  }

  const email = (userDoc.data()?.email || "").toString().toLowerCase();
  const deletedCounts = await deleteKnownUserData(uid);

  await userRef.delete();

  // Remove email from blocked_emails collection
  if (email && email.length > 0) {
    await db.collection("blocked_emails").doc(email).delete();
  }

  try {
    await admin.auth().deleteUser(uid);
  } catch (error) {
    if (error?.code !== "auth/user-not-found") {
      throw error;
    }
  }

  return {
    success: true,
    uid,
    email,
    deletedCounts,
  };
});

exports.checkUserAccessStatus = onCall(async (request) => {
  const callerUid = request.auth?.uid;
  if (!callerUid) {
    throw new HttpsError("unauthenticated", "Authentication required.");
  }

  const userDoc = await db.collection("users").doc(callerUid).get();
  if (!userDoc.exists) {
    return {
      allowed: false,
      reasonCode: "account-deleted",
      message:
        "No account exists with this email. Please create a new account.",
    };
  }

  const data = userDoc.data() || {};
  const accountStatus = data.accountStatus || "active";
  const isBlocked = !!data.isBlocked;
  const suspensionReason =
    typeof data.suspensionReason === "string" &&
    data.suspensionReason.trim().length
      ? data.suspensionReason.trim()
      : "suspicious activities";

  if (accountStatus === "suspended" || isBlocked) {
    return {
      allowed: false,
      reasonCode: "suspended",
      message: `Login denied: your account is currently suspended for ${suspensionReason}. Please contact support.`,
    };
  }

  return {
    allowed: true,
    reasonCode: "active",
    message: "ok",
  };
});
