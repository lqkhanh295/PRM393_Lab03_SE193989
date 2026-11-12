import 'package:flutter/foundation.dart';
import '../models/screen_state.dart';
import '../models/event_model.dart';
import '../models/ticket_model.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import '../services/analytics_service.dart';
import '../services/crashlytics_service.dart';

/// ViewModel điều phối tiến trình đăng ký sự kiện và phát hành vé QR tức thì (Instant QR Pipeline).
///
/// Kiểm tra sức chứa, tránh trùng vé và phát hành ngay mã QR trên Cloud Firestore khi sự kiện còn chỗ.
class RegistrationViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService;
  final AnalyticsService _analyticsService;
  final CrashlyticsService _crashlyticsService;

  ScreenState<TicketModel> _state = const StateInitial();

  /// Trạng thái kết quả phát hành vé điện tử (Initial, Loading, Data, Error).
  ScreenState<TicketModel> get state => _state;

  /// Khởi tạo [RegistrationViewModel] với các phụ thuộc cần thiết.
  RegistrationViewModel({
    required FirestoreService firestoreService,
    required AnalyticsService analyticsService,
    required CrashlyticsService crashlyticsService,
  })  : _firestoreService = firestoreService,
        _analyticsService = analyticsService,
        _crashlyticsService = crashlyticsService;

  /// Thực hiện đăng ký 1 chạm (1-Tap Registration) và sinh ngay vé điện tử kèm mã QR Token.
  ///
  /// Nhận vào [event] và thông tin [user], tự động đo thời gian đăng ký và ghi log Analytics.
  Future<bool> register({
    required EventModel event,
    required UserModel user,
  }) async {
    _state = const StateLoading('Đang mã hóa mã vé và bảo mật Dynamic QR Token...');
    notifyListeners();

    final stopwatch = Stopwatch()..start();

    try {
      // 1.5s transition animation complying with Nielsen Heuristic #1
      await Future.delayed(const Duration(milliseconds: 1400));

      final ticket = await _firestoreService.registerForEvent(
        event: event,
        user: user,
      );

      stopwatch.stop();

      await _analyticsService.logRegisterEvent(
        eventId: event.id,
        clubId: event.clubId,
        durationSeconds: stopwatch.elapsed.inSeconds,
        calendarSynced: true,
      );

      _state = StateData(ticket);
      notifyListeners();
      return true;
    } catch (e, stack) {
      debugPrint('[RegistrationViewModel] Registration error: $e');
      await _crashlyticsService.recordHandledError(
        e,
        stack,
        reason: 'Event registration failure for event ${event.id}',
        customKeys: {'eventId': event.id, 'userId': user.id},
      );
      _state = StateError(e.toString().replaceAll('Exception: ', ''));
      notifyListeners();
      return false;
    }
  }

  /// Đưa trạng thái phát hành vé về mặc định ban đầu ([StateInitial]).
  void reset() {
    _state = const StateInitial();
    notifyListeners();
  }
}
