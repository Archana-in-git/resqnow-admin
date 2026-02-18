import 'package:flutter/material.dart';
import 'package:resqnow_admin/features/admin/data/models/admin_user_model.dart';
import 'package:resqnow_admin/features/admin/presentation/utils/user_helper.dart';

/// Reusable User Card Widget
class UserCard extends StatelessWidget {
  final AdminUserModel user;
  final VoidCallback onTap;
  final Function(String) onActionSelected;

  const UserCard({
    Key? key,
    required this.user,
    required this.onTap,
    required this.onActionSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 28,
          backgroundImage: user.profileImage != null
              ? NetworkImage(user.profileImage!)
              : null,
          backgroundColor: Colors.blue[100],
          child: user.profileImage == null
              ? const Icon(Icons.person, size: 28)
              : null,
        ),
        title: _buildTitle(),
        subtitle: _buildSubtitle(),
        trailing: _buildActionMenu(),
        onTap: onTap,
      ),
    );
  }

  Widget _buildTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user.email,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        UserHelper.getRoleBadge(user.role),
      ],
    );
  }

  Widget _buildSubtitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            UserHelper.getStatusBadge(user),
            const SizedBox(width: 8),
            UserHelper.getVerificationBadge(user.emailVerified),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Joined: ${UserHelper.formatDate(user.createdAt)}',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[700],
          ),
        ),
        if (user.lastLogin != null)
          Text(
            'Last login: ${UserHelper.getLastLoginText(user.lastLogin)}',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
      ],
    );
  }

  Widget _buildActionMenu() {
    return PopupMenuButton(
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'view', child: Text('View Details')),
        const PopupMenuItem(value: 'edit', child: Text('Edit')),
        PopupMenuItem(
          value: user.accountStatus == 'suspended' ? 'reactivate' : 'suspend',
          child: Text(user.accountStatus == 'suspended' ? 'Reactivate' : 'Suspend'),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Text(
            'Delete',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
      onSelected: (value) => onActionSelected(value),
    );
  }
}

/// User Statistics Widget
class UserStatsWidget extends StatelessWidget {
  final List<AdminUserModel> users;

  const UserStatsWidget({Key? key, required this.users}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stats = UserHelper.getStatistics(users);

    return Container(
      color: Colors.blue.shade50,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildStatCard(
              label: 'Total Users',
              value: stats['total']!.toString(),
              icon: Icons.people,
              color: Colors.blue,
            ),
            const SizedBox(width: 16),
            _buildStatCard(
              label: 'Active',
              value: stats['active']!.toString(),
              icon: Icons.check_circle,
              color: Colors.green,
            ),
            const SizedBox(width: 16),
            _buildStatCard(
              label: 'Suspended',
              value: stats['suspended']!.toString(),
              icon: Icons.block,
              color: Colors.red,
            ),
            const SizedBox(width: 16),
            _buildStatCard(
              label: 'Admins',
              value: stats['admin']!.toString(),
              icon: Icons.admin_panel_settings,
              color: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

/// Role Statistics Widget
class RoleStatsWidget extends StatelessWidget {
  final List<AdminUserModel> users;

  const RoleStatsWidget({Key? key, required this.users}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stats = UserHelper.getRoleStats(users);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'User Roles Distribution',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: stats.entries
                .map((entry) => _buildRoleStat(
                      role: entry.key,
                      count: entry.value,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleStat({
    required String role,
    required int count,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: UserHelper.getRoleBgColor(role),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: UserHelper.getRoleColor(role),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            UserHelper.getRoleDisplayName(role),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: UserHelper.getRoleColor(role),
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '($count)',
            style: TextStyle(
              color: UserHelper.getRoleColor(role),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// Empty State Widget
class EmptyUserListWidget extends StatelessWidget {
  const EmptyUserListWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_search_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No users found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
