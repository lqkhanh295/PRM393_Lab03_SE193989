import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:http/http.dart' as http;

/// Dịch vụ quản lý cấu hình động từ xa qua Firebase Remote Config.
///
/// Cho phép cập nhật tham số giao diện và mô hình AI Gemini theo thời gian thực
/// mà không cần phải phát hành lại ứng dụng lên kho ứng dụng.
class RemoteConfigService {
  final FirebaseRemoteConfig? _remoteConfig;

  int _maxFeaturedEvents = 5;
  bool _enableLiveQA = true;
  String _featuredBannerTitle = 'Chào mừng đến với FPTU Tech Expo 2026';

  // Final Assignment: Gemini AI Feature Parameters
  bool _enableGeminiInsights = true;
  String _geminiModelName = 'gemini-3.5-flash-lite';
  String _geminiPromptTemplate =
      'Phân tích sự kiện sau và trả về JSON tóm tắt, điểm nổi bật, đối tượng phù hợp và câu hỏi gợi ý.';

  /// Khởi tạo [RemoteConfigService] với tùy chọn [FirebaseRemoteConfig].
  RemoteConfigService([this._remoteConfig]);

  /// Số lượng sự kiện nổi bật tối đa được phép hiển thị trên màn hình Trang chủ.
  int get maxFeaturedEvents => _maxFeaturedEvents;

  /// Cờ bật/tắt tính năng hỏi đáp trực tiếp (Live Q&A) trong màn hình sự kiện.
  bool get enableLiveQA => _enableLiveQA;

  /// Tiêu đề chữ hiển thị trên thanh biểu ngữ chính (Featured Banner) ở Trang chủ.
  String get featuredBannerTitle => _featuredBannerTitle;

  /// Cờ kiểm soát việc bật hoặc tắt trợ lý phân tích Gemini AI từ xa.
  bool get enableGeminiInsights => _enableGeminiInsights;

  /// Tên phiên bản mô hình Gemini đang được kích hoạt (mặc định: `gemini-3.5-flash-lite`).
  String get geminiModelName => _geminiModelName;

  /// Khuôn mẫu câu lệnh chỉ đạo (Prompt Template) truyền cho Gemini AI.
  String get geminiPromptTemplate => _geminiPromptTemplate;

  /// Thiết lập các giá trị mặc định nội bộ và khởi chạy quá trình kéo cấu hình mới nhất.
  Future<void> initialize() async {
    try {
      if (_remoteConfig != null) {
        await _remoteConfig.setConfigSettings(
          RemoteConfigSettings(
            fetchTimeout: const Duration(seconds: 10),
            minimumFetchInterval: const Duration(minutes: 5),
          ),
        );
        await _remoteConfig.setDefaults(<String, dynamic>{
          'max_featured_events': 5,
          'enable_live_qa': true,
          'featured_banner_title': 'Chào mừng đến với FPTU Tech Expo 2026',
          'enable_gemini_insights': true,
          'gemini_model_name': 'gemini-3.5-flash-lite',
          'gemini_prompt_template':
              'Phân tích sự kiện sau và trả về JSON tóm tắt, điểm nổi bật, đối tượng phù hợp và câu hỏi gợi ý.',
        });
        await fetchAndActivate();
      }
    } catch (e) {
      debugPrint('[RemoteConfigService] Init error, using default fallbacks: $e');
    }
    await fetchAndActivate();
  }

  /// Kéo dữ liệu cấu hình mới nhất từ Firebase Console và kích hoạt áp dụng ngay vào ứng dụng.
  Future<bool> fetchAndActivate() async {
    try {
      if (_remoteConfig != null) {
        final updated = await _remoteConfig.fetchAndActivate();
        _maxFeaturedEvents = _remoteConfig.getInt('max_featured_events');
        _enableLiveQA = _remoteConfig.getBool('enable_live_qa');
        _featuredBannerTitle = _remoteConfig.getString('featured_banner_title');
        _enableGeminiInsights = _remoteConfig.getBool('enable_gemini_insights');
        final model = _remoteConfig.getString('gemini_model_name');
        if (model.isNotEmpty) _geminiModelName = model;
        final prompt = _remoteConfig.getString('gemini_prompt_template');
        if (prompt.isNotEmpty) _geminiPromptTemplate = prompt;

        debugPrint('[RemoteConfigService] Values activated: maxEvents=$_maxFeaturedEvents, geminiAI=$_enableGeminiInsights, model=$_geminiModelName');
        return updated;
      }
    } catch (e) {
      debugPrint('[RemoteConfigService] Fetch error: $e');
    }

    // Try REST fallback from Web Portal
    for (final base in ['http://localhost:3000', 'http://10.0.2.2:3000']) {
      try {
        final res = await http.get(Uri.parse('$base/api/remote-config')).timeout(const Duration(milliseconds: 1500));
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          if (data is Map) {
            if (data['max_featured_events'] != null) {
              _maxFeaturedEvents = int.tryParse(data['max_featured_events'].toString()) ?? _maxFeaturedEvents;
            }
            if (data['enable_live_qa'] != null) {
              _enableLiveQA = data['enable_live_qa'].toString().toLowerCase() == 'true' || data['enable_live_qa'] == true;
            }
            if (data['featured_banner_title'] != null) {
              _featuredBannerTitle = data['featured_banner_title'].toString();
            }
            if (data['enable_gemini_insights'] != null) {
              _enableGeminiInsights = data['enable_gemini_insights'].toString().toLowerCase() == 'true' || data['enable_gemini_insights'] == true;
            }
            debugPrint('[RemoteConfigService] Values activated via Web Portal: enableLiveQA=$_enableLiveQA');
            return true;
          }
        }
        break;
      } catch (_) {}
    }

    return false;
  }

  /// Gán giá trị cấu hình mô phỏng nhanh phục vụ cho việc trình chiếu demo và kiểm thử runtime.
  void setSimulatedConfig({
    int? maxEvents,
    bool? liveQA,
    String? banner,
    bool? geminiInsights,
    String? geminiModel,
  }) {
    if (maxEvents != null) _maxFeaturedEvents = maxEvents;
    if (liveQA != null) _enableLiveQA = liveQA;
    if (banner != null) _featuredBannerTitle = banner;
    if (geminiInsights != null) _enableGeminiInsights = geminiInsights;
    if (geminiModel != null) _geminiModelName = geminiModel;
  }
}
