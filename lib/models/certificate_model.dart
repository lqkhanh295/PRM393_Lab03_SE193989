/// Mô hình chứng nhận tham gia sự kiện điện tử (e-Certificate).
///
/// Lưu trữ thông tin chứng chỉ hoàn thành sự kiện của sinh viên, bao gồm mã băm xác thực
/// tính toàn vẹn [verificationHash] và đường dẫn tệp PDF [downloadUrl] trên Firebase Storage.
class CertificateModel {
  /// Mã định danh duy nhất của chứng chỉ trên Cloud Firestore.
  final String id;

  /// Mã sự kiện mà sinh viên đã tham gia và được cấp chứng chỉ.
  final String eventId;

  /// Tên sự kiện được hiển thị trang trọng trên chứng nhận.
  final String eventTitle;

  /// Mã tài khoản sinh viên nhận chứng nhận.
  final String userId;

  /// Họ tên đầy đủ của sinh viên.
  final String studentName;

  /// Ngày cấp chứng chỉ định dạng hiển thị (ví dụ: DD/MM/YYYY).
  final String issueDate;

  /// Mã băm mật mã dùng để xác thực tính hợp lệ và chống làm giả chứng chỉ.
  final String verificationHash;

  /// Đường dẫn tải tệp PDF chứng chỉ từ Firebase Storage.
  final String downloadUrl;

  /// Khởi tạo một đối tượng [CertificateModel].
  const CertificateModel({
    required this.id,
    required this.eventId,
    required this.eventTitle,
    required this.userId,
    required this.studentName,
    required this.issueDate,
    required this.verificationHash,
    required this.downloadUrl,
  });

  /// Chuyển đổi dữ liệu Map từ Cloud Firestore thành đối tượng [CertificateModel].
  factory CertificateModel.fromMap(Map<String, dynamic> map, String id) {
    return CertificateModel(
      id: id,
      eventId: map['eventId'] as String? ?? '',
      eventTitle: map['eventTitle'] as String? ?? 'Sự kiện FPTU',
      userId: map['userId'] as String? ?? '',
      studentName: map['studentName'] as String? ?? 'Sinh viên FPTU',
      issueDate: map['issueDate'] as String? ?? '28/10/2026',
      verificationHash: map['verificationHash'] as String? ?? 'HASH-FPTU-CERT-$id',
      downloadUrl: map['downloadUrl'] as String? ?? '',
    );
  }

  /// Chuyển đổi đối tượng [CertificateModel] thành Map để lưu trữ trên Cloud Firestore.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eventId': eventId,
      'eventTitle': eventTitle,
      'userId': userId,
      'studentName': studentName,
      'issueDate': issueDate,
      'verificationHash': verificationHash,
      'downloadUrl': downloadUrl,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }
}
