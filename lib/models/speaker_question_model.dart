/// Mô hình câu hỏi gửi diễn giả trong phiên Live Q&A của sự kiện.
///
/// Hỗ trợ bình chọn (upvote) câu hỏi theo thời gian thực và đánh dấu trạng thái
/// câu hỏi đã được diễn giả giải đáp trên sân khấu.
class SpeakerQuestionModel {
  /// Mã định danh duy nhất của câu hỏi trên Cloud Firestore.
  final String id;

  /// Mã sự kiện diễn ra phiên hỏi đáp.
  final String eventId;

  /// Mã người dùng của sinh viên đặt câu hỏi.
  final String userId;

  /// Họ tên của sinh viên đặt câu hỏi (hoặc hiển thị "Sinh viên ẩn danh").
  final String studentName;

  /// Nội dung câu hỏi gửi tới diễn giả.
  final String question;

  /// Số lượt bình chọn quan tâm (upvotes) từ các sinh viên tham gia.
  final int upvotes;

  /// Thời điểm câu hỏi được gửi lên hệ thống.
  final DateTime timestamp;

  /// Cho biết câu hỏi đã được diễn giả trả lời hay chưa.
  final bool isAnswered;

  /// Khởi tạo một đối tượng [SpeakerQuestionModel].
  const SpeakerQuestionModel({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.studentName,
    required this.question,
    required this.upvotes,
    required this.timestamp,
    this.isAnswered = false,
  });

  /// Chuyển đổi dữ liệu Map từ Cloud Firestore thành đối tượng [SpeakerQuestionModel].
  factory SpeakerQuestionModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime resolveDate(dynamic val, dynamic fallback) {
      if (val is DateTime) return val;
      if (val != null && val.runtimeType.toString() == 'Timestamp') {
        try {
          return (val as dynamic).toDate() as DateTime;
        } catch (_) {}
      }
      if (fallback != null && fallback.runtimeType.toString() == 'Timestamp') {
        try {
          return (fallback as dynamic).toDate() as DateTime;
        } catch (_) {}
      }
      if (val != null) {
        final parsed = DateTime.tryParse(val.toString());
        if (parsed != null) return parsed;
      }
      if (fallback != null) {
        final parsed = DateTime.tryParse(fallback.toString());
        if (parsed != null) return parsed;
      }
      return DateTime.now();
    }

    return SpeakerQuestionModel(
      id: id,
      eventId: map['eventId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      studentName: map['studentName'] as String? ?? 'Sinh viên ẩn danh',
      question: map['question'] as String? ?? '',
      upvotes: (map['upvotes'] as num?)?.toInt() ?? 0,
      timestamp: resolveDate(map['timestamp'], map['createdAt']),
      isAnswered: map['isAnswered'] as bool? ?? false,
    );
  }

  /// Chuyển đổi đối tượng [SpeakerQuestionModel] thành Map để cập nhật trên Cloud Firestore.
  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'userId': userId,
      'studentName': studentName,
      'question': question,
      'upvotes': upvotes,
      'timestamp': timestamp.toIso8601String(),
      'isAnswered': isAnswered,
    };
  }
}
