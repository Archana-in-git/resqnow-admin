import 'package:flutter/material.dart';
import 'package:resqnow_admin/features/admin/data/models/blood_donor_model.dart';
import 'package:resqnow_admin/core/constants/admin_constants.dart';

/// Blood Donor Management Page
class BloodDonorManagementPage extends StatefulWidget {
  const BloodDonorManagementPage({Key? key}) : super(key: key);

  @override
  State<BloodDonorManagementPage> createState() =>
      _BloodDonorManagementPageState();
}

class _BloodDonorManagementPageState extends State<BloodDonorManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedBloodGroup = '';
  List<BloodDonorModel> _donors = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDonors();
  }

  Future<void> _loadDonors() async {
    setState(() => _isLoading = true);
    try {
      // TODO: Implement donor loading
      _donors = [];
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading donors: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blood Donor Management'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
                    hintText: 'Search by name or email...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    // TODO: Implement search
                  },
                ),
                const SizedBox(height: 12),
                // Blood Group Filter
                DropdownButtonFormField<String>(
                  value: _selectedBloodGroup.isEmpty
                      ? null
                      : _selectedBloodGroup,
                  decoration: InputDecoration(
                    labelText: 'Blood Group',
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
                    // TODO: Filter donors
                  },
                ),
              ],
            ),
          ),
          // Donor List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _donors.isEmpty
                ? const Center(child: Text('No donors found'))
                : ListView.builder(
                    itemCount: _donors.length,
                    itemBuilder: (context, index) {
                      final donor = _donors[index];
                      return _buildDonorTile(donor);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonorTile(BloodDonorModel donor) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: donor.profileImage != null
              ? NetworkImage(donor.profileImage!)
              : null,
          child: donor.profileImage == null ? const Icon(Icons.person) : null,
        ),
        title: Text(donor.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(donor.email),
            Row(
              children: [
                Chip(
                  label: Text(donor.bloodGroup),
                  backgroundColor: Colors.red[200],
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(donor.isAvailable ? 'Available' : 'Unavailable'),
                  backgroundColor: donor.isAvailable
                      ? Colors.green[200]
                      : Colors.grey[200],
                ),
                if (donor.isSuspended)
                  Chip(
                    label: const Text('Suspended'),
                    backgroundColor: Colors.red[200],
                  ),
              ],
            ),
            Text(
              '${donor.town}, ${donor.district}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'view', child: Text('View Details')),
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(
              value: donor.isSuspended ? 'reactivate' : 'suspend',
              child: Text(donor.isSuspended ? 'Reactivate' : 'Suspend'),
            ),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
          onSelected: (value) {
            _handleDonorAction(donor, value);
          },
        ),
        onTap: () {
          // TODO: Navigate to donor detail page
        },
      ),
    );
  }

  void _handleDonorAction(BloodDonorModel donor, String action) {
    switch (action) {
      case 'view':
        // TODO: Navigate to donor detail page
        break;
      case 'edit':
        // TODO: Navigate to donor edit page
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

  void _showSuspendDialog(BloodDonorModel donor) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Suspend Donor'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: 'Reason for suspension',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement suspend
              Navigator.pop(context);
            },
            child: const Text('Suspend'),
          ),
        ],
      ),
    );
  }

  Future<void> _reactivateDonor(BloodDonorModel donor) async {
    // TODO: Implement reactivate
  }

  void _showDeleteDialog(BloodDonorModel donor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Donor'),
        content: const Text(
          'Are you sure you want to delete this donor? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement delete
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
