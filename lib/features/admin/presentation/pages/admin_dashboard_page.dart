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

// Admin Dashboard color constants based on app theme
class AdminDashboardColors {
  // Primary theme colors
  static const Color primaryGradientStart = Color(0xFF00796B); // Teal primary
  static const Color primaryGradientEnd = Color(0xFF004D4A); // Darker teal
  static const Color accentColor = Color(0xFFD32F2F); // Red alert
  static const Color backgroundColor = Color(0xFFFAFAFA); // Soft white

  // Text colors
  static const Color textPrimary = Color(0xFF212121); // Dark gray
  static const Color textSecondary = Color(0xFF757575); // Muted gray
  static const Color dividerColor = Color(0xFFE0E0E0); // Light gray

  // Status colors
  static const Color success = Color(0xFF388E3C); // Green
  static const Color warning = Color(0xFFFFA000); // Amber
  static const Color emergency = Color(0xFFB71C1C); // Emergency dark red

  // Soft pastel colors for cards
  static const Color softTeal = Color(0xFF80CBC4);
  static const Color softBlue = Color(0xFF81D4FA);
  static const Color softPurple = Color(0xFFCE93D8);
  static const Color softPink = Color(0xFFF48FB1);
  static const Color softOrange = Color(0xFFFFB74D);
  static const Color softGreen = Color(0xFFA5D6A7);
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _selectedMenuIndex = 0;

  final List<AdminMenuItem> _menuItems = [
    AdminMenuItem(
      icon: Icons.dashboard,
      label: 'Dashboard',
      description: 'Overview and Analytics',
      color: AdminDashboardColors.primaryGradientStart,
      lightColor: const Color(0xFFE0F2F1),
    ),
    AdminMenuItem(
      icon: Icons.people,
      label: 'User Management',
      description: 'Manage user accounts and roles',
      color: const Color(0xFF0288D1), // Light blue
      lightColor: const Color(0xFFE1F5FE),
    ),
    AdminMenuItem(
      icon: Icons.bloodtype,
      label: 'Blood Donors',
      description: 'Manage blood donor profiles',
      color: AdminDashboardColors.accentColor, // Red alert
      lightColor: const Color(0xFFFFEBEE),
    ),
    AdminMenuItem(
      icon: Icons.list,
      label: 'Categories',
      description: 'Manage medical categories',
      color: AdminDashboardColors.warning, // Amber
      lightColor: const Color(0xFFFFF8E1),
    ),
    AdminMenuItem(
      icon: Icons.emergency,
      label: 'Emergency Numbers',
      description: 'Manage emergency contacts',
      color: AdminDashboardColors.emergency, // Emergency red
      lightColor: const Color(0xFFFFCDD2),
    ),
    AdminMenuItem(
      icon: Icons.medical_services,
      label: 'First Aid Resources',
      description: 'Manage first aid resources',
      color: const Color(0xFF1976D2), // Blue
      lightColor: const Color(0xFFE3F2FD),
    ),
    AdminMenuItem(
      icon: Icons.health_and_safety,
      label: 'Medical Conditions',
      description: 'Manage medical conditions',
      color: AdminDashboardColors.success, // Green
      lightColor: const Color(0xFFC8E6C9),
    ),
    AdminMenuItem(
      icon: Icons.home,
      label: 'Home Configuration',
      description: 'Configure home page layout',
      color: AdminDashboardColors.primaryGradientEnd, // Darker teal
      lightColor: const Color(0xFFB2DFDB),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF9DD9D2).withOpacity(0.5), // Soft teal
              const Color(0xFFAFD3E8).withOpacity(0.4), // Soft blue
              const Color(0xFFC9B8E0).withOpacity(0.4), // Soft lavender
            ],
          ),
        ),
        child: Row(
          children: [
            // LEFT SIDEBAR
            if (!isMobile) _buildSidebar(context),

            // MAIN CONTENT
            Expanded(
              child: CustomScrollView(
                slivers: [
                  // Header
                  _buildModernAppBar(context),

                  // Main Content
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 20.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Row 1: Two large cards
                          Row(
                            children: [
                              Expanded(
                                child: _buildLargeCard(
                                  context,
                                  menuItem: _menuItems[0],
                                  index: 0,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: _buildLargeCard(
                                  context,
                                  menuItem: _menuItems[1],
                                  index: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Row 2: Large left card + 2x2 grid of small cards
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: _buildLargeCard(
                                  context,
                                  menuItem: _menuItems[2],
                                  index: 2,
                                  minHeight: 320,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: GridView.count(
                                  crossAxisCount: 2,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  crossAxisSpacing: 14,
                                  mainAxisSpacing: 14,
                                  childAspectRatio: 1.0,
                                  children: List.generate(
                                    4,
                                    (idx) => _buildSmallStatCard(
                                      context,
                                      menuItem: _menuItems[3 + idx],
                                      index: 3 + idx,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Row 3: Wide promotional card
                          _buildWidePromotionalCard(context),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: const Color(0xFFB2DFDB).withOpacity(0.5), // Soft greenish teal
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Logo/Branding
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Text(
              'ResQnow',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AdminDashboardColors.primaryGradientStart,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 0.5,
              ),
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView.separated(
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemCount: _menuItems.length,
              itemBuilder: (context, index) {
                final item = _menuItems[index];
                final isSelected = _selectedMenuIndex == index;

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedMenuIndex = index;
                      });
                      _onMenuItemTap(index);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AdminDashboardColors.primaryGradientStart
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            item.icon,
                            size: 18,
                            color: isSelected
                                ? Colors.white
                                : AdminDashboardColors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              item.label,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: isSelected
                                        ? Colors.white
                                        : AdminDashboardColors.textPrimary,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    fontSize: 10,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
      ),
    );
  }

  Widget _buildLargeCard(
    BuildContext context, {
    required AdminMenuItem menuItem,
    required int index,
    double? minHeight,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onMenuItemTap(index),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          constraints: minHeight != null
              ? BoxConstraints(minHeight: minHeight)
              : null,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Header with icon
              Container(
                decoration: BoxDecoration(
                  color: menuItem.lightColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.all(12),
                child: Icon(menuItem.icon, color: menuItem.color, size: 28),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                menuItem.label,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AdminDashboardColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              // Description
              const SizedBox(height: 8),
              Text(
                menuItem.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AdminDashboardColors.textSecondary,
                  fontSize: 12,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmallStatCard(
    BuildContext context, {
    required AdminMenuItem menuItem,
    required int index,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onMenuItemTap(index),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Circular colored icon
              Container(
                decoration: BoxDecoration(
                  color: menuItem.lightColor,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(10),
                child: Icon(menuItem.icon, color: menuItem.color, size: 22),
              ),
              const SizedBox(height: 10),

              // Label
              Text(
                menuItem.label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AdminDashboardColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWidePromotionalCard(BuildContext context) {
    // Combine the last 2 menu items into a wide promotional-style card
    final item1 = _menuItems[6];
    final item2 = _menuItems[7];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            item1.color.withOpacity(0.15),
            item2.color.withOpacity(0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Left side - content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Management',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AdminDashboardColors.textSecondary,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Additional Settings',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AdminDashboardColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _onMenuItemTap(6),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    item1.icon,
                                    size: 16,
                                    color: item1.color,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    item1.label,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color:
                                              AdminDashboardColors.textPrimary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _onMenuItemTap(7),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    item2.icon,
                                    size: 16,
                                    color: item2.color,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    item2.label,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color:
                                              AdminDashboardColors.textPrimary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Right side - decorative element
          const SizedBox(width: 16),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.4),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Icon(
                Icons.settings,
                size: 40,
                color: AdminDashboardColors.primaryGradientStart.withOpacity(
                  0.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 100,
      floating: true,
      pinned: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: Colors.transparent,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 12.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back,',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AdminDashboardColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 11,
                                ),
                          ),
                          Consumer<AdminAuthController>(
                            builder: (context, authController, _) {
                              final name =
                                  authController.currentUser?.email?.split(
                                    '@',
                                  )[0] ??
                                  'Admin';
                              return Text(
                                name,
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      color: AdminDashboardColors.textPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                    ),
                              );
                            },
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          // Search icon
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              Icons.search,
                              size: 20,
                              color: AdminDashboardColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Notification icon
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              Icons.notifications_outlined,
                              size: 20,
                              color: AdminDashboardColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Profile menu
                          Consumer<AdminAuthController>(
                            builder: (context, authController, _) {
                              return PopupMenuButton<String>(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(6),
                                  child: CircleAvatar(
                                    radius: 16,
                                    backgroundColor: AdminDashboardColors
                                        .primaryGradientStart,
                                    child: Text(
                                      authController.currentUser?.email
                                              ?.substring(0, 1)
                                              .toUpperCase() ??
                                          'A',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                itemBuilder: (context) => [
                                  PopupMenuItem<String>(
                                    value: 'profile',
                                    child: Row(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: AdminDashboardColors
                                                .primaryGradientStart
                                                .withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          padding: const EdgeInsets.all(8),
                                          child: Icon(
                                            Icons.person,
                                            size: 20,
                                            color: AdminDashboardColors
                                                .primaryGradientStart,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Text(
                                                'Admin Account',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: AdminDashboardColors
                                                      .textSecondary,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                authController
                                                        .currentUser
                                                        ?.email ??
                                                    'Admin',
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w700,
                                                  color: AdminDashboardColors
                                                      .textPrimary,
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
                                        Container(
                                          decoration: BoxDecoration(
                                            color: AdminDashboardColors
                                                .accentColor
                                                .withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          padding: const EdgeInsets.all(8),
                                          child: Icon(
                                            Icons.logout,
                                            size: 20,
                                            color: AdminDashboardColors
                                                .accentColor,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Logout',
                                          style: TextStyle(
                                            color: AdminDashboardColors
                                                .accentColor,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          backgroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          title: Row(
                                            children: [
                                              Icon(
                                                Icons.logout,
                                                color: AdminDashboardColors
                                                    .accentColor,
                                                size: 28,
                                              ),
                                              const SizedBox(width: 12),
                                              const Text('Confirm Logout'),
                                            ],
                                          ),
                                          content: const Text(
                                            'Are you sure you want to logout of the admin dashboard?',
                                            style: TextStyle(
                                              color: AdminDashboardColors
                                                  .textSecondary,
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const Text(
                                                'Cancel',
                                                style: TextStyle(
                                                  color: AdminDashboardColors
                                                      .textSecondary,
                                                ),
                                              ),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                authController.signOut();
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    AdminDashboardColors
                                                        .accentColor,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 24,
                                                      vertical: 12,
                                                    ),
                                              ),
                                              child: const Text(
                                                'Logout',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700,
                                                ),
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
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
          const SnackBar(content: Text('You are on the Dashboard')),
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
  final Color color;
  final Color lightColor;

  AdminMenuItem({
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
    required this.lightColor,
  });
}
