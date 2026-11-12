import 'package:cloud_firestore/cloud_firestore.dart';

/// Mô hình thông báo (Announcement) trong hệ thống Campus Event.
///
/// Đại diện cho các bản tin được phát thanh từ Web Admin Portal tới ứng dụng di động
/// của sinh viên theo thời gian thực trên Cloud Firestore collection `announcements`.
class AnnouncementModel {
  /// Mã định danh duy nhất của thông báo trên Cloud Firestore.
  final String id;

  /// Tiêu đề ngắn gọn của thông báo.
  final String title;

  /// Nội dung chi tiết hoặc thông điệp gửi tới sinh viên.
  final String content;

  /// Phân loại thông báo (ví dụ: `general`, `urgent`, `event`, `budget`).
  final String category;

  /// Vai trò của người phát hành thông báo (ví dụ: `staff`, `admin`, `leader`).
  final String authorRole;

  /// Mã sự kiện liên quan (nếu thông báo dành riêng cho một sự kiện cụ thể).
  final String? eventId;

  /// Mã người nhận cụ thể (để trống nếu thông báo phát rộng rãi cho toàn trường).
  final String userId;

  /// Cờ đánh dấu thông báo quan trọng được ghim lên đầu danh sách.
  final bool isPinned;

  /// Thời điểm thông báo được tạo hoặc phát thanh.
  final DateTime createdAt;

  /// Khởi tạo một đối tượng [AnnouncementModel].
  const AnnouncementModel({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.authorRole,
    this.eventId,
    this.userId = '',
    this.isPinned = false,
    required this.createdAt,
  });

  /// Chuyển đổi dữ liệu từ Firestore Map và [id] thành đối tượng [AnnouncementModel].
  factory AnnouncementModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) {
        return DateTime.tryParse(val) ?? DateTime.now();
      }
      return DateTime.now();
    }

    return AnnouncementModel(
      id: id,
      title: map['title'] as String? ?? 'Thông báo từ Ban Tổ Chức',
      content: (map['content'] ?? map['message']) as String? ?? '',
      category: map['category'] as String? ?? 'general',
      authorRole: map['authorRole'] as String? ?? 'staff',
      eventId: map['eventId'] as String?,
      userId: map['userId'] as String? ?? '',
      isPinned: (map['isPinned'] as bool?) ?? (map['pinned'] as bool?) ?? false,
      createdAt: parseDate(map['createdAt']),
    );
  }

  /// Chuyển đổi đối tượng [AnnouncementModel] thành Map để lưu trữ trên Cloud Firestore.
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'category': category,
      'authorRole': authorRole,
      if (eventId != null) 'eventId': eventId,
      if (userId.isNotEmpty) 'userId': userId,
      'isPinned': isPinned,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
