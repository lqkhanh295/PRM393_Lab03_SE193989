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
      if (tab == ExploreTab.events && _state is StateInitial) {
        searchEvents(query: _currentQuery, category: _selectedCategory);
      } else {
        notifyListeners();
      }
    }
  }

  /// Sets search query and handles instant filtering for clubs or async search for events
  void setQuery(String query) {
    _currentQuery = query;
    if (_currentTab == ExploreTab.clubs) {
      notifyListeners();
    } else {
      searchEvents(query: query, category: _selectedCategory);
    }
  }

  /// Helper function to strip Vietnamese diacritics for accent-insensitive search
  static String stripDiacritics(String str) {
    const withDiacritics = 'àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ'
        'ÀÁẠẢÃÂẦẤẬẨẪĂẰẮẶẲẴÈÉẸẺẼÊỀẾỆỂỄÌÍỊỈĨÒÓỌỎÕÔỒỐỘỔỖƠỜỚỢỞỠÙÚỤỦŨƯỪỨỰỬỮỲÝỴỶỸĐ';
    const withoutDiacritics = 'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyyd'
        'AAAAAAAAAAAAAAAAAEEEEEEEEEEEIIIIIOOOOOOOOOOOOOOOOOUUUUUUUUUUUYYYYYD';
    var result = str;
    for (int i = 0; i < withDiacritics.length; i++) {
      result = result.replaceAll(withDiacritics[i], withoutDiacritics[i]);
    }
    return result;
  }

  /// Get clubs filtered by current query and selected category with Vietnamese accent support
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

    // Filter by Query (Accent-Insensitive & Case-Insensitive)
    if (_currentQuery.trim().isNotEmpty) {
      final q = _currentQuery.toLowerCase().trim();
      final qClean = stripDiacritics(q);

      result = result.where((c) {
        final name = c.name.toLowerCase();
        final nameClean = stripDiacritics(name);
        final acronym = c.acronym?.toLowerCase() ?? '';
        final cat = c.category.toLowerCase();
        final desc = c.description.toLowerCase();
        final descClean = stripDiacritics(desc);
        final email = c.email?.toLowerCase() ?? '';

        return name.contains(q) ||
            nameClean.contains(qClean) ||
            acronym.contains(q) ||
            cat.contains(q) ||
            desc.contains(q) ||
            descClean.contains(qClean) ||
            email.contains(q);
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
        final qClean = stripDiacritics(q);
        filtered = filtered.where((e) {
          final title = e.title.toLowerCase();
          final desc = e.description.toLowerCase();
          final club = e.clubName.toLowerCase();
          final loc = e.location.toLowerCase();

          return title.contains(q) ||
              stripDiacritics(title).contains(qClean) ||
              desc.contains(q) ||
              stripDiacritics(desc).contains(qClean) ||
              club.contains(q) ||
              stripDiacritics(club).contains(qClean) ||
              loc.contains(q) ||
              stripDiacritics(loc).contains(qClean);
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
