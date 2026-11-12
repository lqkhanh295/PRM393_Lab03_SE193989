/// Mô hình phân công ca trực cổng soát vé (Gate Duty Assignment).
///
/// Quản lý việc phân công cộng tác viên hoặc cán bộ trực tại các cổng sự kiện,
/// tích hợp đồng bộ trực tiếp với Cloud Firestore collection `gate_assignments`.
class GateAssignmentModel {
  /// Mã định danh duy nhất của bản ghi phân công.
  final String id;

  /// Địa chỉ email FPT của nhân sự được phân công trực.
  final String email;

  /// Họ tên của cộng tác viên hoặc cán bộ trực.
  final String studentName;

  /// Mã số sinh viên của cộng tác viên.
  final String studentId;

  /// Mã sự kiện diễn ra ca trực.
  final String eventId;

  /// Tên sự kiện được phân công trực.
  final String eventTitle;

  /// Tên hoặc số hiệu của cổng soát vé (ví dụ: `Cổng Chính (Cửa 1)`).
  final String gateName;

  /// Vai trò hoặc nhiệm vụ cụ thể trong ca trực (ví dụ: `CTV Soát Vé Cổng`).
  final String role;

  /// Khung giờ diễn ra ca trực (ví dụ: `13:00 - 17:30`).
  final String shiftTime;

  /// Trạng thái của ca trực (ví dụ: `active`, `completed`, `cancelled`).
  final String status;

  /// Tên đơn vị hoặc cán bộ thực hiện phân công (ví dụ: `Phòng CTSV`).
  final String assignedBy;

  /// Thời điểm phân công ca trực được tạo.
  final DateTime? assignedAt;

  /// Khởi tạo một đối tượng [GateAssignmentModel].
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

  /// Kiểm tra xem ca trực hiện tại có đang trong trạng thái kích hoạt hiệu lực hay không.
  bool get isActive => status.toLowerCase() == 'active';

  /// Chuyển đổi dữ liệu Map từ Cloud Firestore thành đối tượng [GateAssignmentModel].
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

  /// Chuyển đổi đối tượng [GateAssignmentModel] thành Map để cập nhật trên Cloud Firestore.
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
