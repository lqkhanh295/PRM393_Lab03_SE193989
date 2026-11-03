import 'package:flutter/foundation.dart';
import '../models/screen_state.dart';
import '../models/ticket_model.dart';
import '../services/firestore_service.dart';

/// MVVM MyTicketsViewModel
class MyTicketsViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService;

  ScreenState<List<TicketModel>> _state = const StateInitial();
  ScreenState<List<TicketModel>> get state => _state;

  List<TicketModel> _allTickets = [];
  int _selectedTabIndex = 0; // 0: Upcoming/Active, 1: History/Checked-in
  int get selectedTabIndex => _selectedTabIndex;

  MyTicketsViewModel({required FirestoreService firestoreService})
      : _firestoreService = firestoreService;

  void selectTab(int index) {
    _selectedTabIndex = index;
    _filterTicketsByTab();
  }

  Future<void> loadUserTickets(String userId) async {
    _state = const StateLoading('Đang tải danh sách vé điện tử...');
    notifyListeners();

    try {
      _allTickets = await _firestoreService.getUserTickets(userId);
      _filterTicketsByTab();
    } catch (e) {
      _state = StateError('Không thể tải danh sách vé: $e');
      notifyListeners();
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
}
