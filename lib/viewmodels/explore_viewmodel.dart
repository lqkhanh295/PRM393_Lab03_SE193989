import 'package:flutter/foundation.dart';
import '../models/screen_state.dart';
import '../models/event_model.dart';
import '../models/club_model.dart';
import '../services/firestore_service.dart';
import '../services/analytics_service.dart';

/// MVVM ExploreViewModel
/// Manages category filtering, keyword searching, and club directory browsing.
class ExploreViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService;
  final AnalyticsService _analyticsService;

  ScreenState<List<EventModel>> _state = const StateInitial();
  ScreenState<List<EventModel>> get state => _state;

  List<ClubModel> _clubs = [];
  List<ClubModel> get clubs => _clubs;

  String _selectedCategory = 'Tất cả';
  String get selectedCategory => _selectedCategory;

  String _currentQuery = '';
  String get currentQuery => _currentQuery;

  final List<String> categories = ['Tất cả', 'Technology', 'Design', 'Sports', 'Media'];

  ExploreViewModel({
    required FirestoreService firestoreService,
    required AnalyticsService analyticsService,
  })  : _firestoreService = firestoreService,
        _analyticsService = analyticsService;

  Future<void> loadExploreData() async {
    _state = const StateLoading('Đang tải danh mục sự kiện...');
    notifyListeners();

    try {
      _clubs = await _firestoreService.getClubs();
      await searchEvents(query: _currentQuery, category: _selectedCategory);
    } catch (e) {
      _state = StateError('Lỗi tải danh mục: $e');
      notifyListeners();
    }
  }

  void selectCategory(String category) {
    _selectedCategory = category;
    searchEvents(query: _currentQuery, category: _selectedCategory);
  }

  Future<void> searchEvents({String query = '', String? category}) async {
    _currentQuery = query;
    _state = const StateLoading('Đang tìm kiếm sự kiện...');
    notifyListeners();

    try {
      final effectiveCategory = (category ?? _selectedCategory) == 'Tất cả' ? null : (category ?? _selectedCategory);
      final rawEvents = await _firestoreService.getEvents(category: effectiveCategory);

      var filtered = rawEvents;
      if (query.trim().isNotEmpty) {
        final q = query.toLowerCase().trim();
        filtered = filtered.where((e) {
          return e.title.toLowerCase().contains(q) ||
              e.description.toLowerCase().contains(q) ||
              e.clubName.toLowerCase().contains(q) ||
              e.location.toLowerCase().contains(q);
        }).toList();
      }

      await _analyticsService.logSearch(
        searchTerm: query.isEmpty ? 'category_${category ?? _selectedCategory}' : query,
        resultCount: filtered.length,
        category: category ?? _selectedCategory,
      );

      if (filtered.isEmpty) {
        _state = const StateEmpty('Không tìm thấy sự kiện nào phù hợp với từ khóa của bạn.');
      } else {
        _state = StateData(filtered);
      }
      notifyListeners();
    } catch (e) {
      _state = StateError('Lỗi trong quá trình tìm kiếm: $e');
      notifyListeners();
    }
  }
}
