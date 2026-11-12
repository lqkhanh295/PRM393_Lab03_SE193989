import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/screen_state.dart';
import '../models/announcement_model.dart';
import '../services/firestore_service.dart';
import '../services/analytics_service.dart';

/// Quản lý trạng thái và luồng thông báo thời gian thực (Inbox / Announcements) cho sinh viên.
///
/// Lắng nghe trực tiếp collection `announcements` trên Cloud Firestore qua [FirestoreService],
/// hỗ trợ lọc theo danh mục, tính toán số lượng tin chưa đọc và ghi log analytics khi mở hộp thư.
class InboxViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService;
  final AnalyticsService _analyticsService;

  StreamSubscription<List<AnnouncementModel>>? _subscription;
  ScreenState<List<AnnouncementModel>> _state = const StateInitial();

  /// Trạng thái giao diện hiện tại của danh sách thông báo ([StateInitial], [StateLoading], [StateData], [StateEmpty], [StateError]).
  ScreenState<List<AnnouncementModel>> get state => _state;

  List<AnnouncementModel> _allAnnouncements = [];
  String _selectedCategory = 'All';

  /// Danh mục thông báo hiện đang được chọn để lọc (mặc định là 'All' / 'Tất cả').
  String get selectedCategory => _selectedCategory;
  String? _currentUserId;

  /// Danh sách thông báo đã được lọc theo danh mục được chọn [selectedCategory].
  List<AnnouncementModel> get filteredAnnouncements {
    if (_selectedCategory == 'All' || _selectedCategory == 'Tất cả') {
      return _allAnnouncements;
    }
    return _allAnnouncements.where((a) => a.category == _selectedCategory).toList();
  }

  /// Tổng số thông báo hiện có trong danh sách.
  int get unreadCount => _allAnnouncements.length;

  /// Khởi tạo [InboxViewModel] với [FirestoreService] và [AnalyticsService], bắt đầu lắng nghe thông báo.
  InboxViewModel({
    required FirestoreService firestoreService,
    required AnalyticsService analyticsService,
  })  : _firestoreService = firestoreService,
        _analyticsService = analyticsService {
    listenToAnnouncements();
  }

  /// Cập nhật mã người dùng hiện tại [userId] và thiết lập lại luồng lắng nghe thông báo mục tiêu.
  void updateCurrentUser(String? userId) {
    if (_currentUserId != userId) {
      _currentUserId = userId;
      listenToAnnouncements(currentUserId: userId);
    }
  }

  /// Bắt đầu lắng nghe stream thông báo từ Cloud Firestore theo [currentUserId].
  void listenToAnnouncements({String? currentUserId}) {
    if (currentUserId != null) _currentUserId = currentUserId;
    _state = const StateLoading('Đang tải hộp thư thông báo...');
    notifyListeners();

    _subscription?.cancel();
    _subscription = _firestoreService.streamAnnouncements(currentUserId: _currentUserId).listen(
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

  /// Thay đổi danh mục lọc [category] và thông báo tới các widget đăng ký.
  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  /// Ghi nhận sự kiện Analytics khi sinh viên mở màn hình hộp thư thông báo.
  Future<void> logOpenInbox() async {
    await _analyticsService.logViewItem(
      itemId: 'inbox_announcements',
      itemName: 'Student Announcements Inbox',
      category: 'inbox',
      spotsRemaining: 0,
    );
  }

  /// Hủy đăng ký stream Firestore và giải phóng tài nguyên.
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
