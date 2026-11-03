import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AppNotificationItem {
  final String id;
  final String title;
  final String body;
  final String? route;
  final DateTime timestamp;

  const AppNotificationItem({
    required this.id,
    required this.title,
    required this.body,
    this.route,
    required this.timestamp,
  });
}

/// Firebase Cloud Messaging (FCM) Service Wrapper
class FCMService {
  final FirebaseMessaging? _messaging;
  final List<AppNotificationItem> _notifications = [];
  final _notificationsStreamController = StreamController<List<AppNotificationItem>>.broadcast();

  FCMService([this._messaging]) {
    // Seed initial notifications for realistic student onboarding experience
    _notifications.addAll([
      AppNotificationItem(
        id: 'notif-01',
        title: 'Nhắc giờ G: Tech Expo 2026',
        body: 'Sự kiện sẽ bắt đầu sau 1 tiếng tại Hội trường Trịnh Công Sơn. Đừng quên mở vé QR!',
        route: '/tickets/TICKET-2026-01',
        timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
      ),
      AppNotificationItem(
        id: 'notif-02',
        title: 'CLB F-Code vừa đăng sự kiện mới',
        body: 'Workshop "Ứng dụng AI thực chiến với Flutter" đã chính thức mở đăng ký.',
        route: '/events/EVT-2026-01',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    ]);
  }

  List<AppNotificationItem> get notifications => List.unmodifiable(_notifications);
  Stream<List<AppNotificationItem>> get notificationsStream => _notificationsStreamController.stream;

  Future<void> initialize() async {
    try {
      if (_messaging != null) {
        // Request notification permission (Android 13+ & iOS)
        final settings = await _messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
        debugPrint('[FCMService] Permission authorization status: ${settings.authorizationStatus}');

        // Foreground messaging listener
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          _handleIncomingRemoteMessage(message);
        });

        // Background / Terminated launch listener
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          debugPrint('[FCMService] App opened from background notification: ${message.messageId}');
        });

        final fcmToken = await _messaging.getToken();
        debugPrint('[FCMService] Device FCM Token: $fcmToken');
      }
    } catch (e) {
      debugPrint('[FCMService] FCM init warning: $e');
    }
  }

  void _handleIncomingRemoteMessage(RemoteMessage message) {
    final notif = AppNotificationItem(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: message.notification?.title ?? 'Thông báo sự kiện',
      body: message.notification?.body ?? '',
      route: message.data['route'] as String?,
      timestamp: DateTime.now(),
    );
    _notifications.insert(0, notif);
    _notificationsStreamController.add(List.unmodifiable(_notifications));
    debugPrint('[FCMService] Foreground message received: ${notif.title}');
  }

  /// Demo helper to simulate console push notification during live presentation
  void simulateConsolePush({required String title, required String body, String? route}) {
    final notif = AppNotificationItem(
      id: 'demo-fcm-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      body: body,
      route: route,
      timestamp: DateTime.now(),
    );
    _notifications.insert(0, notif);
    _notificationsStreamController.add(List.unmodifiable(_notifications));
    debugPrint('[FCMService] Simulated console push received: $title');
  }

  void dispose() {
    _notificationsStreamController.close();
  }
}
