import 'package:flutter/material.dart';
import 'package:resqnow_admin/features/admin/data/models/admin_user_model.dart';
import 'package:resqnow_admin/core/services/admin_service.dart';
import 'package:resqnow_admin/features/admin/presentation/utils/user_helper.dart';
import 'package:resqnow_admin/features/admin/presentation/widgets/user_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// User Management Page
class UserManagementPage extends StatefulWidget {
  const UserManagementPage({Key? key}) : super(key: key);

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  late AdminService _adminService;
  final TextEditingController _searchController = TextEditingController();
  String _selectedRole = '';
  String _selectedStatus = '';
  List<AdminUserModel> _allUsers = [];
  List<AdminUserModel> _filteredUsers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _adminService = AdminService(
      firestore: FirebaseFirestore.instance,
      auth: FirebaseAuth.instance,
    );
    _loadUsers();
    _searchController.addListener(_applyFilters);
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await _adminService.getAllUsers(limit: 100);
      setState(() {
        _allUsers = users;
        _filteredUsers = users;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading users: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredUsers = _allUsers.where((user) {
        // Search filter
        final searchQuery = _searchController.text.toLowerCase();
        final matchesSearch = searchQuery.isEmpty ||
            user.name.toLowerCase().contains(searchQuery) ||
            user.email.toLowerCase().contains(searchQuery);

        // Role filter
        final matchesRole =
            _selectedRole.isEmpty || user.role == _selectedRole;

        // Status filter
        final matchesStatus =
            _selectedStatus.isEmpty || user.accountStatus == _selectedStatus;

        return matchesSearch && matchesRole && matchesStatus;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 4,
      ),
      body: Column(
        children: [
          // Filter Bar
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name or email...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Filters Row
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedRole.isEmpty ? null : _selectedRole,
                        decoration: InputDecoration(
                          labelText: 'Role',
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: ['', 'admin', 'support', 'moderator', 'user']
                            .map(
                              (role) => DropdownMenuItem(
                                value: role,
                                child: Text(
                                  role.isEmpty ? 'All Roles' : role,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() => _selectedRole = value ?? '');
                          _applyFilters();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedStatus.isEmpty ? null : _selectedStatus,
                        decoration: InputDecoration(
                          labelText: 'Status',
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: ['', 'active', 'suspended', 'pending']
                            .map(
                              (status) => DropdownMenuItem(
                                value: status,
                                child: Text(
                                  status.isEmpty ? 'All Status' : status,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() => _selectedStatus = value ?? '');
                          _applyFilters();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _selectedRole = '';
                          _selectedStatus = '';
                        });
                        _applyFilters();
                      },
                      icon: const Icon(Icons.clear),
                      label: const Text('Clear'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Stats Bar
          UserStatsWidget(users: _filteredUsers),
          // User List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredUsers.isEmpty
                    ? const EmptyUserListWidget()
                    : ListView.builder(
                        itemCount: _filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = _filteredUsers[index];
                          return _buildUserTile(user);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTile(AdminUserModel user) {
    return UserCard(
      user: user,
      onTap: () => _showUserDetailsDialog(user),
      onActionSelected: (action) => _handleUserAction(user, action),
    );
  }

  void _handleUserAction(AdminUserModel user, String action) {
    switch (action) {
      case 'view':
        _showUserDetailsDialog(user);
        break;
      case 'edit':
        _showEditUserDialog(user);
        break;
      case 'suspend':
        _showSuspendDialog(user);
        break;
      case 'reactivate':
        _reactivateUser(user);
        break;
      case 'delete':
        _showDeleteDialog(user);
        break;
    }
  }

  void _showUserDetailsDialog(AdminUserModel user) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'User Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: user.profileImage != null
                            ? NetworkImage(user.profileImage!)
                            : null,
                        backgroundColor: Colors.blue[100],
                        child: user.profileImage == null
                            ? const Icon(Icons.person, size: 50)
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          UserHelper.getRoleBadge(user.role),
                          const SizedBox(width: 8),
                          UserHelper.getStatusBadge(user),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildDetailRow('Email:', user.email),
                _buildDetailRow('Role:', UserHelper.getRoleDisplayName(user.role)),
                _buildDetailRow('Status:', user.accountStatus),
                _buildDetailRow('Account Created:', UserHelper.formatDate(user.createdAt)),
                if (user.lastLogin != null)
                  _buildDetailRow(
                    'Last Login:',
                    UserHelper.formatDateTime(user.lastLogin!),
                  ),
                _buildDetailRow(
                  'Email Verified:',
                  user.emailVerified ? '✓ Yes' : '✗ No',
                ),
                if (user.accountStatus != 'active')
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.yellow.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.yellow.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning, color: Colors.yellow.shade700),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Status: ${user.accountStatus}',
                                style: TextStyle(
                                  color: Colors.yellow.shade900,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _showEditUserDialog(AdminUserModel user) {
    final nameController = TextEditingController(text: user.name);
    String selectedRole = user.role;
    String selectedStatus = user.accountStatus;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: StatefulBuilder(
              builder: (context, setState) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Edit User',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'Role',
                      border: OutlineInputBorder(),
                    ),
                    items: ['admin', 'support', 'moderator', 'user']
                        .map(
                          (role) => DropdownMenuItem(
                            value: role,
                            child: Text(UserHelper.getRoleDisplayName(role)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => selectedRole = value ?? user.role);
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items: ['active', 'suspended', 'pending']
                        .map(
                          (status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => selectedStatus = value ?? user.accountStatus);
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          _updateUser(
                            user,
                            nameController.text,
                            selectedRole,
                            selectedStatus,
                          );
                          Navigator.pop(context);
                        },
                        child: const Text('Save Changes'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSuspendDialog(AdminUserModel user) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Suspend User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to suspend ${user.name}?'),
            const SizedBox(height: 16),
            const Text(
              'Reason for suspension:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Enter reason...',
                border: OutlineInputBorder(),
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
            onPressed: () {
              _suspendUser(user);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text(
              'Suspend',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _suspendUser(AdminUserModel user) async {
    try {
      await _adminService.updateUser(user.uid, {'accountStatus': 'suspended'});
      _loadUsers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${user.name} has been suspended'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error suspending user: $e')),
        );
      }
    }
  }

  Future<void> _reactivateUser(AdminUserModel user) async {
    try {
      await _adminService.updateUser(user.uid, {'accountStatus': 'active'});
      _loadUsers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${user.name} has been reactivated'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error reactivating user: $e')),
        );
      }
    }
  }

  void _showDeleteDialog(AdminUserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete ${user.name}?',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'This action cannot be undone. All user data will be permanently deleted.',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteUser(user);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteUser(AdminUserModel user) async {
    try {
      await _adminService.deleteUser(user.uid);
      _loadUsers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${user.name} has been deleted'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting user: $e')),
        );
      }
    }
  }

  Future<void> _updateUser(
    AdminUserModel user,
    String name,
    String role,
    String status,
  ) async {
    try {
      await _adminService.updateUser(user.uid, {
        'name': name,
        'role': role,
        'accountStatus': status,
      });
      _loadUsers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating user: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyFilters);
    _searchController.dispose();
    super.dispose();
  }
}
