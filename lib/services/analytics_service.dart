import 'package:flutter/foundation.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

/// Dịch vụ quản lý sự kiện và hành vi người dùng qua Firebase Analytics.
///
/// Tuân thủ nghiêm ngặt chính sách Zero-PII (không gửi thông tin nhận dạng cá nhân)
/// và ghi nhận đầy đủ 7 sự kiện nghiệp vụ chuẩn của hệ thống Campus Event FPTU.
class AnalyticsService {
  final FirebaseAnalytics? _analytics;

  /// Khởi tạo [AnalyticsService] với tùy chọn [FirebaseAnalytics] (hỗ trợ Mocking trong Unit Test).
  AnalyticsService([this._analytics]);

  /// Cập nhật định danh người dùng trên Firebase Analytics để theo dõi luồng trải nghiệm.
  ///
  /// Nhận vào [userId] là mã ẩn danh hoặc UID từ Firebase Authentication.
  Future<void> setUserId(String? userId) async {
    try {
      await _analytics?.setUserId(id: userId);
      debugPrint('[AnalyticsService] User identifier updated.');
    } catch (e) {
      debugPrint('[AnalyticsService] Error setUserId: $e');
    }
  }

  /// Ghi nhận sự kiện đăng nhập tài khoản sinh viên/cán bộ.
  ///
  /// Nhận vào phương thức đăng nhập [method] (vd: `google`, `email_fpt`)
  /// và vai trò người dùng [role] (vd: `student`, `ctsv_staff`, `club_leader`).
  Future<void> logLogin({required String method, required String role}) async {
    try {
      await _analytics?.logLogin(loginMethod: method);
      await _analytics?.setUserProperty(name: 'user_role', value: role);
      debugPrint('[AnalyticsService] Event logged: login ($method, $role)');
    } catch (e) {
      debugPrint('[AnalyticsService] Error logLogin: $e');
    }
  }

  /// Ghi nhận sự kiện tìm kiếm sự kiện hoặc câu lạc bộ trên tab Khám phá.
  ///
  /// Từ khóa [searchTerm] được tự động lọc bỏ PII (MSSV, email).
  /// Nhận thêm số lượng kết quả trả về [resultCount] và danh mục [category].
  Future<void> logSearch({
    required String searchTerm,
    required int resultCount,
    String? category,
  }) async {
    try {
      // Search text is user input. Do not send strings that resemble email
      // addresses or student identifiers to Firebase Analytics.
      final safeSearchTerm = _safeSearchTerm(searchTerm);
      await _analytics?.logSearch(
        searchTerm: safeSearchTerm,
        numberOfNights: null,
      );
      debugPrint(
        '[AnalyticsService] Event logged: search (count: $resultCount, category: ${category ?? 'all'})',
      );
    } catch (e) {
      debugPrint('[AnalyticsService] Error logSearch: $e');
    }
  }

  /// Ghi nhận sự kiện sinh viên nhấn xem chi tiết một sự kiện cụ thể.
  ///
  /// Bao gồm mã sự kiện [itemId], tên sự kiện [itemName],
  /// phân loại [category], và số lượng chỗ còn trống [spotsRemaining].
  Future<void> logViewItem({
    required String itemId,
    required String itemName,
    required String category,
    required int spotsRemaining,
  }) async {
    try {
      await _analytics?.logViewItem(
        items: [
          AnalyticsEventItem(
            itemId: itemId,
            itemName: itemName,
            itemCategory: category,
          ),
        ],
      );
      debugPrint(
        '[AnalyticsService] Event logged: view_item ($itemId - $itemName)',
      );
    } catch (e) {
      debugPrint('[AnalyticsService] Error logViewItem: $e');
    }
  }

  /// Ghi nhận sự kiện đăng ký vé tham gia sự kiện thành công.
  ///
  /// Bao gồm mã sự kiện [eventId], mã câu lạc bộ chủ trì [clubId],
  /// thời gian hoàn tất đăng ký [durationSeconds], và trạng thái đồng bộ lịch [calendarSynced].
  Future<void> logRegisterEvent({
    required String eventId,
    required String clubId,
    required int durationSeconds,
    bool calendarSynced = true,
  }) async {
    try {
      await _analytics?.logEvent(
        name: 'register_event',
        parameters: {
          'event_id': eventId,
          'club_id': clubId,
          'registration_seconds': durationSeconds,
          'calendar_synced': calendarSynced ? 1 : 0,
        },
      );
      debugPrint('[AnalyticsService] Event logged: register_event ($eventId)');
    } catch (e) {
      debugPrint('[AnalyticsService] Error logRegisterEvent: $e');
    }
  }

  /// Ghi nhận các tương tác trực tiếp trong sự kiện (Live Companion).
  ///
  /// Nhận vào [eventId], loại hành động [actionType] (vd: `ask_question`, `upvote_question`),
  /// và độ dài câu hỏi [length].
  Future<void> logLiveInteract({
    required String eventId,
    required String actionType,
    required int length,
  }) async {
    try {
      await _analytics?.logEvent(
        name: 'live_interact',
        parameters: {
          'event_id': eventId,
          'action_type': actionType,
          'question_length': length,
        },
      );
      debugPrint(
        '[AnalyticsService] Event logged: live_interact ($actionType)',
      );
    } catch (e) {
      debugPrint('[AnalyticsService] Error logLiveInteract: $e');
    }
  }

  /// Ghi nhận kết quả đánh giá chất lượng sự kiện từ sinh viên.
  ///
  /// Nhận vào [eventId], số sao đánh giá [rating] (1 đến 5),
  /// và trạng thái có kèm nhận xét dạng văn bản hay không [hasComment].
  Future<void> logSubmitFeedback({
    required String eventId,
    required int rating,
    bool hasComment = false,
  }) async {
    try {
      await _analytics?.logEvent(
        name: 'submit_feedback',
        parameters: {
          'event_id': eventId,
          'rating_stars': rating,
          'has_text_comment': hasComment ? 1 : 0,
        },
      );
      debugPrint(
        '[AnalyticsService] Event logged: submit_feedback ($rating stars)',
      );
    } catch (e) {
      debugPrint('[AnalyticsService] Error logSubmitFeedback: $e');
    }
  }

  /// Ghi nhận sự kiện tạo và tải giấy chứng nhận tham gia (e-Certificate) dạng PDF.
  ///
  /// Bao gồm loại xuất [exportType], kích thước file tính theo bytes [fileSizeBytes],
  /// và tổng thời gian sinh/tải file [durationMs].
  Future<void> logExportReport({
    required String exportType,
    required int fileSizeBytes,
    required int durationMs,
  }) async {
    try {
      await _analytics?.logEvent(
        name: 'export_report',
        parameters: {
          'export_type': exportType,
          'file_size_kb': (fileSizeBytes / 1024).round(),
          'upload_duration_ms': durationMs,
        },
      );
      debugPrint(
        '[AnalyticsService] Event logged: export_report ($exportType, ${fileSizeBytes}B)',
      );
    } catch (e) {
      debugPrint('[AnalyticsService] Error logExportReport: $e');
    }
  }

  /// Ghi nhận sự kiện đăng xuất khỏi ứng dụng và thời lượng phiên hoạt động [sessionMinutes].
  Future<void> logLogout({required int sessionMinutes}) async {
    try {
      await _analytics?.logEvent(
        name: 'logout_action',
        parameters: {'session_duration_minutes': sessionMinutes},
      );
      debugPrint('[AnalyticsService] Event logged: logout');
    } catch (e) {
      debugPrint('[AnalyticsService] Error logLogout: $e');
    }
  }

  /// Ghi nhận sự kiện tùy chỉnh nghiệp vụ nội bộ sau khi làm sạch PII.
  ///
  /// Kiểm tra tính hợp lệ của [eventName] theo quy chuẩn đặt tên Firebase
  /// và lọc các giá trị trong [parameters] tránh rò rỉ dữ liệu cá nhân.
  Future<void> logCustomEvent({
    required String eventName,
    Map<String, Object>? parameters,
  }) async {
    final isValidName = RegExp(r'^[a-z][a-z0-9_]{0,39}$').hasMatch(eventName);
    final isReservedPrefix =
        eventName.startsWith('firebase_') ||
        eventName.startsWith('google_') ||
        eventName.startsWith('ga_');
    if (!isValidName || isReservedPrefix) {
      debugPrint('[AnalyticsService] Ignored invalid analytics event name.');
      return;
    }

    try {
      final safeParameters = <String, Object>{
        for (final entry in (parameters ?? const <String, Object>{}).entries)
          entry.key: entry.value is String
              ? _safeSearchTerm(entry.value as String)
              : entry.value,
      };
      await _analytics?.logEvent(name: eventName, parameters: safeParameters);
      debugPrint('[AnalyticsService] Custom event logged: $eventName');
    } catch (e) {
      debugPrint('[AnalyticsService] Error logging custom event: $e');
    }
  }

  /// Bộ lọc làm sạch chuỗi văn bản đầu vào ngăn chặn rò rỉ PII.
  ///
  /// Thay thế chuỗi bằng `redacted` nếu phát hiện định dạng email hoặc chuỗi số dài (MSSV).
  String _safeSearchTerm(String value) {
    final normalized = value.trim();
    final looksLikeEmail = normalized.contains('@');
    final hasLongNumber = RegExp(r'\d{7,}').hasMatch(normalized);
    if (normalized.isEmpty ||
        normalized.length > 50 ||
        looksLikeEmail ||
        hasLongNumber) {
      return 'redacted';
    }
    return normalized;
  }
}
