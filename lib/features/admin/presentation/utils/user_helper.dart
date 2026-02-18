import 'package:flutter/material.dart';
import 'package:resqnow_admin/features/admin/data/models/admin_user_model.dart';

/// Helper utilities for user management
class UserHelper {
  /// Get color for role
  static Color getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.red;
      case 'support':
        return Colors.blue;
      case 'moderator':
        return Colors.orange;
      case 'user':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  /// Get background color for role badge
  static Color getRoleBgColor(String role) {
    return getRoleColor(role).withOpacity(0.2);
  }

  /// Get color for account status
  static Color getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'suspended':
        return Colors.red;
      case 'inactive':
        return Colors.grey;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  /// Get background color for status badge
  static Color getStatusBgColor(String status) {
    return getStatusColor(status).withOpacity(0.2);
  }

  /// Format date for display
  static String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Format datetime with time
  static String formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Get user status badge
  static Widget getStatusBadge(AdminUserModel user) {
    late IconData icon;
    late String label;
    late Color color;

    switch (user.accountStatus) {
      case 'active':
        icon = Icons.check_circle;
        label = 'Active';
        color = Colors.green;
        break;
      case 'suspended':
        icon = Icons.block;
        label = 'Suspended';
        color = Colors.red;
        break;
      case 'pending':
        icon = Icons.pending;
        label = 'Pending';
        color = Colors.orange;
        break;
      default:
        icon = Icons.cancel;
        label = 'Inactive';
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// Get role display name with icon
  static Widget getRoleBadge(String role) {
    late String label;
    late IconData icon;

    switch (role) {
      case 'admin':
        label = 'Admin';
        icon = Icons.admin_panel_settings;
        break;
      case 'support':
        label = 'Support';
        icon = Icons.support_agent;
        break;
      case 'moderator':
        label = 'Moderator';
        icon = Icons.security;
        break;
      default:
        label = 'User';
        icon = Icons.person;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: getRoleBgColor(role),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: getRoleColor(role)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: getRoleColor(role),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// Get role display name
  static String getRoleDisplayName(String role) {
    switch (role) {
      case 'admin':
        return 'Administrator';
      case 'support':
        return 'Support Staff';
      case 'moderator':
        return 'Moderator';
      case 'user':
        return 'User';
      default:
        return role;
    }
  }

  /// Check if user is active
  static bool isUserActive(AdminUserModel user) {
    return user.accountStatus == 'active';
  }

  /// Get last login text
  static String getLastLoginText(DateTime? lastLogin) {
    if (lastLogin == null) {
      return 'Never logged in';
    }
    final days = DateTime.now().difference(lastLogin).inDays;
    if (days < 1) {
      return 'Just now';
    } else if (days == 1) {
      return 'Yesterday';
    } else if (days < 30) {
      return '$days days ago';
    } else if (days < 365) {
      final months = (days / 30).floor();
      return '$months months ago';
    } else {
      final years = (days / 365).floor();
      return '$years years ago';
    }
  }

  /// Get user statistics
  static Map<String, int> getStatistics(List<AdminUserModel> users) {
    return {
      'total': users.length,
      'active': users.where((u) => u.accountStatus == 'active').length,
      'suspended': users.where((u) => u.accountStatus == 'suspended').length,
      'admin': users.where((u) => u.role == 'admin').length,
    };
  }

  /// Get role statistics
  static Map<String, int> getRoleStats(List<AdminUserModel> users) {
    final stats = <String, int>{};
    for (final user in users) {
      stats[user.role] = (stats[user.role] ?? 0) + 1;
    }
    return stats;
  }

  /// Check if user is email verified
  static Widget getVerificationBadge(bool emailVerified) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: emailVerified ? Colors.green.shade100 : Colors.yellow.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            emailVerified ? Icons.verified : Icons.mail,
            size: 12,
            color: emailVerified ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 2),
          Text(
            emailVerified ? 'Verified' : 'Unverified',
            style: TextStyle(
              fontSize: 10,
              color: emailVerified ? Colors.green[900] : Colors.orange[900],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
