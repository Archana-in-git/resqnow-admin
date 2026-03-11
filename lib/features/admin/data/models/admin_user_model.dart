import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resqnow_admin/features/admin/domain/entities/admin_user_entity.dart';

/// Admin User Model for data transfer
class AdminUserModel {
  final String uid;
  final String email;
  final String name;
  final String role;
  final String accountStatus;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final String? profileImageUrl;
  final bool emailVerified;
  final bool isBlocked;
  final DateTime? suspendedAt;
  final String? suspensionReason;

  AdminUserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    required this.accountStatus,
    required this.createdAt,
    this.lastLogin,
    this.profileImageUrl,
    this.emailVerified = false,
    this.isBlocked = false,
    this.suspendedAt,
    this.suspensionReason,
  });

  /// Create model from entity
  factory AdminUserModel.fromEntity(AdminUserEntity entity) {
    return AdminUserModel(
      uid: entity.uid,
      email: entity.email,
      name: entity.name,
      role: entity.role,
      accountStatus: entity.accountStatus,
      createdAt: entity.createdAt,
      lastLogin: entity.lastLogin,
      profileImageUrl: entity.profileImageUrl,
      emailVerified: entity.emailVerified,
      isBlocked: entity.isBlocked,
      suspendedAt: entity.suspendedAt,
      suspensionReason: entity.suspensionReason,
    );
  }

  /// Convert to entity
  AdminUserEntity toEntity() {
    return AdminUserEntity(
      uid: uid,
      email: email,
      name: name,
      role: role,
      accountStatus: accountStatus,
      createdAt: createdAt,
      lastLogin: lastLogin,
      profileImageUrl: profileImageUrl,
      emailVerified: emailVerified,
      isBlocked: isBlocked,
      suspendedAt: suspendedAt,
      suspensionReason: suspensionReason,
    );
  }

  /// Get proxied image URL to bypass CORS issues in web
  String? getProxiedImageUrl() {
    if (profileImageUrl == null || profileImageUrl!.isEmpty) {
      return null;
    }

    try {
      final url = profileImageUrl!;
      // Extract the path from Firebase Storage URL
      // URL format: https://firebasestorage.googleapis.com/v0/b/bucket/o/path%2Fto%2Ffile?...
      if (url.contains('/o/')) {
        final pathWithParams = url.split('/o/')[1];
        final path = Uri.decodeComponent(pathWithParams.split('?')[0]);

        // Return proxied URL using Cloud Function
        return 'https://us-central1-resqnow-12e6c.cloudfunctions.net/getImage?path=${Uri.encodeComponent(path)}';
      }
    } catch (e) {
      // If parsing fails, return null
    }

    return null;
  }

  /// Create from Firestore JSON
  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    // Helper function to convert Timestamp, int, or String to DateTime
    DateTime parseDateTime(dynamic value) {
      if (value == null) {
        return DateTime.now();
      } else if (value is Timestamp) {
        return value.toDate();
      } else if (value is String && value.isNotEmpty) {
        try {
          return DateTime.parse(value);
        } catch (_) {
          return DateTime.now();
        }
      } else if (value is int) {
        try {
          if (value > 10000000000) {
            // milliseconds
            return DateTime.fromMillisecondsSinceEpoch(value);
          } else {
            // seconds
            return DateTime.fromMillisecondsSinceEpoch(value * 1000);
          }
        } catch (_) {
          return DateTime.now();
        }
      }
      return DateTime.now();
    }

    return AdminUserModel(
      uid: json['uid'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      role: json['role'] as String? ?? 'user',
      accountStatus: json['accountStatus'] as String? ?? 'active',
      createdAt: parseDateTime(json['createdAt']),
      lastLogin: json['lastLogin'] != null
          ? parseDateTime(json['lastLogin'])
          : null,
      profileImageUrl: json['profileImageUrl'] as String?,
      emailVerified: json['emailVerified'] as bool? ?? false,
      isBlocked: json['isBlocked'] as bool? ?? false,
      suspendedAt: json['suspendedAt'] != null
          ? parseDateTime(json['suspendedAt'])
          : null,
      suspensionReason: json['suspensionReason'] as String?,
    );
  }

  /// Convert to Firestore JSON
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role,
      'accountStatus': accountStatus,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
      'profileImageUrl': profileImageUrl,
      'emailVerified': emailVerified,
      'isBlocked': isBlocked,
      'suspendedAt': suspendedAt?.toIso8601String(),
      'suspensionReason': suspensionReason,
    };
  }

  AdminUserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? role,
    String? accountStatus,
    DateTime? createdAt,
    DateTime? lastLogin,
    String? profileImageUrl,
    bool? emailVerified,
    bool? isBlocked,
    DateTime? suspendedAt,
    String? suspensionReason,
  }) {
    return AdminUserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      accountStatus: accountStatus ?? this.accountStatus,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      emailVerified: emailVerified ?? this.emailVerified,
      isBlocked: isBlocked ?? this.isBlocked,
      suspendedAt: suspendedAt ?? this.suspendedAt,
      suspensionReason: suspensionReason ?? this.suspensionReason,
    );
  }
}

