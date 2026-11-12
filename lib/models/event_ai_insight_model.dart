/// Mô hình dữ liệu phân tích thông minh sự kiện được tạo bởi Google Gemini AI.
///
/// Tuân thủ nguyên tắc Zero-PII: chỉ phân tích tóm tắt nội dung hội thảo, chủ đề nghị trình
/// và nhóm khán giả phù hợp mà không lưu trữ hay xử lý bất kỳ thông tin nhận dạng cá nhân nào.
class EventAiInsightModel {
  /// Tóm tắt nội dung sự kiện bằng ngôn ngữ tự nhiên xúc tích do AI sinh ra.
  final String summary;

  /// Các bài học hoặc giá trị cốt lõi mà người tham gia sẽ thu hoạch được.
  final List<String> keyTakeaways;

  /// Đối tượng sinh viên hoặc chuyên ngành phù hợp nhất với sự kiện này.
  final List<String> recommendedAudience;

  /// Danh sách câu hỏi gợi ý để sinh viên tham gia đặt câu hỏi trong phiên Q&A.
  final List<String> suggestedQuestions;

  /// Cờ báo hiệu nội dung này được tạo từ thuật toán dự phòng nội bộ (khi ngoại tuyến hoặc lỗi mạng).
  final bool isFallback;

  /// Khởi tạo một đối tượng [EventAiInsightModel].
  const EventAiInsightModel({
    required this.summary,
    required this.keyTakeaways,
    required this.recommendedAudience,
    required this.suggestedQuestions,
    this.isFallback = false,
  });

  /// Chuyển đổi phản hồi JSON có cấu trúc từ Gemini API thành đối tượng [EventAiInsightModel].
  factory EventAiInsightModel.fromJson(Map<String, dynamic> json, {bool isFallback = false}) {
    List<String> parseList(dynamic val) {
      if (val is List) {
        return val.map((e) => e.toString().trim()).where((s) => s.isNotEmpty).toList();
      }
      return [];
    }

    return EventAiInsightModel(
      summary: json['summary'] as String? ?? 'Tóm tắt nội dung hội thảo từ Trí tuệ Nhân tạo Gemini.',
      keyTakeaways: parseList(json['keyTakeaways']),
      recommendedAudience: parseList(json['recommendedAudience']),
      suggestedQuestions: parseList(json['suggestedQuestions']),
      isFallback: isFallback,
    );
  }

  /// Chuyển đổi đối tượng [EventAiInsightModel] thành định dạng Map JSON.
  Map<String, dynamic> toJson() {
    return {
      'summary': summary,
      'keyTakeaways': keyTakeaways,
      'recommendedAudience': recommendedAudience,
      'suggestedQuestions': suggestedQuestions,
      'isFallback': isFallback,
    };
  }

  /// Tạo một bản sao của đối tượng với các thuộc tính được cập nhật có chọn lọc.
  EventAiInsightModel copyWith({
    String? summary,
    List<String>? keyTakeaways,
    List<String>? recommendedAudience,
    List<String>? suggestedQuestions,
    bool? isFallback,
  }) {
    return EventAiInsightModel(
      summary: summary ?? this.summary,
      keyTakeaways: keyTakeaways ?? this.keyTakeaways,
      recommendedAudience: recommendedAudience ?? this.recommendedAudience,
      suggestedQuestions: suggestedQuestions ?? this.suggestedQuestions,
      isFallback: isFallback ?? this.isFallback,
    );
  }
}
