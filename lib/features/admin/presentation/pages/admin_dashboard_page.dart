import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resqnow_admin/features/authentication/controllers/admin_auth_controller.dart';
import 'package:resqnow_admin/features/admin/presentation/pages/blood_donor_management/blood_donor_management_page.dart';
import 'package:resqnow_admin/features/admin/presentation/pages/blood_donor_management/call_request_management_page.dart';
import 'package:resqnow_admin/features/admin/presentation/pages/user_management/user_management_page.dart';
import 'package:resqnow_admin/features/admin/presentation/pages/category_management/category_management_page.dart';
import 'package:resqnow_admin/features/admin/presentation/pages/emergency_numbers_management/emergency_numbers_management_page.dart';
import 'package:resqnow_admin/features/admin/presentation/pages/resources_management/resources_management_page.dart';
import 'package:resqnow_admin/features/admin/presentation/pages/conditions_management/conditions_management_page.dart';
import 'package:resqnow_admin/features/admin/presentation/pages/home_config_management/home_config_management_page.dart';
import 'package:resqnow_admin/core/services/admin_service.dart';
import 'package:resqnow_admin/features/admin/presentation/widgets/analytics_widgets.dart';
import 'package:resqnow_admin/features/admin/data/models/analytics_model.dart'
    as models;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Admin Dashboard Home Page with Analytics
class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({Key? key}) : super(key: key);

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

// Admin Dashboard color constants based on app theme
class AdminDashboardColors {
  static const Color primaryGradientStart = Color(0xFF00796B);
  static const Color primaryGradientEnd = Color(0xFF004D4A);
  static const Color accentColor = Color(0xFFD32F2F);
  static const Color backgroundColor = Color(0xFFFAFAFA);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color dividerColor = Color(0xFFE0E0E0);
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFFFA000);
  static const Color emergency = Color(0xFFB71C1C);
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _selectedMenuIndex = 0;
  late AdminService _adminService;
  late Future<models.AnalyticsStats> _analyticsStatsFuture;
  late Future<models.UserGrowthData> _userGrowthFuture;
  late Future<models.EmergencyTrendData> _emergencyTrendFuture;
  late Future<List<models.TopConditionData>> _topConditionsFuture;
  late Future<models.ContentStatusMetrics> _contentStatusFuture;
  late Future<models.RealTimeActivityPanel> _realTimeActivityFuture;
  late Future<Map<String, int>> _callRequestStatsFuture;

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
      color: const Color(0xFF0288D1),
      lightColor: const Color(0xFFE1F5FE),
    ),
    AdminMenuItem(
      icon: Icons.bloodtype,
      label: 'Blood Donors',
      description: 'Manage blood donor profiles',
      color: AdminDashboardColors.accentColor,
      lightColor: const Color(0xFFFFEBEE),
    ),
    AdminMenuItem(
      icon: Icons.phone_in_talk,
      label: 'Call Requests',
      description: 'Manage donor call requests',
      color: const Color(0xFF1565C0),
      lightColor: const Color(0xFFBBDEFB),
    ),
    AdminMenuItem(
      icon: Icons.list,
      label: 'Categories',
      description: 'Manage medical categories',
      color: AdminDashboardColors.warning,
      lightColor: const Color(0xFFFFF8E1),
    ),
    AdminMenuItem(
      icon: Icons.emergency,
      label: 'Emergency Numbers',
      description: 'Manage emergency contacts',
      color: AdminDashboardColors.emergency,
      lightColor: const Color(0xFFFFCDD2),
    ),
    AdminMenuItem(
      icon: Icons.medical_services,
      label: 'First Aid Resources',
      description: 'Manage first aid resources',
      color: const Color(0xFF1976D2),
      lightColor: const Color(0xFFE3F2FD),
    ),
    AdminMenuItem(
      icon: Icons.health_and_safety,
      label: 'Medical Conditions',
      description: 'Manage medical conditions',
      color: AdminDashboardColors.success,
      lightColor: const Color(0xFFC8E6C9),
    ),
    AdminMenuItem(
      icon: Icons.home,
      label: 'Home Configuration',
      description: 'Configure home page layout',
      color: AdminDashboardColors.primaryGradientEnd,
      lightColor: const Color(0xFFB2DFDB),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _adminService = AdminService(
      firestore: FirebaseFirestore.instance,
      auth: FirebaseAuth.instance,
    );
    _initializeFutures();
  }

  void _initializeFutures() {
    _analyticsStatsFuture = _adminService.getAnalyticsStats();
    _userGrowthFuture = _adminService.getUserGrowthData();
    _emergencyTrendFuture = _adminService.getEmergencyTrendData();
    _topConditionsFuture = _adminService.getTopConditions();
    _contentStatusFuture = _adminService.getContentStatusMetrics();
    _realTimeActivityFuture = _adminService.getRealTimeActivityData();
    _callRequestStatsFuture = _adminService.getCallRequestStats();
  }

  void _refreshAllData() {
    setState(() {
      _initializeFutures();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dashboard refreshed'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;
    final isTablet = MediaQuery.of(context).size.width < 1400;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF9DD9D2).withOpacity(0.5),
              const Color(0xFFAFD3E8).withOpacity(0.4),
              const Color(0xFFC9B8E0).withOpacity(0.4),
            ],
          ),
        ),
        child: Row(
          children: [
            if (!isMobile) _buildSidebar(context),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  _buildModernAppBar(context),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 20.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Section Title
                          const Text(
                            'Dashboard Analytics',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AdminDashboardColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Key Statistics Cards
                          _buildStatisticsSection(),
                          const SizedBox(height: 28),

                          // Charts and Analytics Row
                          if (!isTablet)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 2, child: _buildChartsColumn()),
                                const SizedBox(width: 20),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    children: [
                                      _buildRealTimeActivitySection(),
                                      const SizedBox(height: 20),
                                      _buildContentStatusSection(),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          else
                            Column(
                              children: [
                                _buildChartsColumn(),
                                const SizedBox(height: 20),
                                _buildRealTimeActivitySection(),
                                const SizedBox(height: 20),
                                _buildContentStatusSection(),
                              ],
                            ),

                          const SizedBox(height: 28),

                          // Push Notification Control
                          _buildNotificationControlSection(),
                          const SizedBox(height: 28),

                          // Management Shortcuts
                          _buildManagementShortcuts(),
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

  Widget _buildStatisticsSection() {
    return FutureBuilder<models.AnalyticsStats>(
      future: _analyticsStatsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final stats = snapshot.data ?? models.AnalyticsStats.empty();

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              StatCard(
                icon: Icons.people,
                title: 'Total Users',
                value: stats.totalUsers.toString(),
                description: 'Registered users',
                growthPercent: stats.userGrowthPercent,
                backgroundColor: const Color(0xFFE1F5FE),
                iconColor: const Color(0xFF0288D1),
              ),
              const SizedBox(width: 16),
              StatCard(
                icon: Icons.person_add,
                title: 'New Users',
                value: stats.newUsersLastWeek.toString(),
                description: 'Last 7 days',
                growthPercent: 2.5,
                backgroundColor: const Color(0xFFC8E6C9),
                iconColor: AdminDashboardColors.success,
              ),
              const SizedBox(width: 16),
              StatCard(
                icon: Icons.bloodtype,
                title: 'Active Donors',
                value: stats.activeDonors.toString(),
                description: 'Available for donation',
                growthPercent: stats.donorGrowthPercent,
                backgroundColor: const Color(0xFFFFEBEE),
                iconColor: AdminDashboardColors.accentColor,
              ),
              const SizedBox(width: 16),
              StatCard(
                icon: Icons.emergency_share,
                title: 'Emergency Clicks',
                value: stats.emergencyClicksToday.toString(),
                description: 'Today',
                growthPercent: stats.emergencyTrendsPercent,
                backgroundColor: const Color(0xFFFFCDD2),
                iconColor: AdminDashboardColors.emergency,
              ),
              const SizedBox(width: 16),
              StatCard(
                icon: Icons.trending_up,
                title: 'Active Users',
                value: stats.activeUsers.toString(),
                description: 'Currently active',
                growthPercent: stats.activeUsersPercent,
                backgroundColor: const Color(0xFFF3E5F5),
                iconColor: const Color(0xFF6A1B9A),
              ),
              const SizedBox(width: 16),
              StatCard(
                icon: Icons.search,
                title: 'Top Searched',
                value: stats.mostSearchedCondition.length > 15
                    ? '${stats.mostSearchedCondition.substring(0, 15)}...'
                    : stats.mostSearchedCondition,
                description: 'Most searched condition',
                backgroundColor: const Color(0xFFFFF8E1),
                iconColor: AdminDashboardColors.warning,
              ),
              const SizedBox(width: 16),
              // Call Request Stats Cards
              _buildCallRequestStatsCards(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCallRequestStatsCards() {
    return FutureBuilder<Map<String, int>>(
      future: _callRequestStatsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return StatCard(
            icon: Icons.phone_in_talk,
            title: 'Loading...',
            value: '...',
            description: 'Call requests',
            growthPercent: 0,
            backgroundColor: const Color(0xFFBBDEFB),
            iconColor: const Color(0xFF1565C0),
          );
        }

        if (snapshot.hasError) {
          return const SizedBox.shrink();
        }

        final stats = snapshot.data ?? {};
        final pending = stats['pending'] ?? 0;
        final approved = stats['approved'] ?? 0;

        return Row(
          children: [
            StatCard(
              icon: Icons.hourglass_empty,
              title: 'Pending Calls',
              value: pending.toString(),
              description: 'Awaiting approval',
              growthPercent: 0,
              backgroundColor: const Color(0xFFFFE0B2),
              iconColor: Colors.orange,
            ),
            const SizedBox(width: 16),
            StatCard(
              icon: Icons.check_circle,
              title: 'Approved Calls',
              value: approved.toString(),
              description: 'Ready to connect',
              growthPercent: 0,
              backgroundColor: const Color(0xFFC8E6C9),
              iconColor: AdminDashboardColors.success,
            ),
          ],
        );
      },
    );
  }

  Widget _buildChartsColumn() {
    return Column(
      children: [
        // User Growth Chart
        FutureBuilder<models.UserGrowthData>(
          future: _userGrowthFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(child: CircularProgressIndicator()),
              );
            }
            final data =
                snapshot.data ??
                models.UserGrowthData(months: [], userCounts: []);
            return UserGrowthChart(data: data);
          },
        ),
        const SizedBox(height: 20),

        // Emergency Trend Chart
        FutureBuilder<models.EmergencyTrendData>(
          future: _emergencyTrendFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(child: CircularProgressIndicator()),
              );
            }
            final data =
                snapshot.data ??
                models.EmergencyTrendData(labels: [], counts: []);
            return EmergencyTrendChart(data: data);
          },
        ),
        const SizedBox(height: 20),

        // Top Conditions Chart
        FutureBuilder<List<models.TopConditionData>>(
          future: _topConditionsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(child: CircularProgressIndicator()),
              );
            }
            final data = snapshot.data ?? [];
            return TopConditionsWidget(conditions: data);
          },
        ),
      ],
    );
  }

  Widget _buildRealTimeActivitySection() {
    return FutureBuilder<models.RealTimeActivityPanel>(
      future: _realTimeActivityFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        final data = snapshot.data;
        if (data == null) {
          return Container();
        }
        return RealTimeActivityPanelWidget(data: data);
      },
    );
  }

  Widget _buildContentStatusSection() {
    return FutureBuilder<models.ContentStatusMetrics>(
      future: _contentStatusFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        final data = snapshot.data;
        if (data == null) {
          return Container();
        }
        return ContentStatusWidget(metrics: data);
      },
    );
  }

  Widget _buildNotificationControlSection() {
    return PushNotificationControlWidget(
      onSendNotification: (title, message, recipientType, district) async {
        try {
          await _adminService.sendNotification(
            title: title,
            message: message,
            recipientType: recipientType,
            targetDistrict: district,
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Notification sent successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: $e')));
          }
        }
      },
    );
  }

  Widget _buildManagementShortcuts() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _menuItems[6].color.withOpacity(0.15),
            _menuItems[7].color.withOpacity(0.15),
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Access',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AdminDashboardColors.textSecondary,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Management Tools',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AdminDashboardColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildQuickAccessButton(1),
                    _buildQuickAccessButton(2),
                    _buildQuickAccessButton(3),
                  ],
                ),
              ],
            ),
          ),
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
                Icons.dashboard_customize,
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

  Widget _buildQuickAccessButton(int menuIndex) {
    final item = _menuItems[menuIndex];
    return SizedBox(
      height: 40,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onMenuItemTap(menuIndex),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.icon, size: 16, color: item.color),
                const SizedBox(width: 6),
                Text(
                  item.label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AdminDashboardColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: const Color(0xFFB2DFDB).withOpacity(0.5),
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
                      setState(() => _selectedMenuIndex = index);
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
                          GestureDetector(
                            onTap: _refreshAllData,
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
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                Icons.refresh,
                                size: 20,
                                color: AdminDashboardColors.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
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
                                      (authController.currentUser?.email
                                              ?.toUpperCase()[0] ??
                                          'A'),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                itemBuilder: (context) => [
                                  const PopupMenuItem<String>(
                                    child: Text('Profile'),
                                    value: 'profile',
                                  ),
                                  const PopupMenuItem<String>(
                                    child: Text('Settings'),
                                    value: 'settings',
                                  ),
                                  const PopupMenuDivider(),
                                  const PopupMenuItem<String>(
                                    child: Text('Logout'),
                                    value: 'logout',
                                  ),
                                ],
                                onSelected: (value) {
                                  if (value == 'logout') {
                                    authController.signOut();
                                  }
                                },
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You are on the Dashboard')),
        );
        return;
      case 1:
        pageToNavigate = const UserManagementPage();
        break;
      case 2:
        pageToNavigate = const BloodDonorManagementPage();
        break;
      case 3:
        pageToNavigate = const CallRequestManagementPage();
        break;
      case 4:
        pageToNavigate = const CategoryManagementPage();
        break;
      case 5:
        pageToNavigate = const EmergencyNumbersManagementPage();
        break;
      case 6:
        pageToNavigate = const ResourcesManagementPage();
        break;
      case 7:
        pageToNavigate = const ConditionsManagementPage();
        break;
      case 8:
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
