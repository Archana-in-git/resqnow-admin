import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resqnow_admin/features/authentication/controllers/admin_auth_controller.dart';
import 'package:resqnow_admin/features/authentication/pages/admin_login_page.dart';
import 'package:resqnow_admin/features/admin/presentation/pages/admin_dashboard_page.dart';

/// Admin Shell - Handles authentication routing and state management
/// Routes to login page if not authenticated, admin dashboard if authenticated
class AdminShell extends StatelessWidget {
  const AdminShell({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminAuthController>(
      builder: (context, authController, _) {
        // Show loading while checking auth state
        if (!authController.isAuthenticated && authController.currentUser == null) {
          // Not authenticated - show login page
          return const AdminLoginPage();
        }

        // Authenticated but not admin
        if (authController.isAuthenticated && !authController.isAdmin) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: 64,
                      color: Colors.red[300],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Access Denied',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Admin role required to access this dashboard.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        authController.signOut();
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Authenticated and admin - show dashboard
        return const AdminDashboardPage();
      },
    );
  }
}
