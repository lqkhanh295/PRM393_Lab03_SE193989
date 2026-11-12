/// Trạng thái sử dụng của vé tham dự sự kiện.
enum TicketStatus {
  /// Vé đang có hiệu lực, sẵn sàng để quét check-in tại cổng.
  active,

  /// Vé đã được quét và điểm danh thành công tại cổng soát vé.
  checkedIn,

  /// Vé đã hết hạn sử dụng (sự kiện đã kết thúc hoặc bị hủy).
  expired,
}

/// Mô hình vé điện tử (Digital Ticket) kèm mã QR phục vụ điểm danh sự kiện.
///
/// Quản lý thông tin chi tiết của vé tham dự, mã băm định danh QR `qrToken`,
/// trạng thái điểm danh và mốc thời gian check-in tại cổng soát vé.
class TicketModel {
  /// Mã định danh duy nhất của vé trên Cloud Firestore.
  final String id;

  /// Mã sự kiện mà vé này cấp quyền tham dự.
  final String eventId;

  /// Tên sự kiện được in trên vé.
  final String eventTitle;

  /// Ngày diễn ra sự kiện.
  final String eventDate;

  /// Khung giờ diễn ra sự kiện.
  final String eventTime;

  /// Địa điểm tổ chức sự kiện.
  final String eventLocation;

  /// Mã tài khoản người dùng sở hữu vé.
  final String userId;

  /// Họ tên của sinh viên sở hữu vé.
  final String studentName;

  /// Địa chỉ email trường FPT của người sở hữu vé.
  final String studentEmail;

  /// Mã token bảo mật được mã hóa bên trong mã QR để quét điểm danh tại cổng.
  final String qrToken;

  /// Trạng thái hiện tại của vé ([TicketStatus.active], [TicketStatus.checkedIn], [TicketStatus.expired]).
  final TicketStatus status;

  /// Mốc thời gian chính xác khi sinh viên được quét mã check-in qua cổng.
  final DateTime? checkedInAt;

  /// Thời điểm vé được khởi tạo và cấp phát cho sinh viên.
  final DateTime? createdAt;

  /// Khởi tạo một đối tượng [TicketModel].
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

  /// Kiểm tra xem vé có đang ở trạng thái hoạt động hợp lệ hay không.
  bool get isActive => status == TicketStatus.active;

  /// Kiểm tra xem vé đã được quét check-in thành công tại cổng hay chưa.
  bool get isCheckedIn => status == TicketStatus.checkedIn;

  /// Chuyển đổi dữ liệu Map từ Cloud Firestore thành đối tượng [TicketModel].
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

  /// Chuyển đổi đối tượng [TicketModel] thành Map để cập nhật trên Cloud Firestore.
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

  /// Tạo bản sao [TicketModel] với các giá trị được cập nhật có chọn lọc.
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
