import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// FCM Service - Firebase Cloud Messaging for Push Notifications
///
/// Handles push notifications that are delivered even when the app is closed.
/// Used for critical notifications (emergency alerts, urgent updates).
///
/// For in-app notifications, use NotificationService (Firestore-based).

class FCMService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Initialize FCM and save token to Firestore
  Future<void> initializeFCM() async {
    try {
      // Request user permission for notifications
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        return;
      }

      // Get and save FCM token
      String? token = await _messaging.getToken();
      if (token != null) {
        await _saveFCMToken(token);
      }

      // Listen for token refresh
      _messaging.onTokenRefresh.listen(_saveFCMToken);

      // Handle foreground notifications
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _handleForegroundNotification(message);
      });
    } catch (e) {
      // FCM initialization failed - app continues without push notifications
    }
  }

  /// Save FCM token to user's Firestore document
  Future<void> _saveFCMToken(String token) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'fcmToken': token,
          'lastTokenUpdate': DateTime.now().toIso8601String(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      // Token save failed - FCM will retry on next token refresh
    }
  }

  /// Handle foreground notifications
  void _handleForegroundNotification(RemoteMessage message) {
    // You can add custom handling here like showing a dialog or updating UI
  }
}
