/// Model representing a Gate Check-in Duty Assignment (Phân công ca trực cổng)
/// 100% Real Cloud Firestore Integration for FPTU Campus Event System.
class GateAssignmentModel {
  final String id;
  final String email;
  final String studentName;
  final String studentId;
  final String eventId;
  final String eventTitle;
  final String gateName;
  final String role;
  final String shiftTime;
  final String status;
  final String assignedBy;
  final DateTime? assignedAt;

  const GateAssignmentModel({
    required this.id,
    required this.email,
    required this.studentName,
    required this.studentId,
    required this.eventId,
    required this.eventTitle,
    required this.gateName,
    required this.role,
    required this.shiftTime,
    this.status = 'active',
    this.assignedBy = 'Phòng CTSV',
    this.assignedAt,
  });

  bool get isActive => status.toLowerCase() == 'active';

  factory GateAssignmentModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime? resolveDateTime(dynamic val) {
      if (val == null) return null;
      if (val is DateTime) return val;
      final str = val.toString();
      if (val.runtimeType.toString() == 'Timestamp') {
        try {
          return (val as dynamic).toDate() as DateTime;
        } catch (_) {}
      }
      return DateTime.tryParse(str);
    }

    return GateAssignmentModel(
      id: id,
      email: map['email'] as String? ?? '',
      studentName: map['studentName'] as String? ?? 'CTV FPTU',
      studentId: map['studentId'] as String? ?? '',
      eventId: map['eventId'] as String? ?? '',
      eventTitle: map['eventTitle'] as String? ?? 'Sự kiện FPTU',
      gateName: map['gateName'] as String? ?? 'Cổng Chính (Cửa 1)',
      role: map['role'] as String? ?? 'CTV Soát Vé Cổng',
      shiftTime: map['shiftTime'] as String? ?? '13:00 - 17:30',
      status: map['status'] as String? ?? 'active',
      assignedBy: map['assignedBy'] as String? ?? 'Phòng CTSV',
      assignedAt: resolveDateTime(map['assignedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'studentName': studentName,
      'studentId': studentId,
      'eventId': eventId,
      'eventTitle': eventTitle,
      'gateName': gateName,
      'role': role,
      'shiftTime': shiftTime,
      'status': status,
      'assignedBy': assignedBy,
      'assignedAt': assignedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }
}
