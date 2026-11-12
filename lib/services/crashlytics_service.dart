import 'package:flutter/foundation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// Dịch vụ giám sát lỗi và quản lý sự cố ứng dụng qua Firebase Crashlytics.
///
/// Xử lý ghi nhận các lỗi nghiêm trọng (fatal) và lỗi được xử lý (non-fatal),
/// đồng thời đính kèm mã người dùng và các khóa ngữ cảnh chẩn đoán (custom keys).
class CrashlyticsService {
  final FirebaseCrashlytics? _crashlytics;

  /// Khởi tạo [CrashlyticsService] với tùy chọn [FirebaseCrashlytics] (hỗ trợ Mocking).
  CrashlyticsService([this._crashlytics]);

  /// Gán định danh người dùng [userId] vào báo cáo Crashlytics giúp lọc lỗi theo phiên làm việc.
  Future<void> setUserId(String userId) async {
    try {
      await _crashlytics?.setUserIdentifier(userId);
      debugPrint('[CrashlyticsService] User identifier updated.');
    } catch (e) {
      debugPrint('[CrashlyticsService] Error setUserIdentifier: $e');
    }
  }

  /// Gán một cặp khóa [key] - giá trị [value] tùy chỉnh để cung cấp ngữ cảnh khi xảy ra lỗi.
  Future<void> setCustomKey(String key, Object value) async {
    try {
      await _crashlytics?.setCustomKey(key, value);
      debugPrint('[CrashlyticsService] Custom key set: $key = $value');
    } catch (e) {
      debugPrint('[CrashlyticsService] Error setCustomKey: $e');
    }
  }

  /// Ghi nhận ngoại lệ được xử lý an toàn (non-fatal error) lên Firebase Crashlytics.
  ///
  /// Nhận vào ngoại lệ [exception], vết ngăn xếp [stack], lý do [reason],
  /// và bản đồ các khóa chẩn đoán bổ sung [customKeys].
  Future<void> recordHandledError(
    dynamic exception,
    StackTrace? stack, {
    String? reason,
    Map<String, Object>? customKeys,
  }) async {
    try {
      if (customKeys != null) {
        for (final entry in customKeys.entries) {
          await _crashlytics?.setCustomKey(entry.key, entry.value);
        }
      }
      await _crashlytics?.recordError(
        exception,
        stack ?? StackTrace.current,
        reason: reason ?? 'Handled error from Campus Event app',
        fatal: false,
      );
      debugPrint(
        '[CrashlyticsService] Handled non-fatal error recorded: $exception ($reason)',
      );
    } catch (e) {
      debugPrint('[CrashlyticsService] Error recording non-fatal: $e');
    }
  }

  /// Kích hoạt một vụ sập có chủ đích (Test Crash) phục vụ kiểm tra và chấm demo nghiệm thu.
  ///
  /// Sau khi kích hoạt crash và khởi động lại app, SDK sẽ tự động gửi báo cáo lên Firebase Console.
  void triggerTestCrash() {
    if (_crashlytics == null) {
      debugPrint(
        '[CrashlyticsService] Test crash skipped in offline/test mode.',
      );
      return;
    }
    _crashlytics.setCustomKey('test_crash_origin', 'verification_screen');
    _crashlytics.crash();
  }
}
