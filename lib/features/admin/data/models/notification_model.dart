import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resqnow_admin/features/admin/domain/entities/notification_entity.dart';

/// Notification Model
/// Represents notifications sent to users about call request approvals
class NotificationModel {
  final String notificationId;
  final String userId; // User who receives the notification
  final String title;
  final String message;
  final String type; // 'call_approved', 'call_declined'
  final String? donorId; // Reference to donor (when relevant)
  final String? callRequestId; // Reference to call request
  final DateTime createdAt;
  final bool isRead;

  NotificationModel({
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

  /// Convert to entity
  NotificationEntity toEntity() {
    return NotificationEntity(
      notificationId: notificationId,
      userId: userId,
      title: title,
      message: message,
      type: type,
      donorId: donorId,
      callRequestId: callRequestId,
      createdAt: createdAt,
      isRead: isRead,
    );
  }

  /// Create from Firestore JSON
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDateTime(dynamic value) {
      if (value == null) {
        return DateTime.now();
      } else if (value is Timestamp) {
        return value.toDate();
      } else if (value is String && value.isNotEmpty) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          return DateTime.now();
        }
      }
      return DateTime.now();
    }

    return NotificationModel(
      notificationId: json['notificationId'] ?? '',
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'call_approved',
      donorId: json['donorId'],
      callRequestId: json['callRequestId'],
      createdAt: parseDateTime(json['createdAt']),
      isRead: json['isRead'] ?? false,
    );
  }

  /// Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'notificationId': notificationId,
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'donorId': donorId,
      'callRequestId': callRequestId,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
    };
  }

  /// Copy with modifications
  NotificationModel copyWith({
    String? notificationId,
    String? userId,
    String? title,
    String? message,
    String? type,
    String? donorId,
    String? callRequestId,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return NotificationModel(
      notificationId: notificationId ?? this.notificationId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      donorId: donorId ?? this.donorId,
      callRequestId: callRequestId ?? this.callRequestId,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}

