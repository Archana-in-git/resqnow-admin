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

  /// Check if the path is a network URL
  bool _isNetworkUrl(String path) {
    return path.startsWith('http://') || path.startsWith('https://');
  }

  /// Transform database asset path to actual file location
  /// Handles any path format with forward or backward slashes
  /// Extracts filename and applies space-to-underscore conversion
  String _transformAssetPath(String databasePath) {
    // If it's a URL, return as-is
    if (_isNetworkUrl(databasePath)) return databasePath;
    // Normalize path: replace backslashes with forward slashes
    var normalizedPath = databasePath.replaceAll('\\', '/');
    // Extract just the filename from any path format
    var filename = normalizedPath.split('/').last;
    // Replace spaces with underscores to avoid web URL encoding issues
    filename = filename.replaceAll(' ', '_');
    // Return correct asset path
    return 'assets/images/icons/$filename';
  }

  /// Build asset image with proper error handling - supports both URLs and local assets
  /// Priority: imageUrl (if available) > local asset
  Widget _buildAssetImage(CategoryModel category) {
    // Try image URL first if available
    if (category.imageUrls.isNotEmpty) {
      final imageUrl = category.imageUrls.first;
      return ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.orange[50],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image, size: 60, color: Colors.orange[400]),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'URL Error: ${imageUrl.split('/').last}',
                      style: TextStyle(fontSize: 9, color: Colors.orange[600]),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }

    // Fall back to local asset
    if (category.iconAsset != null && category.iconAsset!.isNotEmpty) {
      final actualPath = _transformAssetPath(category.iconAsset!);
      return ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        child: Image.asset(
          actualPath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.blue[50],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image, size: 60, color: Colors.blue[400]),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'Asset: ${category.iconAsset!.split('/').last}',
                      style: TextStyle(fontSize: 10, color: Colors.blue[600]),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }

    // No image provided
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
      ),
      child: Container(
        color: Colors.grey[200],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              'No image',
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Category Management'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.update),
            tooltip: 'Fix duplicate orders',
            onPressed: _showFixOrdersDialog,
          ),
        ],
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
              padding: const EdgeInsets.all(16),
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
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              color: Colors.white,
            ),
            child:
                (category.imageUrls.isNotEmpty ||
                    (category.iconAsset != null &&
                        category.iconAsset!.isNotEmpty))
                ? _buildAssetImage(category)
                : Container(
                    color: Colors.grey[200],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.category, size: 60, color: Colors.grey[400]),
                        const SizedBox(height: 8),
                        Text(
                          'No image',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
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
                  const SizedBox(height: 8),
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
                  const Spacer(),
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
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
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
                            backgroundColor: Colors.red[600],
                            foregroundColor: Colors.white,
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
      text: category?.aliases.join(", ") ?? '',
    );

    // Local icon asset field
    final iconAssetController = TextEditingController(
      text: category?.iconAsset ?? '',
    );

    // Image URL field (use first URL if available)
    final imageUrlController = TextEditingController(
      text: category?.imageUrls.isNotEmpty ?? false
          ? category!.imageUrls.first
          : '',
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

                // Divider for Image Section
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey[400])),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          'Image Options',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey[400])),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Local Asset Field
                TextField(
                  controller: iconAssetController,
                  decoration: const InputDecoration(
                    labelText: 'Local Asset (File Name)',
                    border: OutlineInputBorder(),
                    hintText: 'e.g., avatar.jpg, icon.png',
                    helperText:
                        'Files should be in assets/images/icons/ folder',
                  ),
                ),
                const SizedBox(height: 12),

                // OR Divider
                Center(
                  child: Text(
                    '— OR —',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
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
                    helperText:
                        'Direct URL to image (takes priority over local asset)',
                  ),
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 8),

                // Info box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, size: 18, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Provide at least one image source. URL takes priority.',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.blue[700],
                          ),
                        ),
                      ),
                    ],
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
                if (nameController.text.isEmpty) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Name cannot be empty')),
                    );
                  }
                  return;
                }

                // Check if at least one image source is provided
                final hasIconAsset = iconAssetController.text.trim().isNotEmpty;
                final hasImageUrl = imageUrlController.text.trim().isNotEmpty;

                if (!hasIconAsset && !hasImageUrl) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Please provide either a local asset or an image URL',
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

                  final iconAsset = iconAssetController.text.trim();
                  final imageUrlInput = imageUrlController.text.trim();

                  // Build imageUrls list - include URL if provided
                  final imageUrls = <String>[];
                  if (imageUrlInput.isNotEmpty) {
                    imageUrls.add(imageUrlInput);
                  }

                  if (isEdit) {
                    await _adminService.updateCategory(category.id, {
                      'name': nameController.text.trim(),
                      'order': orderValue,
                      'aliases': aliases,
                      'iconAsset': iconAsset.isNotEmpty ? iconAsset : null,
                      'imageUrls': imageUrls,
                    });
                  } else {
                    await _adminService.createCategory(
                      CategoryModel(
                        id: '',
                        name: nameController.text.trim(),
                        order: orderValue,
                        aliases: aliases.isNotEmpty ? aliases : null,
                        iconAsset: iconAsset.isNotEmpty ? iconAsset : null,
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

  void _showFixOrdersDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Fix Duplicate Orders'),
        content: const Text(
          'Renumber all categories sequentially (1, 2, 3, ...)?\n\nThis will fix any duplicate order values.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final count = await _adminService.fixDuplicateOrders();
                if (mounted && dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                  await _loadCategories();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Fixed duplicate orders! Renumbered $count categories.',
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
                      content: Text('Failed to fix orders: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Fix', style: TextStyle(color: Colors.white)),
          ),
        ],
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
