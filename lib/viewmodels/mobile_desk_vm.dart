import 'package:flutter/foundation.dart';
import '../services/firestore_service.dart';
import '../services/crashlytics_service.dart';
import '../services/analytics_service.dart';

/// MVVM MobileDeskViewModel
/// Governs the high-speed Mobile Gate Check-in Desk, duplicate detection, and manual override.
class MobileDeskViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService;
  final CrashlyticsService _crashlyticsService;
  final AnalyticsService _analyticsService;

  int _checkedInCount = 0;
  int _totalCapacity = 0;
  int get checkedInCount => _checkedInCount;
  int get totalCapacity => _totalCapacity;
  double get attendanceRate => _totalCapacity > 0 ? (_checkedInCount / _totalCapacity) : 0.0;

  CheckInValidationResult? _lastResult;
  CheckInValidationResult? get lastResult => _lastResult;

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  MobileDeskViewModel({
    required FirestoreService firestoreService,
    required CrashlyticsService crashlyticsService,
    required AnalyticsService analyticsService,
  })  : _firestoreService = firestoreService,
        _crashlyticsService = crashlyticsService,
        _analyticsService = analyticsService;

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

  void resetLastResult() {
    _lastResult = null;
    notifyListeners();
  }
}
