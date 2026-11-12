import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/screen_state.dart';
import '../models/ticket_model.dart';
import '../services/firestore_service.dart';

/// ViewModel quản lý màn hình "Vé của tôi" (My Tickets Screen).
///
/// Phân chia vé theo 2 tab: Vé đang có hiệu lực (Sắp diễn ra) và Lịch sử vé đã check-in (Đã tham gia),
/// đồng thời tự động cập nhật thời gian thực khi có hành động quét vé thành công tại cổng.
class MyTicketsViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService;
  StreamSubscription<List<TicketModel>>? _streamSubscription;
  String? _subscribedUserId;

  ScreenState<List<TicketModel>> _state = const StateInitial();

  /// Trạng thái hiển thị danh sách vé (Initial, Loading, Data, Empty, Error).
  ScreenState<List<TicketModel>> get state => _state;

  List<TicketModel> _allTickets = [];

  /// Toàn bộ danh sách vé của người dùng trước khi lọc theo tab.
  List<TicketModel> get allTickets => _allTickets;

  int _selectedTabIndex = 0; // 0: Upcoming/Active, 1: History/Checked-in

  /// Chỉ mục tab hiện tại (0: Sắp diễn ra, 1: Đã tham gia).
  int get selectedTabIndex => _selectedTabIndex;

  /// Khởi tạo [MyTicketsViewModel] và kết nối bộ lắng nghe thay đổi vé từ [FirestoreService].
  MyTicketsViewModel({required FirestoreService firestoreService})
      : _firestoreService = firestoreService {
    _firestoreService.ticketsNotifier.addListener(_onTicketsNotifierChanged);
  }

  bool _isRefreshing = false;

  /// Phản hồi khi có tín hiệu thay đổi danh sách vé từ tầng Service.
  void _onTicketsNotifierChanged() {
    if (_subscribedUserId != null && !_isRefreshing) {
      _refreshTicketsSilently(_subscribedUserId!);
    }
  }

  /// Chuyển đổi tab hiển thị theo chỉ mục [index] (0: Sắp diễn ra, 1: Đã tham gia).
  void selectTab(int index) {
    _selectedTabIndex = index;
    _filterTicketsByTab();
  }

  /// Tải toàn bộ vé của sinh viên có mã [userId] và kết nối luồng Stream thời gian thực.
  Future<void> loadUserTickets(String userId) async {
    _subscribedUserId = userId;
    _streamSubscription?.cancel();

    _state = const StateLoading('Đang tải danh sách vé điện tử...');
    notifyListeners();

    try {
      _allTickets = await _firestoreService.getUserTickets(userId);
      _filterTicketsByTab();
    } catch (e) {
      _state = StateError('Không thể tải danh sách vé: $e');
      notifyListeners();
    }

    // Connect to real-time Cloud Firestore ticket stream
    _streamSubscription = _firestoreService.streamUserTickets(userId).listen(
      (liveList) {
        _allTickets = liveList;
        _filterTicketsByTab();
      },
      onError: (err) {
        debugPrint('[MyTicketsViewModel] Stream notice: $err');
      },
    );
  }

  /// Làm mới ngầm danh sách vé của [userId] từ cơ sở dữ liệu mà không gây giật màn hình.
  Future<void> _refreshTicketsSilently(String userId) async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    try {
      _allTickets = await _firestoreService.getUserTickets(userId);
      _filterTicketsByTab();
    } catch (e) {
      debugPrint('[MyTicketsViewModel] Silent refresh notice: $e');
    } finally {
      _isRefreshing = false;
    }
  }

  /// Lọc vé theo tab đang chọn (Active hoặc Used/Expired).
  void _filterTicketsByTab() {
    if (_allTickets.isEmpty) {
      _state = const StateEmpty('Bạn chưa đăng ký sự kiện nào. Hãy khám phá và giữ chỗ ngay!');
    } else {
      final filtered = _selectedTabIndex == 0
          ? _allTickets.where((t) => t.status == TicketStatus.active).toList()
          : _allTickets.where((t) => t.status != TicketStatus.active).toList();

      if (filtered.isEmpty) {
        _state = StateEmpty(_selectedTabIndex == 0
            ? 'Không có vé nào đang chờ tham gia.'
            : 'Chưa có lịch sử sự kiện đã tham gia.');
      } else {
        _state = StateData(filtered);
      }
    }
    notifyListeners();
  }

  /// Kích hoạt tải lại danh sách vé theo yêu cầu (Pull-to-refresh).
  Future<void> refreshTickets(String userId) async {
    await loadUserTickets(userId);
  }

  /// Tìm kiếm vé của sự kiện có mã [eventId] trong danh sách vé đã tải của người dùng.
  TicketModel? getTicketForEvent(String eventId) {
    try {
      return _allTickets.firstWhere((t) => t.eventId == eventId);
    } catch (_) {
      return null;
    }
  }

  /// Giải phóng tài nguyên và hủy các bộ lắng nghe khi ViewModel bị hủy.
  @override
  void dispose() {
    _firestoreService.ticketsNotifier.removeListener(_onTicketsNotifierChanged);
    _streamSubscription?.cancel();
    super.dispose();
  }
}
