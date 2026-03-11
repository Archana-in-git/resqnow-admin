import 'package:flutter/material.dart';
import 'package:resqnow_admin/features/admin/data/models/blood_donor_model.dart';
import 'package:resqnow_admin/features/admin/presentation/utils/blood_donor_helper.dart';

/// Reusable Donor Card Widget - Redesigned to match UserCard
class DonorCard extends StatelessWidget {
  final BloodDonorModel donor;
  final VoidCallback onTap;
  final Function(String) onActionSelected;

  const DonorCard({
    super.key,
    required this.donor,
    required this.onTap,
    required this.onActionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isSuspended = donor.isSuspended;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Donor info header
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: donor.getProxiedImageUrl() != null
                      ? NetworkImage(donor.getProxiedImageUrl()!)
                      : null,
                  backgroundColor: Colors.red[100],
                  child: donor.getProxiedImageUrl() == null
                      ? Icon(Icons.person, size: 24, color: Colors.red[700])
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        donor.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Color(0xFF212121),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        donor.email,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: BloodDonorHelper.getBloodGroupBgColor(
                      donor.bloodGroup,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    donor.bloodGroup,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: BloodDonorHelper.getBloodGroupColor(
                        donor.bloodGroup,
                      ),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Status and info row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: donor.isAvailable
                            ? Colors.green[100]
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        donor.isAvailable ? 'Available' : 'Unavailable',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: donor.isAvailable
                              ? Colors.green[700]
                              : Colors.grey[700],
                        ),
                      ),
                    ),
                    if (isSuspended) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Suspended',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.red[700],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  '📞 ${donor.phone}',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
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
                    label: isSuspended ? 'Reactivate' : 'Suspend',
                    icon: isSuspended
                        ? Icons.restore_rounded
                        : Icons.block_rounded,
                    onPressed: () => onActionSelected(
                      isSuspended ? 'reactivate' : 'suspend',
                    ),
                    backgroundColor: isSuspended
                        ? Colors.orange[50]
                        : Colors.red[50],
                    textColor: isSuspended
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

/// Donor Statistics Card Widget - All stats in single row
class DonorStatsWidget extends StatelessWidget {
  final List<BloodDonorModel> donors;

  const DonorStatsWidget({super.key, required this.donors});

  @override
  Widget build(BuildContext context) {
    final stats = BloodDonorHelper.getStatistics(donors);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              label: 'Total Donors',
              value: stats['total']!.toString(),
              icon: Icons.people,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              label: 'Available',
              value: stats['available']!.toString(),
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
            color: Colors.black.withValues(alpha: 0.04),
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
              color: color.withValues(alpha: 0.1),
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

/// Blood Group Statistics Widget
class BloodGroupStatsWidget extends StatelessWidget {
  final List<BloodDonorModel> donors;

  const BloodGroupStatsWidget({super.key, required this.donors});

  @override
  Widget build(BuildContext context) {
    final stats = BloodDonorHelper.getBloodGroupStats(donors);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Blood Group Distribution',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: stats.entries
                .map(
                  (entry) => _buildBloodGroupStat(
                    bloodGroup: entry.key,
                    count: entry.value,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBloodGroupStat({
    required String bloodGroup,
    required int count,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: BloodDonorHelper.getBloodGroupBgColor(bloodGroup),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: BloodDonorHelper.getBloodGroupColor(bloodGroup),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            bloodGroup,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: BloodDonorHelper.getBloodGroupColor(bloodGroup),
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '($count)',
            style: TextStyle(
              color: BloodDonorHelper.getBloodGroupColor(bloodGroup),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// Empty State Widget
class EmptyDonorListWidget extends StatelessWidget {
  const EmptyDonorListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_search_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No donors found',
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

