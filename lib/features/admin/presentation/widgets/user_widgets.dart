import 'package:flutter/material.dart';
import 'package:resqnow_admin/features/admin/data/models/admin_user_model.dart';
import 'package:resqnow_admin/features/admin/presentation/utils/user_helper.dart';

/// Reusable User Card Widget - Redesigned with direct action buttons
class UserCard extends StatelessWidget {
  final AdminUserModel user;
  final VoidCallback onTap;
  final Function(String) onActionSelected;

  const UserCard({
    super.key,
    required this.user,
    required this.onTap,
    required this.onActionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isBlockedOrSuspended =
        user.isBlocked || user.accountStatus == 'suspended';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // User info header
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: user.getProxiedImageUrl() != null
                      ? NetworkImage(user.getProxiedImageUrl()!)
                      : null,
                  backgroundColor: Colors.blue[100],
                  child: user.getProxiedImageUrl() == null
                      ? Icon(Icons.person, size: 24, color: Colors.blue[700])
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Color(0xFF212121),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.email,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                UserHelper.getRoleBadge(user.role),
              ],
            ),
            const SizedBox(height: 12),
            // Status and badges row
            Row(children: [UserHelper.getStatusBadge(user)]),
            const SizedBox(height: 12),
            // Action buttons row
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    label: 'View',
                    icon: Icons.visibility_rounded,
                    onPressed: () => onActionSelected('view'),
                    backgroundColor: Colors.blue[50],
                    textColor: Colors.blue[700],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildActionButton(
                    label: 'Edit',
                    icon: Icons.edit_rounded,
                    onPressed: () => onActionSelected('edit'),
                    backgroundColor: Colors.green[50],
                    textColor: Colors.green[700],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildActionButton(
                    label: isBlockedOrSuspended ? 'Reactivate' : 'Suspend',
                    icon: isBlockedOrSuspended
                        ? Icons.restore_rounded
                        : Icons.block_rounded,
                    onPressed: () => onActionSelected(
                      isBlockedOrSuspended ? 'reactivate' : 'suspend',
                    ),
                    backgroundColor: isBlockedOrSuspended
                        ? Colors.orange[50]
                        : Colors.red[50],
                    textColor: isBlockedOrSuspended
                        ? Colors.orange[700]
                        : Colors.red[700],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required Color? backgroundColor,
    required Color? textColor,
  }) {
    return Material(
      color: backgroundColor ?? Colors.grey[100],
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: textColor),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// User Statistics Widget - Separate card design
class UserStatsWidget extends StatelessWidget {
  final List<AdminUserModel> users;

  const UserStatsWidget({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    final stats = UserHelper.getStatistics(users);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              label: 'Total Users',
              value: stats['total']!.toString(),
              icon: Icons.people,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              label: 'Active',
              value: stats['active']!.toString(),
              icon: Icons.check_circle,
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              label: 'Suspended',
              value: stats['suspended']!.toString(),
              icon: Icons.block,
              color: Colors.red,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              label: 'Admins',
              value: stats['admin']!.toString(),
              icon: Icons.admin_panel_settings,
              color: Colors.purple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Role Statistics Widget
class RoleStatsWidget extends StatelessWidget {
  final List<AdminUserModel> users;

  const RoleStatsWidget({super.key, required this.users});

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
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: stats.entries
                .map(
                  (entry) =>
                      _buildRoleStat(role: entry.key, count: entry.value),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleStat({required String role, required int count}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: UserHelper.getRoleBgColor(role),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: UserHelper.getRoleColor(role), width: 1.5),
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
  const EmptyUserListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_search_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No users found',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
