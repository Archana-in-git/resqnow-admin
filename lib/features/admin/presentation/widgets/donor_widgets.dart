import 'package:flutter/material.dart';
import 'package:resqnow_admin/features/admin/data/models/blood_donor_model.dart';
import 'package:resqnow_admin/features/admin/presentation/utils/blood_donor_helper.dart';

/// Reusable Donor Card Widget
class DonorCard extends StatelessWidget {
  final BloodDonorModel donor;
  final VoidCallback onTap;
  final Function(String) onActionSelected;

  const DonorCard({
    Key? key,
    required this.donor,
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
          backgroundImage: donor.profileImage != null
              ? NetworkImage(donor.profileImage!)
              : null,
          backgroundColor: Colors.red[100],
          child: donor.profileImage == null
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
                donor.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                donor.email,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: BloodDonorHelper.getBloodGroupBgColor(donor.bloodGroup),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            donor.bloodGroup,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: BloodDonorHelper.getBloodGroupColor(donor.bloodGroup),
              fontSize: 14,
            ),
          ),
        ),
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
            Chip(
              label: Text(donor.isAvailable ? 'Available' : 'Unavailable'),
              backgroundColor: donor.isAvailable
                  ? Colors.green[200]
                  : Colors.grey[200],
              labelStyle: TextStyle(
                color: donor.isAvailable
                    ? Colors.green[900]
                    : Colors.grey[900],
                fontSize: 11,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
            ),
            const SizedBox(width: 8),
            if (donor.isSuspended)
              Chip(
                label: const Text('Suspended'),
                backgroundColor: Colors.red[200],
                labelStyle: const TextStyle(
                  color: Colors.red,
                  fontSize: 11,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          '📍 ${BloodDonorHelper.getLocationString(donor)} | 📱 ${donor.phone}',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[700],
          ),
        ),
        if (donor.lastDonatedAt != null)
          Text(
            '${BloodDonorHelper.getDaysSinceLastDonation(donor.lastDonatedAt)} ago',
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
          value: donor.isSuspended ? 'reactivate' : 'suspend',
          child: Text(donor.isSuspended ? 'Reactivate' : 'Suspend'),
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

/// Donor Statistics Card Widget
class DonorStatsWidget extends StatelessWidget {
  final List<BloodDonorModel> donors;

  const DonorStatsWidget({Key? key, required this.donors}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stats = BloodDonorHelper.getStatistics(donors);

    return Container(
      color: Colors.blue.shade50,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatCard(
            label: 'Total',
            value: stats['total']!.toString(),
            icon: Icons.people,
          ),
          _buildStatCard(
            label: 'Available',
            value: stats['available']!.toString(),
            icon: Icons.check_circle,
            color: Colors.green,
          ),
          _buildStatCard(
            label: 'Suspended',
            value: stats['suspended']!.toString(),
            icon: Icons.block,
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    Color color = Colors.blue,
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
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

/// Blood Group Statistics Widget
class BloodGroupStatsWidget extends StatelessWidget {
  final List<BloodDonorModel> donors;

  const BloodGroupStatsWidget({Key? key, required this.donors})
      : super(key: key);

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
                .map((entry) => _buildBloodGroupStat(
                      bloodGroup: entry.key,
                      count: entry.value,
                    ))
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
  const EmptyDonorListWidget({Key? key}) : super(key: key);

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
            'No donors found',
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
