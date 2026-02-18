# Firestore Setup & Security Rules Guide

## 🔴 Current Issue: Permission Denied Error

The admin dashboard is showing:

```
Error loading donors: Exception: Failed to fetch blood donors:
[cloud_firestore/permission-denied] Missing or insufficient permissions.
```

This means **Firestore is blocking read access** because of security rule configuration.

---

## ✅ Solution: Configure Firestore Security Rules

Your Firestore Database security rules must allow admin users to read/write donor and user data.

### Step 1: Open Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **resqnow-12e6c**
3. Navigate to **Firestore Database** → **Rules** tab

### Step 2: Update Security Rules

Replace the existing rules with:

```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {

    // 🔐 Users collection
    match /users/{userId} {
      // User can read all users
      allow read: if request.auth != null;

      // User can create their own document
      allow create: if request.auth != null &&
                    request.auth.uid == userId;

      // User can update their own document BUT NOT role, OR admins can update any user (for suspending/managing)
      allow update: if (request.auth != null &&
                        request.auth.uid == userId &&
                        !("role" in request.resource.data.diff(resource.data).changedKeys()))
                    || isAdmin();

      // Only admins can delete users
      allow delete: if isAdmin();
    }

    // 📖 Public read collections
    match /categories/{doc} {
      allow read: if true;
      allow write: if isAdmin();
    }

    match /medical_conditions/{doc} {
      allow read: if true;
      allow write: if isAdmin();
    }

    match /resources/{doc} {
      allow read: if true;
      allow write: if isAdmin();
    }

    match /emergency_numbers/{doc} {
      allow read: if true;
      allow write: if isAdmin();
    }

    // 💬 Chats (only authenticated users)
    match /chats/{doc} {
      allow read, write: if request.auth != null;
    }

    // 👥 Donors
    match /donors/{doc} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }

    // 🔑 Admin check function
    function isAdmin() {
      return request.auth != null &&
        get(/databases/$(database)/documents/users/$(request.auth.uid))
          .data.role == "admin";
    }
  }
}
```

### Step 3: Publish Rules

Click **Publish** to apply the new rules.

---

## 🔐 Security Rules Breakdown

| Collection             | Read            | Write                | Notes                                   |
| ---------------------- | --------------- | -------------------- | --------------------------------------- |
| **users**              | All Auth Users  | Own Doc + Admin Edit | Admins can suspend/manage users         |
| **donors**             | All Auth Users  | All Auth Users       | Full read/write for authenticated users |
| **categories**         | Everyone        | Admin Only           | Public read, admin write                |
| **medical_conditions** | Everyone        | Admin Only           | Public read, admin write                |
| **resources**          | Everyone        | Admin Only           | Public read, admin write                |
| **emergency_numbers**  | Everyone        | Admin Only           | Public read, admin write                |
| **chats**              | Auth Users Only | Auth Users Only      | Private messages, auth required         |

---

## 👤 User Access Mapping

### **Admin Users** (role: "admin")

- ✅ Read all users
- ✅ Update all users (suspend, reactivate, etc.)
- ✅ Delete users
- ✅ Update all public collections
- ✅ Read/write all donors
- ✅ Access admin dashboard

### **Regular Users** (role: "user", "support", "moderator")

- ✅ Read all users
- ✅ Read all public collections
- ✅ Read/write own donors data
- ✅ Read/write all donors (can search/discover)
- ❌ Cannot modify public collections
- ❌ Cannot access admin dashboard (app-level check)

---

## 🔑 Authentication Requirements

The admin dashboard now checks:

1. **Is user authenticated?**

   - Status: ✅ Displayed in pages
   - Error: "Not authenticated. Please login first."

2. **Does user have admin role?**

   - Status: ✅ Verified against Firestore `users/{uid}/role`
   - Error: "Access denied. Admin privileges required."

3. **Does Firestore allow access?**
   - Status: ✅ Managed by security rules
   - Error: "[cloud_firestore/permission-denied]"

---

## � Security Architecture: Two-Layer Protection

### **Layer 1: Firestore Rules** (Database Level)

- Donors collection: ✅ All authenticated users can read/write
- Public collections: ✅ Everyone can read, admin-only write
- Users collection: ✅ Authenticated users can read, own-document write
- Chats: ✅ Authenticated users only

### **Layer 2: App-Level Authorization** (Admin Dashboard)

Even though Firestore allows all auth users to access donors, the **admin dashboard** adds an extra check:

```dart
final isAdmin = await _adminService.isCurrentUserAdmin();
if (!isAdmin) {
  // Deny access - "Admin privileges required"
}
```

This means:

- ✅ Regular users CAN read/write donors via the main app
- ❌ Regular users CANNOT access the admin dashboard (app-level block)
- ✅ Admins CAN access the admin dashboard

**This is intentional and provides better security!**

---

## 📋 User Role Structure

Your Firestore `users` collection should have documents like:

```json
{
  "uid": "user123",
  "email": "admin@resqnow.com",
  "name": "Admin User",
  "role": "admin",
  "accountStatus": "active",
  "createdAt": "2024-01-15T10:30:00Z",
  "lastLogin": "2024-02-18T15:45:00Z",
  "profileImage": "https://...",
  "emailVerified": true
}
```

**Valid roles:**

- `admin` - Full admin dashboard + writing to public collections ✅
- `support` - Cannot access admin dashboard, regular app access
- `moderator` - Cannot access admin dashboard, regular app access
- `user` - Cannot access admin dashboard, regular app access

---

## 🧪 Testing the Setup

1. **Create a test account with `role: "admin"`** in Firestore
2. **Login to the admin dashboard** with that admin account
3. **Go to Users page** → Should show list of users (no permission error)
4. **Go to Blood Donor page** → Should show list of donors (no permission error)
5. **Try as a non-admin user** → Should see "Access denied. Admin privileges required."

If still seeing errors:

- ✅ Verify Firestore rules are published
- ✅ Check user `role` is exactly `"admin"` (lowercase)
- ✅ Clear browser cache and refresh
- ✅ Check browser console for detailed error messages

---

## ⚠️ Important Notes

- **Firestore rules are case-sensitive** - Make sure `role` is lowercase `"admin"`
- **Rules take 1-2 minutes to propagate** - Wait after publishing before testing
- **App-level checks override Firestore permissions** - Even if Firestore allows it, app code can deny access
- **Donors are readable by all auth users** - This allows the main app to function normally
- **Admin dashboard is more restrictive** - Only admins can see the management pages

---

## 🔧 Troubleshooting

### Still getting "permission-denied" error?

**Check 1: User is logged in**

- Dashboard should show: "Not authenticated. Please login first." if not
- Make sure you're using the same Firebase project

**Check 2: User has admin role**

- Go to Firebase Console → Firestore → users collection
- Find your user document
- Verify `role` field is exactly `"admin"` (lowercase)

**Check 3: Firestore rules are published**

- Go to Firebase Console → Firestore → Rules
- Check last modified timestamp is recent
- Click Publish if changes are pending

**Check 4: Collection names match**

- Admin dashboard uses: `users` and `donors` collections
- Make sure your documents are in these exact collections

**Check 5: Browser cache**

- Clear browser cookies/cache
- Close and reopen the tab
- Try in an incognito window

---

## 🎯 Quick Setup Checklist

- [ ] Copy the security rules provided above
- [ ] Paste into Firebase Console → Firestore → Rules
- [ ] Click **Publish**
- [ ] Create a test user with `role: "admin"` in the `users` collection
- [ ] Login to admin dashboard with that account
- [ ] Verify no permission errors appear
- [ ] Test data loading (Users and Donors pages)

---

## 📚 Reference

- [Firestore Security Rules Documentation](https://firebase.google.com/docs/firestore/security/start)
- [Custom Claims for Better Access Control](https://firebase.google.com/docs/auth/admin/custom-claims)
- [Firebase Console](https://console.firebase.google.com/)
