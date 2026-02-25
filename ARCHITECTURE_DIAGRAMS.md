# ResQNow: Architecture & Visual Diagrams

## 🏗️ System Architecture

```
┌────────────────────────────────────────────────────────────────────┐
│                     RESQNOW ECOSYSTEM                              │
└────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│         CLIENTS (Flutter Apps)          │
├─────────────────────────────────────────┤
│                                         │
│  ┌──────────────────┐  ┌──────────────┐ │
│  │  Main App        │  │  Admin App   │ │
│  │  (ResQNow)       │  │  (ResQNow    │ │
│  │                  │  │   Admin)     │ │
│  │ - Signup         │  │              │ │
│  │ - Login          │  │ - Login      │ │
│  │ - Logout         │  │ - User Mgmt  │ │
│  │ - Browse Donors  │  │ - Suspend    │ │
│  │ - Call Requests  │  │ - Block Users│ │
│  └────────┬─────────┘  └──────┬───────┘ │
│           │                   │         │
└───────────┼───────────────────┼─────────┘
            │                   │
            ├───────────────────┤
            │   Flutter Packages│
            │   Firebase SDK    │
            │   Cloud Functions │
            └─────────┬─────────┘
                      │
    ┌─────────────────┴──────────────────┐
    │                                    │
    ↓                                    ↓
┌──────────────────────┐      ┌──────────────────────┐
│  FIREBASE BACKEND    │      │  FIREBASE BACKEND    │
│                      │      │                      │
│  Authentication (v9) │      │  Cloud Firestore     │
│  ├─ Email/Password   │      │  ├─ users            │
│  ├─ UID Generation   │      │  ├─ blocked_emails   │
│  ├─ Auth Tokens      │      │  ├─ donors           │
│  └─ Session Mgmt     │      │  ├─ notifications    │
│                      │      │  ├─ user_sessions    │
│                      │      │  └─ call_requests    │
└──────────┬───────────┘      └──────────┬──────────┘
           │                             │
           │                             │
    ┌──────┴─────────────────────────────┴─────────┐
    │                                              │
    ↓                                              ↓
┌──────────────────────────┐      ┌──────────────────────────┐
│  CLOUD FUNCTIONS         │      │  FIRESTORE RULES         │
│  (Node.js v20)           │      │  (Security.rules)        │
│                          │      │                          │
│  ├─ suspendUserAccount   │      │  ├─ users collection     │
│  ├─ reactivateUserAccount│      │  ├─ blocked_emails col   │
│  ├─ deleteUserAccount    │      │  ├─ donors collection    │
│  ├─ checkUserAccess      │      │  ├─ notifications col    │
│  ├─ syncBlockedEmails    │      │  └─ Authentication checks│
│  └─ sendNotification     │      │                          │
│                          │      │                          │
│  Uses Admin SDK          │      │  Server-side auth        │
│  Bypasses Firestore Rules│      │  enforced automatically  │
└──────────────────────────┘      └──────────────────────────┘
```

---

## 📱 Authentication States

```
┌──────────────────────────────────────────┐
│       USER ACCOUNT LIFECYCLE             │
└──────────────────────────────────────────┘

    ┌─────────────────┐
    │  Not Registered │
    │  (No Account)   │
    └────────┬────────┘
             │
             │ User fills signup form
             │ (name, email, password)
             ↓
    ┌──────────────────┐              ┌──────────────────┐
    │ CHECK blocked    │──YES (Blocked)─→ SHOW ERROR      │
    │ _emails exists?  │                  Signup Blocked  │
    └────────┬─────────┘                └──────────────────┘
             │
             NO
             │
             ↓
    ┌──────────────────────────┐
    │ Create Firebase Auth User│
    │ Create Firestore Doc     │
    │ accountStatus = "active" │
    │ isBlocked = false        │
    └────────┬─────────────────┘
             │
             ↓
    ┌─────────────────────┐
    │   ACTIVE ACCOUNT    │◄──────┐
    │                     │       │ User reactivated
    │ Can Login           │       │ (admin action)
    │ Can use app         │       │
    └────────┬────────────┘       │
             │                    │
             │ Admin suspended    │
             │ account            │
             ↓                    │
    ┌──────────────────────────┐ │
    │   SUSPENDED ACCOUNT      │ │
    │ (accountStatus=suspended)│ │
    │ (isBlocked=true)         │ │
    │ (in blocked_emails)      │ │
    │                          │ │
    │ Cannot Login             │ │
    │ Cannot Signup same email │─┘
    │ Cannot use app features  │
    └────────┬─────────────────┘
             │
             │ Admin deleted account
             │
             ↓
    ┌──────────────────────────┐
    │   DELETED ACCOUNT        │
    │ (accountStatus=deleted)  │
    │ (in blocked_emails       │
    │  with status=deleted)    │
    │                          │
    │ Forever blocked          │
    │ Cannot re-signup         │
    └──────────────────────────┘
```

---

## 🔐 Login Validation Sequence

```
Client (Main App) ┌─────────────────────────────────┐ Firebase Backend
                  │                                 │
   User enters    │                                 │
   email & pwd    │                                 │
       │          │                                 │
       ├─────────────── Sign In Request ──────────→ │
       │          │                                 │ Firebase Auth
       │          │  ✅/❌ Auth Validation         │ Validates credentials
       │          │  Returns Auth Token & User      │
       │          │                                 │
       │ ←─────────── Auth Response ──────────────  │
       │          │                                 │
       │          │  (Credentials OK)              │
       │          ├─ Call Cloud Function          │
       │          │  checkUserAccessStatus()      │
       │          │                                 │
       ├─────────────── [VERIFY ACCESS] ─────────→ │ Cloud Functions
       │          │                                 │ Gets user doc
       │          │  Check fields:                 │ Reads:
       │          │  • accountStatus?              │ • accountStatus
       │          │  • isBlocked?                  │ • isBlocked
       │          │  • suspensionReason?          │ • suspensionReason
       │          │                                 │
       │          │  If suspended:                 │
       │          │  Return { allowed: false }     │
       │          │  If active:                    │
       │          │  Return { allowed: true }      │
       │          │                                 │
       │ ←─────────── Access Response ────────────  │
       │          │                                 │
       │ Check if allowed?                         │
       │          │                                 │
       ├─ YES ────┴──→ UPDATE user_sessions      → │
       │               Log successful login        │ Firestore
       │               REDIRECT TO HOME PAGE ✅    │
       │               USER IS LOGGED IN           │
       │                                           │
       └─ NO ──────→ SHOW ERROR MESSAGE           │
                    "Login denied: your account   │
                     is suspended..."             │
                    AUTH SIGN OUT
                    USER IS NOT LOGGED IN ❌      │
```

---

## 🚫 Signup with Blocked Email Sequence

```
Client (Main App)         Firebase Backend

User wants to signup
with email: john@mail.com

       │                  │
       │ Signup Form Filled│
       │                  │
       ├──────────────────────┐
       │                      │ Check: Does email exist
       │ blockedEmailCheck()  │ in blocked_emails collection?
       │                      │
       ├─ Query: blocked     │
       │  _emails/            │
       │  john@mail.com      │ ← Firestore
       │                      │
       │  FOUND!              │
       │  status: "suspended" │
       │  reason: "Suspicious"│
       │                      │
       │ ←──────────────────── Document snapshot
       │
       │  Extract status
       │  └─ status = "suspended"
       │
       ├─→ THROW ERROR
       │   "This email address is
       │    associated with a
       │    suspended account"
       │
       │  SHOW ERROR TO USER
       │  PREVENT SIGNUP ❌
       │
       └─ SIGNUP BLOCKED
```

**If email NOT in blocked_emails:**

```
       ├─ NOT FOUND in blocked_emails
       │  Continue with signup
       │
       ├─ Create Firebase Auth → Auth created ✅
       │
       ├─ Create Firestore doc → Doc created ✅
       │  accountStatus: "active"
       │  isBlocked: false
       │
       └─ SIGNUP COMPLETED ✅
```

---

## 🔒 Account Suspension Sequence

```
Admin (Admin App)                    Backend Services

Admin finds user
"john@mail.com" in list

       │                            │
       │ Clicks "Suspend" Button    │
       │                            │
       ├─→ [Suspension Dialog]      │
       │   "Enter Reason..."        │
       │   [type] "Suspicious activity"
       │   [Submit]                 │
       │                            │
       ├────────────────────────────────────┐
       │                                    │
       │ Call Cloud Function:               │
       │ suspendUserAccount({              │ Cloud Function
       │   uid: "XYZ789",                  │ suspendUserAccount()
       │   reason: "Suspicious activity"   │
       │ })                                │
       │                                  │ Step 1: Update users/XYZ789
       │                                  │ ├─ accountStatus="suspended"
       │ ←─── Processing ─────────────────→ │ ├─ isBlocked=true
       │                                  │ ├─ suspendedAt=NOW
       │                                  │ ├─ suspensionReason="..."
       │                                  │ └─ Updated at=NOW
       │                                  │
       │                                  │ Step 2: Add to blocked_emails
       │                                  │ ├─ email="john@mail.com"
       │                                  │ ├─ uid="XYZ789"
       │                                  │ ├─ status="suspended"
       │                                  │ ├─ reason="Suspicious..."
       │                                  │ └─ blockedAt=NOW
       │                                  │
       │                                  │ Step 3: Revoke Tokens
       │                                  │ └─ All refresh tokens deleted
       │                                  │    User auto-logged out
       │                                  │
       │ ←──── Success Response ──────────┤
       │  {                                │
       │    success: true,                 │
       │    uid: "XYZ789",                 │
       │    email: "john@mail.com",       │
       │    status: "suspended"            │
       │  }                                │
       │                                  │
       ├─→ SHOW SUCCESS MESSAGE           │
       │   "Account suspended!"           │
       │   REFRESH USER LIST              │
       │                                  │
       │ John's account now shows:        │
       │ [SUSPENDED] badge 🔴             │
       │ "Reactivate" button available    │
       │                                  │
       └─ JOHN IS NOW BLOCKED ❌
          Cannot login
          Cannot signup with same email
```

---

## ♻️ Account Reactivation Sequence

```
Admin (Admin App)                   Backend Services

Admin finds suspended
user "john@mail.com"

       │                           │
       │ Clicks "Reactivate" Button│
       │                           │
       ├──────────────────────────────────┐
       │                                  │
       │ Call Cloud Function:             │
       │ reactivateUserAccount({          │
       │   uid: "XYZ789"                 │ Cloud Function
       │ })                              │ reactivateUserAccount()
       │                                 │
       │                                 │ Step 1: Update users/XYZ789
       │ ←─── Processing ───────────────→ │ ├─ accountStatus="active"
       │                                 │ ├─ isBlocked=false
       │                                 │ ├─ DELETE suspendedAt
       │                                 │ ├─ DELETE suspensionReason
       │                                 │ └─ updatedAt=NOW
       │                                 │
       │                                 │ Step 2: Remove from blocked_emails
       │                                 │ └─ DELETE blocked_emails/john@mail.com
       │                                 │
       │ ←──── Success Response ────────┤
       │  {                              │
       │    success: true,               │
       │    uid: "XYZ789",              │
       │    email: "john@mail.com",    │
       │    status: "active"             │
       │  }                              │
       │                                 │
       ├─→ SHOW SUCCESS MESSAGE          │
       │   "Account reactivated!"        │
       │   REFRESH USER LIST             │
       │                                 │
       │ John's account now shows:       │
       │ [ACTIVE] badge 🟢               │
       │ "Suspend" button available      │
       │                                 │
       └─ JOHN IS NOW ACTIVE ✅
          Can login again
          Can signup with same email
          Has full access to app
```

---

## 📊 Data States Diagram

```
┌─────────────────────────────────────────────────────────────┐
│              FIRESTORE DATABASE STATES                      │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│  STATE: New User (Active)               │
├─────────────────────────────────────────┤
│  users/{uid}:                           │
│  {                                      │
│    accountStatus: "active"         ✅   │
│    isBlocked: false                ✅   │
│    suspendedAt: null               ✅   │
│    suspensionReason: null          ✅   │
│  }                                      │
│                                         │
│  blocked_emails/john@mail.com:          │
│  ❌ DOES NOT EXIST                      │
│                                         │
│  CAN LOGIN: ✅ YES                      │
│  CAN SIGNUP: ✅ YES                     │
└─────────────────────────────────────────┘

         ↓ [ADMIN SUSPENDS]

┌─────────────────────────────────────────┐
│  STATE: Suspended Account               │
├─────────────────────────────────────────┤
│  users/{uid}:                           │
│  {                                      │
│    accountStatus: "suspended"      ❌   │
│    isBlocked: true                 ❌   │
│    suspendedAt: Timestamp          ❌   │
│    suspensionReason: "reason..."   ❌   │
│  }                                      │
│                                         │
│  blocked_emails/john@mail.com:          │
│  {                                      │
│    status: "suspended"              ❌  │
│    blockedAt: Timestamp             ❌  │
│    reason: "reason..."              ❌  │
│  }                                      │
│  ✅ EXISTS                              │
│                                         │
│  CAN LOGIN: ❌ NO                       │
│  CAN SIGNUP: ❌ NO                      │
└─────────────────────────────────────────┘

         ↓ [ADMIN REACTIVATES]

┌─────────────────────────────────────────┐
│  STATE: Reactivated Account (Active)    │
├─────────────────────────────────────────┤
│  users/{uid}:                           │
│  {                                      │
│    accountStatus: "active"         ✅   │
│    isBlocked: false                ✅   │
│    suspendedAt: null               ✅   │
│    suspensionReason: null          ✅   │
│  }                                      │
│                                         │
│  blocked_emails/john@mail.com:          │
│  ❌ DELETED (REMOVED)                   │
│                                         │
│  CAN LOGIN: ✅ YES                      │
│  CAN SIGNUP: ✅ YES                     │
└─────────────────────────────────────────┘
```

---

## ⚙️ Cloud Functions Execution Flow

```
EVENT TRIGGER
  │
  ├─ Signup (Client) → signUpWithEmail()
  │  │
  │  ├─ Check blocked_emails collection
  │  ├─ Create Firebase Auth user
  │  └─ Create Firestore users document
  │
  ├─ Login (Client) → loginWithEmail()
  │  │
  │  ├─ Firebase Auth validation
  │  ├─ Call checkUserAccessStatus() Cloud Function
  │  │  │
  │  │  └─ [CLOUD FUNCTION EXECUTION]
  │  │     ├─ Auth: Verify caller is authenticated
  │  │     ├─ Query: Get user document
  │  │     ├─ Check: accountStatus & isBlocked
  │  │     └─ Return: {allowed: true/false, message: "..."}
  │  │
  │  ├─ Process response
  │  │  ├─ If allowed: Log session, redirect home
  │  │  └─ If denied: Show error, sign out
  │  │
  │  └─ Create user_sessions document
  │
  ├─ Admin Suspend (Admin App)
  │  │
  │  └─ Call suspendUserAccount({uid, reason}) Cloud Function
  │     │
  │     └─ [CLOUD FUNCTION EXECUTION]
  │        ├─ Auth: Verify caller is admin (requireAdmin check)
  │        ├─ Update: users document
  │        │  └─ accountStatus="suspended", isBlocked=true, ...
  │        ├─ Create: blocked_emails document
  │        │  └─ status="suspended", reason="...", ...
  │        ├─ Revoke: All refresh tokens
  │        │  └─ User forcefully logged out
  │        └─ Return: {success: true, ...}
  │
  ├─ Admin Reactivate (Admin App)
  │  │
  │  └─ Call reactivateUserAccount({uid}) Cloud Function
  │     │
  │     └─ [CLOUD FUNCTION EXECUTION]
  │        ├─ Auth: Verify caller is admin
  │        ├─ Update: users document
  │        │  └─ accountStatus="active", isBlocked=false, ...
  │        ├─ Delete: blocked_emails document
  │        │  └─ Email removed from block list
  │        └─ Return: {success: true, ...}
  │
  └─ Notification Created → Auto-trigger sendNotificationToUsers
     │
     └─ [CLOUD FUNCTION EXECUTION]
        ├─ Listen: notifications collection
        ├─ Query: Matching users
        └─ Send: FCM push notifications

```

---

## 🔍 Error Handling Tree

```
SIGNUP ERRORS:
│
├─ Email in blocked_emails?
│  ├─ status="suspended"
│  │  └─ ERROR: "Email is associated with suspended account"
│  └─ status="deleted"
│     └─ ERROR: "Email was previously deleted"
│
├─ Firebase Auth Error?
│  ├─ weak-password
│  │  └─ ERROR: "Password is too weak"
│  ├─ email-already-in-use
│  │  └─ ERROR: "Email already registered"
│  └─ invalid-email
│     └─ ERROR: "Invalid email format"
│
└─ Firestore Write Error?
   ├─ PERMISSION_DENIED
   │  └─ ERROR: "Permission denied (security rules)"
   └─ RESOURCE_EXHAUSTED
      └─ ERROR: "Service temporarily unavailable"

───────────────────────────────────────

LOGIN ERRORS:
│
├─ Auth Validation Failed
│  ├─ user-not-found
│  │  └─ ERROR: "No account with this email"
│  └─ wrong-password
│     └─ ERROR: "Incorrect password"
│
├─ checkUserAccessStatus returns denied
│  ├─ account-deleted
│  │  └─ ERROR: "No account exists"
│  └─ suspended
│     └─ ERROR: "Account suspended: {reason}"
│
└─ Cloud Function Error
   ├─ service-unavailable
   │  └─ ERROR: "Unable to verify account status"
   └─ internal
      └─ ERROR: "Server error occurred"

───────────────────────────────────────

SUSPENSION ERRORS:
│
├─ Permission Check Failed
│  └─ ERROR: "Only admins can suspend accounts"
│
├─ User Not Found
│  └─ ERROR: "Target user does not exist"
│
├─ Cloud Function Error
│  └─ ERROR: "Failed to suspend account"
│
└─ Firestore Write Error
   └─ ERROR: "Database operation failed"
```

---

## 🔐 Security Rules Hierarchy

```
CURRENT RULES (Testing Mode - Ultra Permissive):

┌─────────────────────────────────────────┐
│ match /{document=**} {                  │
│   allow read, write:                    │
│     if request.auth != null;            │
│ }                                       │
│                                         │
│ ✅ Any authenticated user can:          │
│ • Read any document                     │
│ • Write any document                    │
│ • Delete any document                   │
│                                         │
│ ⚠️ NOT SUITABLE FOR PRODUCTION          │
└─────────────────────────────────────────┘

PRODUCTION RULES (Recommended):

┌─────────────────────────────────────────┐
│ match /users/{userId} {                 │
│   allow read: if request.auth != null;  │
│   allow create: if request.auth != null │
│     && request.resource.data.role       │
│        == "user";                       │
│   allow update: if request.auth != null │
│     && request.auth.uid == userId       │
│     && !request.resource.data.keys()    │
│        .hasAny(["role", "uid"]);        │
│   allow delete: if isAuthAdmin();       │
│ }                                       │
│                                         │
│ match /blocked_emails/{document=**} {   │
│   allow read: if request.auth != null;  │
│   allow write: if false;                │
│   // Cloud Functions use Admin SDK      │
│ }                                       │
└─────────────────────────────────────────┘

Note: Cloud Functions use Admin SDK which
      automatically bypasses all rules.
```

---

## 📈 User Count & Status Distribution

```
┌─────────────────────────────────────┐
│  TYPICAL USER DISTRIBUTION          │
├─────────────────────────────────────┤
│                                     │
│ Active Users               [████] 85% │
│ ├─ Can login                        │
│ ├─ Can use app                      │
│ └─ Full functionality               │
│                                     │
│ Suspended Users            [░░░░] 10%│
│ ├─ Cannot login                     │
│ ├─ Cannot signup again              │
│ └─ Email in blocked_emails          │
│                                     │
│ Deleted Users              [░░] 5%  │
│ ├─ Permanently removed              │
│ ├─ Never re-sign                    │
│ └─ Email in blocked_emails          │
│                                     │
│ Total Users: ~10,000               │
└─────────────────────────────────────┘
```

---

## 🎯 Quick Reference

| Operation          | User State | Can Login | Can Signup | Can Use App |
| ------------------ | ---------- | --------- | ---------- | ----------- |
| New Account        | active     | ✅        | ✅         | ✅          |
| After Suspension   | suspended  | ❌        | ❌         | ❌          |
| After Reactivation | active     | ✅        | ✅         | ✅          |
| After Deletion     | deleted    | ❌        | ❌         | ❌          |

---

## 📡 API Response Format

### checkUserAccessStatus (Login Validation)

**If Access Allowed:**

```json
{
  "allowed": true,
  "reasonCode": "active",
  "message": "ok"
}
```

**If Access Denied (Suspended):**

```json
{
  "allowed": false,
  "reasonCode": "suspended",
  "message": "Login denied: your account is currently suspended for suspicious activities. Please contact support."
}
```

**If Access Denied (Deleted):**

```json
{
  "allowed": false,
  "reasonCode": "account-deleted",
  "message": "No account exists with this email. Please create a new account."
}
```

### suspendUserAccount

**Success:**

```json
{
  "success": true,
  "uid": "XYZ789",
  "email": "john@mail.com",
  "status": "suspended"
}
```

**Error:**

```json
{
  "code": "permission-denied",
  "message": "Operation failed: Only admins can suspend accounts."
}
```

---

**Last Updated:** February 25, 2026
**System:** ResQNow Emergency Management Platform
