import 'package:flutter/foundation.dart';
import '../models/screen_state.dart';
import '../models/event_model.dart';
import '../models/club_model.dart';
import '../services/firestore_service.dart';
import '../services/analytics_service.dart';

/// Tab hiển thị trên màn hình Khám phá (Sự kiện hoặc Câu lạc bộ).
enum ExploreTab { events, clubs }

/// ViewModel quản lý tìm kiếm, lọc danh mục và tra cứu 46 Câu lạc bộ FPTU.
///
/// Hỗ trợ tìm kiếm thông minh không phân biệt chữ hoa/thường và không dấu (Accent-Insensitive)
/// nhằm tối ưu hóa trải nghiệm tìm kiếm sự kiện của sinh viên Việt Nam.
class ExploreViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService;
  final AnalyticsService _analyticsService;

  ScreenState<List<EventModel>> _state = const StateInitial();

  /// Trạng thái dữ liệu danh sách sự kiện trên màn hình Khám phá.
  ScreenState<List<EventModel>> get state => _state;

  List<ClubModel> _clubs = [];

  /// Danh sách các câu lạc bộ chính thức FPTU được tải về từ hệ thống.
  List<ClubModel> get clubs => _clubs;

  ExploreTab _currentTab = ExploreTab.events;

  /// Tab hiện tại đang được chọn (Sự kiện hoặc Câu lạc bộ).
  ExploreTab get currentTab => _currentTab;

  String _selectedCategory = 'Tất cả';

  /// Danh mục sự kiện/CLB hiện đang được chọn để lọc.
  String get selectedCategory => _selectedCategory;

  String _currentQuery = '';

  /// Từ khóa tìm kiếm hiện tại do người dùng nhập vào ô tìm kiếm.
  String get currentQuery => _currentQuery;

  /// Danh sách các danh mục sự kiện và câu lạc bộ hỗ trợ lọc.
  final List<String> categories = [
    'Tất cả',
    'Technology',
    'Design',
    'Entertainment',
    'Business',
    'Languages',
    'Sports',
    'Media',
    'Arts',
    'Community',
  ];

  /// Khởi tạo [ExploreViewModel] với các phụ thuộc dịch vụ.
  ExploreViewModel({
    required FirestoreService firestoreService,
    required AnalyticsService analyticsService,
  })  : _firestoreService = firestoreService,
        _analyticsService = analyticsService;

  /// Chuyển đổi tab hiển thị giữa Sự kiện và Câu lạc bộ [tab].
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

  /// Cập nhật từ khóa tìm kiếm [query] và thực hiện lọc dữ liệu ngay lập tức.
  void setQuery(String query) {
    _currentQuery = query;
    if (_currentTab == ExploreTab.clubs) {
      notifyListeners();
    } else {
      searchEvents(query: query, category: _selectedCategory);
    }
  }

  /// Hàm tiện ích loại bỏ dấu thanh tiếng Việt phục vụ tìm kiếm không dấu.
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

  /// Danh sách các câu lạc bộ đã được lọc theo từ khóa và danh mục đã chọn.
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

  /// Nạp toàn bộ dữ liệu ban đầu cho màn hình Khám phá bao gồm CLB và sự kiện.
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

  /// Chọn một danh mục [category] mới và kích hoạt lọc lại danh sách.
  void selectCategory(String category) {
    _selectedCategory = category;
    searchEvents(query: _currentQuery, category: _selectedCategory);
  }

  /// Tìm kiếm sự kiện theo từ khóa [query] và danh mục [category], hỗ trợ tiếng Việt không dấu.
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
