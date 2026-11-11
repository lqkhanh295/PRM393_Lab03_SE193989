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
  final DateTime? createdAt;

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
    this.createdAt,
  });

  bool get isActive => status == TicketStatus.active;
  bool get isCheckedIn => status == TicketStatus.checkedIn;

  factory TicketModel.fromMap(Map<String, dynamic> map, String id) {
    TicketStatus resolveStatus(String? val) {
      final s = val?.toLowerCase() ?? '';
      if (s == 'checkedin' || s == 'checked_in') return TicketStatus.checkedIn;
      if (s == 'expired') return TicketStatus.expired;
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
      createdAt: resolveDateTime(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'id': id,
      'eventId': eventId,
      'eventTitle': eventTitle,
      'eventDate': eventDate,
      'eventTime': eventTime,
      'eventLocation': eventLocation,
      'userId': userId,
      'studentName': studentName,
      'studentEmail': studentEmail,
      'ticketCode': id,
      'qrToken': qrToken,
      'qrData': 'FPTU-CE-$eventId-$userId-$id',
      'status': status == TicketStatus.checkedIn ? 'checkedIn' : 'active',
      'checkInStatus': status == TicketStatus.checkedIn,
      'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
    };
    if (checkedInAt != null) {
      map['checkedInAt'] = checkedInAt!.toIso8601String();
    }
    return map;
  }

  TicketModel copyWith({
    TicketStatus? status,
    DateTime? checkedInAt,
    DateTime? createdAt,
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
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
