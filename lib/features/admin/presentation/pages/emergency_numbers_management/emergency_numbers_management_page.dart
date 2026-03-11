import 'package:flutter/material.dart';
import 'package:resqnow_admin/core/services/admin_service.dart';
import 'package:resqnow_admin/features/admin/data/models/resource_models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Emergency Numbers Management Page
class EmergencyNumbersManagementPage extends StatefulWidget {
  const EmergencyNumbersManagementPage({super.key});

  @override
  State<EmergencyNumbersManagementPage> createState() =>
      _EmergencyNumbersManagementPageState();
}

class _EmergencyNumbersManagementPageState
    extends State<EmergencyNumbersManagementPage> {
  late AdminService _adminService;
  List<EmergencyNumberModel> _emergencyNumbers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _adminService = AdminService(
      firestore: FirebaseFirestore.instance,
      auth: FirebaseAuth.instance,
    );
    _loadEmergencyNumbers();
  }

  Future<void> _loadEmergencyNumbers() async {
    setState(() => _isLoading = true);
    try {
      final numbers = await _adminService.getAllEmergencyNumbers();
      setState(() => _emergencyNumbers = numbers);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading emergency numbers: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Numbers Management'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _emergencyNumbers.isEmpty
          ? const Center(child: Text('No emergency numbers found'))
          : ListView.builder(
              padding: const EdgeInsets.all(12).copyWith(bottom: 80),
              itemCount: _emergencyNumbers.length,
              itemBuilder: (context, index) {
                final number = _emergencyNumbers[index];
                return _buildEmergencyNumberCard(number);
              },
            ),
    );
  }

  Widget _buildEmergencyNumberCard(EmergencyNumberModel number) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Small Icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.red[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(Icons.phone, color: Colors.red[600], size: 24),
              ),
            ),
            const SizedBox(width: 16),
            // Service Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    number.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    number.number,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.red[700],
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Action Buttons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _showAddEditDialog(number: number),
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Edit'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    backgroundColor: Colors.teal[100],
                    foregroundColor: Colors.teal[900],
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () => _showDeleteDialog(number),
                  icon: const Icon(Icons.delete, size: 18),
                  label: const Text('Delete'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    backgroundColor: Colors.red[100],
                    foregroundColor: Colors.red[900],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _showAddEditDialog({EmergencyNumberModel? number}) {
    final isEdit = number != null;
    final nameController = TextEditingController(text: number?.name ?? '');
    final numberController = TextEditingController(text: number?.number ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isEdit ? 'Edit Emergency Number' : 'Add Emergency Number'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Service Name',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., Ambulance Service',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: numberController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., 108',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty ||
                  numberController.text.isEmpty) {
                _showSnackBar('All fields are required');
                return;
              }

              Navigator.pop(dialogContext);

              try {
                if (isEdit) {
                  await _adminService.updateEmergencyNumber(number.id, {
                    'name': nameController.text,
                    'number': numberController.text,
                  });
                } else {
                  await _adminService.createEmergencyNumber(
                    EmergencyNumberModel(
                      id: '',
                      name: nameController.text,
                      number: numberController.text,
                    ),
                  );
                }
                _loadEmergencyNumbers();
                _showSnackBar(isEdit ? 'Number updated' : 'Number added');
              } catch (e) {
                _showSnackBar('Error: $e');
              }
            },
            child: Text(isEdit ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(EmergencyNumberModel number) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Emergency Number'),
        content: Text(
          'Are you sure you want to delete ${number.name} (${number.number})? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              try {
                await _adminService.deleteEmergencyNumber(number.id);
                _loadEmergencyNumbers();
                _showSnackBar('Emergency number deleted');
              } catch (e) {
                _showSnackBar('Error: $e');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
