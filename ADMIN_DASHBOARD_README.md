# ResQnow Admin Dashboard - Setup & Implementation Guide

## Overview

This is the admin dashboard for the ResQnow application. It provides administrators with tools to manage users, blood donors, medical content, emergency numbers, and home page configuration.

## Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   ├── admin_constants.dart      # Enums and constants
│   │   └── admin_routes.dart         # Route definitions
│   └── services/
│       └── admin_service.dart        # Core Firestore service
│
├── features/
│   └── admin/
│       ├── data/
│       │   ├── datasources/
│       │   │   └── remote/          # Firebase data sources
│       │   ├── models/
│       │   │   ├── admin_user_model.dart
│       │   │   ├── blood_donor_model.dart
│       │   │   └── resource_models.dart
│       │   └── repositories/        # Repository implementations
│       │
│       ├── domain/
│       │   ├── entities/            # Domain entities
│       │   ├── repositories/        # Abstract repositories
│       │   └── usecases/            # Business logic use cases
│       │
│       └── presentation/
│           ├── controllers/         # State management
│           ├── pages/              # Main pages
│           │   ├── admin_dashboard_page.dart
│           │   ├── user_management/
│           │   ├── blood_donor_management/
│           │   ├── category_management/
│           │   ├── emergency_numbers_management/
│           │   ├── resources_management/
│           │   ├── conditions_management/
│           │   └── home_config_management/
│           └── widgets/            # Reusable widgets
```

## Implemented Admin Modules

### 1. **Admin Dashboard** (Main Page)

- **File**: `features/admin/presentation/pages/admin_dashboard_page.dart`
- **Features**:
  - Grid view of all admin modules
  - Quick navigation to each feature
  - Module descriptions and icons

### 2. **User Management**

- **File**: `features/admin/presentation/pages/user_management/user_management_page.dart`
- **Features**:
  - View all registered users
  - Search users by email
  - Filter by role and status
  - Suspend/Unsuspend accounts
  - Delete user accounts
  - Edit user information
  - Change user roles

### 3. **Blood Donor Management**

- **File**: `features/admin/presentation/pages/blood_donor_management/blood_donor_management_page.dart`
- **Features**:
  - View all blood donors
  - Search by name/email
  - Filter by blood group
  - Filter by location (district, town)
  - Suspend/Reactivate donors
  - Delete donor profiles
  - Edit donor information
  - Track donor availability

### 4. **Category Management**

- **File**: `features/admin/presentation/pages/category_management/category_management_page.dart`
- **Features**:
  - View all condition categories
  - Create new categories
  - Edit category information
  - Reorder categories (drag & drop)
  - Toggle visibility
  - Delete categories

### 5. **Emergency Numbers Management**

- **File**: `features/admin/presentation/pages/emergency_numbers_management/emergency_numbers_management_page.dart`
- **Features**:
  - View all emergency numbers
  - Create emergency contacts
  - Edit service details
  - Set priority ordering
  - Activate/Deactivate services
  - Delete emergency numbers

### 6. **First Aid Resources Management**

- **File**: `features/admin/presentation/pages/resources_management/resources_management_page.dart`
- **Features**:
  - View all first aid resources
  - Create new resources
  - Edit resource content
  - Toggle featured status
  - View associated tags and categories
  - Delete resources

### 7. **Medical Conditions Management**

- **File**: `features/admin/presentation/pages/conditions_management/conditions_management_page.dart`
- **Features**:
  - View all medical conditions
  - Create new conditions
  - Edit condition information
  - Filter by severity
  - View first aid steps
  - Delete conditions

### 8. **Home Page Configuration**

- **File**: `features/admin/presentation/pages/home_config_management/home_config_management_page.dart`
- **Features**:
  - Manage section visibility
  - Reorder home page sections
  - Configure featured content
  - Control section display count

## Core Services & Models

### AdminService (`core/services/admin_service.dart`)

Central service for all Firestore operations:

```dart
// User operations
getAllUsers()
searchUsersByEmail()
getUserByUid()
updateUser()
suspendUser()
reactivateUser()

// Blood donor operations
getAllBloodDonors()
searchDonorsByBloodGroup()
filterDonorsByLocation()
updateBloodDonor()

// Category operations
getAllCategories()
createCategory()
updateCategory()
deleteCategory()

// Emergency numbers operations
getAllEmergencyNumbers()
createEmergencyNumber()
updateEmergencyNumber()
deleteEmergencyNumber()

// Resources operations
getAllResources()
createResource()
updateResource()

// Conditions operations
getAllConditions()
createCondition()
updateCondition()
```

### Models

- **AdminUserModel**: User data transfer object
- **BloodDonorModel**: Blood donor data transfer object
- **CategoryModel**: Category data transfer object
- **EmergencyNumberModel**: Emergency number data transfer object
- **ResourceModel**: First aid resource data transfer object
- **ConditionModel**: Medical condition data transfer object

### Constants (`core/constants/admin_constants.dart`)

- Enums: UserRole, AccountStatus, DonorStatus, etc.
- Blood groups list
- Medical conditions list
- Emergency service categories
- Validation rules and default values

## Implementation Checklist

### Phase 1: Core Setup ✅

- [x] Project structure created
- [x] Firebase initialized
- [x] Core services created
- [x] Models and entities defined
- [x] Routes configured

### Phase 2: Basic UI ✅

- [x] Admin dashboard main page
- [x] Navigation structure
- [x] Basic page layouts for all modules
- [x] List views and filtering UI

### Phase 3: Firestore Integration (TODO)

- [ ] Implement AdminService methods with actual Firestore queries
- [ ] Connect models to Firebase collections
- [ ] Implement error handling and validation
- [ ] Add pagination support
- [ ] Implement real-time updates with StreamBuilder

### Phase 4: Advanced Features (TODO)

- [ ] Create edit/create forms for each module
- [ ] Implement image upload functionality
- [ ] Add date picker for conditions
- [ ] Implement search suggestions
- [ ] Add bulk operations
- [ ] Create analytics dashboard

### Phase 5: State Management (TODO)

- [ ] Integrate Provider or Riverpod for state management
- [ ] Create controllers for each feature
- [ ] Implement loading and error states
- [ ] Add success/failure notifications

### Phase 6: Testing & Polish (TODO)

- [ ] Unit tests for services
- [ ] Widget tests for pages
- [ ] Integration tests
- [ ] Performance optimization
- [ ] Accessibility improvements

## Getting Started

### 1. Install Dependencies

Add required packages to `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^3.3.0
  cloud_firestore: ^latest
  firebase_auth: ^latest
  # For state management (recommended):
  provider: ^latest
  # OR
  riverpod: ^latest
```

### 2. Run the App

```bash
flutter pub get
flutter run
```

### 3. Test Admin Functions

- Navigate to each admin module using the dashboard
- Verify page structure and navigation
- Check Firebase connection in Firestore console

### 4. Implement Firestore Methods

Each page has TODO comments indicating where to:

- Fetch data from AdminService
- Implement CRUD operations
- Handle loading/error states

## Firestore Schema Expected

```
users/
  {uid}/
    name, email, role, accountStatus, createdAt, etc.

blood_donors/
  {uid}/
    name, email, phone, bloodGroup, district, town, etc.

categories/
  {categoryId}/
    name, iconPath, displayOrder, isVisible, createdAt, etc.

emergency_numbers/
  {numberId}/
    serviceName, phoneNumber, category, priority, isActive, etc.

resources/
  {resourceId}/
    name, description, categories, tags, imageUrls, etc.

conditions/
  {conditionId}/
    name, severity, imageUrls, firstAidSteps, doctorTypes, etc.
```

## Next Steps

1. **Implement Controllers**: Create Provider/Riverpod controllers for state management
2. **Add Edit Forms**: Create dedicated edit/create pages for each resource
3. **Image Upload**: Implement Firebase Storage integration
4. **Validation**: Add input validation and error handling
5. **Testing**: Write unit and widget tests
6. **Authentication**: Add admin-only authentication layer
7. **Audit Logging**: Track all admin actions
8. **Analytics**: Add admin dashboard analytics

## Key Files to Modify

1. `core/services/admin_service.dart` - Implement Firestore methods
2. Individual page files - Add controllers and implement business logic
3. `pubspec.yaml` - Add required dependencies
4. Firestore Rules - Set appropriate security rules for admin access

## Security Considerations

- Implement Firebase Authentication checks
- Set Firestore security rules to allow only admin access
- Add audit logging for sensitive operations
- Implement role-based access control
- Validate all inputs on backend

## Support & Documentation

For detailed feature documentation, see:

- `ADMIN_FUNCTIONALITIES.md` - Authentication module features
- `BLOOD_DONORS_README.md` - Blood donor management features
- `CATEGORY_ADMIN_README.md` - Category management features
- `EMERGENCY_NUMBERS_ADMIN_README.md` - Emergency numbers features
- And other feature-specific documentation files

---

**Status**: Initial setup complete - Ready for Firestore integration

**Last Updated**: February 17, 2026
