/// Call Request Entity
/// Business logic representation of a call request
class CallRequestEntity {
  final String requestId;
  final String requesterId;
  final String donorId;
  final String status; // 'pending', 'approved', 'declined'
  final DateTime createdAt;
  final DateTime? approvedAt;
  final String? adminNotes;
  final String? requesterName;
  final String? requesterEmail;
  final String? donorName;
  final String? donorPhone;

  CallRequestEntity({
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

  @override
  String toString() {
    return 'CallRequestEntity('
        'requestId: $requestId, '
        'requesterId: $requesterId, '
        'donorId: $donorId, '
        'status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CallRequestEntity && other.requestId == requestId;
  }

  @override
  int get hashCode => requestId.hashCode;
}
