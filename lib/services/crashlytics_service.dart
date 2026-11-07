import 'package:flutter/foundation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// Firebase Crashlytics Service Wrapper
/// Handles fatal and non-fatal production reporting with user ID and custom keys.
class CrashlyticsService {
  final FirebaseCrashlytics? _crashlytics;

  CrashlyticsService([this._crashlytics]);

  Future<void> setUserId(String userId) async {
    try {
      await _crashlytics?.setUserIdentifier(userId);
      debugPrint('[CrashlyticsService] User identifier updated.');
    } catch (e) {
      debugPrint('[CrashlyticsService] Error setUserIdentifier: $e');
    }
  }

  Future<void> setCustomKey(String key, Object value) async {
    try {
      await _crashlytics?.setCustomKey(key, value);
      debugPrint('[CrashlyticsService] Custom key set: $key = $value');
    } catch (e) {
      debugPrint('[CrashlyticsService] Error setCustomKey: $e');
    }
  }

  /// Reports a handled non-fatal error with context keys
  Future<void> recordHandledError(
    dynamic exception,
    StackTrace? stack, {
    String? reason,
    Map<String, Object>? customKeys,
  }) async {
    try {
      if (customKeys != null) {
        for (final entry in customKeys.entries) {
          await _crashlytics?.setCustomKey(entry.key, entry.value);
        }
      }
      await _crashlytics?.recordError(
        exception,
        stack ?? StackTrace.current,
        reason: reason ?? 'Handled error from Campus Event app',
        fatal: false,
      );
      debugPrint(
        '[CrashlyticsService] Handled non-fatal error recorded: $exception ($reason)',
      );
    } catch (e) {
      debugPrint('[CrashlyticsService] Error recording non-fatal: $e');
    }
  }

  /// Triggers a test crash for verification demo.
  /// Stack trace message: "Simulated Crashlytics Test Crash: Verified in demo mode"
  /// After crash, restart the app so the SDK flushes the report to Firebase Console.
  void triggerTestCrash() {
    if (_crashlytics == null) {
      debugPrint(
        '[CrashlyticsService] Crash test unavailable: Firebase Crashlytics is not configured.',
      );
      return;
    }
    debugPrint('[CrashlyticsService] Triggering verification test crash: "Simulated Crashlytics Test Crash: Verified in demo mode"');
    _crashlytics.crash();
  }
}
