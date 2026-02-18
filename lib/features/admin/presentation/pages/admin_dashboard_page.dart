import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resqnow_admin/features/authentication/controllers/admin_auth_controller.dart';
import 'package:resqnow_admin/features/admin/presentation/pages/blood_donor_management/blood_donor_management_page.dart';
import 'package:resqnow_admin/features/admin/presentation/pages/user_management/user_management_page.dart';
import 'package:resqnow_admin/features/admin/presentation/pages/category_management/category_management_page.dart';
import 'package:resqnow_admin/features/admin/presentation/pages/emergency_numbers_management/emergency_numbers_management_page.dart';
import 'package:resqnow_admin/features/admin/presentation/pages/resources_management/resources_management_page.dart';
import 'package:resqnow_admin/features/admin/presentation/pages/conditions_management/conditions_management_page.dart';
import 'package:resqnow_admin/features/admin/presentation/pages/home_config_management/home_config_management_page.dart';

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
        actions: [
          Consumer<AdminAuthController>(
            builder: (context, authController, _) {
              return PopupMenuButton<String>(
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    value: 'profile',
                    child: Row(
                      children: [
                        Icon(
                          Icons.person,
                          size: 20,
                          color: Colors.grey[700],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Logged In',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                authController.currentUser?.email ?? 'Admin',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    enabled: false,
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(
                          Icons.logout,
                          size: 20,
                          color: Colors.red[600],
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Logout',
                          style: TextStyle(
                            color: Colors.red[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Confirm Logout'),
                          content: const Text(
                            'Are you sure you want to logout of the admin dashboard?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                authController.signOut();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text(
                                'Logout',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
          const SizedBox(width: 8),
        ],
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
    Widget pageToNavigate;
    
    switch (index) {
      case 0:
        // Dashboard - refresh current page
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Refreshing dashboard...')),
        );
        return;
      case 1:
        // User Management
        pageToNavigate = const UserManagementPage();
        break;
      case 2:
        // Blood Donor Management
        pageToNavigate = const BloodDonorManagementPage();
        break;
      case 3:
        // Category Management
        pageToNavigate = const CategoryManagementPage();
        break;
      case 4:
        // Emergency Numbers Management
        pageToNavigate = const EmergencyNumbersManagementPage();
        break;
      case 5:
        // Resources Management
        pageToNavigate = const ResourcesManagementPage();
        break;
      case 6:
        // Conditions Management
        pageToNavigate = const ConditionsManagementPage();
        break;
      case 7:
        // Home Config Management
        pageToNavigate = const HomeConfigManagementPage();
        break;
      default:
        return;
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => pageToNavigate),
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
