// ===== Reactivation Fix Deployed: Feb 25, 2026 =====
// Fixed: reactivateUserAccount now verifies blocked_emails deletion and throws errors if it fails
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

    // Update user document
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
      try {
        const blockedEmailRef = db.collection("blocked_emails").doc(email);

        const blockedEmailData = {
          email: email,
          uid: uid,
          blockedAt: admin.firestore.FieldValue.serverTimestamp(),
          reason: reason || "Suspended by admin for suspicious activity",
          blockedBy: request.auth.uid,
          status: "suspended",
        };

        await blockedEmailRef.set(blockedEmailData, { merge: true });

        console.log(`✓ Successfully blocked email: ${email}`, {
          uid,
          timestamp: new Date().toISOString(),
        });
      } catch (frozenError) {
        console.error(`✗ CRITICAL ERROR: Failed to block email ${email}:`, {
          code: frozenError?.code,
          message: frozenError?.message,
          errorDetails: frozenError?.toString(),
        });
        // Log but do NOT throw - user suspension in main collection is still valid
        // This prevents the entire suspend operation from failing
      }
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

    // Update user document
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
      // Verify the email exists in blocked_emails first
      const blockedEmailDoc = await db
        .collection("blocked_emails")
        .doc(email)
        .get();

      if (blockedEmailDoc.exists) {
        try {
          await db.collection("blocked_emails").doc(email).delete();

          // Verify deletion succeeded
          const afterDelete = await db
            .collection("blocked_emails")
            .doc(email)
            .get();

          if (afterDelete.exists) {
            throw new Error(
              `Deletion verification failed: ${email} still exists in blocked_emails`
            );
          }

          console.log(`✓ Successfully unblocked email: ${email}`, {
            uid,
            timestamp: new Date().toISOString(),
          });
        } catch (deleteError) {
          console.error(
            `✗ CRITICAL ERROR: Failed to unblock ${email} during reactivation:`,
            {
              message: deleteError?.message,
              code: deleteError?.code,
              uid,
            }
          );
          // Throw error so admin knows something went wrong
          throw new HttpsError(
            "internal",
            `Failed to remove email from blocked list. Email: ${email}. Error: ${deleteError?.message}`
          );
        }
      } else {
        console.log(
          `ℹ Email not in blocked_emails (already unblocked): ${email}`
        );
      }
    }

    return {
      success: true,
      uid,
      email,
      status: "active",
      message: `Account reactivated successfully. User can now login and signup.`,
      timestamp: new Date().toISOString(), // Added timestamp to force deploy
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
    const deletedCounts = await deleteKnownUserData(uid);

    // Delete user document
    await userRef.delete();

    // Keep email in blocked_emails collection with status "deleted" to prevent re-signup
    if (email && email.length > 0) {
      try {
        const blockedEmailData = {
          email: email,
          uid: uid,
          blockedAt: admin.firestore.FieldValue.serverTimestamp(),
          reason: "Account deleted by admin",
          blockedBy: request.auth.uid,
          status: "deleted",
          deletedAt: admin.firestore.FieldValue.serverTimestamp(),
        };

        await db
          .collection("blocked_emails")
          .doc(email)
          .set(blockedEmailData, { merge: true });

        console.log(`✓ Successfully marked email as deleted: ${email}`, {
          uid,
          timestamp: new Date().toISOString(),
        });
      } catch (blockError) {
        console.error(`✗ ERROR: Failed to block deleted email ${email}:`, {
          code: blockError?.code,
          message: blockError?.message,
          errorDetails: blockError?.toString(),
        });
        // Continue anyway - account is deleted even if blocked_emails write fails
      }
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
  } catch (error) {
    if (error instanceof HttpsError) {
      throw error;
    }

    console.error("deleteUserAccountCompletely failed", {
      code: error?.code,
      message: error?.message,
      stack: error?.stack,
    });

    throw new HttpsError("internal", "Delete failed due to a server error.", {
      code: error?.code || "unknown",
      message: error?.message || "Unknown error",
    });
  }
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

// ============ NOTIFICATION DELIVERY FUNCTION ============
const { onDocumentCreated } = require("firebase-functions/v2/firestore");

exports.sendNotificationToUsers = onDocumentCreated(
  "notifications/{notificationId}",
  async (event) => {
    const notificationData = event.data.data();
    const { title, message, recipientType, targetDistrict } = notificationData;

    if (!title || !message || !recipientType) {
      console.error("Invalid notification data", notificationData);
      return;
    }

    try {
      let userQuery = db.collection("users");

      // Filter based on recipientType
      if (recipientType === "donors_only") {
        userQuery = userQuery.where("isDonor", "==", true);
      } else if (recipientType === "specific_district" && targetDistrict) {
        userQuery = userQuery.where("district", "==", targetDistrict);
      }
      // If 'all_users', no additional filter

      const usersSnapshot = await userQuery.get();

      if (usersSnapshot.empty) {
        console.log(
          "No users found for notification criteria:",
          recipientType,
          targetDistrict
        );
        return;
      }

      let successCount = 0;
      let failureCount = 0;
      const failedTokens = [];

      // Send to all matching users
      for (const userDoc of usersSnapshot.docs) {
        const userData = userDoc.data();
        const fcmToken = userData?.fcmToken || userData?.deviceToken;

        if (!fcmToken) {
          console.log(
            `No FCM token for user ${userDoc.id}, skipping notification`
          );
          failureCount++;
          continue;
        }

        try {
          const response = await admin.messaging().send({
            token: fcmToken,
            notification: {
              title: title,
              body: message,
            },
            data: {
              notificationId: event.id,
              type: notificationData.type || "general",
              timestamp: new Date().toISOString(),
            },
            android: {
              priority: "high",
              notification: {
                sound: "default",
                channelId: "default",
              },
            },
            apns: {
              headers: {
                "apns-priority": "10",
              },
              payload: {
                aps: {
                  sound: "default",
                  "content-available": 1,
                  badge: 1,
                },
              },
            },
          });

          console.log(`Notification sent to ${userDoc.id}:`, response);
          successCount++;
        } catch (error) {
          console.error(
            `Failed to send notification to ${userDoc.id}:`,
            error.message
          );
          if (
            error.code === "messaging/invalid-registration-token" ||
            error.code === "messaging/registration-token-not-registered"
          ) {
            failedTokens.push(userDoc.id);
          }
          failureCount++;
        }
      }

      // Update notification document with delivery status
      await db.collection("notifications").doc(event.id).update({
        deliveredCount: successCount,
        failedCount: failureCount,
        sentAt: admin.firestore.FieldValue.serverTimestamp(),
        invalidTokenUsers: failedTokens,
      });

      console.log(
        `Notification ${event.id} delivered to ${successCount} users, failed for ${failureCount}`
      );
    } catch (error) {
      console.error(
        "Error in sendNotificationToUsers:",
        error.message,
        error.stack
      );
    }
  }
);

exports.syncBlockedEmails = onCall(async (request) => {
  try {
    await requireAdmin(request);

    console.log("Starting syncBlockedEmails...");

    // Get all suspended users
    const suspendedSnapshot = await db
      .collection("users")
      .where("accountStatus", "==", "suspended")
      .get();

    console.log(`Found ${suspendedSnapshot.size} suspended users`);

    const batch = db.batch();
    let addedCount = 0;
    let errors = [];

    // Add each suspended user's email to blocked_emails
    for (const userDoc of suspendedSnapshot.docs) {
      try {
        const userData = userDoc.data();
        const email = (userData.email || "").toString().toLowerCase();
        const uid = userDoc.id;

        if (!email || email.length === 0) {
          console.warn(`Skipping user ${uid} - no email found`);
          continue;
        }

        const blockedEmailRef = db.collection("blocked_emails").doc(email);
        const blockedEmailData = {
          email: email,
          uid: uid,
          blockedAt: admin.firestore.FieldValue.serverTimestamp(),
          reason: userData.suspensionReason || "Suspended by admin",
          status: "suspended",
          syncedAt: admin.firestore.FieldValue.serverTimestamp(),
        };

        batch.set(blockedEmailRef, blockedEmailData, { merge: true });
        addedCount++;
        console.log(`✓ Prepared email for sync: ${email} (UID: ${uid})`);
      } catch (err) {
        errors.push({
          uid: userDoc.id,
          error: err.message,
        });
        console.error(`Error processing user ${userDoc.id}:`, err.message);
      }
    }

    // Commit the batch
    if (addedCount > 0) {
      await batch.commit();
      console.log(
        `✓ Successfully synced ${addedCount} suspended users to blocked_emails`
      );
    }

    return {
      success: true,
      addedCount,
      errors: errors.length > 0 ? errors : [],
      message: `Synced ${addedCount} suspended users to blocked_emails collection`,
    };
  } catch (error) {
    if (error instanceof HttpsError) {
      throw error;
    }

    console.error("syncBlockedEmails failed", {
      code: error?.code,
      message: error?.message,
      stack: error?.stack,
    });

    throw new HttpsError("internal", "Sync failed due to a server error.", {
      code: error?.code || "unknown",
      message: error?.message || "Unknown error",
    });
  }
});

// ===== Image Proxy Function =====
// Serves images from Firebase Storage to bypass CORS issues in web apps
const { onRequest } = require("firebase-functions/v2/https");

exports.getImage = onRequest(async (req, res) => {
  try {
    // Enable CORS
    res.set("Access-Control-Allow-Origin", "*");
    res.set("Access-Control-Allow-Methods", "GET, HEAD, OPTIONS");
    res.set("Access-Control-Allow-Headers", "Content-Type");

    if (req.method === "OPTIONS") {
      res.status(204).send("");
      return;
    }

    if (req.method !== "GET") {
      res.status(405).send("Method Not Allowed");
      return;
    }

    // Get the image path from query parameter
    const imagePath = req.query.path;
    if (!imagePath) {
      res.status(400).send("Missing path parameter");
      return;
    }

    // Verify path is safe (prevent directory traversal)
    if (imagePath.includes("..") || imagePath.startsWith("/")) {
      res.status(400).send("Invalid path");
      return;
    }

    // Get the bucket name from environment or default
    const bucket = admin.storage().bucket();
    const file = bucket.file(imagePath);

    // Check if file exists
    const [exists] = await file.exists();
    if (!exists) {
      res.status(404).send("Image not found");
      return;
    }

    // Get file metadata for content type
    const [metadata] = await file.getMetadata();
    const contentType = metadata.contentType || "image/jpeg";

    // Set response headers
    res.set("Content-Type", contentType);
    res.set("Cache-Control", "public, max-age=3600");
    res.set("Access-Control-Allow-Origin", "*");

    // Stream the file to response
    file.createReadStream().pipe(res);
  } catch (error) {
    console.error("Error serving image:", error);
    res.status(500).send("Error retrieving image");
  }
});
