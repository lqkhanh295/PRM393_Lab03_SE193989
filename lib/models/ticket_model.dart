enum TicketStatus { active, checkedIn, expired }

class TicketModel {
  final String id;
  final String eventId;
  final String eventTitle;
  final String eventDate;
  final String eventTime;
  final String eventLocation;
  final String userId;
  final String studentName;
  final String studentEmail;
  final String qrToken;
  final TicketStatus status;
  final DateTime? checkedInAt;

  const TicketModel({
    required this.id,
    required this.eventId,
    required this.eventTitle,
    required this.eventDate,
    required this.eventTime,
    required this.eventLocation,
    required this.userId,
    required this.studentName,
    required this.studentEmail,
    required this.qrToken,
    this.status = TicketStatus.active,
    this.checkedInAt,
  });

  bool get isActive => status == TicketStatus.active;
  bool get isCheckedIn => status == TicketStatus.checkedIn;

  factory TicketModel.fromMap(Map<String, dynamic> map, String id) {
    TicketStatus resolveStatus(String? val) {
      if (val == 'checkedIn' || val == 'CHECKED_IN') return TicketStatus.checkedIn;
      if (val == 'expired' || val == 'EXPIRED') return TicketStatus.expired;
      return TicketStatus.active;
    }

    DateTime? resolveDateTime(dynamic val) {
      if (val == null) return null;
      if (val is DateTime) return val;
      // Handle Firestore Timestamp or ISO string
      final str = val.toString();
      if (val.runtimeType.toString() == 'Timestamp') {
        try {
          return (val as dynamic).toDate() as DateTime;
        } catch (_) {}
      }
      return DateTime.tryParse(str);
    }

    return TicketModel(
      id: id,
      eventId: map['eventId'] as String? ?? '',
      eventTitle: map['eventTitle'] as String? ?? 'Sự kiện FPTU',
      eventDate: map['eventDate'] as String? ?? '',
      eventTime: map['eventTime'] as String? ?? '',
      eventLocation: map['eventLocation'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      studentName: map['studentName'] as String? ?? 'Sinh viên FPTU',
      studentEmail: map['studentEmail'] as String? ?? '',
      qrToken: map['qrToken'] as String? ?? 'TOKEN-$id',
      status: resolveStatus(map['status'] as String?),
      checkedInAt: resolveDateTime(map['checkedInAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'eventTitle': eventTitle,
      'eventDate': eventDate,
      'eventTime': eventTime,
      'eventLocation': eventLocation,
      'userId': userId,
      'studentName': studentName,
      'studentEmail': studentEmail,
      'qrToken': qrToken,
      'status': status.name,
      'checkedInAt': checkedInAt?.toIso8601String(),
    };
  }

  TicketModel copyWith({
    TicketStatus? status,
    DateTime? checkedInAt,
  }) {
    return TicketModel(
      id: id,
      eventId: eventId,
      eventTitle: eventTitle,
      eventDate: eventDate,
      eventTime: eventTime,
      eventLocation: eventLocation,
      userId: userId,
      studentName: studentName,
      studentEmail: studentEmail,
      qrToken: qrToken,
      status: status ?? this.status,
      checkedInAt: checkedInAt ?? this.checkedInAt,
    );
  }
}
