import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/screen_state.dart';
import '../models/ticket_model.dart';
import '../services/firestore_service.dart';

/// MVVM MyTicketsViewModel
class MyTicketsViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService;
  StreamSubscription<List<TicketModel>>? _streamSubscription;
  String? _subscribedUserId;

  ScreenState<List<TicketModel>> _state = const StateInitial();
  ScreenState<List<TicketModel>> get state => _state;

  List<TicketModel> _allTickets = [];
  List<TicketModel> get allTickets => _allTickets;
  int _selectedTabIndex = 0; // 0: Upcoming/Active, 1: History/Checked-in
  int get selectedTabIndex => _selectedTabIndex;

  MyTicketsViewModel({required FirestoreService firestoreService})
      : _firestoreService = firestoreService {
    _firestoreService.ticketsNotifier.addListener(_onTicketsNotifierChanged);
  }

  bool _isRefreshing = false;

  void _onTicketsNotifierChanged() {
    if (_subscribedUserId != null && !_isRefreshing) {
      _refreshTicketsSilently(_subscribedUserId!);
    }
  }

  void selectTab(int index) {
    _selectedTabIndex = index;
    _filterTicketsByTab();
  }

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

  bool hasTicketForEvent(String eventId) => getTicketForEvent(eventId) != null;

  TicketModel? getTicketForEvent(String eventId) {
    try {
      return _allTickets.firstWhere((t) => t.eventId == eventId);
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _firestoreService.ticketsNotifier.removeListener(_onTicketsNotifierChanged);
    super.dispose();
  }
}
