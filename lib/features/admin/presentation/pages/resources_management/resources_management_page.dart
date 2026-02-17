import 'package:flutter/material.dart';
import 'package:resqnow_admin/features/admin/data/models/resource_models.dart';

/// First Aid Resources Management Page
class ResourcesManagementPage extends StatefulWidget {
  const ResourcesManagementPage({Key? key}) : super(key: key);

  @override
  State<ResourcesManagementPage> createState() =>
      _ResourcesManagementPageState();
}

class _ResourcesManagementPageState extends State<ResourcesManagementPage> {
  List<ResourceModel> _resources = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadResources();
  }

  Future<void> _loadResources() async {
    setState(() => _isLoading = true);
    try {
      // TODO: Implement resources loading
      _resources = [];
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading resources: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('First Aid Resources Management'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to create resource page
        },
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _resources.isEmpty
          ? const Center(child: Text('No resources found'))
          : ListView.builder(
              itemCount: _resources.length,
              itemBuilder: (context, index) {
                final resource = _resources[index];
                return _buildResourceTile(resource);
              },
            ),
    );
  }

  Widget _buildResourceTile(ResourceModel resource) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: resource.imageUrls.isNotEmpty
            ? Image.network(
                resource.imageUrls.first,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              )
            : const Icon(Icons.image_not_supported),
        title: Text(resource.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              resource.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
            Row(
              children: [
                if (resource.isFeatured)
                  Chip(
                    label: const Text('Featured'),
                    backgroundColor: Colors.amber[200],
                  ),
                const SizedBox(width: 8),
                Chip(label: Text('${resource.tags.length} tags')),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'view', child: Text('View')),
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(
              value: resource.isFeatured ? 'unfeature' : 'feature',
              child: Text(resource.isFeatured ? 'Unfeature' : 'Feature'),
            ),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
          onSelected: (value) {
            _handleResourceAction(resource, value);
          },
        ),
      ),
    );
  }

  void _handleResourceAction(ResourceModel resource, String action) {
    switch (action) {
      case 'view':
        // TODO: Navigate to resource detail
        break;
      case 'edit':
        // TODO: Navigate to resource edit
        break;
      case 'feature':
      case 'unfeature':
        // TODO: Toggle featured status
        break;
      case 'delete':
        _showDeleteDialog(resource);
        break;
    }
  }

  void _showDeleteDialog(ResourceModel resource) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Resource'),
        content: const Text('Are you sure you want to delete this resource?'),
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
