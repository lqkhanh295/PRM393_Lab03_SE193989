import 'dart:async';
import 'package:flutter/foundation.dart';

import '../models/screen_state.dart';
import '../models/certificate_model.dart';
import '../models/club_model.dart';
import '../models/gate_assignment_model.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../services/remote_config_service.dart';
import '../services/crashlytics_service.dart';
import '../services/fcm_service.dart';
import '../services/analytics_service.dart';
import '../services/pdf_export_service.dart';

/// Quản lý dữ liệu trang cá nhân sinh viên, chứng nhận hoạt động, câu lạc bộ theo dõi,
/// phân công ca trực cổng soát vé và toàn bộ kịch bản kiểm thử tích hợp Firebase Lab 3.
class ProfileViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService;
  final StorageService _storageService;

  /// Cung cấp instance của [StorageService] để xử lý tải tệp tin lên Firebase Storage.
  StorageService get storageService => _storageService;
  final RemoteConfigService _remoteConfigService;
  final CrashlyticsService _crashlyticsService;
  final FCMService _fcmService;
  final AnalyticsService _analyticsService;
  final PdfExportService _pdfExportService;

  ScreenState<List<CertificateModel>> _certificatesState = const StateInitial();

  /// Trạng thái tải danh sách chứng nhận e-Certificate của sinh viên.
  ScreenState<List<CertificateModel>> get certificatesState =>
      _certificatesState;

  List<ClubModel> _followedClubs = [];

  /// Danh sách các câu lạc bộ mà sinh viên đang theo dõi.
  List<ClubModel> get followedClubs => _followedClubs;

  // Gate Check-in Duty Assignments (Phân công ca trực cổng)
  List<GateAssignmentModel> _gateAssignments = [];

  /// Danh sách phân công ca trực cổng soát vé được gán cho tài khoản cộng tác viên/cán bộ.
  List<GateAssignmentModel> get gateAssignments => _gateAssignments;
  bool _isLoadingAssignments = false;

  /// Cho biết trạng thái đang tải dữ liệu phân công ca trực cổng.
  bool get isLoadingAssignments => _isLoadingAssignments;

  /// Tải danh sách phân công ca trực cổng soát vé theo địa chỉ [email] của người dùng.
  Future<void> loadGateAssignments(String email) async {
    if (email.isEmpty) return;
    _isLoadingAssignments = true;
    notifyListeners();
    try {
      _gateAssignments = await _firestoreService.getGateAssignments(email: email);
    } catch (e) {
      debugPrint('[ProfileViewModel] loadGateAssignments error: $e');
    } finally {
      _isLoadingAssignments = false;
      notifyListeners();
    }
  }

  // Firebase Demo Area State
  double _uploadProgress = 0.0;

  /// Tiến độ tải lên Cloud Storage từ 0.0 đến 1.0.
  double get uploadProgress => _uploadProgress;

  String? _lastUploadedUrl;

  /// Đường dẫn URL tải về của tệp tin vừa tải lên Firebase Storage thành công gần nhất.
  String? get lastUploadedUrl => _lastUploadedUrl;

  bool _isUploading = false;

  /// Cờ báo hiệu quá trình xuất PDF hoặc tải lên Firebase Storage đang diễn ra.
  bool get isUploading => _isUploading;

  String? _statusMessage;

  /// Thông điệp trạng thái kết quả của hành động demo Firebase vừa thực hiện.
  String? get statusMessage => _statusMessage;

  StreamSubscription<List<CertificateModel>>? _certSubscription;
  String? _subscribedUserId;

  /// Khởi tạo [ProfileViewModel] và đăng ký lắng nghe bộ thông báo chứng nhận từ [FirestoreService].
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
       _pdfExportService = pdfExportService {
    _firestoreService.certificatesNotifier.addListener(_onCertificatesChanged);
  }

  /// Lắng nghe sự kiện phát hành chứng nhận mới từ [FirestoreService] và cập nhật ngầm.
  void _onCertificatesChanged() {
    if (_subscribedUserId != null) {
      _refreshCertificatesSilently(_subscribedUserId!);
    }
  }

  /// Tải danh sách và thiết lập stream lắng nghe e-Certificate của sinh viên [userId] từ Cloud Firestore.
  Future<void> loadProfileCertificates(String userId) async {
    _subscribedUserId = userId;
    _certSubscription?.cancel();

    _certificatesState = const StateLoading();
    notifyListeners();

    try {
      final certs = await _firestoreService.getUserCertificates(userId);
      _certificatesState = StateData(certs);
      notifyListeners();
    } catch (e) {
      _certificatesState = StateError('Lỗi tải chứng nhận: $e');
      notifyListeners();
    }

    _certSubscription = _firestoreService.streamUserCertificates(userId).listen(
      (liveList) {
        _certificatesState = StateData(liveList);
        notifyListeners();
      },
      onError: (err) {
        debugPrint('[ProfileViewModel] stream cert error: $err');
      },
    );
  }

  /// Tải ngầm danh sách chứng nhận của [userId] mà không hiển thị vòng xoay loading.
  Future<void> _refreshCertificatesSilently(String userId) async {
    try {
      final certs = await _firestoreService.getUserCertificates(userId);
      _certificatesState = StateData(certs);
      notifyListeners();
    } catch (e) {
      debugPrint('[ProfileViewModel] silent cert error: $e');
    }
  }

  /// Hủy đăng ký stream và xóa bộ lắng nghe sự kiện khi ViewModel bị hủy.
  @override
  void dispose() {
    _certSubscription?.cancel();
    _firestoreService.certificatesNotifier.removeListener(_onCertificatesChanged);
    super.dispose();
  }

  /// Tải thông tin các câu lạc bộ mà người dùng đang theo dõi dựa vào danh sách ID [followedIds].
  Future<void> loadFollowedClubs(List<String> followedIds) async {
    try {
      final allClubs = await _firestoreService.getClubs();
      _followedClubs = allClubs.where((c) => followedIds.contains(c.id)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('[ProfileViewModel] loadFollowedClubs error: $e');
    }
  }

  // ==========================================
  // FIREBASE DEMO AREA ACTIONS (LAB 3 SECTION 3)
  // ==========================================

  /// Mở hộp thoại xem trước và in PDF hoặc tải chứng nhận [certificate] trực tiếp trên thiết bị di động.
  Future<void> viewAndDownloadCertificatePdf(CertificateModel certificate) async {
    try {
      await _pdfExportService.openAndDownloadCertificatePdf(certificate);
    } catch (e) {
      debugPrint('[ProfileViewModel] viewAndDownloadCertificatePdf error: $e');
    }
  }

  /// Sinh tệp PDF chứng nhận [certificate], tải lên Firebase Storage và ghi nhận Analytics.
  Future<void> generateAndUploadPdfSummary(CertificateModel certificate) async {
    _isUploading = true;
    _uploadProgress = 0.0;
    _statusMessage = 'Đang khởi tạo tài liệu PDF...';
    notifyListeners();

    final stopwatch = Stopwatch()..start();

    try {
      final result = await _pdfExportService.exportAndUploadCertificate(
        certificate: certificate,
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
        exportType: 'certificate',
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

  /// Kích hoạt mô phỏng nhận thông báo đẩy FCM (foreground notification) từ hệ thống.
  void triggerDemoPushNotification() {
    _fcmService.simulateConsolePush(
      title: 'Thông báo mới từ Phòng CTSV',
      body: 'Điểm rèn luyện của sự kiện Tech Expo 2026 đã được cập nhật vào hồ sơ sinh viên!',
      route: '/profile',
    );
    _statusMessage = '🔔 Đã nhận thông báo đẩy FCM (foreground test)';
    notifyListeners();
  }

  /// Kích hoạt ghi nhận ngoại lệ phi nghiêm trọng (non-fatal error) có kiểm soát lên Firebase Crashlytics.
  Future<void> triggerHandledErrorDemo() async {
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
          'screen': 'profile_demo',
        },
      );
      _statusMessage = '⚠️ Đã ghi nhận lỗi non-fatal lên Firebase Crashlytics dashboard với custom key.';
      notifyListeners();
    }
  }

  /// Kích hoạt lỗi crash ứng dụng để kiểm tra crash report trên Firebase Crashlytics dashboard.
  void triggerTestCrash() {
    _crashlyticsService.triggerTestCrash();
  }

  /// Chuyển đổi qua lại giá trị cấu hình động `max_featured_events` (2 hoặc 5) từ Firebase Remote Config.
  Future<void> toggleRemoteConfigDemo() async {
    final currentMax = _remoteConfigService.maxFeaturedEvents;
    final nextMax = currentMax == 5 ? 2 : 5;
    _remoteConfigService.setSimulatedConfig(maxEvents: nextMax);
    _statusMessage =
        '⚙️ Remote Config cập nhật: max_featured_events = $nextMax (Không cần build lại)';
    notifyListeners();
  }

  // ==========================================
  // TASK 4 (ĐẠT): ANALYTICS DEBUGVIEW 7-EVENT TRIGGERS
  // Phụ lục A — Kích hoạt từng event một cách tuần tự trên app
  // Strictly zero-PII: chỉ ghi anonymous entity IDs và counters.
  // ==========================================

  /// Kích hoạt sự kiện Analytics `login` ghi nhận đăng nhập bằng Email FPT trên DebugView.
  Future<void> triggerAnalyticsLogin() async {
    await _analyticsService.logLogin(method: 'email_fpt', role: 'student');
    _statusMessage = '✅ [1/7] login — method="email_fpt", role="student" → DebugView';
    notifyListeners();
  }

  /// Kích hoạt sự kiện Analytics `search` tìm kiếm sự kiện theo từ khóa "AI" trên DebugView.
  Future<void> triggerAnalyticsSearch() async {
    await _analyticsService.logSearch(
      searchTerm: 'AI',
      resultCount: 3,
      category: 'Technology',
    );
    _statusMessage = '✅ [2/7] search — search_term="AI", result_count=3 → DebugView';
    notifyListeners();
  }

  /// Kích hoạt sự kiện Analytics `view_item` xem chi tiết sự kiện demo trên DebugView.
  Future<void> triggerAnalyticsViewItem() async {
    await _analyticsService.logViewItem(
      itemId: 'evt_tech_expo_2026',
      itemName: 'Tech Expo 2026',
      category: 'Technology',
      spotsRemaining: 42,
    );
    _statusMessage = '✅ [3/7] view_item — item_id="evt_tech_expo_2026" → DebugView';
    notifyListeners();
  }

  /// Kích hoạt sự kiện Analytics `register_event` đăng ký sự kiện thành công trên DebugView.
  Future<void> triggerAnalyticsRegisterEvent() async {
    await _analyticsService.logRegisterEvent(
      eventId: 'evt_tech_expo_2026',
      clubId: 'fcode',
      durationSeconds: 4,
      calendarSynced: true,
    );
    _statusMessage = '✅ [4/7] register_event — event_id="evt_tech_expo_2026", duration=4s → DebugView';
    notifyListeners();
  }

  /// Kích hoạt sự kiện Analytics `live_interact` tương tác đặt câu hỏi hoặc upvote trong Live Q&A trên DebugView.
  Future<void> triggerAnalyticsLiveInteract() async {
    await _analyticsService.logLiveInteract(
      eventId: 'evt_tech_expo_2026',
      actionType: 'upvote',
      length: 0,
    );
    _statusMessage = '✅ [5/7] live_interact — action_type="upvote" → DebugView';
    notifyListeners();
  }

  /// Kích hoạt sự kiện Analytics `submit_feedback` gửi đánh giá phản hồi sự kiện trên DebugView.
  Future<void> triggerAnalyticsSubmitFeedback() async {
    await _analyticsService.logSubmitFeedback(
      eventId: 'evt_tech_expo_2026',
      rating: 5,
      hasComment: true,
    );
    _statusMessage = '✅ [6/7] submit_feedback — rating_stars=5, has_comment=1 → DebugView';
    notifyListeners();
  }

  /// Kích hoạt sự kiện Analytics `export_report` xuất chứng nhận PDF lên Cloud Storage trên DebugView.
  Future<void> triggerAnalyticsExportReport() async {
    await _analyticsService.logExportReport(
      exportType: 'certificate',
      fileSizeBytes: 128000,
      durationMs: 850,
    );
    _statusMessage = '✅ [7/7] export_report — export_type="certificate", size=125KB → DebugView';
    notifyListeners();
  }
}
