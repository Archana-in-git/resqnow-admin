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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading categories: $e')),
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
              : ListView.builder(
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    return _buildCategoryTile(category);
                  },
                ),
    );
  }

  Widget _buildCategoryTile(CategoryModel category) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.teal[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.category, color: Colors.teal[700]),
        ),
        title: Text(category.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order: ${category.order ?? "Not set"}'),
            Text(
              'Aliases: ${category.aliases?.join(", ") ?? "None"}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
          onSelected: (value) {
            if (value == 'edit') {
              _showAddEditDialog(category: category);
            } else if (value == 'delete') {
              _showDeleteDialog(category);
            }
          },
        ),
      ),
    );
  }

  void _showAddEditDialog({CategoryModel? category}) {
    final isEdit = category != null;
    final nameController = TextEditingController(text: category?.name ?? '');
    final orderController = TextEditingController(
      text: category?.order?.toString() ?? '0',
    );
    final aliasesController = TextEditingController(
      text: category?.aliases?.join(", ") ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Edit Category' : 'Add New Category'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: orderController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Display Order',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: aliasesController,
                decoration: const InputDecoration(
                  labelText: 'Aliases (comma separated)',
                  border: OutlineInputBorder(),
                  hintText: 'pain, headache, migraine',
                ),
                maxLines: 2,
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
              if (nameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Name cannot be empty')),
                );
                return;
              }

              try {
                final aliases = aliasesController.text
                    .split(',')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList();

                if (isEdit) {
                  await _adminService.updateCategory(
                    category.id,
                    {
                      'name': nameController.text,
                      'order': int.parse(orderController.text),
                      'aliases': aliases,
                    },
                  );
                } else {
                  await _adminService.createCategory(
                    CategoryModel(
                      id: '',
                      name: nameController.text,
                      order: int.parse(orderController.text),
                      aliases: aliases,
                    ),
                  );
                }
                if (mounted) {
                  Navigator.pop(context);
                  _loadCategories();
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

  void _showDeleteDialog(CategoryModel category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text(
          'Are you sure you want to delete "${category.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _adminService.deleteCategory(category.id);
                if (mounted) {
                  Navigator.pop(context);
                  _loadCategories();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Category deleted')),
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
