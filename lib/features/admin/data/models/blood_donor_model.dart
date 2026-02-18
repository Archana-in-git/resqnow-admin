import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resqnow_admin/features/admin/domain/entities/blood_donor_entity.dart';

/// Blood Donor Model for data transfer
class BloodDonorModel {
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

  BloodDonorModel({
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

  /// Convert to entity
  BloodDonorEntity toEntity() {
    return BloodDonorEntity(
      uid: uid,
      name: name,
      email: email,
      phone: phone,
      bloodGroup: bloodGroup,
      gender: gender,
      age: age,
      address: address,
      town: town,
      district: district,
      pincode: pincode,
      isAvailable: isAvailable,
      medicalConditions: medicalConditions,
      notes: notes,
      registeredAt: registeredAt,
      lastDonatedAt: lastDonatedAt,
      profileImage: profileImage,
      isSuspended: isSuspended,
      suspensionReason: suspensionReason,
    );
  }

  /// Create from Firestore JSON
  factory BloodDonorModel.fromJson(Map<String, dynamic> json) {
    // Helper function to convert Timestamp or String to DateTime
    DateTime _parseDateTime(dynamic value) {
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
      } else if (value is int) {
        // Handle unix timestamp in milliseconds or seconds
        try {
          if (value > 10000000000) {
            // Likely milliseconds
            return DateTime.fromMillisecondsSinceEpoch(value);
          } else {
            // Likely seconds
            return DateTime.fromMillisecondsSinceEpoch(value * 1000);
          }
        } catch (e) {
          return DateTime.now();
        }
      }
      return DateTime.now();
    }

    return BloodDonorModel(
      uid: json['uid'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      bloodGroup: json['bloodGroup'] as String? ?? 'O+',
      gender: json['gender'] as String? ?? 'Not Specified',
      age: json['age'] as int? ?? 0,
      address: json['address'] as String? ?? '',
      town: json['town'] as String? ?? '',
      district: json['district'] as String? ?? '',
      pincode: json['pincode'] as String? ?? '',
      isAvailable: json['isAvailable'] as bool? ?? true,
      medicalConditions: List<String>.from(
        json['medicalConditions'] as List? ?? [],
      ),
      notes: json['notes'] as String?,
      registeredAt: _parseDateTime(json['registeredAt']),
      lastDonatedAt: json['lastDonatedAt'] != null
          ? _parseDateTime(json['lastDonatedAt'])
          : null,
      profileImage: json['profileImage'] as String?,
      isSuspended: json['isSuspended'] as bool? ?? false,
      suspensionReason: json['suspensionReason'] as String?,
    );
  }

  /// Convert to Firestore JSON
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'bloodGroup': bloodGroup,
      'gender': gender,
      'age': age,
      'address': address,
      'town': town,
      'district': district,
      'pincode': pincode,
      'isAvailable': isAvailable,
      'medicalConditions': medicalConditions,
      'notes': notes,
      'registeredAt': registeredAt.toIso8601String(),
      'lastDonatedAt': lastDonatedAt?.toIso8601String(),
      'profileImage': profileImage,
      'isSuspended': isSuspended,
      'suspensionReason': suspensionReason,
    };
  }

  BloodDonorModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? phone,
    String? bloodGroup,
    String? gender,
    int? age,
    String? address,
    String? town,
    String? district,
    String? pincode,
    bool? isAvailable,
    List<String>? medicalConditions,
    String? notes,
    DateTime? registeredAt,
    DateTime? lastDonatedAt,
    String? profileImage,
    bool? isSuspended,
    String? suspensionReason,
  }) {
    return BloodDonorModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      address: address ?? this.address,
      town: town ?? this.town,
      district: district ?? this.district,
      pincode: pincode ?? this.pincode,
      isAvailable: isAvailable ?? this.isAvailable,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      notes: notes ?? this.notes,
      registeredAt: registeredAt ?? this.registeredAt,
      lastDonatedAt: lastDonatedAt ?? this.lastDonatedAt,
      profileImage: profileImage ?? this.profileImage,
      isSuspended: isSuspended ?? this.isSuspended,
      suspensionReason: suspensionReason ?? this.suspensionReason,
    );
  }
}
