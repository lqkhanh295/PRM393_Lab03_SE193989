import 'package:flutter/foundation.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

/// Firebase Remote Config Service Wrapper
/// Supplies in-app defaults and fetches dynamic overrides without app rebuilds.
/// Supports both Lab 3 UI flags and Final Assignment Gemini AI parameters.
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

  RemoteConfigService([this._remoteConfig]);

  int get maxFeaturedEvents => _maxFeaturedEvents;
  bool get enableLiveQA => _enableLiveQA;
  String get featuredBannerTitle => _featuredBannerTitle;

  bool get enableGeminiInsights => _enableGeminiInsights;
  String get geminiModelName => _geminiModelName;
  String get geminiPromptTemplate => _geminiPromptTemplate;

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
  }

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
    return false;
  }

  /// Demo helper to simulate console toggle live in demo area / presentation
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
