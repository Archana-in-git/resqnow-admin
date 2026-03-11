import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resqnow_admin/features/admin/data/models/notification_model.dart';

/// Service for managing notifications
class NotificationService {
  final FirebaseFirestore firestore;

  static const String notificationsCollection = 'notifications';

  NotificationService({required this.firestore});

  /// Create a notification for a user
  Future<String> createNotification({
    required String userId,
    required String title,
    required String message,
    required String type, // 'call_approved', 'call_declined', etc.
    String? donorId,
    String? callRequestId,
  }) async {
    try {
      final notification = NotificationModel(
        notificationId: '', // Will be set by Firestore
        userId: userId,
        title: title,
        message: message,
        type: type,
        donorId: donorId,
        callRequestId: callRequestId,
        createdAt: DateTime.now(),
        isRead: false,
      );

      final docRef = await firestore
          .collection(notificationsCollection)
          .add(notification.toJson());

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create notification: $e');
    }
  }

  /// Get notifications for a user
  Future<List<NotificationModel>> getUserNotifications(
    String userId, {
    int limit = 20,
  }) async {
    try {
      final snapshot = await firestore
          .collection(notificationsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map(
            (doc) => NotificationModel.fromJson({
              ...doc.data(),
              'notificationId': doc.id,
            }),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch notifications: $e');
    }
  }

  /// Stream notifications for a user (real-time)
  Stream<List<NotificationModel>> getUserNotificationsStream(
    String userId, {
    int limit = 20,
  }) {
    try {
      return firestore
          .collection(notificationsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map(
                  (doc) => NotificationModel.fromJson({
                    ...doc.data(),
                    'notificationId': doc.id,
                  }),
                )
                .toList(),
          );
    } catch (e) {
      throw Exception('Failed to stream notifications: $e');
    }
  }

  /// Get unread notifications count for a user
  Future<int> getUnreadCount(String userId) async {
    try {
      final snapshot = await firestore
          .collection(notificationsCollection)
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e) {
      throw Exception('Failed to fetch unread count: $e');
    }
  }

  /// Stream unread count for a user (real-time)
  Stream<int> getUnreadCountStream(String userId) {
    try {
      return firestore
          .collection(notificationsCollection)
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .snapshots()
          .map((snapshot) => snapshot.size);
    } catch (e) {
      throw Exception('Failed to stream unread count: $e');
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await firestore
          .collection(notificationsCollection)
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  /// Mark multiple notifications as read
  Future<void> markMultipleAsRead(List<String> notificationIds) async {
    try {
      final batch = firestore.batch();
      for (final id in notificationIds) {
        batch.update(firestore.collection(notificationsCollection).doc(id), {
          'isRead': true,
        });
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to mark notifications as read: $e');
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await firestore
          .collection(notificationsCollection)
          .doc(notificationId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }

  /// Get notification by ID
  Future<NotificationModel?> getNotificationById(String notificationId) async {
    try {
      final doc = await firestore
          .collection(notificationsCollection)
          .doc(notificationId)
          .get();

      if (!doc.exists) return null;

      return NotificationModel.fromJson({
        ...doc.data() ?? {},
        'notificationId': doc.id,
      });
    } catch (e) {
      throw Exception('Failed to fetch notification: $e');
    }
  }

  /// Get notifications for a call request
  Future<NotificationModel?> getNotificationForCallRequest(
    String callRequestId,
  ) async {
    try {
      final snapshot = await firestore
          .collection(notificationsCollection)
          .where('callRequestId', isEqualTo: callRequestId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      final doc = snapshot.docs.first;
      return NotificationModel.fromJson({
        ...doc.data(),
        'notificationId': doc.id,
      });
    } catch (e) {
      throw Exception('Failed to fetch call request notification: $e');
    }
  }
}

