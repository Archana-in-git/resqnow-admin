import 'package:equatable/equatable.dart';

/// Admin User entity
class AdminUserEntity extends Equatable {
  final String uid;
  final String email;
  final String name;
  final String role;
  final String accountStatus;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final String? profileImage;
  final bool emailVerified;

  const AdminUserEntity({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    required this.accountStatus,
    required this.createdAt,
    this.lastLogin,
    this.profileImage,
    required this.emailVerified,
  });

  @override
  List<Object?> get props => [
    uid,
    email,
    name,
    role,
    accountStatus,
    createdAt,
    lastLogin,
    profileImage,
    emailVerified,
  ];
}

/// Admin Session entity
class AdminSessionEntity extends Equatable {
  final String uid;
  final String email;
  final String role;
  final String? profileImage;
  final DateTime loginTime;

  const AdminSessionEntity({
    required this.uid,
    required this.email,
    required this.role,
    this.profileImage,
    required this.loginTime,
  });

  bool get isAdmin => role == 'admin';

  @override
  List<Object?> get props => [uid, email, role, profileImage, loginTime];
}
