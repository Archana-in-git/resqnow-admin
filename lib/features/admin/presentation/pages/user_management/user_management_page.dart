import 'package:flutter/material.dart';
import 'dart:async';
import 'package:resqnow_admin/features/admin/data/models/admin_user_model.dart';
import 'package:resqnow_admin/core/services/admin_service.dart';
import 'package:resqnow_admin/features/admin/presentation/utils/user_helper.dart';
import 'package:resqnow_admin/features/admin/presentation/widgets/user_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// User Management Page
class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

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
  final int _pageSize = 50; // Load 50 users at a time instead of 100
  int _loadedCount = 50;

  // Debounce timer for search
  Future<void>? _filterDebounceTimer;

  @override
  void initState() {
    super.initState();
    _adminService = AdminService(
      firestore: FirebaseFirestore.instance,
      auth: FirebaseAuth.instance,
    );
    _loadUsers();
    // Use debounced filter for search to avoid excessive filtering
    _searchController.addListener(_applyFiltersDebounced);
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await _adminService.getAllUsers(limit: _loadedCount);
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

  /// Load more users for pagination
  Future<void> _loadMoreUsers() async {
    setState(() => _isLoading = true);
    try {
      _loadedCount += _pageSize;
      final users = await _adminService.getAllUsers(limit: _loadedCount);
      setState(() {
        _allUsers = users;
      });
      _applyFilters();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading more users: $e'),
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

        // Status filter - also check isBlocked for suspended users
        bool matchesStatus;
        if (_selectedStatus.isEmpty) {
          matchesStatus = true;
        } else if (_selectedStatus == 'suspended') {
          // Show users where accountStatus is 'suspended' OR isBlocked is true
          matchesStatus = user.accountStatus == 'suspended' || user.isBlocked;
        } else {
          matchesStatus = user.accountStatus == _selectedStatus;
        }

        return matchesSearch && matchesRole && matchesStatus;
      }).toList();
    });
  }

  /// Debounced filter for search input (300ms delay)
  void _applyFiltersDebounced() {
    // Cancel previous timer
    _filterDebounceTimer?.ignore();

    // Debounce with 300ms delay
    _filterDebounceTimer = Future.delayed(
      const Duration(milliseconds: 300),
      () {
        if (mounted) {
          _applyFilters();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: UserManagementColors.textPrimary,
            size: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'User Management',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 22,
            color: UserManagementColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Content with modern filters
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Filter Section
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(color: Colors.grey[200]!, width: 1),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Search Bar
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.black, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search by name, email...',
                              hintStyle: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                              ),
                              prefixIcon: Padding(
                                padding: const EdgeInsets.only(
                                  left: 20,
                                  right: 12,
                                ),
                                child: Icon(
                                  Icons.search_rounded,
                                  color: Colors.grey[400],
                                  size: 24,
                                ),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 18,
                              ),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? GestureDetector(
                                      onTap: () {
                                        _searchController.clear();
                                        FocusScope.of(context).unfocus();
                                        _applyFilters();
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          right: 16,
                                        ),
                                        child: Icon(
                                          Icons.close_rounded,
                                          color: Colors.grey[400],
                                          size: 20,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Filter chips
                        Row(
                          children: [
                            Expanded(
                              child: _buildFilterDropdown(
                                label: 'Role',
                                value: _selectedRole.isEmpty
                                    ? null
                                    : _selectedRole,
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
                                value: _selectedStatus.isEmpty
                                    ? null
                                    : _selectedStatus,
                                items: [
                                  ('', 'All Status'),
                                  ('active', 'Active'),
                                  ('suspended', 'Suspended'),
                                ],
                                onChanged: (value) {
                                  setState(() => _selectedStatus = value ?? '');
                                  _applyFilters();
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _searchController.clear();
                                  _selectedRole = '';
                                  _selectedStatus = '';
                                });
                                _applyFilters();
                              },
                              child: Container(
                                height: 56,
                                width: 56,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.06,
                                      ),
                                      blurRadius: 12,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.refresh_rounded,
                                  color: UserManagementColors.primaryTeal,
                                  size: 24,
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
                  _isLoading && _filteredUsers.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(40),
                          child: CircularProgressIndicator(
                            color: UserManagementColors.primaryTeal,
                          ),
                        )
                      : _filteredUsers.isEmpty
                      ? const EmptyUserListWidget()
                      : Container(
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28,
                              vertical: 24,
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount:
                                  _filteredUsers.length +
                                  (_loadedCount < _allUsers.length ? 1 : 0),
                              itemBuilder: (context, index) {
                                // Show load more button at the end
                                if (index == _filteredUsers.length) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 20,
                                    ),
                                    child: Center(
                                      child: _isLoading
                                          ? const SizedBox(
                                              height: 40,
                                              width: 40,
                                              child: CircularProgressIndicator(
                                                color: UserManagementColors
                                                    .primaryTeal,
                                              ),
                                            )
                                          : ElevatedButton(
                                              onPressed: _loadMoreUsers,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    UserManagementColors
                                                        .primaryTeal,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 32,
                                                      vertical: 12,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              child: const Text(
                                                'Load More',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                    ),
                                  );
                                }

                                final user = _filteredUsers[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: _buildUserTile(user),
                                );
                              },
                            ),
                          ),
                        ),
                ],
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
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey[500],
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 14,
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
                    fontSize: 14,
                    color: UserManagementColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: UserManagementColors.primaryTeal,
          size: 24,
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
    }
  }

  void _showUserDetailsDialog(AdminUserModel user) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      UserManagementColors.primaryTeal,
                      UserManagementColors.primaryDarkTeal,
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(28, 24, 28, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'User Profile',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Center(
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 52,
                              backgroundColor: Colors.white,
                              backgroundImage: user.getProxiedImageUrl() != null
                                  ? NetworkImage(user.getProxiedImageUrl()!)
                                  : null,
                              child: user.getProxiedImageUrl() == null
                                  ? const Icon(
                                      Icons.person_rounded,
                                      size: 52,
                                      color: UserManagementColors.primaryTeal,
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            user.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.2,
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
                  ],
                ),
              ),
              // Details section
              Padding(
                padding: const EdgeInsets.all(28.0),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[200]!, width: 1),
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          _buildModernDetailRow('Email', user.email),
                          const SizedBox(height: 20),
                          _buildModernDetailRow(
                            'Role',
                            UserHelper.getRoleDisplayName(user.role),
                          ),
                          const SizedBox(height: 20),
                          _buildModernDetailRow('Status', user.accountStatus),
                          const SizedBox(height: 20),
                          _buildModernDetailRow(
                            'Created',
                            UserHelper.formatDate(user.createdAt),
                          ),
                          if (user.lastLogin != null) ...[
                            const SizedBox(height: 20),
                            _buildModernDetailRow(
                              'Last Login',
                              UserHelper.formatDateTime(user.lastLogin!),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (user.accountStatus != 'active') ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              UserManagementColors.warningAmber.withValues(
                                alpha: 0.12,
                              ),
                              UserManagementColors.warningAmber.withValues(
                                alpha: 0.06,
                              ),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: UserManagementColors.warningAmber.withValues(
                              alpha: 0.3,
                            ),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: UserManagementColors.warningAmber
                                    .withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.warning_rounded,
                                color: UserManagementColors.warningAmber,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Account: ${user.accountStatus}',
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
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: const Text(
                            'Close',
                            style: TextStyle(
                              color: UserManagementColors.textSecondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: UserManagementColors.textSecondary,
              fontSize: 12,
              letterSpacing: 0.3,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: UserManagementColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  void _showEditUserDialog(AdminUserModel user) {
    final nameController = TextEditingController(text: user.name);
    String selectedRole = user.role;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      UserManagementColors.primaryTeal,
                      UserManagementColors.primaryDarkTeal,
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Edit User',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Form fields
              Padding(
                padding: const EdgeInsets.all(28.0),
                child: StatefulBuilder(
                  builder: (context, setState) => Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStyledTextField(
                        controller: nameController,
                        label: 'Full Name',
                        icon: Icons.person_rounded,
                      ),
                      const SizedBox(height: 20),
                      _buildStyledDropdown(
                        label: 'Role',
                        value: selectedRole,
                        items: ['admin', 'support', 'moderator', 'user']
                            .map(
                              (role) =>
                                  (role, UserHelper.getRoleDisplayName(role)),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() => selectedRole = value ?? user.role);
                        },
                        icon: Icons.security_rounded,
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                color: UserManagementColors.textSecondary,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
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
                              );
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: UserManagementColors.primaryTeal,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Save Changes',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 18, right: 12),
            child: Icon(
              icon,
              color: UserManagementColors.primaryTeal,
              size: 22,
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 18,
          ),
          labelStyle: TextStyle(
            color: Colors.grey[500],
            fontWeight: FontWeight.w600,
            fontSize: 13,
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
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 18, right: 12),
            child: Icon(
              icon,
              color: UserManagementColors.primaryTeal,
              size: 22,
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 18,
          ),
          labelStyle: TextStyle(
            color: Colors.grey[500],
            fontWeight: FontWeight.w600,
            fontSize: 13,
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
                    fontSize: 14,
                  ),
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: UserManagementColors.primaryTeal,
          size: 24,
        ),
      ),
    );
  }

  void _showSuspendDialog(AdminUserModel user) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 450),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          UserManagementColors.warningAmber,
                          UserManagementColors.warningAmber.withValues(
                            alpha: 0.8,
                          ),
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Suspend User',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(28.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Are you sure you want to suspend ${user.name}?',
                          style: const TextStyle(
                            color: UserManagementColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Reason for suspension',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: UserManagementColors.textSecondary,
                            fontSize: 13,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 12,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: reasonController,
                            decoration: InputDecoration(
                              hintText: 'Enter reason...',
                              hintStyle: const TextStyle(
                                color: Color(0xFFB0BEC5),
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 14,
                              ),
                            ),
                            maxLines: 3,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  color: UserManagementColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: () {
                                final reason = reasonController.text.trim();
                                _suspendUser(
                                  user,
                                  reason.isEmpty
                                      ? 'Suspended by admin for suspicious activity'
                                      : reason,
                                );
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    UserManagementColors.warningAmber,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 28,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Suspend',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _suspendUser(AdminUserModel user, String reason) async {
    try {
      await _adminService.suspendUser(user.uid, reason);
      // Update local list instead of reloading from Firestore
      setState(() {
        final index = _allUsers.indexWhere((u) => u.uid == user.uid);
        if (index != -1) {
          _allUsers[index] = _allUsers[index].copyWith(
            accountStatus: 'suspended',
            isBlocked: true,
          );
        }
      });
      _applyFilters();
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
      await _adminService.reactivateUser(user.uid);
      // Update local list instead of reloading from Firestore
      setState(() {
        final index = _allUsers.indexWhere((u) => u.uid == user.uid);
        if (index != -1) {
          _allUsers[index] = _allUsers[index].copyWith(
            accountStatus: 'active',
            isBlocked: false,
          );
        }
      });
      _applyFilters();
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

  Future<void> _updateUser(
    AdminUserModel user,
    String name,
    String role,
  ) async {
    try {
      await _adminService.updateUser(user.uid, {'name': name, 'role': role});
      // Update local list instead of reloading from Firestore
      setState(() {
        final index = _allUsers.indexWhere((u) => u.uid == user.uid);
        if (index != -1) {
          _allUsers[index] = _allUsers[index].copyWith(name: name, role: role);
        }
      });
      _applyFilters();
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
    _searchController.removeListener(_applyFiltersDebounced);
    _filterDebounceTimer?.ignore();
    _searchController.dispose();
    super.dispose();
  }
}
