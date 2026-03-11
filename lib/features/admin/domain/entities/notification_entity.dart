/// Notification Entity
/// Business logic representation of a notification
class NotificationEntity {
  final String notificationId;
  final String userId;
  final String title;
  final String message;
  final String type; // 'call_approved', 'call_declined'
  final String? donorId;
  final String? callRequestId;
  final DateTime createdAt;
  final bool isRead;

  NotificationEntity({
    required this.notificationId,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.donorId,
    this.callRequestId,
    required this.createdAt,
    required this.isRead,
  });

  @override
  String toString() {
    return 'NotificationEntity('
        'notificationId: $notificationId, '
        'userId: $userId, '
        'type: $type, '
        'isRead: $isRead)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NotificationEntity &&
        other.notificationId == notificationId;
  }

  @override
  int get hashCode => notificationId.hashCode;
}

