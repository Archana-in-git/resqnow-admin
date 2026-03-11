import 'package:flutter/material.dart';
import 'package:resqnow_admin/core/services/admin_service.dart';
import 'package:resqnow_admin/features/admin/data/models/resource_models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Medical Conditions Management Page
class ConditionsManagementPage extends StatefulWidget {
  const ConditionsManagementPage({super.key});

  @override
  State<ConditionsManagementPage> createState() =>
      _ConditionsManagementPageState();
}

class _ConditionsManagementPageState extends State<ConditionsManagementPage>
    with WidgetsBindingObserver {
  late AdminService _adminService;
  List<CategoryModel> _categories = [];
  bool _isLoading = false;

  final List<String> _severityLevels = ['low', 'medium', 'high', 'critical'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _adminService = AdminService(
      firestore: FirebaseFirestore.instance,
      auth: FirebaseAuth.instance,
    );
    _loadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Refresh categories when app resumes (returns from category management page)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      _loadCategories();
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: backgroundColor),
      );
    }
  }

  Future<void> _handleCategoryTap(CategoryModel category) async {
    // Check if condition exists for this category
    final existingConditions = await _adminService.getConditionsByCategory(
      category.id,
    );
    if (mounted) {
      if (existingConditions.isNotEmpty) {
        // Show existing condition details
        _showConditionDetailsDialog(existingConditions.first);
      } else {
        // Show "No condition found" dialog with Add button
        _showNoConditionFoundDialog(category);
      }
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      await _loadCategories();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _adminService.getAllCategories();
      if (mounted) {
        setState(() => _categories = categories);
      }
    } catch (e) {
      // Don't show error snackbar for categories, just log it
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medical Conditions Management (${_categories.length})'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      floatingActionButton: null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _categories.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00796B).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.category,
                      size: 64,
                      color: const Color(0xFF00796B),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'No Categories Yet',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create categories in Category Management first',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                mainAxisSpacing: 13,
                crossAxisSpacing: 13,
                childAspectRatio: 1.0,
              ),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return _buildCategoryTile(category);
              },
            ),
    );
  }

  Widget _buildCategoryTile(CategoryModel category) {
    return GestureDetector(
      onTap: () => _handleCategoryTap(category),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Container
            Container(
              height: 100,
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
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Header with name
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade100,
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Icon(
                            Icons.category,
                            color: Colors.purple.shade600,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            category.name,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              height: 1.15,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    // Manage button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _handleCategoryTap(category),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text(
                          'Manage',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
          errorBuilder: (context, error, stackTrace) {
            return Container(
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
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: Colors.grey[100],
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
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

  Widget _buildCategoriesBadges(List<String> categoryIds) {
    // Get category names for the IDs
    final categoryNames = categoryIds.map((id) {
      final category = _categories.firstWhere(
        (c) => c.id == id,
        orElse: () => CategoryModel(
          id: id,
          name: 'Unknown',
          imageUrls: [],
          description: '',
          order: 999,
        ),
      );
      return category.name;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purple.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.category,
                color: Colors.purple.shade600,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Categories (${categoryNames.length})',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categoryNames
              .map(
                (name) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.purple.shade400, width: 1),
                  ),
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.purple.shade700,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  /// Get severity color palette based on severity level
  Map<String, Color> _getSeverityColors(String severity) {
    switch (severity) {
      case 'low':
        return {
          'color': const Color(0xFF4CAF50),
          'bgColor': const Color(0xFFE8F5E9),
        };
      case 'medium':
        return {
          'color': const Color(0xFFFF9800),
          'bgColor': const Color(0xFFFFF3E0),
        };
      case 'high':
        return {
          'color': const Color(0xFFF44336),
          'bgColor': const Color(0xFFFFEBEE),
        };
      case 'critical':
        return {
          'color': const Color(0xFFC62828),
          'bgColor': const Color(0xFFB71C1C).withValues(alpha: 0.1),
        };
      default:
        return {'color': Colors.grey, 'bgColor': Colors.grey.shade100};
    }
  }

  void _showConditionDetailsDialog(ConditionModel condition) {
    final severityColors = _getSeverityColors(condition.severity);
    final Color severityColor = severityColors['color']!;
    final Color severityBgColor = severityColors['bgColor']!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with condition name and severity
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: severityBgColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.health_and_safety,
                          color: severityColor,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              condition.name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: severityBgColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                condition.severity.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: severityColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Image Gallery (with actual image previews)
                  if (condition.imageUrls.isNotEmpty) ...[
                    _buildImageGallerySectionModern(condition.imageUrls),
                    const SizedBox(height: 24),
                  ],

                  // Categories
                  if (condition.categories.isNotEmpty) ...[
                    _buildCategoriesBadges(condition.categories),
                    const SizedBox(height: 24),
                  ],

                  // Doctor Types
                  _buildInfoCard(
                    icon: Icons.person_4,
                    title: 'Medical Specialists',
                    content: condition.doctorType.isEmpty
                        ? 'None specified'
                        : condition.doctorType.join(', '),
                    bgColor: const Color(0xFFE3F2FD),
                    iconColor: const Color(0xFF1976D2),
                  ),
                  const SizedBox(height: 16),

                  // First Aid Description
                  if (condition.firstAidDescription.isNotEmpty) ...[
                    _buildStepsCard(
                      'First Aid Steps',
                      condition.firstAidDescription,
                      Colors.green,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Video URL
                  if (condition.videoUrl != null &&
                      condition.videoUrl!.isNotEmpty) ...[
                    _buildInfoCard(
                      icon: Icons.video_library,
                      title: 'Reference Video',
                      content: condition.videoUrl!,
                      bgColor: const Color(0xFFF3E5F5),
                      iconColor: const Color(0xFF7B1FA2),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Hospital Locator Link
                  if (condition.hospitalLocatorLink != null &&
                      condition.hospitalLocatorLink!.isNotEmpty) ...[
                    _buildInfoCard(
                      icon: Icons.location_on,
                      title: 'Find Hospitals',
                      content: condition.hospitalLocatorLink!,
                      bgColor: const Color(0xFFECEFF1),
                      iconColor: const Color(0xFF455A64),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Metadata
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Information',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Created: ${condition.createdAt.toString().split('.')[0]}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.update,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Updated: ${condition.updatedAt.toString().split('.')[0]}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                          label: const Text('Close'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _showAddEditDialog(condition: condition);
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageGallerySectionModern(List<String> imageUrls) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.image, color: Colors.blue.shade600, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'Medical Images (${imageUrls.length})',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: imageUrls.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(
                  right: index == imageUrls.length - 1 ? 0 : 12,
                ),
                child: GestureDetector(
                  onTap: () {
                    // Can add image preview dialog here
                  },
                  child: Container(
                    width: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Container(
                            color: Colors.grey[200],
                            child: Image.network(
                              imageUrls[index],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.broken_image,
                                        color: Colors.grey[500],
                                        size: 32,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Failed to load',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value:
                                            loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                            : null,
                                      ),
                                    );
                                  },
                            ),
                          ),
                          // Index badge
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade600,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '#${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    required Color bgColor,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: iconColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: TextStyle(fontSize: 13, color: Colors.grey[800]),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsCard(String title, List<String> steps, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: steps
                .asMap()
                .entries
                .map(
                  (e) => Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: accentColor,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${e.key + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            e.value,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[800],
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  void _showNoConditionFoundDialog(CategoryModel category) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('No Condition Found'),
        content: Text(
          'No condition exists for "${category.name}" yet.\n\nWould you like to add one?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(dialogContext);
              _showAddEditDialog(category: category);
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Condition'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddEditDialog({
    ConditionModel? condition,
    CategoryModel? category,
  }) {
    final isEdit = condition != null;
    final nameController = TextEditingController(text: condition?.name ?? '');
    String? selectedSeverity = condition?.severity ?? 'medium';
    final imageUrlsController = TextEditingController(
      text: condition?.imageUrls.join('\n') ?? '',
    );
    final firstAidDescriptionController = TextEditingController(
      text: condition?.firstAidDescription.join('\n') ?? '',
    );
    final doctorTypeController = TextEditingController(
      text: condition?.doctorType.join(', ') ?? '',
    );
    final videoUrlController = TextEditingController(
      text: condition?.videoUrl ?? '',
    );
    final hospitalLocatorController = TextEditingController(
      text: condition?.hospitalLocatorLink ?? '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (innerContext, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Edit Condition' : 'Add New Condition'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Condition Name *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedSeverity,
                  decoration: const InputDecoration(
                    labelText: 'Severity Level',
                    border: OutlineInputBorder(),
                  ),
                  items: _severityLevels.map((severity) {
                    return DropdownMenuItem(
                      value: severity,
                      child: Text(severity.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() => selectedSeverity = value ?? 'medium');
                  },
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Medical Images',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'One per line',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.blue[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: imageUrlsController,
                      decoration: InputDecoration(
                        labelText: 'Image URLs (HTTPS recommended)',
                        border: const OutlineInputBorder(),
                        hintText:
                            'https://example.com/image1.jpg\nhttps://example.com/image2.jpg',
                        helperText: 'Valid URLs start with https:// or http://',
                      ),
                      maxLines: 3,
                      onChanged: (value) {
                        setDialogState(() {});
                      },
                    ),
                    if (imageUrlsController.text.trim().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.blue[200]!),
                          ),
                          child: Text(
                            'URLs Found: ${imageUrlsController.text.split('\n').where((e) => e.trim().isNotEmpty && (e.trim().startsWith('http://') || e.trim().startsWith('https://'))).length}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: doctorTypeController,
                  decoration: const InputDecoration(
                    labelText: 'Doctor Types (comma separated)',
                    border: OutlineInputBorder(),
                    hintText: 'General Practitioner, Cardiologist',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: firstAidDescriptionController,
                  decoration: const InputDecoration(
                    labelText: 'First Aid Steps (line separated)',
                    border: OutlineInputBorder(),
                    hintText: 'Step 1\nStep 2\nStep 3',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: videoUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Video URL (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: hospitalLocatorController,
                  decoration: const InputDecoration(
                    labelText: 'Hospital Locator Link (optional)',
                    border: OutlineInputBorder(),
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
                  _showSnackBar('Name cannot be empty', Colors.red);
                  return;
                }

                Navigator.pop(dialogContext);

                try {
                  final imageUrls = imageUrlsController.text
                      .split('\n')
                      .map((e) => e.trim())
                      .where(
                        (e) =>
                            e.isNotEmpty &&
                            (e.startsWith('http://') ||
                                e.startsWith('https://')),
                      )
                      .toList();

                  final firstAidDescription = firstAidDescriptionController.text
                      .split('\n')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList();

                  final doctorType = doctorTypeController.text
                      .split(',')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList();

                  if (isEdit) {
                    // Keep existing categories when updating
                    await _adminService.updateCondition(condition.id, {
                      'name': nameController.text,
                      'severity': selectedSeverity,
                      'imageUrls': imageUrls,
                      'firstAidDescription': firstAidDescription,
                      'doctorType': doctorType,
                      'videoUrl': videoUrlController.text.isEmpty
                          ? null
                          : videoUrlController.text,
                      'hospitalLocatorLink':
                          hospitalLocatorController.text.isEmpty
                          ? null
                          : hospitalLocatorController.text,
                      'updatedAt': DateTime.now(),
                    });
                  } else {
                    // Link to current category when creating
                    await _adminService.createCondition(
                      ConditionModel(
                        id: '',
                        name: nameController.text,
                        severity: selectedSeverity ?? 'medium',
                        imageUrls: imageUrls,
                        firstAidDescription: firstAidDescription,
                        faqs: [],
                        doctorType: doctorType,
                        categories: category != null ? [category.id] : [],
                        videoUrl: videoUrlController.text.isEmpty
                            ? null
                            : videoUrlController.text,
                        hospitalLocatorLink:
                            hospitalLocatorController.text.isEmpty
                            ? null
                            : hospitalLocatorController.text,
                        createdAt: DateTime.now(),
                      ),
                    );
                  }
                  await _loadData();
                  _showSnackBar(
                    isEdit
                        ? 'Condition updated successfully'
                        : 'Condition created successfully',
                    Colors.green,
                  );
                } catch (e) {
                  _showSnackBar('Error: $e', Colors.red);
                }
              },
              child: Text(isEdit ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }
}
