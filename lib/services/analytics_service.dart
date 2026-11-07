import 'package:flutter/foundation.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

/// Firebase Analytics Service Wrapper
/// Strictly enforces Section 6 zero-PII policy and logs all 7 required events.
class AnalyticsService {
  final FirebaseAnalytics? _analytics;

  AnalyticsService([this._analytics]);

  Future<void> setUserId(String? userId) async {
    try {
      await _analytics?.setUserId(id: userId);
      debugPrint('[AnalyticsService] User identifier updated.');
    } catch (e) {
      debugPrint('[AnalyticsService] Error setUserId: $e');
    }
  }

  Future<void> logLogin({required String method, required String role}) async {
    try {
      await _analytics?.logLogin(loginMethod: method);
      await _analytics?.setUserProperty(name: 'user_role', value: role);
      debugPrint('[AnalyticsService] Event logged: login ($method, $role)');
    } catch (e) {
      debugPrint('[AnalyticsService] Error logLogin: $e');
    }
  }

  Future<void> logSearch({
    required String searchTerm,
    required int resultCount,
    String? category,
  }) async {
    try {
      // Search text is user input. Do not send strings that resemble email
      // addresses or student identifiers to Firebase Analytics.
      final safeSearchTerm = _safeSearchTerm(searchTerm);
      await _analytics?.logSearch(
        searchTerm: safeSearchTerm,
        numberOfNights: null,
      );
      debugPrint(
        '[AnalyticsService] Event logged: search (count: $resultCount, category: ${category ?? 'all'})',
      );
    } catch (e) {
      debugPrint('[AnalyticsService] Error logSearch: $e');
    }
  }

  Future<void> logViewItem({
    required String itemId,
    required String itemName,
    required String category,
    required int spotsRemaining,
  }) async {
    try {
      await _analytics?.logViewItem(
        items: [
          AnalyticsEventItem(
            itemId: itemId,
            itemName: itemName,
            itemCategory: category,
          ),
        ],
      );
      debugPrint(
        '[AnalyticsService] Event logged: view_item ($itemId - $itemName)',
      );
    } catch (e) {
      debugPrint('[AnalyticsService] Error logViewItem: $e');
    }
  }

  Future<void> logRegisterEvent({
    required String eventId,
    required String clubId,
    required int durationSeconds,
    bool calendarSynced = true,
  }) async {
    try {
      await _analytics?.logEvent(
        name: 'register_event',
        parameters: {
          'event_id': eventId,
          'club_id': clubId,
          'registration_seconds': durationSeconds,
          'calendar_synced': calendarSynced ? 1 : 0,
        },
      );
      debugPrint('[AnalyticsService] Event logged: register_event ($eventId)');
    } catch (e) {
      debugPrint('[AnalyticsService] Error logRegisterEvent: $e');
    }
  }

  Future<void> logLiveInteract({
    required String eventId,
    required String actionType,
    required int length,
  }) async {
    try {
      await _analytics?.logEvent(
        name: 'live_interact',
        parameters: {
          'event_id': eventId,
          'action_type': actionType,
          'question_length': length,
        },
      );
      debugPrint(
        '[AnalyticsService] Event logged: live_interact ($actionType)',
      );
    } catch (e) {
      debugPrint('[AnalyticsService] Error logLiveInteract: $e');
    }
  }

  Future<void> logSubmitFeedback({
    required String eventId,
    required int rating,
    bool hasComment = false,
  }) async {
    try {
      await _analytics?.logEvent(
        name: 'submit_feedback',
        parameters: {
          'event_id': eventId,
          'rating_stars': rating,
          'has_text_comment': hasComment ? 1 : 0,
        },
      );
      debugPrint(
        '[AnalyticsService] Event logged: submit_feedback ($rating stars)',
      );
    } catch (e) {
      debugPrint('[AnalyticsService] Error logSubmitFeedback: $e');
    }
  }

  Future<void> logExportReport({
    required String exportType,
    required int fileSizeBytes,
    required int durationMs,
  }) async {
    try {
      await _analytics?.logEvent(
        name: 'export_report',
        parameters: {
          'export_type': exportType,
          'file_size_kb': (fileSizeBytes / 1024).round(),
          'upload_duration_ms': durationMs,
        },
      );
      debugPrint(
        '[AnalyticsService] Event logged: export_report ($exportType, ${fileSizeBytes}B)',
      );
    } catch (e) {
      debugPrint('[AnalyticsService] Error logExportReport: $e');
    }
  }

  Future<void> logLogout({required int sessionMinutes}) async {
    try {
      await _analytics?.logEvent(
        name: 'logout_action',
        parameters: {'session_duration_minutes': sessionMinutes},
      );
      debugPrint('[AnalyticsService] Event logged: logout');
    } catch (e) {
      debugPrint('[AnalyticsService] Error logLogout: $e');
    }
  }

  /// Logs an internal product event after validating its Firebase-compatible
  /// name and redacting any value that resembles PII.
  Future<void> logCustomEvent({
    required String eventName,
    Map<String, Object>? parameters,
  }) async {
    final isValidName = RegExp(r'^[a-z][a-z0-9_]{0,39}$').hasMatch(eventName);
    final isReservedPrefix =
        eventName.startsWith('firebase_') ||
        eventName.startsWith('google_') ||
        eventName.startsWith('ga_');
    if (!isValidName || isReservedPrefix) {
      debugPrint('[AnalyticsService] Ignored invalid analytics event name.');
      return;
    }

    try {
      final safeParameters = <String, Object>{
        for (final entry in (parameters ?? const <String, Object>{}).entries)
          entry.key: entry.value is String
              ? _safeSearchTerm(entry.value as String)
              : entry.value,
      };
      await _analytics?.logEvent(name: eventName, parameters: safeParameters);
      debugPrint('[AnalyticsService] Custom event logged: $eventName');
    } catch (e) {
      debugPrint('[AnalyticsService] Error logging custom event: $e');
    }
  }

  String _safeSearchTerm(String value) {
    final normalized = value.trim();
    final looksLikeEmail = normalized.contains('@');
    final hasLongNumber = RegExp(r'\d{7,}').hasMatch(normalized);
    if (normalized.isEmpty ||
        normalized.length > 50 ||
        looksLikeEmail ||
        hasLongNumber) {
      return 'redacted';
    }
    return normalized;
  }
}
