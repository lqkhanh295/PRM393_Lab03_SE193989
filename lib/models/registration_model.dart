import 'package:cloud_firestore/cloud_firestore.dart';

/// Trạng thái đơn đăng ký giữ chỗ tham gia sự kiện.
enum RegistrationStatus {
  /// Đang chờ ban tổ chức hoặc cán bộ CTSV xét duyệt.
  pending,

  /// Đã được phê duyệt và tự động cấp vé điện tử có QR code.
  approved,

  /// Bị từ chối duyệt kèm lý do phản hồi.
  rejected,
}

/// Mô hình đơn đăng ký sự kiện hỗ trợ luồng xét duyệt liên vai trò (Cross-Role Flow).
///
/// Luồng xử lý: Sinh viên nộp đơn trên Mobile (`pending`) -> Cán bộ/Ban tổ chức thẩm định
/// trên Web Portal (`approved` hoặc `rejected`) -> Ứng dụng di động của sinh viên cập nhật tức thời
/// kèm vé điện tử và thông báo Inbox.
class RegistrationModel {
  /// Mã định danh duy nhất của đơn đăng ký trên Cloud Firestore.
  final String id;

  /// Mã sự kiện sinh viên đăng ký tham gia.
  final String eventId;

  /// Tên sự kiện đăng ký.
  final String eventTitle;

  /// Mã người dùng của sinh viên nộp đơn.
  final String userId;

  /// Họ tên đầy đủ của sinh viên.
  final String studentName;

  /// Địa chỉ email trường FPT của sinh viên.
  final String studentEmail;

  /// Trạng thái xét duyệt hiện tại ([RegistrationStatus.pending], [RegistrationStatus.approved], [RegistrationStatus.rejected]).
  final RegistrationStatus status;

  /// Lý do từ chối đơn hoặc ghi chú bổ sung từ ban tổ chức.
  final String? reason;

  /// Mã vé điện tử được cấp phát sau khi đơn được duyệt thành công.
  final String? ticketId;

  /// Thời điểm sinh viên gửi đơn đăng ký.
  final DateTime createdAt;

  /// Thời điểm cán bộ hoặc ban tổ chức hoàn tất thẩm định đơn.
  final DateTime? reviewedAt;

  /// Khởi tạo một đối tượng [RegistrationModel].
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

  /// Chuyển đổi dữ liệu Map từ Cloud Firestore thành đối tượng [RegistrationModel].
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

  /// Chuyển đổi đối tượng [RegistrationModel] thành Map để cập nhật trên Cloud Firestore.
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
