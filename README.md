# ResQNow Admin

## User suspension and deletion flow

This project now uses Firebase Cloud Functions for admin-enforced account lifecycle actions:

- `suspendUserAccount`:
  - marks the user as suspended (`accountStatus = suspended`, `isBlocked = true`)
  - stores suspension reason/message
  - revokes refresh tokens
- `reactivateUserAccount`:
  - restores account access (`accountStatus = active`, `isBlocked = false`)
- `deleteUserAccountCompletely`:
  - deletes known profile/history data from Firestore (`users`, `donors`, `call_requests`, `notifications`, `user_sessions`)
  - deletes Firebase Auth user record

The admin Flutter app calls these as callable functions from `AdminService`.

## Deploy Cloud Functions

1. Install dependencies:
   - `cd functions`
   - `npm install`
2. Deploy:
   - `firebase deploy --only functions`

## Client-side behavior (user app)

- Suspended users are force-signed-out when status changes while they are logged in.
- Suspended users see a login-denied message when attempting to log in.
- Deleted users (auth record removed) receive a "no account exists" login message.

## Notes

- Ensure this admin app and the user app point to the same Firebase project.
- Ensure admin callers have `users/{uid}.role == "admin"` in Firestore.
