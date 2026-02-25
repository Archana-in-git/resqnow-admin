# ResQNow Admin

## User suspension and deletion flow

This project now uses Firebase Cloud Functions for admin-enforced account lifecycle actions:

- `suspendUserAccount`:

  - marks the user as suspended (`accountStatus = suspended`, `isBlocked = true`)
  - stores suspension reason/message and timestamp
  - adds email to `blocked_emails` collection with suspension details
  - revokes refresh tokens
  - **NEW**: blocked_emails collection now tracks all suspended accounts for security

- `reactivateUserAccount`:

  - restores account access (`accountStatus = active`, `isBlocked = false`)
  - removes email from `blocked_emails` collection
  - clears suspension metadata

- `deleteUserAccountCompletely`:
  - removes email from `blocked_emails` collection
  - deletes known profile/history data from Firestore (`users`, `donors`, `call_requests`, `notifications`, `user_sessions`)
  - deletes Firebase Auth user record

The admin Flutter app calls these as callable functions from `AdminService`.

## Blocked Emails Collection

A new `blocked_emails` collection automatically maintains a list of suspended/blocked accounts:

- **Document ID**: Email address (lowercase)
- **Fields**:
  - `email`: The blocked email address
  - `uid`: User ID
  - `blockedAt`: Timestamp of suspension
  - `reason`: Reason for suspension
  - `blockedBy`: UID of admin who suspended
  - `status`: 'suspended' or 'deleted'

This collection can be used for:

- Preventing new signups with blocked emails
- Security audits and compliance
- Quick lookups of suspended accounts

## Analytics Improvements

The dashboard now provides better user analytics:

- **Total Users**: All registered accounts (active + suspended)
- **Active Users**: Accounts with `accountStatus = 'active'` and `isBlocked = false`
- **Suspended Users**: Accounts with `accountStatus = 'suspended'`
- **New Users This Week**: Active accounts created in the last 7 days
- **Active Sessions**: Users currently logged in (from user_sessions collection)

This helps distinguish between:

- Total growth (all accounts)
- Healthy growth (active accounts)
- Problem accounts (suspended)
- Real-time engagement (active sessions)

## Deploy Cloud Functions

1. Install dependencies:
   - `cd functions`
   - `npm install`
2. Deploy:
   - `firebase deploy --only functions`

## Firestore Security Rules

Ensure proper security rules for the `blocked_emails` collection:

```
match /blocked_emails/{email} {
  allow read: if request.auth.uid != null &&
              get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
  allow write: if false; // Only Cloud Functions can write
}
```

## Client-side behavior (user app)

- Suspended users are force-signed-out when status changes while they are logged in.
- Suspended users see a login-denied message when attempting to log in.
- Deleted users (auth record removed) receive a "no account exists" login message.
- **NEW**: Sign-up should check `blocked_emails` collection to prevent suspended users from creating new accounts

## User Account Creation

New user/admin accounts are now properly saved to Firestore with:

- `createdAt`: Timestamp of account creation
- `accountStatus`: 'active' by default
- `isBlocked`: false by default
- All required fields for proper analytics and user management

## Notes

- Ensure this admin app and the user app point to the same Firebase project.
- Ensure admin callers have `users/{uid}.role == "admin"` in Firestore.
- Check `blocked_emails` collection when implementing signup validation in the main app
- Run analytics after account creation to ensure new users are reflected in dashboards
