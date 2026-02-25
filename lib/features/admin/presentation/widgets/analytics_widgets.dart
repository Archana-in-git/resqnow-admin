import 'package:flutter/material.dart';
import 'package:resqnow_admin/features/admin/data/models/analytics_model.dart';

/// ============ Widgets for displaying analytics ============

/// Stat Card Widget - displays a single statistic
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String description;
  final double growthPercent;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final bool isPositiveGrowth;

  const StatCard({
    Key? key,
    required this.title,
    required this.value,
    required this.description,
    this.growthPercent = 0.0,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    this.isPositiveGrowth = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final growthColor = isPositiveGrowth ? Colors.green : Colors.red;
    final growthIcon = isPositiveGrowth
        ? Icons.trending_up
        : Icons.trending_down;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              if (growthPercent != 0)
                Row(
                  children: [
                    Icon(growthIcon, color: growthColor, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${growthPercent.toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: growthColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF757575),
            ),
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

/// Simple Chart Display Widget (Placeholder for actual charting library)
class UserGrowthChart extends StatelessWidget {
  final UserGrowthData data;

  const UserGrowthChart({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'User Growth',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(data.userCounts.length, (index) {
                      final maxValue = data.userCounts.reduce(
                        (a, b) => a > b ? a : b,
                      );
                      final value = data.userCounts[index];
                      final height = maxValue > 0
                          ? (value / maxValue * 150)
                          : 10.0;

                      return Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              height: height,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00796B),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Tooltip(
                                message:
                                    '${data.months[index]}: ${data.userCounts[index]} users',
                                child: const SizedBox.expand(),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              data.months[index].split('-')[1],
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF757575),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total users this period: ${data.userCounts.fold<int>(0, (prev, curr) => prev + curr)}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF757575)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2F1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'View Details',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF00796B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Emergency Trend Chart
class EmergencyTrendChart extends StatelessWidget {
  final EmergencyTrendData data;

  const EmergencyTrendChart({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Emergency Usage Trends',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(data.counts.length, (index) {
                final maxValue = data.counts.reduce((a, b) => a > b ? a : b);
                final value = data.counts[index];
                final height = maxValue > 0 ? (value / maxValue * 150) : 10.0;

                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: height,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD32F2F),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Tooltip(
                          message:
                              '${data.labels[index]}: ${data.counts[index]} clicks',
                          child: const SizedBox.expand(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        data.labels[index],
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF757575),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Total emergency clicks: ${data.counts.fold<int>(0, (prev, curr) => prev + curr)}',
            style: const TextStyle(fontSize: 12, color: Color(0xFF757575)),
          ),
        ],
      ),
    );
  }
}

/// Top Conditions Widget
class TopConditionsWidget extends StatelessWidget {
  final List<TopConditionData> conditions;

  const TopConditionsWidget({Key? key, required this.conditions})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (conditions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(child: Text('No condition data available')),
      );
    }

    final maxViews = conditions
        .map((c) => c.viewCount)
        .reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Medical Conditions Viewed',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(conditions.length, (index) {
            final condition = conditions[index];

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        condition.conditionName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF212121),
                        ),
                      ),
                      Text(
                        '${condition.percentage.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF757575),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: condition.viewCount / maxViews,
                      minHeight: 8,
                      backgroundColor: const Color(0xFFE0E0E0),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color.lerp(
                          const Color(0xFF4CAF50),
                          const Color(0xFF00796B),
                          (index / conditions.length),
                        )!,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${condition.viewCount} views',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF9E9E9E),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// Real-Time Activity Panel
class RealTimeActivityPanelWidget extends StatelessWidget {
  final RealTimeActivityPanel data;

  const RealTimeActivityPanelWidget({Key? key, required this.data})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.timeline,
                    color: Color(0xFFD32F2F),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Real-Time Activity',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildActivityMetric(
                  '🚨 Emergency Requests Today',
                  data.liveEmergencyRequestsToday.toString(),
                  Colors.red,
                ),
                const SizedBox(height: 12),
                _buildActivityMetric(
                  '📍 Most Emergency Location',
                  data.mostEmergencyTriggeredLocation,
                  Colors.orange,
                ),
                const SizedBox(height: 12),
                _buildActivityMetric(
                  '⚠️ Most Common Emergency Type',
                  data.mostCommonEmergencyType,
                  Colors.amber,
                ),
                const SizedBox(height: 12),
                _buildActivityMetric(
                  '⏰ Peak Usage Hour',
                  data.peakUsageHour,
                  Colors.blue,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121),
                  ),
                ),
                const SizedBox(height: 12),
                if (data.recentActivities.isEmpty)
                  const Text(
                    'No recent activities',
                    style: TextStyle(fontSize: 12, color: Color(0xFF999999)),
                  )
                else
                  ...List.generate(
                    data.recentActivities.length,
                    (index) => _buildActivityItem(data.recentActivities[index]),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityMetric(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF757575)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(RecentActivityItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 4,
            backgroundColor: _getActivityColor(item.type),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF212121),
                  ),
                ),
                Text(
                  item.description,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF999999),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            _getTimeAgo(item.timestamp),
            style: const TextStyle(fontSize: 9, color: Color(0xFFBDBDBD)),
          ),
        ],
      ),
    );
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'user_registered':
        return Colors.blue;
      case 'donor_registered':
        return Colors.red;
      case 'emergency_triggered':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getTimeAgo(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inSeconds < 60) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

/// Content Status Widget
class ContentStatusWidget extends StatelessWidget {
  final ContentStatusMetrics metrics;

  const ContentStatusWidget({Key? key, required this.metrics})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Content Status',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 16),
          _buildStatusRow(
            'Total Medical Conditions',
            metrics.totalConditions.toString(),
            Colors.teal,
          ),
          _buildStatusRow(
            'Missing Videos',
            '${metrics.conditionsMissingVideo}',
            Colors.orange,
          ),
          _buildStatusRow(
            'Missing Images',
            '${metrics.conditionsMissingImages}',
            Colors.amber,
          ),
          _buildStatusRow(
            'Published Items',
            '${metrics.publishedItems}',
            Colors.green,
          ),
          _buildStatusRow('Draft Items', '${metrics.draftItems}', Colors.blue),
          _buildStatusRow(
            'Firestore Documents',
            '${metrics.firestoreDocumentCount}',
            Colors.purple,
          ),
          _buildStatusRow(
            'Failed API Calls',
            '${metrics.failedApiCalls}',
            Colors.red,
          ),
          _buildStatusRow(
            'Error Logs',
            '${metrics.errorLogsCount}',
            Colors.redAccent,
          ),
          _buildStatusRow(
            'Crash Reports',
            '${metrics.crashReportsCount}',
            Colors.pink,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'App Version: ${metrics.appVersionActive}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF757575),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Storage Used: ${metrics.firebaseStorageUsedGB.toStringAsFixed(2)} GB',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF757575),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Last Updated: ${_formatDate(metrics.lastUpdatedContent)}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF757575),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF757575)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Push Notification Control Widget
class PushNotificationControlWidget extends StatefulWidget {
  final Function(String, String, String, String?) onSendNotification;

  const PushNotificationControlWidget({
    Key? key,
    required this.onSendNotification,
  }) : super(key: key);

  @override
  State<PushNotificationControlWidget> createState() =>
      _PushNotificationControlWidgetState();
}

class _PushNotificationControlWidgetState
    extends State<PushNotificationControlWidget> {
  final titleController = TextEditingController();
  final messageController = TextEditingController();
  String selectedRecipient = 'all_users';
  String? selectedDistrict;

  final districts = ['Thiruvananthapuram', 'Ernakulam', 'Kozhikode', 'Other'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📢 Push Notification Control',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: titleController,
            decoration: InputDecoration(
              labelText: 'Notification Title',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: messageController,
            decoration: InputDecoration(
              labelText: 'Notification Message',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: selectedRecipient,
            decoration: InputDecoration(
              labelText: 'Send to',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'all_users', child: Text('All Users')),
              DropdownMenuItem(
                value: 'donors_only',
                child: Text('Donors Only'),
              ),
              DropdownMenuItem(
                value: 'specific_district',
                child: Text('Specific District'),
              ),
            ],
            onChanged: (value) {
              setState(() => selectedRecipient = value ?? 'all_users');
            },
          ),
          if (selectedRecipient == 'specific_district') ...[
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedDistrict,
              decoration: InputDecoration(
                labelText: 'Select District',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
              items: districts
                  .map(
                    (district) => DropdownMenuItem(
                      value: district,
                      child: Text(district),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() => selectedDistrict = value);
              },
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (titleController.text.isEmpty ||
                        messageController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill in all fields'),
                        ),
                      );
                      return;
                    }
                    widget.onSendNotification(
                      titleController.text,
                      messageController.text,
                      selectedRecipient,
                      selectedDistrict,
                    );
                    titleController.clear();
                    messageController.clear();
                  },
                  icon: const Icon(Icons.send),
                  label: const Text('Send Notification'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00796B),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    messageController.dispose();
    super.dispose();
  }
}
