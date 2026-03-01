import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      appBar: AppBar(
        title: const Text('Hospital Approvals'),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: hospitalsRef
            .where('status', whereIn: ['pending', 'approved', 'rejected'])
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(
              child: Text(
                'No hospital registrations found.',
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final hospital = HospitalModel.fromJson(
                doc.data() as Map<String, dynamic>,
                doc.id,
              );
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            hospital.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: hospital.status == 'approved'
                                  ? Colors.green.shade100
                                  : hospital.status == 'rejected'
                                  ? Colors.red.shade100
                                  : Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              hospital.status.toUpperCase(),
                              style: TextStyle(
                                color: hospital.status == 'approved'
                                    ? Colors.green
                                    : hospital.status == 'rejected'
                                    ? Colors.red
                                    : Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Address: ${hospital.address}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        'Phone: ${hospital.phone}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        'Email: ${hospital.email}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: hospital.status == 'approved'
                                ? null
                                : () async {
                                    await _updateStatus(
                                      hospital.id,
                                      'approved',
                                    );
                                  },
                            icon: const Icon(Icons.check),
                            label: const Text('Approve'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              disabledBackgroundColor: Colors.green.shade200,
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: hospital.status == 'rejected'
                                ? null
                                : () async {
                                    await _updateStatus(
                                      hospital.id,
                                      'rejected',
                                    );
                                  },
                            icon: const Icon(Icons.close),
                            label: const Text('Reject'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              disabledBackgroundColor: Colors.red.shade200,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
