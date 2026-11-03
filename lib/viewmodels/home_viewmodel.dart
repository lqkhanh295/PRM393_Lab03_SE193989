import 'package:flutter/foundation.dart';
import '../models/screen_state.dart';
import '../models/event_model.dart';
import '../services/firestore_service.dart';
import '../services/remote_config_service.dart';
import '../services/analytics_service.dart';

/// MVVM HomeViewModel
/// Governs the Home Campus Pulse screen, applying dynamic Remote Config values.
class HomeViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService;
  final RemoteConfigService _remoteConfigService;
  final AnalyticsService _analyticsService;

  ScreenState<List<EventModel>> _state = const StateInitial();
  ScreenState<List<EventModel>> get state => _state;

  List<EventModel> _allEvents = [];
  String get bannerTitle => _remoteConfigService.featuredBannerTitle;
  int get maxFeatured => _remoteConfigService.maxFeaturedEvents;

  HomeViewModel({
    required FirestoreService firestoreService,
    required RemoteConfigService remoteConfigService,
    required AnalyticsService analyticsService,
  })  : _firestoreService = firestoreService,
        _remoteConfigService = remoteConfigService,
        _analyticsService = analyticsService;

  Future<void> loadHomeScreenData() async {
    _state = const StateLoading('Đang cập nhật sự kiện nổi bật...');
    notifyListeners();

    try {
      await _remoteConfigService.fetchAndActivate();
      _allEvents = await _firestoreService.getEvents();

      if (_allEvents.isEmpty) {
        _state = const StateEmpty('Hiện chưa có sự kiện nào sắp diễn ra.');
      } else {
        // Apply Remote Config parameter threshold: max_featured_events
        final featuredEvents = _allEvents.take(_remoteConfigService.maxFeaturedEvents).toList();
        _state = StateData(featuredEvents);
        await _analyticsService.logViewItem(
          itemId: 'home_featured_feed',
          itemName: 'Home Campus Pulse Feed',
          category: 'screen_feed',
          spotsRemaining: 0,
        );
      }
      notifyListeners();
    } catch (e) {
      debugPrint('[HomeViewModel] Load error: $e');
      _state = StateError('Không thể tải danh sách sự kiện: $e');
      notifyListeners();
    }
  }

  void refreshRemoteConfig() {
    if (_allEvents.isNotEmpty) {
      final featuredEvents = _allEvents.take(_remoteConfigService.maxFeaturedEvents).toList();
      _state = StateData(featuredEvents);
      notifyListeners();
    }
  }
}
