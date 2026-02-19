import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Home Configuration Management Page
class HomeConfigManagementPage extends StatefulWidget {
  const HomeConfigManagementPage({Key? key}) : super(key: key);

  @override
  State<HomeConfigManagementPage> createState() =>
      _HomeConfigManagementPageState();
}

class _HomeConfigManagementPageState extends State<HomeConfigManagementPage> {
  late final FirebaseFirestore firestore;
  List<HomeSection> _sections = [];
  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    firestore = FirebaseFirestore.instance;
    _loadSections();
  }

  Future<void> _loadSections() async {
    setState(() => _isLoading = true);
    try {
      final doc = await firestore.collection('app_config').doc('home').get();
      
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final sectionsData = data['sections'] as List? ?? [];
        _sections = sectionsData
            .map((s) => HomeSection.fromJson(s as Map<String, dynamic>))
            .toList();
      } else {
        // Initialize default sections
        _sections = [
          HomeSection(
            id: 'first_aid_categories',
            name: 'First Aid Categories',
            description: 'Browse medical condition categories',
            isVisible: true,
            order: 1,
            icon: Icons.list.codePoint,
          ),
          HomeSection(
            id: 'nearby_hospitals',
            name: 'Nearby Hospitals',
            description: 'Find nearest hospitals and clinics',
            isVisible: true,
            order: 2,
            icon: Icons.local_hospital.codePoint,
          ),
          HomeSection(
            id: 'first_aid_resources',
            name: 'First Aid Resources',
            description: 'Learn first aid techniques and safety',
            isVisible: true,
            order: 3,
            icon: Icons.medical_services.codePoint,
          ),
          HomeSection(
            id: 'blood_banks',
            name: 'Blood Banks & Donors',
            description: 'Find blood donors and blood banks',
            isVisible: true,
            order: 4,
            icon: Icons.bloodtype.codePoint,
          ),
          HomeSection(
            id: 'workshops',
            name: 'Workshops & Training',
            description: 'Attend first aid workshops',
            isVisible: true,
            order: 5,
            icon: Icons.school.codePoint,
          ),
          HomeSection(
            id: 'emergency_contacts',
            name: 'Emergency Contacts',
            description: 'Quick access to emergency numbers',
            isVisible: true,
            order: 6,
            icon: Icons.emergency.codePoint,
          ),
        ];
      }
    } catch (e) {
      _showErrorSnackbar('Error loading configuration: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSections() async {
    setState(() => _isSaving = true);
    try {
      // Update order based on current list order
      for (int i = 0; i < _sections.length; i++) {
        _sections[i] = _sections[i].copyWith(order: i + 1);
      }

      await firestore.collection('app_config').doc('home').set({
        'sections': _sections.map((s) => s.toJson()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _showErrorSnackbar('Configuration saved successfully');
    } catch (e) {
      _showErrorSnackbar('Error saving configuration: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!_isSaving) {
          return true;
        }
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Home Page Configuration'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            if (_isSaving)
              const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: _saveSections,
                tooltip: 'Save configuration',
              ),
            const SizedBox(width: 8),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Section Management',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Drag to reorder sections. Toggle visibility to show/hide from home page. Click Edit to customize details.',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ReorderableListView(
                      onReorder: (oldIndex, newIndex) {
                        setState(() {
                          if (newIndex > oldIndex) {
                            newIndex -= 1;
                          }
                          final item = _sections.removeAt(oldIndex);
                          _sections.insert(newIndex, item);
                        });
                      },
                      children: _sections.map((section) {
                        return _buildSectionTile(section);
                      }).toList(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isSaving ? null : _saveSections,
                        icon: const Icon(Icons.save),
                        label: const Text('Save Changes'),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSectionTile(HomeSection section) {
    return Card(
      key: ValueKey(section.id),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.drag_handle),
        title: Text(section.name),
        subtitle: Text(section.description),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: section.isVisible,
              onChanged: (value) {
                setState(() {
                  final index = _sections.indexOf(section);
                  _sections[index] = section.copyWith(isVisible: value);
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                _showEditDialog(section);
              },
            ),
            IconButton(
              icon: const Icon(Icons.info),
              onPressed: () {
                _showSectionInfo(section);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(HomeSection section) {
    final nameController = TextEditingController(text: section.name);
    final descriptionController =
        TextEditingController(text: section.description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${section.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Section Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                final index = _sections.indexOf(section);
                _sections[index] = section.copyWith(
                  name: nameController.text,
                  description: descriptionController.text,
                );
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showSectionInfo(HomeSection section) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(section.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('ID: ${section.id}'),
              const SizedBox(height: 8),
              Text('Status: ${section.isVisible ? "Visible" : "Hidden"}'),
              const SizedBox(height: 8),
              Text('Display Order: ${section.order}'),
              const SizedBox(height: 8),
              Text('Description: ${section.description}'),
              const SizedBox(height: 16),
              Text(
                'This section will ${section.isVisible ? "be shown" : "not be shown"} on the home page.',
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class HomeSection {
  final String id;
  final String name;
  final String description;
  final bool isVisible;
  final int order;
  final int icon;

  HomeSection({
    required this.id,
    required this.name,
    required this.description,
    required this.isVisible,
    required this.order,
    this.icon = 0,
  });

  HomeSection copyWith({
    String? id,
    String? name,
    String? description,
    bool? isVisible,
    int? order,
    int? icon,
  }) {
    return HomeSection(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isVisible: isVisible ?? this.isVisible,
      order: order ?? this.order,
      icon: icon ?? this.icon,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'isVisible': isVisible,
      'order': order,
      'icon': icon,
    };
  }

  factory HomeSection.fromJson(Map<String, dynamic> json) {
    return HomeSection(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      isVisible: json['isVisible'] as bool? ?? true,
      order: json['order'] as int? ?? 0,
      icon: json['icon'] as int? ?? 0,
    );
  }
}
