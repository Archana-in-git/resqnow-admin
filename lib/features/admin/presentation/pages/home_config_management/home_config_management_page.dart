import 'package:flutter/material.dart';

/// Home Configuration Management Page
class HomeConfigManagementPage extends StatefulWidget {
  const HomeConfigManagementPage({Key? key}) : super(key: key);

  @override
  State<HomeConfigManagementPage> createState() =>
      _HomeConfigManagementPageState();
}

class _HomeConfigManagementPageState extends State<HomeConfigManagementPage> {
  List<HomeSection> _sections = [
    HomeSection(
      id: 'first_aid_categories',
      name: 'First Aid Categories',
      isVisible: true,
      order: 1,
    ),
    HomeSection(
      id: 'nearby_hospitals',
      name: 'Nearby Hospitals',
      isVisible: true,
      order: 2,
    ),
    HomeSection(
      id: 'first_aid_resources',
      name: 'First Aid Resources',
      isVisible: true,
      order: 3,
    ),
    HomeSection(
      id: 'blood_banks',
      name: 'Blood Banks & Donors',
      isVisible: true,
      order: 4,
    ),
    HomeSection(id: 'workshops', name: 'Workshops', isVisible: true, order: 5),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page Configuration'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
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
                      'Drag to reorder sections. Toggle visibility to show/hide from home page.',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
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
                  // Update order values
                  for (int i = 0; i < _sections.length; i++) {
                    _sections[i] = _sections[i].copyWith(order: i + 1);
                  }
                });
                // TODO: Save order to backend
              },
              children: _sections.map((section) {
                return _buildSectionTile(section);
              }).toList(),
            ),
          ),
        ],
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
        subtitle: Text('Order: ${section.order}'),
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
                // TODO: Save visibility to backend
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
              const SizedBox(height: 16),
              Text(
                'This section will ${section.isVisible ? "be shown" : "not be shown"} on the home page.',
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
  final bool isVisible;
  final int order;

  HomeSection({
    required this.id,
    required this.name,
    required this.isVisible,
    required this.order,
  });

  HomeSection copyWith({
    String? id,
    String? name,
    bool? isVisible,
    int? order,
  }) {
    return HomeSection(
      id: id ?? this.id,
      name: name ?? this.name,
      isVisible: isVisible ?? this.isVisible,
      order: order ?? this.order,
    );
  }
}
