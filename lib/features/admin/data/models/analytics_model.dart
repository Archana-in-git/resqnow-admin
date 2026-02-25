/// Models for Dashboard Analytics and Statistics

class AnalyticsStats {
  final int totalUsers;
  final int
  activeUsersCount; // Users with accountStatus = 'active' and isBlocked = false
  final int suspendedUsersCount;
  final int newUsersLastWeek;
  final int activeNewUsersLastWeek; // New users that are still active
  final int activeDonors;
  final int emergencyClicksToday;
  final String mostSearchedCondition;
  final int activeSessions; // Users with active login sessions

  // Growth percentages
  final double userGrowthPercent;
  final double donorGrowthPercent;
  final double emergencyTrendsPercent;
  final double activeUsersPercent;

  AnalyticsStats({
    required this.totalUsers,
    required this.activeUsersCount,
    required this.suspendedUsersCount,
    required this.newUsersLastWeek,
    required this.activeNewUsersLastWeek,
    required this.activeDonors,
    required this.emergencyClicksToday,
    required this.mostSearchedCondition,
    required this.activeSessions,
    this.userGrowthPercent = 0.0,
    this.donorGrowthPercent = 0.0,
    this.emergencyTrendsPercent = 0.0,
    this.activeUsersPercent = 0.0,
  });

  factory AnalyticsStats.empty() => AnalyticsStats(
    totalUsers: 0,
    activeUsersCount: 0,
    suspendedUsersCount: 0,
    newUsersLastWeek: 0,
    activeNewUsersLastWeek: 0,
    activeDonors: 0,
    emergencyClicksToday: 0,
    mostSearchedCondition: 'N/A',
    activeSessions: 0,
  );
}

class UserGrowthData {
  final List<String> months;
  final List<int> userCounts;

  UserGrowthData({required this.months, required this.userCounts});
}

class EmergencyTrendData {
  final List<String> labels; // Days or weeks
  final List<int> counts;

  EmergencyTrendData({required this.labels, required this.counts});
}

class TopConditionData {
  final String conditionName;
  final int viewCount;
  final double percentage;

  TopConditionData({
    required this.conditionName,
    required this.viewCount,
    required this.percentage,
  });
}

class ContentStatusMetrics {
  final int totalConditions;
  final int conditionsMissingVideo;
  final int conditionsMissingImages;
  final DateTime lastUpdatedContent;
  final int draftItems;
  final int publishedItems;
  final double firebaseStorageUsedGB;
  final int firestoreDocumentCount;
  final int failedApiCalls;
  final int errorLogsCount;
  final String appVersionActive;
  final int crashReportsCount;

  ContentStatusMetrics({
    required this.totalConditions,
    required this.conditionsMissingVideo,
    required this.conditionsMissingImages,
    required this.lastUpdatedContent,
    required this.draftItems,
    required this.publishedItems,
    required this.firebaseStorageUsedGB,
    required this.firestoreDocumentCount,
    required this.failedApiCalls,
    required this.errorLogsCount,
    required this.appVersionActive,
    required this.crashReportsCount,
  });
}

class RecentActivityItem {
  final String
  type; // 'user_registered', 'donor_registered', 'emergency_triggered', etc.
  final String title;
  final String description;
  final DateTime timestamp;
  final String? userId;
  final String? donorId;

  RecentActivityItem({
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
    this.userId,
    this.donorId,
  });
}

class RealTimeActivityPanel {
  final List<RecentActivityItem> recentActivities;
  final int liveEmergencyRequestsToday;
  final String mostEmergencyTriggeredLocation;
  final String mostCommonEmergencyType;
  final String peakUsageHour;

  RealTimeActivityPanel({
    required this.recentActivities,
    required this.liveEmergencyRequestsToday,
    required this.mostEmergencyTriggeredLocation,
    required this.mostCommonEmergencyType,
    required this.peakUsageHour,
  });
}

class NotificationSchedule {
  final String id;
  final String title;
  final String message;
  final String recipientType; // 'all_users', 'donors_only', 'specific_district'
  final String? targetDistrict;
  final DateTime scheduledTime;
  final DateTime sentTime;
  final bool isSent;
  final int deliveredCount;

  NotificationSchedule({
    required this.id,
    required this.title,
    required this.message,
    required this.recipientType,
    this.targetDistrict,
    required this.scheduledTime,
    required this.sentTime,
    required this.isSent,
    required this.deliveredCount,
  });
}

class AdminSecurityMetrics {
  final String adminRole;
  final DateTime lastLogin;
  final List<LoginLog> recentLogins;
  final List<SuspiciousActivity> suspiciousActivities;

  AdminSecurityMetrics({
    required this.adminRole,
    required this.lastLogin,
    required this.recentLogins,
    required this.suspiciousActivities,
  });
}

class LoginLog {
  final DateTime timestamp;
  final String ipAddress;
  final String device;
  final bool successful;

  LoginLog({
    required this.timestamp,
    required this.ipAddress,
    required this.device,
    required this.successful,
  });
}

class SuspiciousActivity {
  final DateTime timestamp;
  final String activityType;
  final String description;
  final String severity; // 'low', 'medium', 'high'

  SuspiciousActivity({
    required this.timestamp,
    required this.activityType,
    required this.description,
    required this.severity,
  });
}
