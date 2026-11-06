import 'package:flutter/foundation.dart';

import '../models/screen_state.dart';
import '../models/certificate_model.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../services/remote_config_service.dart';
import '../services/crashlytics_service.dart';
import '../services/fcm_service.dart';
import '../services/analytics_service.dart';
import '../services/pdf_export_service.dart';

/// MVVM ProfileViewModel
/// Manages student profile data and hosts the mandatory Lab 3 Firebase Demo Area.
class ProfileViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService;
  final StorageService _storageService;
  StorageService get storageService => _storageService;
  final RemoteConfigService _remoteConfigService;
  final CrashlyticsService _crashlyticsService;
  final FCMService _fcmService;
  final AnalyticsService _analyticsService;
  final PdfExportService _pdfExportService;

  ScreenState<List<CertificateModel>> _certificatesState = const StateInitial();
  ScreenState<List<CertificateModel>> get certificatesState =>
      _certificatesState;

  // Firebase Demo Area State
  double _uploadProgress = 0.0;
  double get uploadProgress => _uploadProgress;

  String? _lastUploadedUrl;
  String? get lastUploadedUrl => _lastUploadedUrl;

  bool _isUploading = false;
  bool get isUploading => _isUploading;

  String? _statusMessage;
  String? get statusMessage => _statusMessage;

  ProfileViewModel({
    required FirestoreService firestoreService,
    required StorageService storageService,
    required RemoteConfigService remoteConfigService,
    required CrashlyticsService crashlyticsService,
    required FCMService fcmService,
    required AnalyticsService analyticsService,
    required PdfExportService pdfExportService,
  }) : _firestoreService = firestoreService,
       _storageService = storageService,
       _remoteConfigService = remoteConfigService,
       _crashlyticsService = crashlyticsService,
       _fcmService = fcmService,
       _analyticsService = analyticsService,
       _pdfExportService = pdfExportService;

  Future<void> loadProfileCertificates(String userId) async {
    _certificatesState = const StateLoading();
    notifyListeners();

    try {
      final certs = await _firestoreService.getUserCertificates(userId);
      _certificatesState = certs.isEmpty
          ? const StateEmpty('Bạn chưa có chứng nhận nào.')
          : StateData(certs);
      notifyListeners();
    } catch (e) {
      _certificatesState = StateError('Lỗi tải chứng nhận: $e');
      notifyListeners();
    }
  }

  // ==========================================
  // FIREBASE DEMO AREA ACTIONS (LAB 3 SECTION 3)
  // ==========================================

  /// Action 1: Generate PDF and Upload to Firebase Storage
  Future<void> generateAndUploadPdfSummary(UserModel user) async {
    _isUploading = true;
    _uploadProgress = 0.0;
    _statusMessage = 'Đang khởi tạo tài liệu PDF...';
    notifyListeners();

    final stopwatch = Stopwatch()..start();

    try {
      final certificates = await _firestoreService.getUserCertificates(user.id);
      if (certificates.isEmpty) {
        _certificatesState = const StateEmpty('Bạn chưa có chứng nhận nào.');
        _statusMessage = 'Chưa có chứng nhận thực tế để xuất PDF.';
        _isUploading = false;
        notifyListeners();
        return;
      }
      final cert = certificates.first;

      final result = await _pdfExportService.exportAndUploadCertificate(
        certificate: cert,
        onProgress: (progress) {
          _uploadProgress = progress;
          _statusMessage =
              'Đang tải lên Cloud Storage (${(progress * 100).toInt()}%)...';
          notifyListeners();
        },
      );

      stopwatch.stop();

      _lastUploadedUrl = result.downloadUrl;
      _statusMessage = '✅ Upload thành công: ${result.path}';
      _isUploading = false;

      await _analyticsService.logExportReport(
        exportType: 'certificate_pdf',
        fileSizeBytes: result.fileSizeBytes,
        durationMs: stopwatch.elapsedMilliseconds,
      );

      notifyListeners();
    } catch (e, stack) {
      _isUploading = false;
      _statusMessage = '❌ Lỗi upload: $e';
      await _crashlyticsService.recordHandledError(
        e,
        stack,
        reason: 'PDF upload failure',
      );
      notifyListeners();
    }
  }

  /// Show the count of messages received from Firebase Messaging.
  void showMessagingStatus() {
    _statusMessage =
        'FCM: ${_fcmService.notifications.length} thông báo thực tế đã nhận. Gửi tin kiểm thử từ Firebase Console đến thiết bị.';
    notifyListeners();
  }

  /// Action 3: Trigger Crashlytics Non-Fatal Handled Error
  Future<void> triggerHandledErrorDemo(String userId) async {
    try {
      throw FormatException(
        'Simulated Non-Fatal Exception: Ticket ID checksum invalid at Gate 1',
      );
    } catch (e, stack) {
      await _crashlyticsService.recordHandledError(
        e,
        stack,
        reason: 'Handled error test action from Profile Demo Area',
        customKeys: {
          'test_action': 'trigger_handled_error',
          'user_id': userId,
          'screen': 'profile_demo',
        },
      );
      _statusMessage = '⚠️ Đã ghi nhận lỗi non-fatal lên Firebase Crashlytics dashboard với custom key.';
      notifyListeners();
    }
  }

  /// Action 4: Trigger Crashlytics Verification Test Crash
  void triggerTestCrash() {
    _crashlyticsService.triggerTestCrash();
  }

  /// Fetch published Remote Config values from Firebase.
  Future<void> refreshRemoteConfig() async {
    await _remoteConfigService.fetchAndActivate();
    _statusMessage =
        'Remote Config hiện tại: max_featured_events = ${_remoteConfigService.maxFeaturedEvents}';
    notifyListeners();
  }
}
