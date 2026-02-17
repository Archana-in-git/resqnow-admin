# Admin Dashboard Implementation Guide

## Quick Start for Developers

This guide helps developers complete the admin dashboard implementation.

## File Organization Summary

### Created Directories

```
lib/
├── core/constants/         ✅ admin_constants.dart, admin_routes.dart
├── core/services/          ✅ admin_service.dart
├── features/admin/
│   ├── data/
│   │   ├── datasources/
│   │   │   └── remote/     (ready for Firestore datasource)
│   │   ├── models/         ✅ All model files created
│   │   └── repositories/   (ready for repository implementations)
│   ├── domain/
│   │   ├── entities/       ✅ All entity files created
│   │   ├── repositories/   (ready for abstract repositories)
│   │   └── usecases/       (ready for use case implementations)
│   └── presentation/
│       ├── controllers/    (ready for state management)
│       ├── pages/          ✅ All main pages created
│       └── widgets/        (ready for reusable widgets)
```

## Created Files Summary

### ✅ Completed (27 files)

**Constants & Routes:**

- `lib/core/constants/admin_routes.dart`
- `lib/core/constants/admin_constants.dart`

**Services:**

- `lib/core/services/admin_service.dart`

**Entities:**

- `lib/features/admin/domain/entities/admin_user_entity.dart`
- `lib/features/admin/domain/entities/blood_donor_entity.dart`
- `lib/features/admin/domain/entities/resource_entities.dart`

**Models:**

- `lib/features/admin/data/models/admin_user_model.dart`
- `lib/features/admin/data/models/blood_donor_model.dart`
- `lib/features/admin/data/models/resource_models.dart`

**Pages:**

- `lib/features/admin/presentation/pages/admin_dashboard_page.dart`
- `lib/features/admin/presentation/pages/user_management/user_management_page.dart`
- `lib/features/admin/presentation/pages/blood_donor_management/blood_donor_management_page.dart`
- `lib/features/admin/presentation/pages/category_management/category_management_page.dart`
- `lib/features/admin/presentation/pages/emergency_numbers_management/emergency_numbers_management_page.dart`
- `lib/features/admin/presentation/pages/resources_management/resources_management_page.dart`
- `lib/features/admin/presentation/pages/conditions_management/conditions_management_page.dart`
- `lib/features/admin/presentation/pages/home_config_management/home_config_management_page.dart`

**Configuration:**

- `lib/main.dart` (updated with admin routes)
- `ADMIN_DASHBOARD_README.md`

## What's Ready to Use

### 1. Models & Entities (Ready)

- All data models with `toJson()` and `fromJson()` methods
- All Domain entities with Equatable support
- Sample conversion methods

### 2. AdminService (Partial)

- Method signatures defined
- Basic Firestore query structure
- Need to test with actual Firestore connection

### 3. Page Layouts (UI Complete)

- All pages have proper UI structure
- Navigation and menu items defined
- List tiles and cards created
- Dialog templates for confirmation

### 4. Routing (Complete)

- All routes defined in `AdminRoutes`
- Routes configured in main.dart
- Ready for navigation

## Next Steps - TODO Implementation

### Priority 1: Connect Services (High)

**File:** `core/services/admin_service.dart`

1. **Test Firestore Connection**

   ```dart
   // Add connection test
   Future<bool> testConnection() async {
     try {
       final doc = await firestore.collection('test').doc('test').get();
       return true;
     } catch (e) {
       print('Connection error: $e');
       return false;
     }
   }
   ```

2. **Verify Collection Names** in Firestore
   - users
   - blood_donors
   - categories
   - emergency_numbers
   - resources
   - conditions

### Priority 2: Implement Page Data Loading

**Example for User Management Page:**

```dart
// In _UserManagementPageState

Future<void> _loadUsers() async {
  setState(() => _isLoading = true);
  try {
    final adminService = AdminService(
      firestore: FirebaseFirestore.instance,
      auth: FirebaseAuth.instance,
    );

    final users = await adminService.getAllUsers();
    setState(() => _users = users);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  } finally {
    setState(() => _isLoading = false);
  }
}

Future<void> _handleSearch(String query) async {
  if (query.isEmpty) {
    _loadUsers();
    return;
  }

  try {
    final adminService = AdminService(
      firestore: FirebaseFirestore.instance,
      auth: FirebaseAuth.instance,
    );

    final users = await adminService.searchUsersByEmail(query);
    setState(() => _users = users);
  } catch (e) {
    // Handle error
  }
}
```

### Priority 3: Add State Management

Choose one approach:

**Option A: Provider (Recommended)**

```dart
// Create provider
final userProvider = FutureProvider<List<AdminUserModel>>((ref) async {
  final service = ref.watch(adminServiceProvider);
  return service.getAllUsers();
});

// Use in page
@override
Widget build(BuildContext context, WidgetRef ref) {
  final usersAsyncValue = ref.watch(userProvider);

  return usersAsyncValue.when(
    data: (users) => _buildUserList(users),
    loading: () => const CircularProgressIndicator(),
    error: (err, stack) => Text('Error: $err'),
  );
}
```

**Option B: GetX**

```dart
class UserController extends GetxController {
  final RxList<AdminUserModel> users = <AdminUserModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    loadUsers();
    super.onInit();
  }

  loadUsers() async {
    isLoading.value = true;
    try {
      users.value = await adminService.getAllUsers();
    } finally {
      isLoading.value = false;
    }
  }
}
```

### Priority 4: Implement CRUD Operations

Example - Suspending a User:

```dart
Future<void> _suspendUser(AdminUserModel user, String reason) async {
  try {
    final adminService = AdminService(
      firestore: FirebaseFirestore.instance,
      auth: FirebaseAuth.instance,
    );

    await adminService.suspendUser(user.uid, reason);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User suspended successfully')),
    );

    _loadUsers(); // Refresh list
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}
```

### Priority 5: Add Form Pages

Create edit/create forms for each resource:

```dart
// lib/features/admin/presentation/pages/user_management/edit_user_page.dart

class EditUserPage extends StatefulWidget {
  final AdminUserModel user;

  const EditUserPage({required this.user});

  @override
  State<EditUserPage> createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  String _selectedRole = 'user';

  @override
  void initState() {
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _selectedRole = widget.user.role;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit User')),
      body: Form(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedRole,
              decoration: const InputDecoration(labelText: 'Role'),
              items: ['admin', 'user', 'support', 'moderator']
                  .map((role) => DropdownMenuItem(
                    value: role,
                    child: Text(role),
                  ))
                  .toList(),
              onChanged: (value) => setState(() => _selectedRole = value ?? 'user'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveChanges,
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveChanges() async {
    try {
      final adminService = AdminService(
        firestore: FirebaseFirestore.instance,
        auth: FirebaseAuth.instance,
      );

      await adminService.updateUser(widget.user.uid, {
        'name': _nameController.text,
        'role': _selectedRole,
      });

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
```

## Dependencies to Add

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^3.3.0
  cloud_firestore: ^4.14.0
  firebase_auth: ^4.15.0

  # State Management (choose one)
  provider: ^6.1.0
  # OR
  riverpod: ^2.4.0
  # OR
  get: ^4.6.0

  # UI/UX
  google_fonts: ^6.0.0
  lottie: ^2.7.0

  # Utilities
  intl: ^0.19.0
  uuid: ^4.0.0
```

## Testing the Setup

1. **Run the app**

   ```bash
   flutter pub get
   flutter run
   ```

2. **Verify Firebase connection**

   - Check Firestore console
   - Verify collections exist
   - Check security rules allow admin access

3. **Test navigation**
   - Click dashboard tiles
   - Verify page navigation works
   - Check error handling

## Common Issues & Solutions

### Issue: "Target of URI doesn't exist"

- Run `flutter pub get`
- Verify import paths match file locations
- Check for typos in imports

### Issue: Firestore queries return empty

- Verify collection names match Firestore
- Check security rules allow read access
- Verify data exists in collections

### Issue: Navigation not working

- Check route names in `AdminRoutes`
- Verify all routes are registered in `main.dart`
- Check page imports are correct

## Performance Tips

1. Use pagination for large lists (implemented in AdminService)
2. Add caching layer for frequently accessed data
3. Use StreamBuilder for real-time updates
4. Implement proper error boundaries
5. Add loading skeletons instead of spinners

---

**Ready to implement?** Start with Priority 1 above!
