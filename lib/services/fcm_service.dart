import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// Đại diện cho một tin nhắn thông báo đẩy (Push Notification) hiển thị trong ứng dụng.
class AppNotificationItem {
  /// Mã định danh duy nhất của thông báo.
  final String id;

  /// Tiêu đề thông báo.
  final String title;

  /// Nội dung chi tiết của thông báo.
  final String body;

  /// Đường dẫn điều hướng màn hình nội bộ khi sinh viên nhấn vào thông báo (nếu có).
  final String? route;

  /// Thời điểm thông báo được nhận.
  final DateTime timestamp;

  /// Khởi tạo [AppNotificationItem] với các trường dữ liệu cần thiết.
  const AppNotificationItem({
    required this.id,
    required this.title,
    required this.body,
    this.route,
    required this.timestamp,
  });
}

/// Dịch vụ quản lý thông báo đẩy qua Firebase Cloud Messaging (FCM).
///
/// Quản lý yêu cầu quyền thông báo, thu nhận token thiết bị,
/// lắng nghe tin nhắn khi ứng dụng đang mở (foreground) hoặc dưới nền (background).
class FCMService {
  final FirebaseMessaging? _messaging;
  final List<AppNotificationItem> _notifications = [];
  final _notificationsStreamController =
      StreamController<List<AppNotificationItem>>.broadcast();

  /// Khởi tạo [FCMService] với tùy chọn [FirebaseMessaging] phục vụ kiểm thử.
  FCMService([this._messaging]);

  /// Danh sách bất biến chứa các thông báo đã nhận.
  List<AppNotificationItem> get notifications =>
      List.unmodifiable(_notifications);

  /// Luồng phát tín hiệu thời gian thực khi có thông báo mới đến.
  Stream<List<AppNotificationItem>> get notificationsStream =>
      _notificationsStreamController.stream;

  /// Khởi tạo dịch vụ FCM, yêu cầu quyền thông báo người dùng và đăng ký lắng nghe tin nhắn.
  Future<void> initialize() async {
    try {
      if (_messaging != null) {
        // Request notification permission (Android 13+ & iOS)
        final settings = await _messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
        debugPrint(
          '[FCMService] Permission authorization status: ${settings.authorizationStatus}',
        );

        // Foreground messaging listener
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          _handleIncomingRemoteMessage(message);
        });

        // Background / Terminated launch listener
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          debugPrint(
            '[FCMService] App opened from background notification: ${message.messageId}',
          );
        });

        // ignore: deprecated_member_use
        final fcmToken = await _messaging.getToken();
        debugPrint('[FCMService] Device FCM Token: $fcmToken');
      }
    } catch (e) {
      debugPrint('[FCMService] FCM init warning: $e');
    }
  }

  /// Xử lý tin nhắn từ xa [message] khi ứng dụng đang chạy ở tiền cảnh.
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

  /// Mô phỏng một thông báo đẩy đến từ Firebase Console phục vụ kiểm thử và thuyết trình demo.
  void simulateConsolePush({required String title, required String body, String? route}) {
    final notif = AppNotificationItem(
      id: 'fcm-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      body: body,
      route: route,
      timestamp: DateTime.now(),
    );
    _notifications.insert(0, notif);
    _notificationsStreamController.add(List.unmodifiable(_notifications));
    debugPrint('[FCMService] Simulated console push received: $title');
  }

  /// Đóng luồng phát tín hiệu thông báo khi dịch vụ bị hủy.
  void dispose() {
    _notificationsStreamController.close();
  }
}
