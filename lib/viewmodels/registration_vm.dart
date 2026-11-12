import 'package:flutter/foundation.dart';
import '../models/screen_state.dart';
import '../models/event_model.dart';
import '../models/ticket_model.dart';
import '../models/user_model.dart';
import '../models/registration_model.dart';
import '../services/firestore_service.dart';
import '../services/analytics_service.dart';
import '../services/crashlytics_service.dart';

/// ViewModel điều phối tiến trình đăng ký tham gia sự kiện của sinh viên (Registration Pipeline).
///
/// Hỗ trợ cả 2 luồng: Đăng ký vé tức thời 1-Tap (sinh vé QR ngay) và
/// Đăng ký có phê duyệt qua hàng chờ của Cán bộ (Cross-role Approval Queue).
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

  /// Nộp hồ sơ đăng ký vào hàng chờ xét duyệt của Cán bộ/Ban tổ chức (Cross-role Review).
  Future<RegistrationModel?> submitPendingRegistration({
    required EventModel event,
    required UserModel user,
  }) async {
    _state = const StateLoading('Đang gửi hồ sơ đăng ký tới Ban Tổ Chức...');
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 1000));
      final registration = await _firestoreService.submitRegistration(
        event: event,
        user: user,
      );

      await _analyticsService.logRegisterEvent(
        eventId: event.id,
        clubId: event.clubId,
        durationSeconds: 1,
        calendarSynced: false,
      );

      _state = const StateInitial();
      notifyListeners();
      return registration;
    } catch (e, stack) {
      debugPrint('[RegistrationViewModel] Pending registration error: $e');
      await _crashlyticsService.recordHandledError(
        e,
        stack,
        reason: 'Cross-role pending registration failure for event ${event.id}',
        customKeys: {'eventId': event.id, 'userId': user.id},
      );
      _state = StateError(e.toString().replaceAll('Exception: ', ''));
      notifyListeners();
      return null;
    }
  }

  /// Đưa trạng thái phát hành vé về mặc định ban đầu ([StateInitial]).
  void reset() {
    _state = const StateInitial();
    notifyListeners();
  }
}
