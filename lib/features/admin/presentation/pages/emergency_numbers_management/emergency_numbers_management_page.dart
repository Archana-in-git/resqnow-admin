import 'package:flutter/material.dart';
import 'package:resqnow_admin/features/admin/data/models/resource_models.dart';

/// Emergency Numbers Management Page
class EmergencyNumbersManagementPage extends StatefulWidget {
  const EmergencyNumbersManagementPage({Key? key}) : super(key: key);

  @override
  State<EmergencyNumbersManagementPage> createState() =>
      _EmergencyNumbersManagementPageState();
}

class _EmergencyNumbersManagementPageState
    extends State<EmergencyNumbersManagementPage> {
  List<EmergencyNumberModel> _emergencyNumbers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadEmergencyNumbers();
  }

  Future<void> _loadEmergencyNumbers() async {
    setState(() => _isLoading = true);
    try {
      // TODO: Implement emergency numbers loading
      _emergencyNumbers = [];
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading emergency numbers: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
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
        onPressed: () {
          // TODO: Navigate to create emergency number page
        },
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
      child: ExpansionTile(
        title: Text(number.serviceName),
        subtitle: Text(number.phoneNumber),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Category:', number.category),
                _buildInfoRow('Priority:', number.priority.toString()),
                _buildInfoRow(
                  'Status:',
                  number.isActive ? 'Active' : 'Inactive',
                ),
                if (number.description != null)
                  _buildInfoRow('Description:', number.description!),
                if (number.areaOfCoverage != null)
                  _buildInfoRow('Coverage:', number.areaOfCoverage!),
                if (number.operatingHours != null)
                  _buildInfoRow('Hours:', number.operatingHours!),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        // TODO: Edit
                      },
                      child: const Text('Edit'),
                    ),
                    TextButton(
                      onPressed: () {
                        // TODO: Toggle status
                      },
                      child: Text(number.isActive ? 'Deactivate' : 'Activate'),
                    ),
                    TextButton(
                      onPressed: () => _showDeleteDialog(number),
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showDeleteDialog(EmergencyNumberModel number) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Emergency Number'),
        content: const Text(
          'Are you sure you want to delete this emergency number?',
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
}
