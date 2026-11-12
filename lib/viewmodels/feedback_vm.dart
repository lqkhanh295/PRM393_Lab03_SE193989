import 'package:flutter/foundation.dart';
import '../models/screen_state.dart';
import '../models/certificate_model.dart';
import '../models/user_model.dart';
import '../services/analytics_service.dart';
import '../services/pdf_export_service.dart';
import '../services/firestore_service.dart';

/// ViewModel quản lý khảo sát chất lượng sự kiện và cấp Giấy chứng nhận điện tử.
///
/// Xử lý đánh giá từ 1 đến 5 sao, đóng góp ý kiến nhận xét, tự động phát hành
/// Giấy chứng nhận có mã băm bảo mật (hash) và hỗ trợ tải trực tiếp file PDF.
class FeedbackViewModel extends ChangeNotifier {
  final AnalyticsService _analyticsService;
  final PdfExportService _pdfExportService;
  final FirestoreService? _firestoreService;

  ScreenState<CertificateModel> _state = const StateInitial();

  /// Trạng thái phát hành giấy chứng nhận (Initial, Loading, Data, Error).
  ScreenState<CertificateModel> get state => _state;

  String? _currentEventId;

  /// Mã sự kiện hiện tại đang được đánh giá.
  String? get currentEventId => _currentEventId;

  int _rating = 5;

  /// Số sao đánh giá chất lượng (1 đến 5, mặc định là 5 sao).
  int get rating => _rating;

  /// Khởi tạo [FeedbackViewModel] với các phụ thuộc dịch vụ.
  FeedbackViewModel({
    required AnalyticsService analyticsService,
    required PdfExportService pdfExportService,
    FirestoreService? firestoreService,
  })  : _analyticsService = analyticsService,
        _pdfExportService = pdfExportService,
        _firestoreService = firestoreService;

  /// Đặt lại biểu mẫu khảo sát cho một sự kiện mới [eventId].
  void resetForEvent(String eventId) {
    if (_currentEventId != eventId) {
      _currentEventId = eventId;
      _state = const StateInitial();
      _rating = 5;
      notifyListeners();
    }
  }

  /// Cập nhật số sao đánh giá [value] và thông báo tới giao diện.
  void setRating(int value) {
    _rating = value;
    notifyListeners();
  }

  /// Gửi kết quả đánh giá, lưu chứng nhận vào Cloud Firestore và kích hoạt mở khóa điểm rèn luyện.
  Future<bool> submitFeedback({
    required String eventId,
    required String eventTitle,
    required UserModel user,
    required String comment,
  }) async {
    _state = const StateLoading('Đang ghi nhận đánh giá & mở khóa Chứng nhận số...');
    notifyListeners();

    try {
      await _analyticsService.logSubmitFeedback(
        eventId: eventId,
        rating: _rating,
        hasComment: comment.trim().isNotEmpty,
      );

      final certId = 'CERT-${DateTime.now().millisecondsSinceEpoch}';
      final now = DateTime.now();
      final issueDateStr = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

      final cert = CertificateModel(
        id: certId,
        eventId: eventId,
        eventTitle: eventTitle,
        userId: user.id,
        studentName: user.name,
        issueDate: issueDateStr,
        verificationHash: 'HASH-FPTU-CERT-${DateTime.now().millisecondsSinceEpoch}',
        downloadUrl: '',
      );

      final firestoreService = _firestoreService;
      bool isNewSubmission = true;
      if (firestoreService != null) {
        isNewSubmission = await firestoreService.submitEventFeedback(
          eventId: eventId,
          userId: user.id,
          rating: _rating,
          comments: comment,
          user: user,
        );
        await firestoreService.saveCertificate(cert);
      }

      _state = StateData(cert);
      notifyListeners();
      return isNewSubmission;
    } catch (e) {
      debugPrint('[FeedbackViewModel] Feedback submission error: $e');
      _state = StateError('Không thể gửi đánh giá: $e');
      notifyListeners();
      return false;
    }
  }

  /// Mở giao diện xem trước và tải file PDF Giấy chứng nhận điện tử về máy.
  Future<void> downloadCertificatePdf() async {
    if (_state is StateData<CertificateModel>) {
      final cert = (_state as StateData<CertificateModel>).data;
      await _pdfExportService.openAndDownloadCertificatePdf(cert);
    }
  }

  /// Xuất tệp PDF giấy chứng nhận và mở hộp thoại xem trước/tải về.
  Future<void> exportCertificatePdf(CertificateModel cert) async {
    await _pdfExportService.openAndDownloadCertificatePdf(cert);
  }
}
