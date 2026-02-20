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

// Theme colors
class UserManagementColors {
  static const Color primaryTeal = Color(0xFF00796B);
  static const Color primaryDarkTeal = Color(0xFF004D4A);
  static const Color accentRed = Color(0xFFD32F2F);
  static const Color successGreen = Color(0xFF388E3C);
  static const Color warningAmber = Color(0xFFFFA000);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color dividerColor = Color(0xFFE0E0E0);
  static const Color softBackground = Color(0xFFFAFAFA);
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
        final matchesSearch =
            searchQuery.isEmpty ||
            user.name.toLowerCase().contains(searchQuery) ||
            user.email.toLowerCase().contains(searchQuery);

        // Role filter
        final matchesRole = _selectedRole.isEmpty || user.role == _selectedRole;

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
      backgroundColor: UserManagementColors.softBackground,
      appBar: AppBar(
        title: const Text(
          'User Management',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
            letterSpacing: 0.3,
          ),
        ),
        backgroundColor: UserManagementColors.primaryTeal,
        elevation: 0,
        toolbarHeight: 80,
        centerTitle: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter Bar with elegant design
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by name or email...',
                      hintStyle: const TextStyle(
                        color: UserManagementColors.textSecondary,
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: UserManagementColors.textSecondary,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // Filters Row
                Row(
                  children: [
                    Expanded(
                      child: _buildFilterDropdown(
                        label: 'Role',
                        value: _selectedRole.isEmpty ? null : _selectedRole,
                        items: [
                          ('', 'All Roles'),
                          ('admin', 'Admin'),
                          ('support', 'Support'),
                          ('moderator', 'Moderator'),
                          ('user', 'User'),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedRole = value ?? '');
                          _applyFilters();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFilterDropdown(
                        label: 'Status',
                        value: _selectedStatus.isEmpty ? null : _selectedStatus,
                        items: [
                          ('', 'All Status'),
                          ('active', 'Active'),
                          ('suspended', 'Suspended'),
                          ('pending', 'Pending'),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedStatus = value ?? '');
                          _applyFilters();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _searchController.clear();
                              _selectedRole = '';
                              _selectedStatus = '';
                            });
                            _applyFilters();
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.clear,
                                color: UserManagementColors.textSecondary,
                                size: 20,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Clear',
                                style: TextStyle(
                                  color: UserManagementColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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
                ? const Center(
                    child: CircularProgressIndicator(
                      color: UserManagementColors.primaryTeal,
                    ),
                  )
                : _filteredUsers.isEmpty
                ? const EmptyUserListWidget()
                : Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    child: ListView.builder(
                      itemCount: _filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = _filteredUsers[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildUserTile(user),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String? value,
    required List<(String, String)> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: UserManagementColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          border: InputBorder.none,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
        ),
        items: items
            .map(
              (item) => DropdownMenuItem(
                value: item.$1,
                child: Text(
                  item.$2,
                  style: const TextStyle(
                    fontSize: 13,
                    color: UserManagementColors.textPrimary,
                  ),
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
        icon: const Icon(
          Icons.expand_more,
          color: UserManagementColors.textSecondary,
        ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(28.0),
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
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: UserManagementColors.textPrimary,
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: UserManagementColors.softBackground,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.close,
                            color: UserManagementColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              UserManagementColors.primaryTeal,
                              UserManagementColors.primaryDarkTeal,
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: UserManagementColors.primaryTeal
                                  .withOpacity(0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.transparent,
                          backgroundImage: user.profileImage != null
                              ? NetworkImage(user.profileImage!)
                              : null,
                          child: user.profileImage == null
                              ? const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: UserManagementColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          UserHelper.getRoleBadge(user.role),
                          const SizedBox(width: 10),
                          UserHelper.getStatusBadge(user),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Container(
                  decoration: BoxDecoration(
                    color: UserManagementColors.softBackground,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: UserManagementColors.dividerColor,
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildDetailRow('Email:', user.email),
                      _buildDivider(),
                      _buildDetailRow(
                        'Role:',
                        UserHelper.getRoleDisplayName(user.role),
                      ),
                      _buildDivider(),
                      _buildDetailRow('Status:', user.accountStatus),
                      _buildDivider(),
                      _buildDetailRow(
                        'Account Created:',
                        UserHelper.formatDate(user.createdAt),
                      ),
                      if (user.lastLogin != null) ...[
                        _buildDivider(),
                        _buildDetailRow(
                          'Last Login:',
                          UserHelper.formatDateTime(user.lastLogin!),
                        ),
                      ],
                      _buildDivider(),
                      _buildDetailRow(
                        'Email Verified:',
                        user.emailVerified ? '✓ Yes' : '✗ No',
                      ),
                    ],
                  ),
                ),
                if (user.accountStatus != 'active') ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: UserManagementColors.warningAmber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: UserManagementColors.warningAmber.withOpacity(
                          0.3,
                        ),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_rounded,
                          color: UserManagementColors.warningAmber,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Status: ${user.accountStatus}',
                            style: const TextStyle(
                              color: UserManagementColors.warningAmber,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'Close',
                        style: TextStyle(
                          color: UserManagementColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Divider(color: UserManagementColors.dividerColor, height: 1),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: UserManagementColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: UserManagementColors.textPrimary,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(28.0),
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
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: UserManagementColors.textPrimary,
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: UserManagementColors.softBackground,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.close,
                              color: UserManagementColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildStyledTextField(
                    controller: nameController,
                    label: 'Name',
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 16),
                  _buildStyledDropdown(
                    label: 'Role',
                    value: selectedRole,
                    items: ['admin', 'support', 'moderator', 'user']
                        .map(
                          (role) => (role, UserHelper.getRoleDisplayName(role)),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => selectedRole = value ?? user.role);
                    },
                    icon: Icons.security,
                  ),
                  const SizedBox(height: 16),
                  _buildStyledDropdown(
                    label: 'Status',
                    value: selectedStatus,
                    items: [
                      'active',
                      'suspended',
                      'pending',
                    ].map((status) => (status, status.toUpperCase())).toList(),
                    onChanged: (value) {
                      setState(
                        () => selectedStatus = value ?? user.accountStatus,
                      );
                    },
                    icon: Icons.assignment_turned_in,
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: UserManagementColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: UserManagementColors.primaryTeal,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Save Changes',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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

  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: UserManagementColors.primaryTeal),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          labelStyle: const TextStyle(
            color: UserManagementColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildStyledDropdown({
    required String label,
    required String value,
    required List<(String, String)> items,
    required Function(String?) onChanged,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: UserManagementColors.primaryTeal),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          labelStyle: const TextStyle(
            color: UserManagementColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        items: items
            .map(
              (item) => DropdownMenuItem(
                value: item.$1,
                child: Text(
                  item.$2,
                  style: const TextStyle(
                    color: UserManagementColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
        icon: const Icon(
          Icons.expand_more,
          color: UserManagementColors.textSecondary,
        ),
      ),
    );
  }

  void _showSuspendDialog(AdminUserModel user) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: UserManagementColors.warningAmber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.warning_rounded,
                color: UserManagementColors.warningAmber,
                size: 26,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Suspend User',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: UserManagementColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to suspend ${user.name}?',
              style: const TextStyle(
                color: UserManagementColors.textPrimary,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Reason for suspension (optional):',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: UserManagementColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: UserManagementColors.softBackground,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: UserManagementColors.dividerColor,
                  width: 1,
                ),
              ),
              child: TextField(
                controller: reasonController,
                decoration: InputDecoration(
                  hintText: 'Enter reason...',
                  hintStyle: const TextStyle(
                    color: UserManagementColors.textSecondary,
                    fontSize: 13,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
                maxLines: 3,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: UserManagementColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _suspendUser(user);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: UserManagementColors.warningAmber,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Suspend',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error suspending user: $e')));
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error reactivating user: $e')));
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting user: $e')));
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating user: $e')));
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
