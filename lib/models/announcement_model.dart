import 'package:cloud_firestore/cloud_firestore.dart';

/// Announcement Model for Campus Event System
/// Displayed in the Mobile App Inbox in real-time and broadcasted from Web Admin.
class AnnouncementModel {
  final String id;
  final String title;
  final String content;
  final String category;
  final String authorRole;
  final String? eventId;
  final String userId;
  final bool isPinned;
  final DateTime createdAt;

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
      isPinned: map['isPinned'] as bool? ?? false,
      createdAt: parseDate(map['createdAt']),
    );
  }

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
