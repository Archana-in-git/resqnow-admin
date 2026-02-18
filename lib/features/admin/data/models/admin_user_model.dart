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
  final String? profileImage;
  final bool emailVerified;

  AdminUserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    required this.accountStatus,
    required this.createdAt,
    this.lastLogin,
    this.profileImage,
    this.emailVerified = false,
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
      profileImage: entity.profileImage,
      emailVerified: entity.emailVerified,
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
      profileImage: profileImage,
      emailVerified: emailVerified,
    );
  }

  /// Create from Firestore JSON
  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    // createdAt and lastLogin can come as Firestore Timestamps, ints, or ISO strings
    final dynamic createdVal = json['createdAt'];
    DateTime createdAt;
    if (createdVal is Timestamp) {
      createdAt = createdVal.toDate();
    } else if (createdVal is int) {
      createdAt = DateTime.fromMillisecondsSinceEpoch(createdVal);
    } else if (createdVal is String) {
      createdAt = DateTime.parse(createdVal);
    } else {
      createdAt = DateTime.now();
    }

    final dynamic lastLoginVal = json['lastLogin'];
    DateTime? lastLogin;
    if (lastLoginVal != null) {
      if (lastLoginVal is Timestamp) {
        lastLogin = lastLoginVal.toDate();
      } else if (lastLoginVal is int) {
        lastLogin = DateTime.fromMillisecondsSinceEpoch(lastLoginVal);
      } else if (lastLoginVal is String) {
        lastLogin = DateTime.parse(lastLoginVal);
      }
    }

    return AdminUserModel(
      uid: json['uid'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: json['role'] as String? ?? 'user',
      accountStatus: json['accountStatus'] as String? ?? 'active',
      createdAt: createdAt,
      lastLogin: lastLogin,
      profileImage: json['profileImage'] as String?,
      emailVerified: json['emailVerified'] as bool? ?? false,
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
      'profileImage': profileImage,
      'emailVerified': emailVerified,
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
    String? profileImage,
    bool? emailVerified,
  }) {
    return AdminUserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      accountStatus: accountStatus ?? this.accountStatus,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      profileImage: profileImage ?? this.profileImage,
      emailVerified: emailVerified ?? this.emailVerified,
    );
  }
}
