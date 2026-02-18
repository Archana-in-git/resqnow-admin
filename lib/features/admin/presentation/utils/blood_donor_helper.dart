import 'package:flutter/material.dart';
import 'package:resqnow_admin/features/admin/data/models/blood_donor_model.dart';

/// Helper utilities for blood donor management
class BloodDonorHelper {
  /// Get color for blood group
  static Color getBloodGroupColor(String bloodGroup) {
    switch (bloodGroup) {
      case 'O+':
      case 'O-':
        return Colors.red;
      case 'A+':
      case 'A-':
        return Colors.orange;
      case 'B+':
      case 'B-':
        return Colors.blue;
      case 'AB+':
      case 'AB-':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  /// Get background color for blood group badge
  static Color getBloodGroupBgColor(String bloodGroup) {
    return getBloodGroupColor(bloodGroup).withOpacity(0.2);
  }

  /// Format date for display
  static String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Format datetime with time
  static String formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Get donor status badge
  static Widget getStatusBadge(BloodDonorModel donor) {
    if (donor.isSuspended) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.block, size: 14, color: Colors.red),
            const SizedBox(width: 4),
            const Text(
              'Suspended',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: (donor.isAvailable ? Colors.green : Colors.orange).withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            donor.isAvailable ? Icons.check_circle : Icons.pause_circle,
            size: 14,
            color: donor.isAvailable ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 4),
          Text(
            donor.isAvailable ? 'Available' : 'Unavailable',
            style: TextStyle(
              color: donor.isAvailable ? Colors.green : Colors.orange,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// Get donation eligibility status
  static bool isDonationEligible(BloodDonorModel donor) {
    return donor.isAvailable && !donor.isSuspended;
  }

  /// Get days since last donation
  static String getDaysSinceLastDonation(DateTime? lastDonatedAt) {
    if (lastDonatedAt == null) {
      return 'Never donated';
    }
    final days = DateTime.now().difference(lastDonatedAt).inDays;
    if (days < 1) {
      return 'Just donated';
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

  /// Check if donor can donate (minimum 56 days since last donation)
  static bool canDonateNow(DateTime? lastDonatedAt) {
    if (lastDonatedAt == null) return true;
    final daysSinceLastDonation =
        DateTime.now().difference(lastDonatedAt).inDays;
    return daysSinceLastDonation >= 56;
  }

  /// Get donation eligibility message
  static String getDonationEligibilityMessage(BloodDonorModel donor) {
    if (donor.isSuspended) {
      return 'Donor is suspended';
    }
    if (!donor.isAvailable) {
      return 'Donor marked as unavailable';
    }
    if (donor.medicalConditions.isNotEmpty) {
      return 'Has medical conditions';
    }
    if (donor.lastDonatedAt != null) {
      if (canDonateNow(donor.lastDonatedAt)) {
        return 'Eligible to donate';
      } else {
        final daysUntilEligible =
            56 - DateTime.now().difference(donor.lastDonatedAt!).inDays;
        return 'Can donate in $daysUntilEligible days';
      }
    }
    return 'Eligible to donate';
  }

  /// Get location string
  static String getLocationString(BloodDonorModel donor) {
    return '${donor.town}, ${donor.district} - ${donor.pincode}';
  }

  /// Get summary statistics for a list of donors
  static Map<String, int> getStatistics(List<BloodDonorModel> donors) {
    return {
      'total': donors.length,
      'available': donors.where((d) => d.isAvailable && !d.isSuspended).length,
      'suspended': donors.where((d) => d.isSuspended).length,
      'unavailable': donors.where((d) => !d.isAvailable).length,
    };
  }

  /// Get blood group statistics
  static Map<String, int> getBloodGroupStats(List<BloodDonorModel> donors) {
    final stats = <String, int>{};
    for (final donor in donors) {
      stats[donor.bloodGroup] = (stats[donor.bloodGroup] ?? 0) + 1;
    }
    return stats;
  }
}
