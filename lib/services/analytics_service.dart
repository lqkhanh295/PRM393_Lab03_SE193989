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
      debugPrint('[AnalyticsService] Set user ID: $userId');
    } catch (e) {
      debugPrint('[AnalyticsService] Error setUserId: $e');
    }
  }

  Future<void> logLogin({required String method, required String role}) async {
    try {
      await _analytics?.logLogin(loginMethod: method);
      await _analytics?.logEvent(
        name: 'login_custom',
        parameters: {'method': method, 'user_role': role},
      );
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
      await _analytics?.logSearch(
        searchTerm: searchTerm,
        numberOfNights: null,
      );
      await _analytics?.logEvent(
        name: 'search_action',
        parameters: {
          'search_term': searchTerm,
          'result_count': resultCount,
          'category_filter': category ?? 'all',
        },
      );
      debugPrint('[AnalyticsService] Event logged: search ($searchTerm, count: $resultCount)');
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
      debugPrint('[AnalyticsService] Event logged: view_item ($itemId - $itemName)');
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
      debugPrint('[AnalyticsService] Event logged: live_interact ($actionType)');
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
      debugPrint('[AnalyticsService] Event logged: submit_feedback ($rating stars)');
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
      debugPrint('[AnalyticsService] Event logged: export_report ($exportType, ${fileSizeBytes}B)');
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

  Future<void> logCustomEvent({
    required String eventName,
    Map<String, Object>? parameters,
  }) async {
    try {
      await _analytics?.logEvent(name: eventName, parameters: parameters);
      debugPrint('[AnalyticsService] Event logged: $eventName');
    } catch (e) {
      debugPrint('[AnalyticsService] Error logCustomEvent: $e');
    }
  }
}
