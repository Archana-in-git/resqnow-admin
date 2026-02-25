# ResQNow: Code Implementation Reference

## Table of Contents

1. [Signup Implementation](#signup-implementation)
2. [Login Implementation](#login-implementation)
3. [Admin Suspension](#admin-suspension)
4. [Cloud Functions](#cloud-functions)
5. [Error Handling](#error-handling)

---

## Signup Implementation

### Complete Signup Method from `auth_service.dart`

```dart
/// Signs up a new user with email and password
///
/// Steps:
/// 1. Check if email is in blocked_emails collection
/// 2. Create Firebase Auth user
/// 3. Create Firestore user document with initial fields
///
/// Returns: User object if successful
/// Throws: FirebaseAuthException if any step fails
Future<User?> signUpWithEmail({
  required String name,
  required String email,
  required String password,
}) async {
  try {
    // ═════════════════════════════════════════════════════
    // STEP 1: CHECK IF EMAIL IS BLOCKED (SUSPENDED/DELETED)
    // ═════════════════════════════════════════════════════
    try {
      final blockedEmailDoc = await _firestore
          .collection('blocked_emails')
          .doc(email.toLowerCase())
          .get();

      if (blockedEmailDoc.exists) {
        final data = blockedEmailDoc.data() ?? {};
        final status = data['status'] as String?;
        final reason = data['reason'] as String?;

        // Email was permanently deleted - cannot re-signup
        if (status == 'deleted') {
          throw FirebaseAuthException(
            code: 'email-deleted',
            message: 'This email address was previously deleted and cannot be '
                'used to create a new account. Please contact support.',
          );
        }

        // Email is currently suspended - cannot signup
        else if (status == 'suspended') {
          throw FirebaseAuthException(
            code: 'email-suspended',
            message: 'This email address is associated with a suspended account. '
                'Reason: ${reason ?? "Account suspended"}. '
                'Please contact support if you believe this is a mistake.',
          );
        }
      }
    } catch (e) {
      // If check fails (network, permission), let it fail with proper error
      if (e is FirebaseAuthException) rethrow;
      print('Warning: Could not check blocked_emails: $e');
      // Continue anyway - might be network issue
    }

    // ═════════════════════════════════════════════════════
    // STEP 2: CREATE FIREBASE AUTH USER
    // ═════════════════════════════════════════════════════
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;
    if (user != null) {
      try {
        // Update display name
        await user.updateDisplayName(name);

        // ═════════════════════════════════════════════════════
        // STEP 3: CREATE FIRESTORE USER DOCUMENT
        // ═════════════════════════════════════════════════════
        await _firestore.collection(usersCollection).doc(user.uid).set({
          // Basic info
          'uid': user.uid,
          'name': name,
          'email': email.toLowerCase(),
          'role': 'user', // Default role for new users

          // Account status fields
          'accountStatus': 'active', // active, suspended, or deleted
          'isBlocked': false, // Whether user is blocked/suspended
          'emailVerified': user.emailVerified,

          // Profile info
          'profileImage': null,

          // Timestamps
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': null,

          // Suspension fields (initially null)
          'suspendedAt': null,
          'suspensionReason': null,
        }, SetOptions(merge: true));

        print('DEBUG: User document created successfully: ${user.uid}');
      } catch (e) {
        // If Firestore fails, delete the Auth user to maintain consistency
        print('ERROR: Failed to create user document: $e');
        try {
          await user.delete();
        } catch (_) {}

        throw FirebaseAuthException(
          code: 'firestore-error',
          message: 'Failed to create user profile. Please try again.',
        );
      }
    }

    return user;
  } on FirebaseAuthException {
    rethrow; // Re-throw auth errors with specific codes
  } catch (e) {
    throw FirebaseAuthException(
      code: 'unknown-error',
      message: 'An unexpected error occurred: $e',
    );
  }
}
```

### What Gets Saved to Firestore

```json
Location: /users/{uid}
Example UID: pAgaRSMSJ4TzbyklhJKwxVc43jG2

{
  "uid": "pAgaRSMSJ4TzbyklhJKwxVc43jG2",
  "name": "John Doe",
  "email": "john@mail.com",
  "role": "user",
  "accountStatus": "active",
  "isBlocked": false,
  "emailVerified": false,
  "profileImage": null,
  "createdAt": Timestamp.fromDate(Date.now()),
  "lastLogin": null,
  "suspendedAt": null,
  "suspensionReason": null
}
```

---

## Login Implementation

### Complete Login Method from `auth_service.dart`

```dart
/// Logs in a user with email and password
///
/// Steps:
/// 1. Authenticate email/password with Firebase Auth
/// 2. Ensure user document exists in Firestore
/// 3. Validate user can access (via checkUserAccessStatus Cloud Function)
/// 4. Log session to user_sessions collection
///
/// Returns: User object if successful
/// Throws: FirebaseAuthException if any step fails
Future<User?> loginWithEmail({
  required String email,
  required String password,
}) async {
  try {
    // ═════════════════════════════════════════════════════
    // STEP 1: AUTHENTICATE WITH FIREBASE AUTH
    // ═════════════════════════════════════════════════════
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;
    if (user != null) {
      // ═════════════════════════════════════════════════════
      // STEP 2: ENSURE USER DOCUMENT EXISTS
      // ═════════════════════════════════════════════════════
      try {
        final userDoc = await _firestore
            .collection(usersCollection)
            .doc(user.uid)
            .get();

        if (!userDoc.exists) {
          // Auto-create user doc if missing (safety measure)
          await _firestore.collection(usersCollection).doc(user.uid).set({
            'uid': user.uid,
            'name': user.displayName ?? 'User',
            'email': user.email?.toLowerCase() ?? email.toLowerCase(),
            'role': 'user',
            'accountStatus': 'active',
            'isBlocked': false,
            'emailVerified': user.emailVerified,
            'profileImage': null,
            'createdAt': FieldValue.serverTimestamp(),
            'lastLogin': null,
            'suspendedAt': null,
            'suspensionReason': null,
          }, SetOptions(merge: true));
        }
      } catch (e) {
        print('WARNING: Could not verify user document: $e');
        // Continue anyway - might be temporary network issue
      }

      // ═════════════════════════════════════════════════════
      // STEP 3: VALIDATE USER CAN ACCESS VIA CLOUD FUNCTION
      // This checks if user is suspended/deleted
      // ═════════════════════════════════════════════════════
      try {
        await _validateUserCanAccess(user);
      } catch (e) {
        print('ERROR: Access validation failed: $e');
        rethrow; // User denied access - re-throw the error
      }

      // ═════════════════════════════════════════════════════
      // STEP 4: LOG SESSION
      // ═════════════════════════════════════════════════════
      try {
        await _firestore.collection('user_sessions').doc(user.uid).set({
          'userId': user.uid,
          'email': user.email,
          'loginTime': FieldValue.serverTimestamp(),
          'logoutTime': null,
          'isActive': true,
        }, SetOptions(merge: true));
      } catch (e) {
        print('WARNING: Could not log session: $e');
        // Continue anyway - session logging not critical
      }
    }

    return user;
  } on FirebaseAuthException {
    rethrow; // Re-throw with specific error code
  } catch (e) {
    throw FirebaseAuthException(
      code: 'unknown-error',
      message: 'Login failed: $e',
    );
  }
}

/// Validates that user can access the app (not suspended/deleted)
///
/// Calls the checkUserAccessStatus Cloud Function which:
/// 1. Verifies user document exists
/// 2. Checks accountStatus field
/// 3. Checks isBlocked field
/// 4. Returns whether user is allowed access
///
/// If not allowed, signs out the user and throws FirebaseAuthException
Future<void> _validateUserCanAccess(User user) async {
  HttpsCallableResult<dynamic> result;

  try {
    result = await _functions
        .httpsCallable('checkUserAccessStatus')
        .call();
  } on FirebaseFunctionsException {
    throw FirebaseAuthException(
      code: 'service-unavailable',
      message: 'Unable to verify account status right now. Please try again later.',
    );
  }

  // ═════════════════════════════════════════════════════
  // PARSE CLOUD FUNCTION RESPONSE
  // ═════════════════════════════════════════════════════
  final data = result.data as Map<dynamic, dynamic>? ?? {};
  final allowed = data['allowed'] == true;
  final reasonCode = (data['reasonCode'] ?? '').toString();
  final message = (data['message'] ?? '').toString();

  if (!allowed) {
    // ═════════════════════════════════════════════════════
    // ACCESS DENIED - SIGN OUT USER
    // ═════════════════════════════════════════════════════
    await _auth.signOut();

    // Different error messages for different reasons
    if (reasonCode == 'account-deleted') {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: message.isNotEmpty
            ? message
            : 'No account exists with this email. Please create a new account.',
      );
    }

    // Account is suspended
    throw FirebaseAuthException(
      code: 'user-disabled',
      message: message.isNotEmpty
          ? message
          : 'Login denied: your account is currently suspended. '
            'Please contact support.',
    );
  }

  // If we reach here, user is allowed to access
}
```

### Cloud Function: checkUserAccessStatus

```javascript
// Called by login page to verify user can login
exports.checkUserAccessStatus = onCall(async (request) => {
  try {
    // ═════════════════════════════════════════════════════
    // VERIFY USER IS AUTHENTICATED
    // ═════════════════════════════════════════════════════
    const callerUid = request.auth?.uid;
    if (!callerUid) {
      throw new HttpsError("unauthenticated", "Authentication required.");
    }

    // ═════════════════════════════════════════════════════
    // GET USER DOCUMENT
    // ═════════════════════════════════════════════════════
    const userDoc = await db.collection("users").doc(callerUid).get();

    if (!userDoc.exists) {
      // User doc doesn't exist - account was deleted
      return {
        allowed: false,
        reasonCode: "account-deleted",
        message:
          "No account exists with this email. Please create a new account.",
      };
    }

    // ═════════════════════════════════════════════════════
    // CHECK SUSPENSION STATUS
    // ═════════════════════════════════════════════════════
    const data = userDoc.data() || {};
    const accountStatus = data.accountStatus || "active";
    const isBlocked = !!data.isBlocked;

    // Get suspension reason if available
    const suspensionReason =
      typeof data.suspensionReason === "string" &&
      data.suspensionReason.trim().length > 0
        ? data.suspensionReason.trim()
        : "suspicious activities";

    // ═════════════════════════════════════════════════════
    // DETERMINE IF ACCOUNT IS SUSPENDED
    // ═════════════════════════════════════════════════════
    if (accountStatus === "suspended" || isBlocked) {
      return {
        allowed: false,
        reasonCode: "suspended",
        message:
          `Login denied: your account is currently suspended for ${suspensionReason}. ` +
          `Please contact support.`,
      };
    }

    // ═════════════════════════════════════════════════════
    // ACCOUNT IS ACTIVE - ALLOW LOGIN
    // ═════════════════════════════════════════════════════
    return {
      allowed: true,
      reasonCode: "active",
      message: "ok",
    };
  } catch (error) {
    console.error("checkUserAccessStatus error:", error);
    throw new HttpsError("internal", "Failed to validate access status.");
  }
});
```

---

## Admin Suspension

### Suspend Dialog from `user_management_page.dart`

```dart
// Show suspension confirmation dialog to admin
void _showSuspendDialog(AdminUserModel user) {
  final reasonController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Suspend Account'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Account: ${user.email}'),
          const SizedBox(height: 16),

          // Reason input field
          TextField(
            controller: reasonController,
            decoration: const InputDecoration(
              labelText: 'Suspension Reason',
              border: OutlineInputBorder(),
              hintText: 'Enter reason for suspension...',
              helperText: 'e.g., Suspicious login activity, Violation of terms',
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            // Call suspend Cloud Function
            await _suspendUser(
              uid: user.uid,
              reason: reasonController.text.isEmpty
                ? 'Suspended by admin'
                : reasonController.text,
            );
            Navigator.pop(context);
            // Refresh UI
            _loadUsers();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[600],
          ),
          child: const Text('Suspend'),
        ),
      ],
    ),
  );
}

// Call suspendUserAccount Cloud Function
Future<void> _suspendUser({
  required String uid,
  required String reason,
}) async {
  try {
    final result = await FirebaseFunctions.instance
        .httpsCallable('suspendUserAccount')
        .call({
          'uid': uid,
          'reason': reason,
        });

    print('Account suspended: ${result.data}');

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Account suspended successfully')),
    );
  } on FirebaseFunctionsException catch (e) {
    print('Error suspending account: ${e.message}');

    // Show error message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${e.message}')),
    );
  }
}

// Show reactivate confirmation
Future<void> _reactivateUser(String uid) async {
  try {
    final result = await FirebaseFunctions.instance
        .httpsCallable('reactivateUserAccount')
        .call({'uid': uid});

    print('Account reactivated: ${result.data}');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Account reactivated successfully')),
    );

    // Refresh UI
    _loadUsers();
  } on FirebaseFunctionsException catch (e) {
    print('Error reactivating account: ${e.message}');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${e.message}')),
    );
  }
}
```

### Display User Status in List

```dart
// Build user list tile with suspension status badge
Widget _buildUserTile(AdminUserModel user) {
  return ListTile(
    title: Text(user.name),
    subtitle: Text(user.email),

    // Status badge
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Show status badge
        if (user.accountStatus == 'suspended')
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red),
            ),
            child: const Text(
              'SUSPENDED',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),

        if (user.accountStatus == 'active')
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green),
            ),
            child: const Text(
              'ACTIVE',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),

        const SizedBox(width: 8),

        // Action buttons
        PopupMenuButton(
          itemBuilder: (context) => [
            if (user.accountStatus != 'suspended')
              PopupMenuItem(
                child: const Text('Suspend'),
                onTap: () => _showSuspendDialog(user),
              ),
            if (user.accountStatus == 'suspended')
              PopupMenuItem(
                child: const Text('Reactivate'),
                onTap: () => _reactivateUser(user.uid),
              ),
            PopupMenuItem(
              child: const Text('Delete'),
              onTap: () => _deleteUser(user.uid),
            ),
          ],
        ),
      ],
    ),
  );
}
```

---

## Cloud Functions

### Complete suspendUserAccount Function

```javascript
exports.suspendUserAccount = onCall(async (request) => {
  try {
    // ═════════════════════════════════════════════════════
    // VERIFY ADMIN PERMISSION
    // ═════════════════════════════════════════════════════
    await requireAdmin(request);

    const uid = request.data?.uid;
    const reason = (request.data?.reason || "").toString().trim();

    // Validate input
    if (!uid || typeof uid !== "string") {
      throw new HttpsError("invalid-argument", "A valid uid is required.");
    }

    // ═════════════════════════════════════════════════════
    // VERIFY USER EXISTS
    // ═════════════════════════════════════════════════════
    const userRef = db.collection("users").doc(uid);
    const userDoc = await userRef.get();

    if (!userDoc.exists) {
      throw new HttpsError("not-found", "Target user does not exist.");
    }

    const email = (userDoc.data()?.email || "").toString().toLowerCase();

    // ═════════════════════════════════════════════════════
    // STEP 1: UPDATE USER DOCUMENT
    // ═════════════════════════════════════════════════════
    await userRef.set(
      {
        accountStatus: "suspended",
        isBlocked: true,
        suspendedAt: admin.firestore.FieldValue.serverTimestamp(),
        suspensionReason:
          reason || "Suspended by admin for suspicious activity",
        accessDeniedMessage:
          "Login denied: your account is currently suspended. Contact support if this is a mistake.",
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true }
    );

    console.log(`✓ Updated user document: ${uid}`);

    // ═════════════════════════════════════════════════════
    // STEP 2: ADD EMAIL TO BLOCKED_EMAILS COLLECTION
    // ═════════════════════════════════════════════════════
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

        console.log(`✓ Successfully blocked email: ${email}`);
      } catch (frozenError) {
        console.error(
          `✗ CRITICAL ERROR: Failed to block email ${email}:`,
          frozenError.message
        );
        // Continue anyway - user suspension is still valid
      }
    }

    // ═════════════════════════════════════════════════════
    // STEP 3: REVOKE REFRESH TOKENS (FORCE LOGOUT)
    // ═════════════════════════════════════════════════════
    try {
      await admin.auth().revokeRefreshTokens(uid);
      console.log(`✓ Revoked refresh tokens for user: ${uid}`);
    } catch (error) {
      if (error?.code !== "auth/user-not-found") {
        throw error;
      }
      // User might be deleted already
    }

    // ═════════════════════════════════════════════════════
    // RETURN SUCCESS RESPONSE
    // ═════════════════════════════════════════════════════
    return {
      success: true,
      uid,
      email,
      status: "suspended",
      message: `Successfully suspended ${email}`,
    };
  } catch (error) {
    console.error("suspendUserAccount failed", error);
    throw new HttpsError("internal", "Suspend failed due to a server error.");
  }
});
```

### Complete reactivateUserAccount Function

```javascript
exports.reactivateUserAccount = onCall(async (request) => {
  try {
    // ═════════════════════════════════════════════════════
    // VERIFY ADMIN PERMISSION
    // ═════════════════════════════════════════════════════
    await requireAdmin(request);

    const uid = request.data?.uid;

    if (!uid || typeof uid !== "string") {
      throw new HttpsError("invalid-argument", "A valid uid is required.");
    }

    // ═════════════════════════════════════════════════════
    // VERIFY USER EXISTS
    // ═════════════════════════════════════════════════════
    const userRef = db.collection("users").doc(uid);
    const userDoc = await userRef.get();

    if (!userDoc.exists) {
      throw new HttpsError("not-found", "Target user does not exist.");
    }

    const email = (userDoc.data()?.email || "").toString().toLowerCase();

    // ═════════════════════════════════════════════════════
    // STEP 1: UPDATE USER DOCUMENT - RESTORE TO ACTIVE
    // ═════════════════════════════════════════════════════
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

    console.log(`✓ User reactivated: ${uid}`);

    // ═════════════════════════════════════════════════════
    // STEP 2: REMOVE EMAIL FROM BLOCKED_EMAILS COLLECTION
    // ═════════════════════════════════════════════════════
    if (email && email.length > 0) {
      try {
        await db.collection("blocked_emails").doc(email).delete();
        console.log(`✓ Successfully unblocked email: ${email}`);
      } catch (deleteError) {
        console.warn(`⚠ WARNING: Could not delete blocked_emails for ${email}`);
        // Continue anyway - user reactivation is still valid
      }
    }

    // ═════════════════════════════════════════════════════
    // RETURN SUCCESS RESPONSE
    // ═════════════════════════════════════════════════════
    return {
      success: true,
      uid,
      email,
      status: "active",
      message: `Successfully reactivated ${email}`,
    };
  } catch (error) {
    console.error("reactivateUserAccount failed", error);
    throw new HttpsError(
      "internal",
      "Reactivation failed due to a server error."
    );
  }
});
```

### Helper Function: requireAdmin

```javascript
// Verify that the caller is an admin
async function requireAdmin(request) {
  // Get caller's UID
  const callerUid = request.auth?.uid;
  if (!callerUid) {
    throw new HttpsError("unauthenticated", "Admin authentication required.");
  }

  // Get caller's user document
  const callerDoc = await db.collection("users").doc(callerUid).get();
  if (!callerDoc.exists) {
    throw new HttpsError(
      "permission-denied",
      "Caller user document not found."
    );
  }

  // Check if caller has admin role
  const callerRole = callerDoc.data()?.role;
  if (callerRole !== "admin") {
    throw new HttpsError(
      "permission-denied",
      `Operation denied: only admins can perform this action. User role: ${callerRole}`
    );
  }
}
```

---

## Error Handling

### Signup Error Handling

```dart
Future<void> _handleSignup() async {
  try {
    final user = await authService.signUpWithEmail(
      name: nameController.text,
      email: emailController.text,
      password: passwordController.text,
    );

    if (user != null) {
      // Success
      Navigator.pushReplacementNamed(context, '/home');
    }
  } on FirebaseAuthException catch (e) {
    String errorMessage;

    switch (e.code) {
      case 'email-suspended':
        errorMessage = e.message ??
          'This email is associated with a suspended account.';
        break;
      case 'email-deleted':
        errorMessage = e.message ??
          'This email was permanently deleted.';
        break;
      case 'weak-password':
        errorMessage = 'Password is too weak. Use at least 6 characters.';
        break;
      case 'email-already-in-use':
        errorMessage = 'This email is already registered.';
        break;
      case 'invalid-email':
        errorMessage = 'Invalid email address format.';
        break;
      case 'firestore-error':
        errorMessage = e.message ??
          'Failed to create account. Please try again.';
        break;
      default:
        errorMessage = e.message ?? 'Signup failed. Please try again.';
    }

    // Show error to user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  } catch (e) {
    // Unknown error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('An unexpected error occurred: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
```

### Login Error Handling

```dart
Future<void> _handleLogin() async {
  try {
    final user = await authService.loginWithEmail(
      email: emailController.text,
      password: passwordController.text,
    );

    if (user != null) {
      // Success
      Navigator.pushReplacementNamed(context, '/home');
    }
  } on FirebaseAuthException catch (e) {
    String errorMessage;

    switch (e.code) {
      case 'user-not-found':
        errorMessage = 'No account found with this email. Please sign up first.';
        break;
      case 'wrong-password':
        errorMessage = 'Incorrect password. Please try again.';
        break;
      case 'user-disabled':
        // Suspended account
        errorMessage = e.message ??
          'Your account has been suspended. Please contact support.';
        break;
      case 'invalid-email':
        errorMessage = 'Invalid email address format.';
        break;
      case 'service-unavailable':
        errorMessage = 'Service unavailable. Please try again later.';
        break;
      default:
        errorMessage = e.message ?? 'Login failed. Please try again.';
    }

    // Show error to user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
```

### Cloud Function Error Handling

```dart
Future<void> _suspendUser({
  required String uid,
  required String reason,
}) async {
  try {
    final result = await FirebaseFunctions.instance
        .httpsCallable('suspendUserAccount')
        .call({
          'uid': uid,
          'reason': reason,
        });

    // Check if operation was successful
    if (result.data['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Successfully suspended ${result.data['email']}',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  } on FirebaseFunctionsException catch (e) {
    String errorMessage;

    switch (e.code) {
      case 'permission-denied':
        errorMessage = 'You do not have permission to suspend accounts.';
        break;
      case 'not-found':
        errorMessage = 'User not found.';
        break;
      case 'invalid-argument':
        errorMessage = 'Invalid user ID.';
        break;
      case 'service-unavailable':
        errorMessage = 'Service temporarily unavailable.';
        break;
      default:
        errorMessage = e.message ?? 'Operation failed.';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
      ),
    );
  }
}
```

---

## Data Models

### AdminUserModel (for display in admin panel)

```dart
class AdminUserModel {
  final String uid;
  final String name;
  final String email;
  final String role;
  final String accountStatus; // "active", "suspended", "deleted"
  final bool isBlocked;
  final DateTime? createdAt;
  final DateTime? suspendedAt;
  final String? suspensionReason;

  AdminUserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.accountStatus,
    required this.isBlocked,
    this.createdAt,
    this.suspendedAt,
    this.suspensionReason,
  });

  // Factory constructor to create from Firestore snapshot
  factory AdminUserModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return AdminUserModel(
      uid: doc.id,
      name: data['name'] ?? 'Unknown',
      email: data['email'] ?? '',
      role: data['role'] ?? 'user',
      accountStatus: data['accountStatus'] ?? 'active',
      isBlocked: data['isBlocked'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      suspendedAt: (data['suspendedAt'] as Timestamp?)?.toDate(),
      suspensionReason: data['suspensionReason'],
    );
  }

  // Convert to JSON/Map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'accountStatus': accountStatus,
      'isBlocked': isBlocked,
      'createdAt': createdAt,
      'suspendedAt': suspendedAt,
      'suspensionReason': suspensionReason,
    };
  }
}
```

---

**Last Updated:** February 25, 2026
**Document Type:** Complete Code Implementation Reference
**ResQNow - Emergency Management System**
