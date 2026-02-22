import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resqnow_admin/features/admin/domain/entities/call_request_entity.dart';

/// Call Request Model
/// Represents a user's request to call a blood donor
class CallRequestModel {
  final String requestId;
  final String requesterId; // User who requested the call
  final String donorId; // Blood donor being called
  final String status; // 'pending', 'approved', 'declined'
  final DateTime createdAt;
  final DateTime? approvedAt;
  final String? adminNotes;
  final String? requesterName;
  final String? requesterEmail;
  final String? donorName;
  final String? donorPhone;

  CallRequestModel({
    required this.requestId,
    required this.requesterId,
    required this.donorId,
    required this.status,
    required this.createdAt,
    this.approvedAt,
    this.adminNotes,
    this.requesterName,
    this.requesterEmail,
    this.donorName,
    this.donorPhone,
  });

  /// Convert to entity
  CallRequestEntity toEntity() {
    return CallRequestEntity(
      requestId: requestId,
      requesterId: requesterId,
      donorId: donorId,
      status: status,
      createdAt: createdAt,
      approvedAt: approvedAt,
      adminNotes: adminNotes,
      requesterName: requesterName,
      requesterEmail: requesterEmail,
      donorName: donorName,
      donorPhone: donorPhone,
    );
  }

  /// Create from Firestore JSON
  factory CallRequestModel.fromJson(Map<String, dynamic> json) {
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
      }
      return DateTime.now();
    }

    return CallRequestModel(
      requestId: json['requestId'] ?? '',
      requesterId: json['requesterId'] ?? '',
      donorId: json['donorId'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: _parseDateTime(json['createdAt']),
      approvedAt: json['approvedAt'] != null
          ? _parseDateTime(json['approvedAt'])
          : null,
      adminNotes: json['adminNotes'],
      requesterName: json['requesterName'],
      requesterEmail: json['requesterEmail'],
      donorName: json['donorName'],
      donorPhone: json['donorPhone'],
    );
  }

  /// Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'requestId': requestId,
      'requesterId': requesterId,
      'donorId': donorId,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'approvedAt': approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
      'adminNotes': adminNotes,
      'requesterName': requesterName,
      'requesterEmail': requesterEmail,
      'donorName': donorName,
      'donorPhone': donorPhone,
    };
  }

  /// Copy with modifications
  CallRequestModel copyWith({
    String? requestId,
    String? requesterId,
    String? donorId,
    String? status,
    DateTime? createdAt,
    DateTime? approvedAt,
    String? adminNotes,
    String? requesterName,
    String? requesterEmail,
    String? donorName,
    String? donorPhone,
  }) {
    return CallRequestModel(
      requestId: requestId ?? this.requestId,
      requesterId: requesterId ?? this.requesterId,
      donorId: donorId ?? this.donorId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      approvedAt: approvedAt ?? this.approvedAt,
      adminNotes: adminNotes ?? this.adminNotes,
      requesterName: requesterName ?? this.requesterName,
      requesterEmail: requesterEmail ?? this.requesterEmail,
      donorName: donorName ?? this.donorName,
      donorPhone: donorPhone ?? this.donorPhone,
    );
  }
}
