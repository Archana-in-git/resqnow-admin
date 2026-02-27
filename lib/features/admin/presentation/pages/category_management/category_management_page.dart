import 'package:flutter/material.dart';
import 'package:resqnow_admin/core/services/admin_service.dart';
import 'package:resqnow_admin/features/admin/data/models/resource_models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Category Management Page
class CategoryManagementPage extends StatefulWidget {
  const CategoryManagementPage({super.key});

  @override
  State<CategoryManagementPage> createState() => _CategoryManagementPageState();
}

class _CategoryManagementPageState extends State<CategoryManagementPage> {
  late AdminService _adminService;
  List<CategoryModel> _categories = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _adminService = AdminService(
      firestore: FirebaseFirestore.instance,
      auth: FirebaseAuth.instance,
    );
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    try {
      final categories = await _adminService.getAllCategories();
      setState(() => _categories = categories);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading categories: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Extract filename from full path (handles legacy full paths)
  String _extractAssetFilename(String assetPath) {
    // If path contains slashes, get just the filename
    if (assetPath.contains('/')) {
      return assetPath.split('/').last;
    }
    return assetPath;
  }

  /// Build image display - shows URL image or local asset
  Widget _buildCategoryImage(CategoryModel category) {
    // Display URL image if available
    if (category.imageUrls.isNotEmpty) {
      final imageUrl = category.imageUrls.first;
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imageUrl,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.orange[50],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image, size: 40, color: Colors.orange[400]),
                const SizedBox(height: 4),
                Text(
                  'Image failed to load',
                  style: TextStyle(fontSize: 9, color: Colors.orange[600]),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Display local asset if available
    if (category.iconAsset != null && category.iconAsset!.isNotEmpty) {
      // Extract just the filename in case full path is stored
      final filename = _extractAssetFilename(category.iconAsset!);
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          'assets/images/icons/$filename',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.blue[50],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image, size: 40, color: Colors.blue[400]),
                const SizedBox(height: 4),
                Text(
                  'Asset not found',
                  style: TextStyle(fontSize: 9, color: Colors.blue[600]),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // No image provided
    return Container(
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.category, size: 40, color: Colors.grey[400]),
          const SizedBox(height: 4),
          Text(
            'No image',
            style: TextStyle(fontSize: 9, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Category Management'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _categories.isEmpty
          ? const Center(child: Text('No categories found'))
          : GridView.builder(
              padding: const EdgeInsets.all(16).copyWith(bottom: 80),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return _buildCategoryCard(category);
              },
            ),
    );
  }

  Widget _buildCategoryCard(CategoryModel category) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Container
          Container(
            height: 140,
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              color: Colors.white,
            ),
            child: _buildCategoryImage(category),
          ),
          // Content Container
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Name
                  Text(
                    category.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // Order Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Text(
                      'Order: ${category.order ?? "Not set"}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _showAddEditDialog(category: category),
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('Edit'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            backgroundColor: Colors.teal[100],
                            foregroundColor: Colors.teal[900],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showDeleteDialog(category),
                          icon: const Icon(Icons.delete, size: 18),
                          label: const Text('Delete'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            backgroundColor: Colors.red[100],
                            foregroundColor: Colors.red[900],
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

  void _showAddEditDialog({CategoryModel? category}) {
    final isEdit = category != null;
    final nameController = TextEditingController(text: category?.name ?? '');
    final orderController = TextEditingController(
      text: isEdit ? (category?.order?.toString() ?? '') : '',
    );
    final aliasesController = TextEditingController(
      text: category != null ? category.aliases.join(", ") : '',
    );

    final imageUrlController = TextEditingController(
      text: category != null && category.imageUrls.isNotEmpty
          ? category.imageUrls.first
          : '',
    );
    final iconAssetController = TextEditingController(
      text: category?.iconAsset ?? '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (innerContext, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Edit Category' : 'Add New Category'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Category Name
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Category Name *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                // Display Order
                TextField(
                  controller: orderController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: isEdit
                        ? 'Display Order'
                        : 'Display Order (optional)',
                    border: const OutlineInputBorder(),
                    hintText: isEdit
                        ? category?.order.toString()
                        : 'Auto-assigned if empty',
                  ),
                ),
                const SizedBox(height: 12),

                // Aliases
                TextField(
                  controller: aliasesController,
                  decoration: const InputDecoration(
                    labelText: 'Aliases (comma separated)',
                    border: OutlineInputBorder(),
                    hintText: 'pain, headache, migraine',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                // Local Asset Field
                TextField(
                  controller: iconAssetController,
                  decoration: const InputDecoration(
                    labelText: 'Local Asset',
                    border: OutlineInputBorder(),
                    hintText: 'e.g., avatar.jpg',
                  ),
                ),
                const SizedBox(height: 12),

                // Image URL Field
                TextField(
                  controller: imageUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Image URL',
                    border: OutlineInputBorder(),
                    hintText: 'e.g., https://example.com/image.jpg',
                  ),
                  keyboardType: TextInputType.url,
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
                if (nameController.text.isEmpty) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Name cannot be empty')),
                    );
                  }
                  return;
                }

                // Check if at least one image source is provided
                final imageUrlInput = imageUrlController.text.trim();
                final iconAssetInput = iconAssetController.text.trim();
                if (imageUrlInput.isEmpty && iconAssetInput.isEmpty) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Please provide either a URL or local asset',
                        ),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                  return;
                }

                try {
                  final aliases = aliasesController.text
                      .split(',')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList();

                  // Parse order - use next sequential number if not specified
                  int orderValue;
                  final orderText = orderController.text.trim();
                  if (orderText.isEmpty) {
                    // For new categories, auto-assign next order number
                    if (!isEdit) {
                      orderValue = _categories.isEmpty
                          ? 1
                          : (_categories
                                    .map((c) => c.order ?? 0)
                                    .reduce((a, b) => a > b ? a : b) +
                                1);
                    } else {
                      orderValue =
                          999; // Keep existing for edits if not specified
                    }
                  } else {
                    orderValue = int.tryParse(orderText) ?? 999;
                  }

                  // Build imageUrls list
                  final List<String> imageUrls = imageUrlInput.isNotEmpty
                      ? [imageUrlInput]
                      : [];

                  // Extract just filename from iconAsset (handles full paths)
                  String? finalIconAsset;
                  if (iconAssetInput.isNotEmpty) {
                    // Get just the filename if a full path was provided
                    finalIconAsset = iconAssetInput.contains('/')
                        ? iconAssetInput.split('/').last
                        : iconAssetInput;
                  }

                  if (isEdit) {
                    await _adminService.updateCategory(category.id, {
                      'name': nameController.text.trim(),
                      'order': orderValue,
                      'aliases': aliases,
                      'iconAsset': finalIconAsset,
                      'imageUrls': imageUrls,
                    });
                  } else {
                    await _adminService.createCategory(
                      CategoryModel(
                        id: '',
                        name: nameController.text.trim(),
                        order: orderValue,
                        aliases: aliases.isNotEmpty ? aliases : null,
                        iconAsset: finalIconAsset,
                        imageUrls: imageUrls,
                      ),
                    );
                  }
                  if (mounted && dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                    await _loadCategories();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isEdit
                              ? 'Category updated successfully'
                              : 'Category created successfully',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted && dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: Text(isEdit ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(CategoryModel category) {
    showDialog(
      context: context,
      builder: (deleteDialogContext) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text(
          'Are you sure you want to delete "${category.name}"? This action cannot be undone and will be reflected on all connected devices.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(deleteDialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _adminService.deleteCategory(category.id);
                if (mounted && deleteDialogContext.mounted) {
                  Navigator.pop(deleteDialogContext);
                  await _loadCategories();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Category deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted && deleteDialogContext.mounted) {
                  Navigator.pop(deleteDialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting category: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
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
