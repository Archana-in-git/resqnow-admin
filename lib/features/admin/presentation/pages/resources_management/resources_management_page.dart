import 'package:flutter/material.dart';
import 'package:resqnow_admin/features/admin/data/models/resource_models.dart';
import 'package:resqnow_admin/core/services/admin_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// First Aid Resources Management Page
class ResourcesManagementPage extends StatefulWidget {
  const ResourcesManagementPage({Key? key}) : super(key: key);

  @override
  State<ResourcesManagementPage> createState() =>
      _ResourcesManagementPageState();
}

class _ResourcesManagementPageState extends State<ResourcesManagementPage> {
  late AdminService adminService;
  List<ResourceModel> _resources = [];
  List<ResourceModel> _filteredResources = [];
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    adminService = AdminService(
      firestore: FirebaseFirestore.instance,
      auth: FirebaseAuth.instance,
    );
    _loadResources();
    _searchController.addListener(_filterResources);
  }

  Future<void> _loadResources() async {
    setState(() => _isLoading = true);
    try {
      final resources = await adminService.getAllResources(limit: 100);
      setState(() {
        _resources = resources;
        _filteredResources = resources;
      });
    } catch (e) {
      _showErrorSnackbar('Error loading resources: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterResources() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredResources = _resources;
      } else {
        _filteredResources = _resources
            .where((resource) =>
                resource.name.toLowerCase().contains(query) ||
                resource.description.toLowerCase().contains(query) ||
                resource.tags.any((tag) => tag.toLowerCase().contains(query)))
            .toList();
      }
    });
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('First Aid Resources Management'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search resources...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredResources.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image_not_supported,
                                size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isEmpty
                                  ? 'No resources found'
                                  : 'No matching resources found',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredResources.length,
                        itemBuilder: (context, index) {
                          final resource = _filteredResources[index];
                          return _buildResourceTile(resource);
                        },
                      ),
          ),
        ],
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
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.image),
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
      case 'edit':
        _showAddEditDialog(resource);
        break;
      case 'feature':
        _toggleFeatured(resource, true);
        break;
      case 'unfeature':
        _toggleFeatured(resource, false);
        break;
      case 'delete':
        _showDeleteDialog(resource);
        break;
    }
  }

  void _toggleFeatured(ResourceModel resource, bool featured) async {
    try {
      await adminService.updateResource(resource.id, {'isFeatured': featured});
      _loadResources();
      _showErrorSnackbar(
        'Resource ${featured ? 'featured' : 'unfeatured'} successfully',
      );
    } catch (e) {
      _showErrorSnackbar('Error updating resource: $e');
    }
  }

  void _showAddEditDialog([ResourceModel? resource]) {
    final isEditing = resource != null;
    final nameController = TextEditingController(text: resource?.name ?? '');
    final descriptionController =
        TextEditingController(text: resource?.description ?? '');
    final tagsController = TextEditingController(
      text: resource?.tags.join(', ') ?? '',
    );
    final imageUrlsController = TextEditingController(
      text: resource?.imageUrls.join('\n') ?? '',
    );
    final whenToUseController =
        TextEditingController(text: resource?.whenToUse ?? '');
    final safetyTipsController =
        TextEditingController(text: resource?.safetyTips ?? '');
    final proTipController = TextEditingController(text: resource?.proTip ?? '');
    final categoriesController = TextEditingController(
      text: resource?.categories.join(', ') ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Resource' : 'Add New Resource'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Resource Name*',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description*',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: categoriesController,
                decoration: const InputDecoration(
                  labelText: 'Categories (comma-separated)',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., First Aid, CPR, Injuries',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags (comma-separated)',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., emergency, safety, health',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: imageUrlsController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Image URLs (one per line)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: whenToUseController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'When to Use',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: safetyTipsController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Safety Tips',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: proTipController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Pro Tip',
                  border: OutlineInputBorder(),
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
              if (nameController.text.isEmpty ||
                  descriptionController.text.isEmpty) {
                _showErrorSnackbar('Name and description are required');
                return;
              }

              try {
                final newResource = ResourceModel(
                  id: resource?.id ?? '',
                  name: nameController.text,
                  description: descriptionController.text,
                  categories: categoriesController.text
                      .split(',')
                      .map((c) => c.trim())
                      .where((c) => c.isNotEmpty)
                      .toList(),
                  tags: tagsController.text
                      .split(',')
                      .map((t) => t.trim())
                      .where((t) => t.isNotEmpty)
                      .toList(),
                  imageUrls: imageUrlsController.text
                      .split('\n')
                      .map((u) => u.trim())
                      .where((u) => u.isNotEmpty)
                      .toList(),
                  whenToUse: whenToUseController.text.isEmpty
                      ? null
                      : whenToUseController.text,
                  safetyTips: safetyTipsController.text.isEmpty
                      ? null
                      : safetyTipsController.text,
                  proTip: proTipController.text.isEmpty
                      ? null
                      : proTipController.text,
                  isFeatured: resource?.isFeatured ?? false,
                  createdAt: resource?.createdAt ?? DateTime.now(),
                  updatedAt: DateTime.now(),
                );

                if (isEditing) {
                  await adminService.updateResource(
                    resource!.id,
                    newResource.toJson(),
                  );
                  _showErrorSnackbar('Resource updated successfully');
                } else {
                  await adminService.createResource(newResource);
                  _showErrorSnackbar('Resource created successfully');
                }

                _loadResources();
                Navigator.pop(context);
              } catch (e) {
                _showErrorSnackbar('Error saving resource: $e');
              }
            },
            child: Text(isEditing ? 'Update' : 'Create'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(ResourceModel resource) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Resource'),
        content: Text('Delete "${resource.name}"?\nThis action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await adminService.deleteResource(resource.id);
                Navigator.pop(context);
                _loadResources();
                _showErrorSnackbar('Resource deleted successfully');
              } catch (e) {
                Navigator.pop(context);
                _showErrorSnackbar('Error deleting resource: $e');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.white),
            ),
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
