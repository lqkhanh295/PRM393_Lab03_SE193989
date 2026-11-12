import 'package:flutter/foundation.dart';
import '../services/firestore_service.dart';
import '../services/crashlytics_service.dart';
import '../services/analytics_service.dart';

/// ViewModel quản lý Bàn điểm danh cổng tốc độ cao (Mobile Gate Check-in Desk).
///
/// Phục vụ cho Leader CLB và CTV tại cửa hội trường quét mã vé QR trong 1.5 giây,
/// phát hiện vé trùng lặp/vé giả mạo và theo dõi tỷ lệ lấp đầy hội trường trực tiếp.
class MobileDeskViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService;
  final CrashlyticsService _crashlyticsService;
  final AnalyticsService _analyticsService;

  int _checkedInCount = 0;
  int _totalCapacity = 0;

  /// Số lượng sinh viên đã check-in qua cổng thành công.
  int get checkedInCount => _checkedInCount;

  /// Sức chứa tối đa của địa điểm tổ chức sự kiện.
  int get totalCapacity => _totalCapacity;

  /// Tỷ lệ lấp đầy hội trường theo thời gian thực (0.0 đến 1.0).
  double get attendanceRate => _totalCapacity > 0 ? (_checkedInCount / _totalCapacity) : 0.0;

  CheckInValidationResult? _lastResult;

  /// Kết quả của lần quét vé gần nhất (hợp lệ, trùng lặp hoặc lỗi).
  CheckInValidationResult? get lastResult => _lastResult;

  bool _isProcessing = false;

  /// Cho biết hệ thống có đang trong tiến trình xử lý và xác thực mã vé hay không.
  bool get isProcessing => _isProcessing;

  /// Khởi tạo [MobileDeskViewModel] với các phụ thuộc dịch vụ.
  MobileDeskViewModel({
    required FirestoreService firestoreService,
    required CrashlyticsService crashlyticsService,
    required AnalyticsService analyticsService,
  })  : _firestoreService = firestoreService,
        _crashlyticsService = crashlyticsService,
        _analyticsService = analyticsService;

  /// Tải thông số sức chứa và số lượng đã điểm danh thực tế của sự kiện [eventId].
  Future<void> loadEventStats(String eventId) async {
    try {
      final event = await _firestoreService.getEventById(eventId);
      if (event != null) {
        _totalCapacity = event.capacity;
        final realChecked = await _firestoreService.getCheckedInCount(eventId);
        _checkedInCount = realChecked;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[MobileDeskViewModel] Load stats note: $e');
    }
  }

  /// Xử lý quét mã QR [qrToken] để điểm danh sinh viên vào sự kiện [eventId].
  ///
  /// Cung cấp tham số [isManual] nếu CTV nhập mã thủ công bằng bàn phím.
  /// Tự động cảnh báo vé trùng lập tức và ghi nhận dữ liệu chẩn đoán lên Crashlytics.
  Future<CheckInValidationResult> processCheckInScan({
    required String qrToken,
    required String eventId,
    bool isManual = false,
  }) async {
    _isProcessing = true;
    notifyListeners();

    try {
      final result = await _firestoreService.validateAndCheckInTicket(
        qrToken: qrToken.trim(),
        eventId: eventId,
      );

      _lastResult = result;
      _isProcessing = false;

      if (result.isValid) {
        _checkedInCount++;
        await _analyticsService.logRegisterEvent(
          eventId: eventId,
          clubId: 'fcode',
          durationSeconds: 1,
        );
      } else if (result.isDuplicate) {
        // Record non-fatal event in Crashlytics
        await _crashlyticsService.setCustomKey('duplicate_ticket_token', qrToken);
        await _crashlyticsService.setCustomKey('scan_method', isManual ? 'manual' : 'qr');
      }

      notifyListeners();
      return result;
    } catch (e, stack) {
      _isProcessing = false;
      await _crashlyticsService.recordHandledError(e, stack, reason: 'Check-in validation error');
      final errorResult = CheckInValidationResult(
        isValid: false,
        isDuplicate: false,
        message: 'Lỗi xác thực hệ thống: $e',
      );
      _lastResult = errorResult;
      notifyListeners();
      return errorResult;
    }
  }

  /// Xóa bỏ kết quả quét gần nhất để sẵn sàng đón lượt quét tiếp theo.
  void clearResult() {
    _lastResult = null;
    notifyListeners();
  }
}
