import 'package:flutter/material.dart';

/// Admin Dashboard Home Page
class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({Key? key}) : super(key: key);

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final List<AdminMenuItem> _menuItems = [
    AdminMenuItem(
      icon: Icons.dashboard,
      label: 'Dashboard',
      description: 'Overview and Analytics',
    ),
    AdminMenuItem(
      icon: Icons.people,
      label: 'User Management',
      description: 'Manage user accounts and roles',
    ),
    AdminMenuItem(
      icon: Icons.bloodtype,
      label: 'Blood Donors',
      description: 'Manage blood donor profiles',
    ),
    AdminMenuItem(
      icon: Icons.list,
      label: 'Categories',
      description: 'Manage medical categories',
    ),
    AdminMenuItem(
      icon: Icons.emergency,
      label: 'Emergency Numbers',
      description: 'Manage emergency contacts',
    ),
    AdminMenuItem(
      icon: Icons.medical_services,
      label: 'First Aid Resources',
      description: 'Manage first aid resources',
    ),
    AdminMenuItem(
      icon: Icons.health_and_safety,
      label: 'Medical Conditions',
      description: 'Manage medical conditions',
    ),
    AdminMenuItem(
      icon: Icons.home,
      label: 'Home Configuration',
      description: 'Configure home page layout',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ResQnow Admin Dashboard'),
        elevation: 2,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome to Admin Dashboard',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Manage ResQnow application content and users',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _menuItems.length,
                itemBuilder: (context, index) {
                  final item = _menuItems[index];
                  return _buildMenuCard(context, item, index);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, AdminMenuItem item, int index) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _onMenuItemTap(index),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                item.icon,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                item.label,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  item.description,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onMenuItemTap(int index) {
    // TODO: Navigate to respective pages
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigate to ${_menuItems[index].label}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class AdminMenuItem {
  final IconData icon;
  final String label;
  final String description;

  AdminMenuItem({
    required this.icon,
    required this.label,
    required this.description,
  });
}
