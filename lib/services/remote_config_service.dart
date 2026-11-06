import 'package:flutter/foundation.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

/// Firebase Remote Config Service Wrapper
/// Supplies in-app defaults and fetches dynamic overrides without app rebuilds.
class RemoteConfigService {
  final FirebaseRemoteConfig? _remoteConfig;

  int _maxFeaturedEvents = 5;
  bool _enableLiveQA = true;
  String _featuredBannerTitle =
      'Chào mừng sinh viên FPTU đến với Campus Event 2026';

  RemoteConfigService([this._remoteConfig]);

  int get maxFeaturedEvents => _maxFeaturedEvents;
  bool get enableLiveQA => _enableLiveQA;
  String get featuredBannerTitle => _featuredBannerTitle;

  Future<void> initialize() async {
    try {
      if (_remoteConfig != null) {
        await _remoteConfig.setConfigSettings(
          RemoteConfigSettings(
            fetchTimeout: const Duration(seconds: 10),
            minimumFetchInterval: Duration.zero,
          ),
        );
        await _remoteConfig.setDefaults(<String, dynamic>{
          'max_featured_events': 5,
          'enable_live_qa': true,
          'featured_banner_title':
              'Chào mừng sinh viên FPTU đến với Campus Event 2026',
        });
        await fetchAndActivate();
      }
    } catch (e) {
      debugPrint(
        '[RemoteConfigService] Init error, using default fallbacks: $e',
      );
    }
  }

  Future<bool> fetchAndActivate() async {
    try {
      if (_remoteConfig != null) {
        final updated = await _remoteConfig.fetchAndActivate();
        final maxEvents = _remoteConfig.getInt('max_featured_events');
        _maxFeaturedEvents = maxEvents < 0 ? 0 : maxEvents;
        _enableLiveQA = _remoteConfig.getBool('enable_live_qa');
        _featuredBannerTitle = _remoteConfig.getString('featured_banner_title');
        debugPrint(
          '[RemoteConfigService] Values activated: maxEvents=$_maxFeaturedEvents, liveQA=$_enableLiveQA',
        );
        return updated;
      }
    } catch (e) {
      debugPrint('[RemoteConfigService] Fetch error: $e');
    }
    return false;
  }
}
