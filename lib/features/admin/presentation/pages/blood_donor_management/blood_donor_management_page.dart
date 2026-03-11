import 'package:flutter/material.dart';
import 'dart:async';
import 'package:resqnow_admin/features/admin/data/models/blood_donor_model.dart';
import 'package:resqnow_admin/core/constants/admin_constants.dart';
import 'package:resqnow_admin/core/services/admin_service.dart';
import 'package:resqnow_admin/features/admin/presentation/utils/blood_donor_helper.dart';
import 'package:resqnow_admin/features/admin/presentation/widgets/donor_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Blood Donor Management Page
class BloodDonorManagementPage extends StatefulWidget {
  const BloodDonorManagementPage({super.key});

  @override
  State<BloodDonorManagementPage> createState() =>
      _BloodDonorManagementPageState();
}

class _BloodDonorManagementPageState extends State<BloodDonorManagementPage> {
  late AdminService _adminService;
  final TextEditingController _searchController = TextEditingController();
  String _selectedBloodGroup = '';
  String _selectedDistrict = '';
  String _selectedTown = '';
  List<BloodDonorModel> _allDonors = [];
  List<BloodDonorModel> _filteredDonors = [];
  bool _isLoading = false;
  final int _loadedCount = 50;
  Future<void>? _filterDebounceTimer;

  @override
  void initState() {
    super.initState();
    _adminService = AdminService(
      firestore: FirebaseFirestore.instance,
      auth: FirebaseAuth.instance,
    );
    _loadDonors();
    _searchController.addListener(_applyFiltersDebounced);
  }

  Future<void> _loadDonors() async {
    setState(() => _isLoading = true);
    try {
      final donors = await _adminService.getAllBloodDonors(limit: _loadedCount);
      setState(() {
        _allDonors = donors;
        _filteredDonors = donors;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading donors: $e'),
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
      _filteredDonors = _allDonors.where((donor) {
        // Search filter
        final searchQuery = _searchController.text.toLowerCase();
        final matchesSearch =
            searchQuery.isEmpty ||
            donor.name.toLowerCase().contains(searchQuery) ||
            donor.email.toLowerCase().contains(searchQuery) ||
            donor.phone.contains(searchQuery);

        // Blood group filter
        final matchesBloodGroup =
            _selectedBloodGroup.isEmpty ||
            donor.bloodGroup == _selectedBloodGroup;

        // District filter
        final matchesDistrict =
            _selectedDistrict.isEmpty || donor.district == _selectedDistrict;

        // Town filter
        final matchesTown =
            _selectedTown.isEmpty || donor.town == _selectedTown;

        return matchesSearch &&
            matchesBloodGroup &&
            matchesDistrict &&
            matchesTown;
      }).toList();
    });
  }

  void _applyFiltersDebounced() {
    _filterDebounceTimer?.ignore();
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
      appBar: AppBar(
        title: const Text('Blood Donor Management'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 4,
      ),
      body: Column(
        children: [
          // Filter Bar
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name, email, or phone...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Filters Row 1
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedBloodGroup.isEmpty
                            ? null
                            : _selectedBloodGroup,
                        decoration: InputDecoration(
                          labelText: 'Blood Group',
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: ['', ...AdminConstants.bloodGroups]
                            .map(
                              (group) => DropdownMenuItem(
                                value: group,
                                child: Text(
                                  group.isEmpty ? 'All Blood Groups' : group,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() => _selectedBloodGroup = value ?? '');
                          _applyFilters();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _selectedBloodGroup = '';
                          _selectedDistrict = '';
                          _selectedTown = '';
                        });
                        _applyFilters();
                      },
                      icon: const Icon(Icons.clear),
                      label: const Text('Clear Filters'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Stats Bar
          DonorStatsWidget(donors: _filteredDonors),
          // Donor List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredDonors.isEmpty
                ? const EmptyDonorListWidget()
                : Container(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 24,
                      ),
                      child: ListView.builder(
                        itemCount: _filteredDonors.length,
                        itemBuilder: (context, index) {
                          final donor = _filteredDonors[index];
                          return _buildDonorTile(donor);
                        },
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonorTile(BloodDonorModel donor) {
    return DonorCard(
      donor: donor,
      onTap: () => _showDonorDetailsDialog(donor),
      onActionSelected: (action) => _handleDonorAction(donor, action),
    );
  }

  void _handleDonorAction(BloodDonorModel donor, String action) {
    switch (action) {
      case 'view':
        _showDonorDetailsDialog(donor);
        break;
      case 'suspend':
        _showSuspendDialog(donor);
        break;
      case 'reactivate':
        _reactivateDonor(donor);
        break;
      case 'delete':
        _showDeleteDialog(donor);
        break;
    }
  }

  void _showDonorDetailsDialog(BloodDonorModel donor) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Donor Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: donor.getProxiedImageUrl() != null
                            ? NetworkImage(donor.getProxiedImageUrl()!)
                            : null,
                        backgroundColor: Colors.red[100],
                        child: donor.getProxiedImageUrl() == null
                            ? const Icon(Icons.person, size: 50)
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        donor.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          donor.bloodGroup,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildDetailRow('Email:', donor.email),
                _buildDetailRow('Phone:', donor.phone),
                _buildDetailRow('Gender:', donor.gender),
                _buildDetailRow('Age:', '${donor.age} years'),
                _buildDetailRow('Address:', donor.address),
                _buildDetailRow(
                  'Location:',
                  '${donor.town}, ${donor.district} - ${donor.pincode}',
                ),
                _buildDetailRow(
                  'Status:',
                  donor.isAvailable ? 'Available' : 'Unavailable',
                ),
                if (donor.lastDonatedAt != null)
                  _buildDetailRow(
                    'Last Donated:',
                    BloodDonorHelper.formatDate(donor.lastDonatedAt!),
                  ),
                _buildDetailRow(
                  'Registered:',
                  BloodDonorHelper.formatDate(donor.registeredAt),
                ),
                if (donor.medicalConditions.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Medical Conditions:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: donor.medicalConditions
                            .map((condition) => Chip(label: Text(condition)))
                            .toList(),
                      ),
                    ],
                  ),
                if (donor.notes != null && donor.notes!.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      const Text(
                        'Notes:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(donor.notes!),
                      ),
                    ],
                  ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showSuspendDialog(BloodDonorModel donor) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Suspend Donor'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to suspend ${donor.name}?'),
            const SizedBox(height: 16),
            const Text(
              'Reason for suspension:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Enter reason...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              _suspendDonor(donor, reasonController.text);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Suspend', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _suspendDonor(BloodDonorModel donor, String reason) async {
    try {
      await _adminService.updateBloodDonor(donor.uid, {
        'isSuspended': true,
        'suspensionReason': reason,
      });
      setState(() {
        final index = _allDonors.indexWhere((d) => d.uid == donor.uid);
        if (index != -1) {
          _allDonors[index] = _allDonors[index].copyWith(
            isSuspended: true,
            suspensionReason: reason,
          );
        }
      });
      _applyFilters();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${donor.name} has been suspended'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error suspending donor: $e')));
      }
    }
  }

  Future<void> _reactivateDonor(BloodDonorModel donor) async {
    try {
      await _adminService.updateBloodDonor(donor.uid, {
        'isSuspended': false,
        'suspensionReason': null,
      });
      setState(() {
        final index = _allDonors.indexWhere((d) => d.uid == donor.uid);
        if (index != -1) {
          _allDonors[index] = _allDonors[index].copyWith(
            isSuspended: false,
            suspensionReason: null,
          );
        }
      });
      _applyFilters();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${donor.name} has been reactivated'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error reactivating donor: $e')));
      }
    }
  }

  void _showDeleteDialog(BloodDonorModel donor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Donor'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete ${donor.name}?',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'This action cannot be undone. All donor data will be permanently deleted.',
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
              _deleteDonor(donor);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteDonor(BloodDonorModel donor) async {
    try {
      await _adminService.deleteDonor(donor.uid);
      setState(() {
        _allDonors.removeWhere((d) => d.uid == donor.uid);
      });
      _applyFilters();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${donor.name} has been deleted'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting donor: $e')));
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
