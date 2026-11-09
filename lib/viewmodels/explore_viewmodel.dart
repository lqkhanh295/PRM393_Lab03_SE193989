import 'package:flutter/foundation.dart';
import '../models/screen_state.dart';
import '../models/event_model.dart';
import '../models/club_model.dart';
import '../services/firestore_service.dart';
import '../services/analytics_service.dart';

enum ExploreTab { events, clubs }

/// MVVM ExploreViewModel
/// Manages category filtering, keyword searching, and club directory browsing.
class ExploreViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService;
  final AnalyticsService _analyticsService;

  ScreenState<List<EventModel>> _state = const StateInitial();
  ScreenState<List<EventModel>> get state => _state;

  List<ClubModel> _clubs = [];
  List<ClubModel> get clubs => _clubs;

  ExploreTab _currentTab = ExploreTab.events;
  ExploreTab get currentTab => _currentTab;

  String _selectedCategory = 'Tất cả';
  String get selectedCategory => _selectedCategory;

  String _currentQuery = '';
  String get currentQuery => _currentQuery;

  final List<String> categories = [
    'Tất cả',
    'Technology',
    'Business',
    'Languages',
    'Sports',
    'Media',
    'Arts',
    'Community',
  ];

  ExploreViewModel({
    required FirestoreService firestoreService,
    required AnalyticsService analyticsService,
  })  : _firestoreService = firestoreService,
        _analyticsService = analyticsService;

  void setTab(ExploreTab tab) {
    if (_currentTab != tab) {
      _currentTab = tab;
      notifyListeners();
    }
  }

  /// Get clubs filtered by current query and selected category
  List<ClubModel> get filteredClubs {
    var result = _clubs;

    // Filter by Category
    if (_selectedCategory != 'Tất cả') {
      final cat = _selectedCategory.toLowerCase();
      result = result.where((c) {
        final cCat = c.category.toLowerCase();
        if (cat == 'languages' && (cCat == 'languages' || cCat == 'skills')) return true;
        if (cat == 'technology' && (cCat == 'technology' || cCat == 'academic' || cCat == 'design')) return true;
        if (cat == 'arts' && (cCat == 'arts' || cCat == 'culture' || cCat == 'lifestyle')) return true;
        return cCat == cat;
      }).toList();
    }

    // Filter by Query
    if (_currentQuery.trim().isNotEmpty) {
      final q = _currentQuery.toLowerCase().trim();
      result = result.where((c) {
        return c.name.toLowerCase().contains(q) ||
            (c.acronym?.toLowerCase().contains(q) ?? false) ||
            c.category.toLowerCase().contains(q) ||
            c.description.toLowerCase().contains(q) ||
            (c.email?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    return result;
  }

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
