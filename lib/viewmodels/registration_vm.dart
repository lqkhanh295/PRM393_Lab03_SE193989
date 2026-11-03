import 'package:flutter/foundation.dart';
import '../models/screen_state.dart';
import '../models/event_model.dart';
import '../models/ticket_model.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import '../services/analytics_service.dart';
import '../services/crashlytics_service.dart';

/// MVVM RegistrationViewModel
/// Coordinates the 1-Tap event registration pipeline with simulated security encoding.
class RegistrationViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService;
  final AnalyticsService _analyticsService;
  final CrashlyticsService _crashlyticsService;

  ScreenState<TicketModel> _state = const StateInitial();
  ScreenState<TicketModel> get state => _state;

  RegistrationViewModel({
    required FirestoreService firestoreService,
    required AnalyticsService analyticsService,
    required CrashlyticsService crashlyticsService,
  })  : _firestoreService = firestoreService,
        _analyticsService = analyticsService,
        _crashlyticsService = crashlyticsService;

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

  void reset() {
    _state = const StateInitial();
    notifyListeners();
  }
}
