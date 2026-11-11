import 'package:flutter/foundation.dart';
import '../models/screen_state.dart';
import '../models/certificate_model.dart';
import '../models/user_model.dart';
import '../services/analytics_service.dart';
import '../services/pdf_export_service.dart';
import '../services/firestore_service.dart';

/// MVVM FeedbackViewModel
/// Handles post-event 5-star ratings, review submissions, and automatic digital certification issuance.
class FeedbackViewModel extends ChangeNotifier {
  final AnalyticsService _analyticsService;
  final PdfExportService _pdfExportService;
  final FirestoreService? _firestoreService;

  ScreenState<CertificateModel> _state = const StateInitial();
  ScreenState<CertificateModel> get state => _state;

  int _rating = 5;
  int get rating => _rating;

  FeedbackViewModel({
    required AnalyticsService analyticsService,
    required PdfExportService pdfExportService,
    FirestoreService? firestoreService,
  })  : _analyticsService = analyticsService,
        _pdfExportService = pdfExportService,
        _firestoreService = firestoreService;

  void setRating(int value) {
    _rating = value;
    notifyListeners();
  }

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
      final cert = CertificateModel(
        id: certId,
        eventId: eventId,
        eventTitle: eventTitle,
        userId: user.id,
        studentName: user.name,
        issueDate: '28/10/2026',
        verificationHash: 'HASH-FPTU-CERT-${DateTime.now().millisecondsSinceEpoch}',
        downloadUrl: '',
      );

      final firestoreService = _firestoreService;
      if (firestoreService != null) {
        await firestoreService.submitEventFeedback(
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
      return true;
    } catch (e) {
      _state = StateError('Lỗi gửi đánh giá: $e');
      notifyListeners();
      return false;
    }
  }

  Future<void> exportCertificatePdf(CertificateModel cert) async {
    try {
      // 1. Open native PDF viewer & Save-as-PDF sheet directly on device
      await _pdfExportService.openAndDownloadCertificatePdf(cert);

      // 2. Background upload to Cloud Storage
      () async {
        try {
          await _pdfExportService.exportAndUploadCertificate(certificate: cert);
        } catch (e) {
          debugPrint('[FeedbackViewModel] Cloud Storage background upload note: $e');
        }
      }();
    } catch (e) {
      debugPrint('[FeedbackViewModel] Export error: $e');
    }
  }
}
