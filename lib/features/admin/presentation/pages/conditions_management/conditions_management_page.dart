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

class _ConditionsManagementPageState extends State<ConditionsManagementPage> {
  late AdminService _adminService;
  List<ConditionModel> _conditions = [];
  bool _isLoading = false;

  final List<String> _severityLevels = ['low', 'medium', 'high', 'critical'];

  @override
  void initState() {
    super.initState();
    _adminService = AdminService(
      firestore: FirebaseFirestore.instance,
      auth: FirebaseAuth.instance,
    );
    _loadConditions();
  }

  Future<void> _loadConditions() async {
    setState(() => _isLoading = true);
    try {
      print('🔍 DEBUG: Starting to load conditions...');
      final conditions = await _adminService.getAllConditions();
      print(
        '✅ DEBUG: Conditions loaded successfully: ${conditions.length} found',
      );
      for (var i = 0; i < conditions.length; i++) {
        print('   [$i] ${conditions[i].name} (${conditions[i].severity})');
      }
      if (mounted) {
        setState(() => _conditions = conditions);
        if (conditions.isEmpty) {
          print('⚠️ DEBUG: No conditions in database - showing empty state');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'No conditions found. Click the + button to add one.',
              ),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      print('❌ DEBUG: Error loading conditions: $e');
      print('📍 Stack trace:\n$stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
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
        title: const Text('Medical Conditions Management'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: Colors.blue.shade600,
        child: const Icon(Icons.add, size: 28),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _conditions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.health_and_safety,
                      size: 64,
                      color: Colors.blue.shade600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'No Conditions Yet',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your first medical condition',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () => _showAddEditDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Condition'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.4,
              ),
              itemCount: _conditions.length,
              itemBuilder: (context, index) {
                final condition = _conditions[index];
                return _buildConditionTile(condition);
              },
            ),
    );
  }

  Widget _buildConditionTile(ConditionModel condition) {
    // Color mapping for severity
    final severityMap = {
      'low': {
        'color': const Color(0xFF4CAF50),
        'bgGradient1': const Color(0xFF81C784),
        'bgGradient2': const Color(0xFF4CAF50),
        'lightBg': const Color(0xFFE8F5E9),
      },
      'medium': {
        'color': const Color(0xFFFF9800),
        'bgGradient1': const Color(0xFFFFB74D),
        'bgGradient2': const Color(0xFFFF9800),
        'lightBg': const Color(0xFFFFF3E0),
      },
      'high': {
        'color': const Color(0xFFE53935),
        'bgGradient1': const Color(0xFFEF5350),
        'bgGradient2': const Color(0xFFE53935),
        'lightBg': const Color(0xFFFFEBEE),
      },
      'critical': {
        'color': const Color(0xFFC62828),
        'bgGradient1': const Color(0xFFD32F2F),
        'bgGradient2': const Color(0xFFC62828),
        'lightBg': const Color(0xFFB71C1C).withOpacity(0.15),
      },
    };

    final severity = condition.severity.toLowerCase();
    final colorScheme = severityMap[severity] ?? severityMap['low']!;

    return GestureDetector(
      onTap: () => _showConditionDetailsDialog(condition),
      child: Container(
        margin: const EdgeInsets.only(bottom: 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: (colorScheme['color'] as Color).withOpacity(0.12),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            children: [
              // Background gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme['bgGradient1'] as Color,
                      colorScheme['bgGradient2'] as Color,
                    ],
                  ),
                ),
              ),
              // Glassmorphism effect
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: colorScheme['lightBg'] as Color,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.health_and_safety,
                            color: colorScheme['color'] as Color,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                condition.name,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  height: 1.1,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: (colorScheme['color'] as Color)
                                      .withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  condition.severity.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme['color'] as Color,
                                    height: 1.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: PopupMenuButton<String>(
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, size: 14),
                                    SizedBox(width: 6),
                                    Text(
                                      'Edit',
                                      style: TextStyle(fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete,
                                      size: 14,
                                      color: Colors.red,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Delete',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'edit') {
                                _showAddEditDialog(condition: condition);
                              } else if (value == 'delete') {
                                _showDeleteDialog(condition);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Stats row  - more compact
                    Row(
                      children: [
                        _buildStatBadgeCompact(
                          Icons.person_4,
                          condition.doctorType.length,
                          'Dr',
                        ),
                        const SizedBox(width: 4),
                        _buildStatBadgeCompact(
                          Icons.directions_walk,
                          condition.firstAidDescription.length,
                          'St',
                        ),
                        const SizedBox(width: 4),
                        _buildStatBadgeCompact(
                          Icons.image,
                          condition.imageUrls.length,
                          'Img',
                        ),
                        const SizedBox(width: 4),
                        _buildStatBadgeCompact(
                          Icons.help,
                          condition.faqs.length,
                          'FAQ',
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Specialists preview (simplified)
                    if (condition.doctorType.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Specialists',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Wrap(
                            spacing: 3,
                            runSpacing: 2,
                            children: condition.doctorType
                                .take(1)
                                .map(
                                  (doctor) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: Colors.blue.shade200,
                                        width: 0.5,
                                      ),
                                    ),
                                    child: Text(
                                      doctor,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.blue.shade700,
                                        fontWeight: FontWeight.w500,
                                        height: 1.0,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                          if (condition.doctorType.length > 1)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                '+${condition.doctorType.length - 1}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w600,
                                  height: 1.0,
                                ),
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
              // Top accent bar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme['bgGradient1'] as Color,
                        colorScheme['bgGradient2'] as Color,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatBadge(IconData icon, int count, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: Colors.grey[700]),
            const SizedBox(height: 4),
            Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBadgeCompact(IconData icon, int count, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 17, color: Colors.grey[700]),
            const SizedBox(height: 2),
            Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
                height: 1.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showConditionDetailsDialog(ConditionModel condition) {
    Color severityColor = Colors.grey;
    Color severityBgColor = Colors.grey[100]!;
    if (condition.severity == 'low') {
      severityColor = const Color(0xFF4CAF50);
      severityBgColor = const Color(0xFFE8F5E9);
    } else if (condition.severity == 'medium') {
      severityColor = const Color(0xFFFF9800);
      severityBgColor = const Color(0xFFFFF3E0);
    } else if (condition.severity == 'high') {
      severityColor = const Color(0xFFF44336);
      severityBgColor = const Color(0xFFFFEBEE);
    } else if (condition.severity == 'critical') {
      severityColor = const Color(0xFFC62828);
      severityBgColor = const Color(0xFFB71C1C).withOpacity(0.1);
    }

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

                  // Do Not Do
                  if (condition.doNotDo.isNotEmpty) ...[
                    _buildStepsCard('Do Not Do', condition.doNotDo, Colors.red),
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

                  // Required Kits
                  if (condition.requiredKits.isNotEmpty) ...[
                    _buildKitsCardSection(
                      'Required Kits',
                      condition.requiredKits,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // FAQs
                  if (condition.faqs.isNotEmpty) ...[
                    _buildFaqsCardSection(
                      'Frequently Asked Questions',
                      condition.faqs,
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
                          color: Colors.black.withOpacity(0.1),
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

  Widget _buildImageGallerySection(List<String> imageUrls) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.image, color: Colors.blue, size: 20),
            const SizedBox(width: 8),
            Text(
              'Images (${imageUrls.length})',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: imageUrls.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(
                  right: index == imageUrls.length - 1 ? 0 : 12,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 140,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          imageUrls[index],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.broken_image,
                                    color: Colors.grey[400],
                                    size: 32,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Failed to load',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                        ),
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '#${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
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
        border: Border.all(color: iconColor.withOpacity(0.2)),
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
        border: Border.all(color: accentColor.withOpacity(0.3)),
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

  Widget _buildKitsCardSection(String title, List<Map<String, dynamic>> kits) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.medical_services, color: Colors.red[600], size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          children: kits
              .asMap()
              .entries
              .map(
                (e) => Container(
                  margin: EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e.value['name'] ?? 'Kit ${e.key + 1}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      if (e.value['description'] != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          e.value['description'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildFaqsCardSection(String title, List<Map<String, dynamic>> faqs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.help, color: Colors.purple[600], size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          children: faqs
              .asMap()
              .entries
              .map(
                (e) => Container(
                  margin: EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E5F5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.purple[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Q: ${e.value['question'] ?? 'Unknown'}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Color(0xFF7B1FA2),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'A: ${e.value['answer'] ?? 'No answer provided'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  void _showAddEditDialog({ConditionModel? condition}) {
    final isEdit = condition != null;
    final nameController = TextEditingController(text: condition?.name ?? '');
    String? _selectedSeverity = condition?.severity ?? 'medium';
    final imageUrlsController = TextEditingController(
      text: condition?.imageUrls.join('\n') ?? '',
    );
    final firstAidDescriptionController = TextEditingController(
      text: condition?.firstAidDescription.join('\n') ?? '',
    );
    final doNotDoController = TextEditingController(
      text: condition?.doNotDo.join('\n') ?? '',
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
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEdit ? 'Edit Condition' : 'Add New Condition'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Condition Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedSeverity,
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
                    setState(() => _selectedSeverity = value ?? 'medium');
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: imageUrlsController,
                  decoration: const InputDecoration(
                    labelText: 'Image URLs (line separated)',
                    border: OutlineInputBorder(),
                    hintText:
                        'https://example.com/image1.jpg\nhttps://example.com/image2.jpg',
                  ),
                  maxLines: 3,
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
                  controller: doNotDoController,
                  decoration: const InputDecoration(
                    labelText: 'Do Not Do (line separated)',
                    border: OutlineInputBorder(),
                    hintText: 'Don\'t do this\nDon\'t do that',
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
                  final imageUrls = imageUrlsController.text
                      .split('\n')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList();

                  final firstAidDescription = firstAidDescriptionController.text
                      .split('\n')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList();

                  final doNotDo = doNotDoController.text
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
                    await _adminService.updateCondition(condition.id, {
                      'name': nameController.text,
                      'severity': _selectedSeverity,
                      'imageUrls': imageUrls,
                      'firstAidDescription': firstAidDescription,
                      'doNotDo': doNotDo,
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
                    await _adminService.createCondition(
                      ConditionModel(
                        id: '',
                        name: nameController.text,
                        severity: _selectedSeverity ?? 'medium',
                        imageUrls: imageUrls,
                        firstAidDescription: firstAidDescription,
                        doNotDo: doNotDo,
                        requiredKits: [],
                        faqs: [],
                        doctorType: doctorType,
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
                  if (mounted) {
                    Navigator.pop(context);
                    _loadConditions();
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Error: $e')));
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

  void _showDeleteDialog(ConditionModel condition) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Condition'),
        content: Text(
          'Are you sure you want to delete "${condition.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _adminService.deleteCondition(condition.id);
                if (mounted) {
                  Navigator.pop(context);
                  _loadConditions();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Condition deleted')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
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
