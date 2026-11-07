import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/screen_state.dart';
import '../models/announcement_model.dart';
import '../services/firestore_service.dart';
import '../services/analytics_service.dart';

/// MVVM InboxViewModel
/// Governs the real-time Announcements Inbox for students.
/// Listens to Cloud Firestore collection 'announcements' in real-time.
class InboxViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService;
  final AnalyticsService _analyticsService;

  StreamSubscription<List<AnnouncementModel>>? _subscription;
  ScreenState<List<AnnouncementModel>> _state = const StateInitial();
  ScreenState<List<AnnouncementModel>> get state => _state;

  List<AnnouncementModel> _allAnnouncements = [];
  String _selectedCategory = 'All';
  String get selectedCategory => _selectedCategory;

  List<AnnouncementModel> get filteredAnnouncements {
    if (_selectedCategory == 'All' || _selectedCategory == 'Tất cả') {
      return _allAnnouncements;
    }
    return _allAnnouncements.where((a) => a.category == _selectedCategory).toList();
  }

  int get unreadCount => _allAnnouncements.length;

  InboxViewModel({
    required FirestoreService firestoreService,
    required AnalyticsService analyticsService,
  })  : _firestoreService = firestoreService,
        _analyticsService = analyticsService {
    listenToAnnouncements();
  }

  void listenToAnnouncements() {
    _state = const StateLoading('Đang tải hộp thư thông báo...');
    notifyListeners();

    _subscription?.cancel();
    _subscription = _firestoreService.streamAnnouncements().listen(
      (list) {
        _allAnnouncements = list;
        if (list.isEmpty) {
          _state = const StateEmpty('Hộp thư chưa có thông báo mới nào từ Ban Tổ Chức.');
        } else {
          _state = StateData(list);
        }
        notifyListeners();
      },
      onError: (e) {
        debugPrint('[InboxViewModel] Stream error: $e');
        _state = StateError('Không thể đồng bộ hộp thư: $e');
        notifyListeners();
      },
    );
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> logOpenInbox() async {
    await _analyticsService.logViewItem(
      itemId: 'inbox_announcements',
      itemName: 'Student Announcements Inbox',
      category: 'inbox',
      spotsRemaining: 0,
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
