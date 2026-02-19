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
                  itemCount: _emergencyNumbers.length,
                  itemBuilder: (context, index) {
                    final number = _emergencyNumbers[index];
                    return _buildEmergencyNumberTile(number);
                  },
                ),
    );
  }

  Widget _buildEmergencyNumberTile(EmergencyNumberModel number) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.red,
          child: const Icon(Icons.phone, color: Colors.white),
        ),
        title: Text(number.name),
        subtitle: Text(number.number),
        trailing: PopupMenuButton<String>(
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
          onSelected: (value) {
            if (value == 'edit') {
              _showAddEditDialog(number: number);
            } else if (value == 'delete') {
              _showDeleteDialog(number);
            }
          },
        ),
      ),
    );
  }

  void _showAddEditDialog({EmergencyNumberModel? number}) {
    final isEdit = number != null;
    final nameController = TextEditingController(text: number?.name ?? '');
    final numberController = TextEditingController(text: number?.number ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty || numberController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All fields are required')),
                );
                return;
              }

              try {
                if (isEdit) {
                  await _adminService.updateEmergencyNumber(
                    number.id,
                    {
                      'name': nameController.text,
                      'number': numberController.text,
                    },
                  );
                } else {
                  await _adminService.createEmergencyNumber(
                    EmergencyNumberModel(
                      id: '',
                      name: nameController.text,
                      number: numberController.text,
                    ),
                  );
                }
                if (mounted) {
                  Navigator.pop(context);
                  _loadEmergencyNumbers();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isEdit ? 'Number updated' : 'Number added'),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
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
      builder: (context) => AlertDialog(
        title: const Text('Delete Emergency Number'),
        content: Text(
          'Are you sure you want to delete ${number.name} (${number.number})? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _adminService.deleteEmergencyNumber(number.id);
                if (mounted) {
                  Navigator.pop(context);
                  _loadEmergencyNumbers();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Emergency number deleted')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
