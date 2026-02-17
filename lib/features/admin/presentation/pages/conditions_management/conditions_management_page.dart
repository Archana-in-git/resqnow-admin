import 'package:flutter/material.dart';
import 'package:resqnow_admin/features/admin/data/models/resource_models.dart';

/// Medical Conditions Management Page
class ConditionsManagementPage extends StatefulWidget {
  const ConditionsManagementPage({Key? key}) : super(key: key);

  @override
  State<ConditionsManagementPage> createState() =>
      _ConditionsManagementPageState();
}

class _ConditionsManagementPageState extends State<ConditionsManagementPage> {
  List<ConditionModel> _conditions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadConditions();
  }

  Future<void> _loadConditions() async {
    setState(() => _isLoading = true);
    try {
      // TODO: Implement conditions loading
      _conditions = [];
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading conditions: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Conditions Management'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to create condition page
        },
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _conditions.isEmpty
          ? const Center(child: Text('No conditions found'))
          : ListView.builder(
              itemCount: _conditions.length,
              itemBuilder: (context, index) {
                final condition = _conditions[index];
                return _buildConditionTile(condition);
              },
            ),
    );
  }

  Widget _buildConditionTile(ConditionModel condition) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: condition.imageUrls.isNotEmpty
            ? Image.network(
                condition.imageUrls.first,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              )
            : const Icon(Icons.medical_services),
        title: Text(condition.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Chip(
                  label: Text(condition.severity),
                  backgroundColor: _getSeverityColor(condition.severity),
                ),
                const SizedBox(width: 8),
                Chip(label: Text('${condition.doctorTypes.length} doctors')),
              ],
            ),
            Text(
              condition.firstAidSteps.length > 0
                  ? '${condition.firstAidSteps.length} first aid steps'
                  : 'No steps',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'view', child: Text('View')),
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
          onSelected: (value) {
            _handleConditionAction(condition, value);
          },
        ),
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'critical':
        return Colors.red[200]!;
      case 'high':
        return Colors.orange[200]!;
      case 'medium':
        return Colors.yellow[200]!;
      case 'low':
        return Colors.green[200]!;
      default:
        return Colors.grey[200]!;
    }
  }

  void _handleConditionAction(ConditionModel condition, String action) {
    switch (action) {
      case 'view':
        // TODO: Navigate to condition detail
        break;
      case 'edit':
        // TODO: Navigate to condition edit
        break;
      case 'delete':
        _showDeleteDialog(condition);
        break;
    }
  }

  void _showDeleteDialog(ConditionModel condition) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Condition'),
        content: const Text(
          'Are you sure you want to delete this medical condition?',
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
