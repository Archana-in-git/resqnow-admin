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
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final resources = await adminService.getAllResources(limit: 100);
      if (mounted) {
        setState(() {
          _resources = resources;
          _filteredResources = resources;
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Error loading resources: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _filterResources() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredResources = _resources;
      } else {
        _filteredResources = _resources
            .where(
              (resource) =>
                  resource.name.toLowerCase().contains(query) ||
                  resource.description.toLowerCase().contains(query) ||
                  resource.tags.any((tag) => tag.toLowerCase().contains(query)),
            )
            .toList();
      }
    });
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
                        Icon(
                          Icons.image_not_supported,
                          size: 64,
                          color: Colors.grey[400],
                        ),
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
                : GridView.builder(
                    padding: const EdgeInsets.all(16).copyWith(bottom: 80),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.85,
                        ),
                    itemCount: _filteredResources.length,
                    itemBuilder: (context, index) {
                      final resource = _filteredResources[index];
                      return _buildResourceCard(resource);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceCard(ResourceModel resource) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Container with Featured Badge
          Stack(
            children: [
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  color: Colors.grey[200],
                ),
                child: resource.imageUrls.isNotEmpty
                    ? Image.network(
                        resource.imageUrls.first,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.blue[50],
                          child: Center(
                            child: Icon(
                              Icons.image,
                              size: 40,
                              color: Colors.blue[300],
                            ),
                          ),
                        ),
                      )
                    : Container(
                        color: Colors.blue[50],
                        child: Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 40,
                            color: Colors.blue[300],
                          ),
                        ),
                      ),
              ),
              // Featured Badge
              if (resource.isFeatured)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber[600],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, size: 14, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'Featured',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Resource Name
                  Text(
                    resource.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // Tags
                  if (resource.tags.isNotEmpty)
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: resource.tags
                          .take(2)
                          .map(
                            (tag) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                tag,
                                style: const TextStyle(fontSize: 9),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  const Spacer(),
                  // Action Buttons
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showAddEditDialog(resource),
                          icon: const Icon(Icons.edit, size: 14),
                          label: const Text('Edit'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            backgroundColor: Colors.teal[100],
                            foregroundColor: Colors.teal[900],
                            textStyle: const TextStyle(fontSize: 11),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showDeleteDialog(resource),
                          icon: const Icon(Icons.delete, size: 14),
                          label: const Text('Delete'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            backgroundColor: Colors.red[100],
                            foregroundColor: Colors.red[900],
                            textStyle: const TextStyle(fontSize: 11),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
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
    final descriptionController = TextEditingController(
      text: resource?.description ?? '',
    );
    final tagsController = TextEditingController(
      text: resource?.tags.join(', ') ?? '',
    );
    final imageUrlsController = TextEditingController(
      text: resource?.imageUrls.join('\n') ?? '',
    );
    final whenToUseController = TextEditingController(
      text: resource?.whenToUse ?? '',
    );
    final safetyTipsController = TextEditingController(
      text: resource?.safetyTips ?? '',
    );
    final proTipController = TextEditingController(
      text: resource?.proTip ?? '',
    );
    final categoriesController = TextEditingController(
      text: resource?.categories.join(', ') ?? '',
    );

    bool isFeaturedLocal = resource?.isFeatured ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
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
                const SizedBox(height: 16),
                // Featured Toggle
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    border: Border.all(color: Colors.amber[200]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber[700]),
                          const SizedBox(width: 8),
                          const Text(
                            'Featured Resource',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      Switch(
                        value: isFeaturedLocal,
                        onChanged: (value) {
                          setDialogState(() {
                            isFeaturedLocal = value;
                          });
                        },
                        activeColor: Colors.amber[700],
                      ),
                    ],
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
                    isFeatured: isFeaturedLocal,
                    createdAt: resource?.createdAt ?? DateTime.now(),
                    updatedAt: DateTime.now(),
                  );

                  if (isEditing) {
                    await adminService.updateResource(
                      resource.id,
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
      ),
    );
  }

  void _showDeleteDialog(ResourceModel resource) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Resource'),
        content: Text(
          'Delete "${resource.name}"?\nThis action cannot be undone.',
        ),
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
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
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
