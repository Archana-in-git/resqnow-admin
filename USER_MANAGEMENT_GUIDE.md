# User Management - Admin Dashboard

## Overview
The User Management page is a comprehensive admin interface for managing application users. It provides full CRUD operations, role-based filtering, status management, and detailed user profile information.

## Features

### 1. **User List & Search**
- View all registered users
- Search users by:
  - Full name
  - Email address
- Real-time search with instant filtering

### 2. **Advanced Filtering**
- Filter by role:
  - Admin
  - Support Staff
  - Moderator
  - User
- Filter by status:
  - Active
  - Suspended
  - Pending
- Multiple filters work together

### 3. **User Information Display**
Each user card shows:
- Profile image (with fallback icon)
- User name and email
- Role badge (color-coded)
- Account status (Active/Suspended/Pending)
- Email verification status
- Account creation date
- Last login information

### 4. **User Management Actions**

#### View Details
- Open comprehensive user profile dialog
- View all user information:
  - Name and email
  - Role and status
  - Account creation date
  - Last login date and time
  - Email verification status
  - Status indicators and warnings

#### Edit User
- Modify user information:
  - Full name
  - Role assignment (Admin, Support, Moderator, User)
  - Account status (Active, Suspended, Pending)
- Save changes with confirmation

#### Suspend User
- Suspend user account
- Provide reason for suspension
- Suspended users cannot perform actions
- Visible suspension flag on user card

#### Reactivate User
- Reactivate suspended users
- Restore account access
- User becomes active again

#### Delete User
- Permanently remove user record
- Two-step confirmation process
- Warning about irreversible action
- Soft delete (marks as deleted, keeps data for records)

### 5. **Statistics Dashboard**
Real-time statistics bar showing:
- **Total Users**: Total number of registered users
- **Active**: Number of active accounts
- **Suspended**: Number of suspended accounts
- **Admins**: Number of admin accounts

### 6. **Role Distribution**
Visual breakdown of users by role:
- Admin count
- Support staff count
- Moderators count
- Regular users count

## Technical Implementation

### Architecture
```
user_management_page.dart
├── UserManagementPage (StatefulWidget)
└── _UserManagementPageState
    ├── AdminService integration
    ├── State management
    ├── Data filtering logic
    └── UI components
```

### Key Components

#### Main Page
- Search bar with real-time filtering
- Role and status filter dropdowns
- Clear filters button
- Statistics dashboard
- User list with pagination

#### Dialog Boxes
- **Details Dialog**: Comprehensive user information view
- **Edit Dialog**: Form for updating user information and role
- **Suspend Dialog**: Confirmation and reason input
- **Delete Dialog**: Confirmation with warning message

### AdminService Integration
The page uses `AdminService` for all database operations:

```dart
// Get all users
await _adminService.getAllUsers(limit: 100);

// Get user by UID
await _adminService.getUserByUid(uid);

// Update user
await _adminService.updateUser(uid, {
  'field': 'value'
});

// Search operations
Future<List<AdminUserModel>> searchUsersByEmail(String email);
```

## Usage

### Loading the Page
```dart
// In your navigation/routing
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const UserManagementPage(),
  ),
);
```

### Filtering Workflow
1. **Search**: Type in search field to find users by name/email
2. **Role**: Select specific role from dropdown
3. **Status**: Filter by account status
4. **Clear Filters**: Click "Clear Filters" button to reset all

### Managing Users
1. **View Details**: Tap on user card or select "View Details" from menu
2. **Edit**: Select "Edit" from menu, modify fields, save
3. **Suspend**: Select "Suspend" for active users, confirm action
4. **Reactivate**: Select "Reactivate" for suspended users
5. **Delete**: Select "Delete", confirm warning, remove user

## Role System

### Roles Available
- **Admin**: Full system access, can manage all users and content
- **Support**: Can assist users, has limited admin capabilities
- **Moderator**: Can moderate content and users
- **User**: Regular user with basic access

### Role Colors
- Admin: Red
- Support: Blue
- Moderator: Orange
- User: Green

## Status System

### Account Status
- **Active**: User account is active and functional
- **Suspended**: User account is temporarily disabled
- **Pending**: User account awaiting verification

### Status Colors
- Active: Green
- Suspended: Red
- Pending: Orange

## Helper Utilities

The `UserHelper` class provides:
- Color utilities for roles and statuses
- Date formatting helpers
- Status badge generation
- Role display names
- Last login text formatting
- Statistical calculations
- Email verification status

```dart
// Example usage
import 'package:resqnow_admin/features/admin/presentation/utils/user_helper.dart';

// Get role color
Color roleColor = UserHelper.getRoleColor('admin');

// Format date
String formatted = UserHelper.formatDate(user.createdAt);

// Get last login text
String loginText = UserHelper.getLastLoginText(user.lastLogin);

// Get statistics
Map<String, int> stats = UserHelper.getStatistics(users);
```

## State Management

### Key State Variables
- `_allUsers`: Complete list of all users
- `_filteredUsers`: List after applying filters
- `_isLoading`: Loading state indicator
- `_selectedRole`: Selected role filter
- `_selectedStatus`: Selected status filter

### Data Flow
1. `_loadUsers()` - Loads all users from AdminService
2. `_applyFilters()` - Applies all active filters to `_allUsers`
3. UI rebuilds with `_filteredUsers`

## Error Handling

All operations include:
- Try-catch blocks for error handling
- User-friendly error messages via SnackBar
- Mounted checks before setState calls
- Loading states during async operations

## Email Verification Badge

Users with verified email addresses show a verification badge:
- ✓ Verified: Green badge
- ✗ Unverified: Yellow badge

## Future Enhancements

### Planned Features
- [ ] Bulk operations (suspend, delete multiple users)
- [ ] User activity logs
- [ ] Export users list to CSV/PDF
- [ ] Role change history tracking
- [ ] User authentication analytics
- [ ] Session management (force logout)
- [ ] Email verification status management
- [ ] User registration approval workflow
- [ ] Two-factor authentication management
- [ ] Advanced user search and filtering
- [ ] User activity reporting

### Performance Improvements
- [ ] Implement pagination for large datasets
- [ ] Add caching mechanism
- [ ] Optimize Firestore queries with indexes
- [ ] Lazy loading for user cards

## Dependencies

```yaml
# Core dependencies used
flutter:
  widgets: Material, Scaffold, Dialog, etc.

firebase:
  - cloud_firestore
  - firebase_auth

Admin Service:
  - AdminService (custom)
  - AdminUserModel
  - UserHelper
  - UserWidgets
```

## File Structure

```
lib/features/admin/
├── data/models/
│   └── admin_user_model.dart
├── domain/entities/
│   └── admin_user_entity.dart
├── presentation/
│   ├── pages/
│   │   └── user_management/
│   │       └── user_management_page.dart
│   ├── utils/
│   │   └── user_helper.dart
│   └── widgets/
│       └── user_widgets.dart
```

## Testing Recommendations

### Unit Tests
- Test search and filter logic
- Test date formatting utilities
- Test statistics calculations
- Test role and status color mappings

### Integration Tests
- Test AdminService integration
- Test dialog interactions
- Test data persistence
- Test user updates

### UI Tests
- Test responsive layout
- Test button interactions
- Test error handling UI
- Test filter combinations

## Troubleshooting

### Common Issues

**Issue**: "No users found"
- *Solution*: Ensure Firestore has user data, check `users` collection exists

**Issue**: Updates not reflecting immediately
- *Solution*: Data refreshes on screen reload, consider adding `_loadUsers()` after updates

**Issue**: Search results empty
- *Solution*: Verify search text matches user data exactly, search is case-insensitive for names

**Issue**: Filters not working
- *Solution*: Ensure filter values match available roles/status, check data in Firebase console

## API Reference

### AdminService Methods Used

```dart
// Get all users with pagination
Future<List<AdminUserModel>> getAllUsers({
  int limit = 10,
  DocumentSnapshot? startAfter,
});

// Get user by UID
Future<AdminUserModel?> getUserByUid(String uid);

// Update user information
Future<void> updateUser(String uid, Map<String, dynamic> data);

// Search users by email
Future<List<AdminUserModel>> searchUsersByEmail(String email);

// Suspend user
Future<void> suspendUser(String uid);

// Reactivate user
Future<void> reactivateUser(String uid);
```

## Support

For issues or feature requests, please refer to the main ResQnow Admin Dashboard documentation.
