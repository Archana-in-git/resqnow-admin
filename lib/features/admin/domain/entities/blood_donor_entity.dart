import 'package:equatable/equatable.dart';

/// Blood Donor entity for admin management
class BloodDonorEntity extends Equatable {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String bloodGroup;
  final String gender;
  final int age;
  final String address;
  final String town;
  final String district;
  final String pincode;
  final bool isAvailable;
  final List<String> medicalConditions;
  final String? notes;
  final DateTime registeredAt;
  final DateTime? lastDonatedAt;
  final String? profileImage;
  final bool isSuspended;
  final String? suspensionReason;

  const BloodDonorEntity({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.bloodGroup,
    required this.gender,
    required this.age,
    required this.address,
    required this.town,
    required this.district,
    required this.pincode,
    required this.isAvailable,
    required this.medicalConditions,
    this.notes,
    required this.registeredAt,
    this.lastDonatedAt,
    this.profileImage,
    required this.isSuspended,
    this.suspensionReason,
  });

  @override
  List<Object?> get props => [
    uid,
    name,
    email,
    phone,
    bloodGroup,
    gender,
    age,
    address,
    town,
    district,
    pincode,
    isAvailable,
    medicalConditions,
    notes,
    registeredAt,
    lastDonatedAt,
    profileImage,
    isSuspended,
    suspensionReason,
  ];
}
