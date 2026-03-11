import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Admin Portal color constants
class ApprovalColors {
  static const Color primaryGradientStart = Color(0xFF00796B);
  static const Color primaryGradientEnd = Color(0xFF004D4A);
  static const Color accentColor = Color(0xFFD32F2F);
  static const Color backgroundColor = Color(0xFFFAFAFA);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color dividerColor = Color(0xFFE0E0E0);
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFFFA000);
  static const Color pending = Color(0xFFFFA000);
}

class HospitalModel {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String email;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  HospitalModel({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  factory HospitalModel.fromJson(Map<String, dynamic> json, String docId) {
    return HospitalModel(
      id: docId,
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: json['updatedAt']?.toDate(),
    );
  }
}

/// Hospital Approvals Page
class HospitalApprovalsPage extends StatefulWidget {
  const HospitalApprovalsPage({super.key});

  @override
  State<HospitalApprovalsPage> createState() => _HospitalApprovalsPageState();
}

class _HospitalApprovalsPageState extends State<HospitalApprovalsPage> {
  final CollectionReference hospitalsRef = FirebaseFirestore.instance
      .collection('hospitals');

  Future<void> _updateStatus(String id, String status) async {
    await hospitalsRef.doc(id).update({
      'status': status,
      'updatedAt': DateTime.now(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ApprovalColors.backgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.local_hospital, color: Colors.white),
            const SizedBox(width: 12),
            const Text(
              'Hospital Approvals',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        backgroundColor: ApprovalColors.primaryGradientStart,
        elevation: 2,
        centerTitle: false,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF9DD9D2).withValues(alpha: 0.3),
              const Color(0xFFAFD3E8).withValues(alpha: 0.2),
              const Color(0xFFC9B8E0).withValues(alpha: 0.2),
            ],
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: hospitalsRef
              .where('status', whereIn: ['pending', 'approved', 'rejected'])
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: ApprovalColors.textSecondary),
                ),
              );
            }
            final docs = snapshot.data?.docs ?? [];
            if (docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.domain_disabled,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hospital registrations found.',
                      style: TextStyle(
                        fontSize: 16,
                        color: ApprovalColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }

            // Separate hospitals by status
            final pendingHospitals = docs.where((doc) {
              final hospital = HospitalModel.fromJson(
                doc.data() as Map<String, dynamic>,
                doc.id,
              );
              return hospital.status == 'pending';
            }).toList();

            final approvedHospitals = docs.where((doc) {
              final hospital = HospitalModel.fromJson(
                doc.data() as Map<String, dynamic>,
                doc.id,
              );
              return hospital.status == 'approved';
            }).toList();

            final rejectedHospitals = docs.where((doc) {
              final hospital = HospitalModel.fromJson(
                doc.data() as Map<String, dynamic>,
                doc.id,
              );
              return hospital.status == 'rejected';
            }).toList();

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (pendingHospitals.isNotEmpty) ...[
                          _buildSectionHeader(
                            'Pending Approvals',
                            pendingHospitals.length,
                            ApprovalColors.pending,
                          ),
                          ...pendingHospitals.map((doc) {
                            final hospital = HospitalModel.fromJson(
                              doc.data() as Map<String, dynamic>,
                              doc.id,
                            );
                            return _buildHospitalCard(hospital);
                          }),
                          const SizedBox(height: 32),
                        ],
                        if (approvedHospitals.isNotEmpty) ...[
                          _buildSectionHeader(
                            'Approved',
                            approvedHospitals.length,
                            ApprovalColors.success,
                          ),
                          ...approvedHospitals.map((doc) {
                            final hospital = HospitalModel.fromJson(
                              doc.data() as Map<String, dynamic>,
                              doc.id,
                            );
                            return _buildHospitalCard(hospital);
                          }),
                          const SizedBox(height: 32),
                        ],
                        if (rejectedHospitals.isNotEmpty) ...[
                          _buildSectionHeader(
                            'Rejected',
                            rejectedHospitals.length,
                            ApprovalColors.accentColor,
                          ),
                          ...rejectedHospitals.map((doc) {
                            final hospital = HospitalModel.fromJson(
                              doc.data() as Map<String, dynamic>,
                              doc.id,
                            );
                            return _buildHospitalCard(hospital);
                          }),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ApprovalColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildHospitalCard(HospitalModel hospital) {
    final statusColor = hospital.status == 'approved'
        ? ApprovalColors.success
        : hospital.status == 'rejected'
        ? ApprovalColors.accentColor
        : ApprovalColors.pending;

    final statusIcon = hospital.status == 'approved'
        ? Icons.check_circle
        : hospital.status == 'rejected'
        ? Icons.cancel
        : Icons.schedule;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              border: Border(
                bottom: BorderSide(
                  color: statusColor.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hospital.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ApprovalColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${hospital.id}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: ApprovalColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        hospital.status.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(Icons.location_on, 'Address', hospital.address),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.phone, 'Phone', hospital.phone),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.email, 'Email', hospital.email),
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.calendar_today,
                  'Applied On',
                  _formatDate(hospital.createdAt),
                ),
                const SizedBox(height: 20),
                if (hospital.status == 'pending')
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await _updateStatus(hospital.id, 'approved');
                          },
                          icon: const Icon(Icons.check),
                          label: const Text('Approve'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ApprovalColors.success,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await _updateStatus(hospital.id, 'rejected');
                          },
                          icon: const Icon(Icons.close),
                          label: const Text('Reject'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ApprovalColors.accentColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(statusIcon, color: statusColor, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            hospital.status == 'approved'
                                ? 'This hospital has been approved'
                                : 'This hospital has been rejected',
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: ApprovalColors.primaryGradientStart),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: ApprovalColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: ApprovalColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
