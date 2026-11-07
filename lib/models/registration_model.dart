import 'package:cloud_firestore/cloud_firestore.dart';

enum RegistrationStatus {
  pending,
  approved,
  rejected,
}

/// Registration Model for Cross-Role Flow
/// Flow: Student registers on Mobile (status: pending)
///    -> Organizer reviews on Web Admin (approved / rejected)
///    -> Student's Mobile updates in real-time stream + Inbox notification.
class RegistrationModel {
  final String id;
  final String eventId;
  final String eventTitle;
  final String userId;
  final String studentName;
  final String studentEmail;
  final RegistrationStatus status;
  final String? reason;
  final String? ticketId;
  final DateTime createdAt;
  final DateTime? reviewedAt;

  const RegistrationModel({
    required this.id,
    required this.eventId,
    required this.eventTitle,
    required this.userId,
    required this.studentName,
    required this.studentEmail,
    required this.status,
    this.reason,
    this.ticketId,
    required this.createdAt,
    this.reviewedAt,
  });

  factory RegistrationModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    final rawStatus = map['status'] as String? ?? 'pending';
    final status = RegistrationStatus.values.firstWhere(
      (s) => s.name == rawStatus,
      orElse: () => RegistrationStatus.pending,
    );

    return RegistrationModel(
      id: id,
      eventId: map['eventId'] as String? ?? '',
      eventTitle: map['eventTitle'] as String? ?? '',
      userId: map['userId'] as String? ?? (map['uid'] as String? ?? ''),
      studentName: map['studentName'] as String? ?? 'Sinh viên FPTU',
      studentEmail: map['studentEmail'] as String? ?? '',
      status: status,
      reason: map['reason'] as String?,
      ticketId: map['ticketId'] as String?,
      createdAt: parseDate(map['createdAt']),
      reviewedAt: map['reviewedAt'] != null ? parseDate(map['reviewedAt']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eventId': eventId,
      'eventTitle': eventTitle,
      'userId': userId,
      'uid': userId,
      'studentName': studentName,
      'studentEmail': studentEmail,
      'status': status.name,
      if (reason != null) 'reason': reason,
      if (ticketId != null) 'ticketId': ticketId,
      'createdAt': Timestamp.fromDate(createdAt),
      if (reviewedAt != null) 'reviewedAt': Timestamp.fromDate(reviewedAt!),
    };
  }
}
