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
import 'package:resqnow_admin/features/admin/presentation/pages/hospital_approvals_page.dart';
import 'package:resqnow_admin/core/services/admin_service.dart';
import 'package:resqnow_admin/features/admin/presentation/widgets/analytics_widgets.dart';
import 'package:resqnow_admin/features/admin/data/models/analytics_model.dart'
    as models;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Admin Dashboard Home Page with Analytics
class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

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
  late Stream<models.AnalyticsStats> _analyticsStatsStream;
  late Stream<Map<String, int>> _callRequestStatsStream;

  // Cache for combined secondary data
  late Future<_SecondaryDataCache> _secondaryDataCacheFuture;

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
      icon: Icons.local_hospital,
      label: 'Hospital Approvals',
      description: 'Approve or reject hospital registrations',
      color: Colors.deepPurple,
      lightColor: const Color(0xFFEDE7F6),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _adminService = AdminService(
      firestore: FirebaseFirestore.instance,
      auth: FirebaseAuth.instance,
    );
    _initializeStreams();
  }

  void _initializeStreams() {
    // Start all streams immediately
    _analyticsStatsStream = _adminService.getAnalyticsStatsStream();
    _callRequestStatsStream = _adminService.getCallRequestStatsStream();

    // Load all secondary data in parallel using Future.wait()
    _secondaryDataCacheFuture =
        Future.wait<dynamic>([
          _adminService.getUserGrowthData(),
          _adminService.getEmergencyTrendData(),
          _adminService.getHospitalApprovalStats(),
        ]).then((results) {
          return _SecondaryDataCache(
            userGrowthData: results[0] as models.UserGrowthData,
            emergencyTrendData: results[1] as models.EmergencyTrendData,
            hospitalApprovalStats: results[2] as Map<String, int>,
          );
        });

    // Keep individual futures for backward compatibility
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
              const Color(0xFF9DD9D2).withValues(alpha: 0.5),
              const Color(0xFFAFD3E8).withValues(alpha: 0.4),
              const Color(0xFFC9B8E0).withValues(alpha: 0.4),
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
                                  child: _buildBloodDonorAnalyticsSection(),
                                ),
                              ],
                            )
                          else
                            Column(
                              children: [
                                _buildChartsColumn(),
                                const SizedBox(height: 20),
                                _buildBloodDonorAnalyticsSection(),
                              ],
                            ),

                          const SizedBox(height: 28),

                          // Push Notification Control
                          _buildNotificationControlSection(),
                          const SizedBox(height: 28),
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
    return RepaintBoundary(
      child: StreamBuilder<models.AnalyticsStats>(
        stream: _analyticsStatsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
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
                  description: 'All registered users',
                  growthPercent: stats.userGrowthPercent,
                  backgroundColor: const Color(0xFFE1F5FE),
                  iconColor: const Color(0xFF0288D1),
                ),
                const SizedBox(width: 16),
                StatCard(
                  icon: Icons.block,
                  title: 'Suspended',
                  value: stats.suspendedUsersCount.toString(),
                  description: 'Blocked accounts',
                  growthPercent: 0.0,
                  backgroundColor: const Color(0xFFFFCDD2),
                  iconColor: AdminDashboardColors.emergency,
                ),
                const SizedBox(width: 16),
                StatCard(
                  icon: Icons.person_add,
                  title: 'New This Week',
                  value: stats.activeNewUsersLastWeek.toString(),
                  description: 'Active new users',
                  growthPercent: 2.5,
                  backgroundColor: const Color(0xFFF3E5F5),
                  iconColor: const Color(0xFF6A1B9A),
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
                  icon: Icons.warning_rounded,
                  title: 'Total Emergency Clicks',
                  value: stats.totalEmergencyClicksInitiated.toString(),
                  description: 'All-time',
                  growthPercent: 0.0,
                  backgroundColor: const Color(0xFFFFEBEE),
                  iconColor: AdminDashboardColors.emergency,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildChartsColumn() {
    return RepaintBoundary(
      child: FutureBuilder<_SecondaryDataCache>(
        future: _secondaryDataCacheFuture,
        builder: (context, snapshot) {
          final cache = snapshot.data;
          final userGrowthData =
              cache?.userGrowthData ??
              models.UserGrowthData(months: [], userCounts: []);
          final emergencyTrendData =
              cache?.emergencyTrendData ??
              models.EmergencyTrendData(labels: [], counts: []);

          return Column(
            children: [
              // User Growth Chart
              if (snapshot.connectionState == ConnectionState.waiting &&
                  cache == null)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(child: CircularProgressIndicator()),
                )
              else
                UserGrowthChart(data: userGrowthData),
              const SizedBox(height: 20),

              // Emergency Trend Chart
              if (snapshot.connectionState == ConnectionState.waiting &&
                  cache == null)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(child: CircularProgressIndicator()),
                )
              else
                EmergencyTrendChart(data: emergencyTrendData),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBloodDonorAnalyticsSection() {
    return _buildBloodDonorAndHospitalCardsGrid();
  }

  Widget _buildBloodDonorAndHospitalCardsGrid() {
    return RepaintBoundary(
      child: StreamBuilder<models.AnalyticsStats>(
        stream: _analyticsStatsStream,
        builder: (context, statSnapshot) {
          if (statSnapshot.connectionState == ConnectionState.waiting &&
              !statSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final stats = statSnapshot.data ?? models.AnalyticsStats.empty();

          // Build call request and hospital stats in parallel
          return StreamBuilder<Map<String, int>>(
            stream: _callRequestStatsStream,
            builder: (context, callSnapshot) {
              return FutureBuilder<_SecondaryDataCache>(
                future: _secondaryDataCacheFuture,
                builder: (context, cacheSnapshot) {
                  // All data available or showing defaults
                  final callStats = callSnapshot.data ?? {};
                  final pending = callStats['pending'] ?? 0;
                  final approved = callStats['approved'] ?? 0;

                  final hospitalStats =
                      cacheSnapshot.data?.hospitalApprovalStats ?? {};
                  final totalHospitals = hospitalStats['total'] ?? 0;
                  final pendingHospitals = hospitalStats['pending'] ?? 0;

                  return GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildBloodDonorCard(
                        icon: Icons.bloodtype,
                        title: 'Active Donors',
                        value: stats.activeDonors.toString(),
                        color: AdminDashboardColors.accentColor,
                        bgColor: Colors.white,
                      ),
                      _buildBloodDonorCard(
                        icon: Icons.search,
                        title: 'Top Searched',
                        value: stats.mostSearchedCondition.length > 12
                            ? '${stats.mostSearchedCondition.substring(0, 12)}...'
                            : stats.mostSearchedCondition,
                        color: AdminDashboardColors.warning,
                        bgColor: Colors.white,
                      ),
                      _buildBloodDonorCard(
                        icon: Icons.hourglass_empty,
                        title: 'Pending Calls',
                        value: pending.toString(),
                        color: Colors.orange,
                        bgColor: Colors.white,
                      ),
                      _buildBloodDonorCard(
                        icon: Icons.check_circle,
                        title: 'Approved Calls',
                        value: approved.toString(),
                        color: AdminDashboardColors.success,
                        bgColor: Colors.white,
                      ),
                      _buildBloodDonorCard(
                        icon: Icons.apartment,
                        title: 'Total Hospitals',
                        value: totalHospitals.toString(),
                        color: Colors.blue,
                        bgColor: Colors.white,
                      ),
                      _buildBloodDonorCard(
                        icon: Icons.hourglass_empty,
                        title: 'Pending Hospitals',
                        value: pendingHospitals.toString(),
                        color: Colors.orange,
                        bgColor: Colors.white,
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBloodDonorCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AdminDashboardColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationControlSection() {
    return PushNotificationControlWidget(
      onSendNotification: (title, message, recipientType, _) async {
        try {
          await _adminService.sendNotification(
            title: title,
            message: message,
            recipientType: recipientType,
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

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: const Color(0xFFB2DFDB).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
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
                                        color: Colors.black.withValues(
                                          alpha: 0.05,
                                        ),
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
                                    value: 'logout',
                                    child: Text('Logout'),
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
        pageToNavigate = const HospitalApprovalsPage();
        break;
      default:
        return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => pageToNavigate),
    ).then((_) {
      // Reset menu selection to Dashboard when returning from any page
      setState(() => _selectedMenuIndex = 0);
    });
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

/// Helper class to cache secondary data loaded in parallel
class _SecondaryDataCache {
  final models.UserGrowthData userGrowthData;
  final models.EmergencyTrendData emergencyTrendData;
  final Map<String, int> hospitalApprovalStats;

  _SecondaryDataCache({
    required this.userGrowthData,
    required this.emergencyTrendData,
    required this.hospitalApprovalStats,
  });
}
