// TODO: Uncomment this file after adding firebase_messaging to pubspec.yaml
// Run: flutter pub add firebase_messaging
// Then uncomment all code below

// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class FCMService {
//   final FirebaseMessaging _messaging = FirebaseMessaging.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//
//   /// Initialize FCM and save token to Firestore
//   Future<void> initializeFCM() async {
//     try {
//       // Request user permission for notifications
//       NotificationSettings settings = await _messaging.requestPermission(
//         alert: true,
//         badge: true,
//         sound: true,
//         provisional: false,
//       );
//
//       if (settings.authorizationStatus != AuthorizationStatus.authorized) {
//         print('User denied notification permission');
//         return;
//       }
//
//       // Get and save FCM token
//       String? token = await _messaging.getToken();
//       if (token != null) {
//         await _saveFCMToken(token);
//       }
//
//       // Listen for token refresh
//       _messaging.onTokenRefresh.listen(_saveFCMToken);
//
//       // Handle foreground notifications
//       FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//         print('Got a message in the foreground: ${message.messageId}');
//         _handleForegroundNotification(message);
//       });
//
//       print('FCM initialized successfully with token: $token');
//     } catch (e) {
//       print('Error initializing FCM: $e');
//     }
//   }
//
//   /// Save FCM token to user's Firestore document
//   Future<void> _saveFCMToken(String token) async {
//     try {
//       final user = _auth.currentUser;
//       if (user != null) {
//         await _firestore.collection('users').doc(user.uid).set({
//           'fcmToken': token,
//           'lastTokenUpdate': DateTime.now().toIso8601String(),
//         }, SetOptions(merge: true));
//         print('FCM token saved to Firestore');
//       }
//     } catch (e) {
//       print('Error saving FCM token: $e');
//     }
//   }
//
//   /// Handle foreground notifications
//   void _handleForegroundNotification(RemoteMessage message) {
//     print('Handling foreground notification: ${message.messageId}');
//     print('Title: ${message.notification?.title}');
//     print('Body: ${message.notification?.body}');
//     // You can add custom handling here like showing a dialog or updating UI
//   }
// }
