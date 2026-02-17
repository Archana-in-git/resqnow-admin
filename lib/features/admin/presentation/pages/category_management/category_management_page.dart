import 'package:flutter/material.dart';
import 'package:resqnow_admin/features/admin/data/models/resource_models.dart';

/// Category Management Page
class CategoryManagementPage extends StatefulWidget {
  const CategoryManagementPage({Key? key}) : super(key: key);

  @override
  State<CategoryManagementPage> createState() => _CategoryManagementPageState();
}

class _CategoryManagementPageState extends State<CategoryManagementPage> {
  List<CategoryModel> _categories = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    try {
      // TODO: Implement category loading
      _categories = [];
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading categories: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Category Management'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to create category page
        },
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _categories.isEmpty
          ? const Center(child: Text('No categories found'))
          : ReorderableListView(
              onReorder: (oldIndex, newIndex) {
                // TODO: Handle reordering
              },
              children: _categories.map((category) {
                return _buildCategoryTile(category);
              }).toList(),
            ),
    );
  }

  Widget _buildCategoryTile(CategoryModel category) {
    return Card(
      key: ValueKey(category.id),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.drag_handle),
        title: Text(category.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order: ${category.displayOrder}'),
            Row(
              children: [
                Chip(
                  label: Text(category.isVisible ? 'Visible' : 'Hidden'),
                  backgroundColor: category.isVisible
                      ? Colors.green[200]
                      : Colors.grey[200],
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(
              value: category.isVisible ? 'hide' : 'show',
              child: Text(category.isVisible ? 'Hide' : 'Show'),
            ),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
          onSelected: (value) {
            _handleCategoryAction(category, value);
          },
        ),
      ),
    );
  }

  void _handleCategoryAction(CategoryModel category, String action) {
    switch (action) {
      case 'edit':
        // TODO: Navigate to edit page
        break;
      case 'show':
      case 'hide':
        // TODO: Toggle visibility
        break;
      case 'delete':
        _showDeleteDialog(category);
        break;
    }
  }

  void _showDeleteDialog(CategoryModel category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: const Text('Are you sure you want to delete this category?'),
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
