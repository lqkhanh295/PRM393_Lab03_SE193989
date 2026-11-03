import 'package:flutter/foundation.dart';
import '../models/screen_state.dart';
import '../models/event_model.dart';
import '../services/firestore_service.dart';
import '../services/analytics_service.dart';
import '../services/crashlytics_service.dart';

/// MVVM EventDetailViewModel
class EventDetailViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService;
  final AnalyticsService _analyticsService;
  final CrashlyticsService _crashlyticsService;

  ScreenState<EventModel> _state = const StateInitial();
  ScreenState<EventModel> get state => _state;

  EventDetailViewModel({
    required FirestoreService firestoreService,
    required AnalyticsService analyticsService,
    required CrashlyticsService crashlyticsService,
  })  : _firestoreService = firestoreService,
        _analyticsService = analyticsService,
        _crashlyticsService = crashlyticsService;

  Future<void> loadEvent(String eventId) async {
    _state = const StateLoading('Đang tải chi tiết sự kiện...');
    notifyListeners();

    try {
      final event = await _firestoreService.getEventById(eventId);
      if (event == null) {
        _state = const StateEmpty('Sự kiện không tồn tại hoặc đã bị gỡ bỏ.');
      } else {
        await _analyticsService.logViewItem(
          itemId: event.id,
          itemName: event.title,
          category: event.category,
          spotsRemaining: event.spotsRemaining,
        );
        _state = StateData(event);
      }
      notifyListeners();
    } catch (e, stack) {
      await _crashlyticsService.recordHandledError(e, stack, reason: 'Failed to load event $eventId');
      _state = StateError('Không thể tải thông tin sự kiện: $e');
      notifyListeners();
    }
  }
}
