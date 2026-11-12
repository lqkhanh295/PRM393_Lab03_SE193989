import 'package:flutter/foundation.dart';
import '../models/screen_state.dart';
import '../models/event_model.dart';
import '../services/firestore_service.dart';
import '../services/remote_config_service.dart';
import '../services/analytics_service.dart';

/// ViewModel điều phối dữ liệu cho màn hình Trang chủ (Home Campus Pulse).
///
/// Tích hợp trực tiếp các tham số từ Firebase Remote Config để giới hạn số lượng
/// sự kiện nổi bật và thay đổi tiêu đề biểu ngữ động mà không cần cập nhật mã nguồn.
class HomeViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService;
  final RemoteConfigService _remoteConfigService;
  final AnalyticsService _analyticsService;

  ScreenState<List<EventModel>> _state = const StateInitial();

  /// Trạng thái màn hình Trang chủ (Initial, Loading, Data, Empty, Error).
  ScreenState<List<EventModel>> get state => _state;

  List<EventModel> _allEvents = [];

  /// Toàn bộ danh sách sự kiện hiện có được tải về từ cơ sở dữ liệu.
  List<EventModel> get allEvents => _allEvents;

  /// Tiêu đề biểu ngữ sự kiện nổi bật được lấy động từ Remote Config hoặc sự kiện sắp diễn ra.
  String get bannerTitle {
    final raw = _remoteConfigService.featuredBannerTitle.trim();
    const staleBanner = 'Chào mừng đến với FPTU Tech Expo 2026';
    if (raw.isEmpty || raw == staleBanner || raw == RemoteConfigService.defaultBannerTitle) {
      final nextUpcoming = _allEvents.where((e) => !e.isPast).toList();
      if (nextUpcoming.isNotEmpty) {
        return 'Sắp diễn ra: ${nextUpcoming.first.title}';
      }
      return RemoteConfigService.defaultBannerTitle;
    }
    return raw;
  }

  /// Sắp xếp sự kiện ưu tiên sự kiện đang diễn ra / sắp diễn ra lên trước sự kiện đã kết thúc.
  static List<EventModel> sortEventsByPriority(List<EventModel> events) =>
      EventModel.sortByPriority(events);

  /// Số lượng sự kiện nổi bật tối đa được cấu hình từ xa.
  int get maxFeatured => _remoteConfigService.maxFeaturedEvents;

  /// Khởi tạo [HomeViewModel] với các phụ thuộc cần thiết.
  HomeViewModel({
    required FirestoreService firestoreService,
    required RemoteConfigService remoteConfigService,
    required AnalyticsService analyticsService,
  })  : _firestoreService = firestoreService,
        _remoteConfigService = remoteConfigService,
        _analyticsService = analyticsService;

  /// Tải dữ liệu sự kiện cho màn hình Trang chủ và áp dụng cấu hình Remote Config.
  Future<void> loadHomeScreenData() async {
    _state = const StateLoading('Đang cập nhật sự kiện nổi bật...');
    notifyListeners();

    try {
      await _remoteConfigService.fetchAndActivate();
      final fetched = await _firestoreService.getEvents(forceRefresh: true);
      _allEvents = sortEventsByPriority(fetched);

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

  /// Làm mới lại danh sách sự kiện nổi bật khi có thay đổi cấu hình từ Remote Config.
  void refreshRemoteConfig() {
    if (_allEvents.isNotEmpty) {
      final featuredEvents = _allEvents.take(_remoteConfigService.maxFeaturedEvents).toList();
      _state = StateData(featuredEvents);
      notifyListeners();
    }
  }
}
