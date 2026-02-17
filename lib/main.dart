import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/constants/admin_routes.dart';
import 'features/admin/presentation/pages/admin_dashboard_page.dart';
import 'features/admin/presentation/pages/user_management/user_management_page.dart';
import 'features/admin/presentation/pages/blood_donor_management/blood_donor_management_page.dart';
import 'features/admin/presentation/pages/category_management/category_management_page.dart';
import 'features/admin/presentation/pages/emergency_numbers_management/emergency_numbers_management_page.dart';
import 'features/admin/presentation/pages/resources_management/resources_management_page.dart';
import 'features/admin/presentation/pages/conditions_management/conditions_management_page.dart';
import 'features/admin/presentation/pages/home_config_management/home_config_management_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ResQnow Admin Dashboard',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const AdminDashboardPage(),
      routes: _buildRoutes(),
    );
  }

  Map<String, WidgetBuilder> _buildRoutes() {
    return {
      AdminRoutes.adminDashboard: (context) => const AdminDashboardPage(),
      AdminRoutes.userManagement: (context) => const UserManagementPage(),
      AdminRoutes.bloodDonorManagement: (context) =>
          const BloodDonorManagementPage(),
      AdminRoutes.categoryManagement: (context) =>
          const CategoryManagementPage(),
      AdminRoutes.emergencyNumbersManagement: (context) =>
          const EmergencyNumbersManagementPage(),
      AdminRoutes.resourcesManagement: (context) =>
          const ResourcesManagementPage(),
      AdminRoutes.conditionsManagement: (context) =>
          const ConditionsManagementPage(),
      AdminRoutes.homeConfigManagement: (context) =>
          const HomeConfigManagementPage(),
    };
  }
}
