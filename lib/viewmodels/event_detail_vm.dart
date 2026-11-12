import 'package:flutter/foundation.dart';
import '../models/screen_state.dart';
import '../models/event_model.dart';
import '../services/firestore_service.dart';
import '../services/analytics_service.dart';
import '../services/crashlytics_service.dart';

/// ViewModel quản lý dữ liệu chi tiết sự kiện trên màn hình Event Detail.
///
/// Xử lý tải thông tin sự kiện, danh sách diễn giả, lịch trình chi tiết,
/// hỗ trợ cập nhật lạc quan (Optimistic Update) số lượng chỗ và làm mới ngầm.
class EventDetailViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService;
  final AnalyticsService _analyticsService;
  final CrashlyticsService _crashlyticsService;

  ScreenState<EventModel> _state = const StateInitial();

  /// Trạng thái hiển thị của màn hình Chi tiết Sự kiện.
  ScreenState<EventModel> get state => _state;

  /// Khởi tạo [EventDetailViewModel] với các dịch vụ cần thiết.
  EventDetailViewModel({
    required FirestoreService firestoreService,
    required AnalyticsService analyticsService,
    required CrashlyticsService crashlyticsService,
  })  : _firestoreService = firestoreService,
        _analyticsService = analyticsService,
        _crashlyticsService = crashlyticsService;

  /// Tải thông tin chi tiết sự kiện theo [eventId] và ghi nhận sự kiện Analytics `view_item`.
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

  /// Tăng số lượng người đăng ký theo kiểu lạc quan (Optimistic Update) giúp UI phản hồi tức thì.
  void incrementRegistration() {
    if (_state is StateData<EventModel>) {
      final current = (_state as StateData<EventModel>).data;
      _state = StateData(current.copyWith(
        registeredCount: current.registeredCount + 1,
      ));
      notifyListeners();
    }
  }

  /// Làm mới ngầm dữ liệu sự kiện [eventId] từ Cloud Firestore mà không hiện vòng xoay tải trang.
  Future<void> refreshEvent(String eventId) async {
    try {
      final event = await _firestoreService.getEventById(eventId);
      if (event != null) {
        _state = StateData(event);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[EventDetailViewModel] refreshEvent warning: $e');
    }
  }
}
