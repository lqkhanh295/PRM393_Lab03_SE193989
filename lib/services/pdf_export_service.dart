import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/ticket_model.dart';
import '../models/certificate_model.dart';
import '../viewmodels/explore_viewmodel.dart';
import 'storage_service.dart';

/// PDF Generation & Cloud Export Service
/// Generates verifiable student PDF documents and uploads them to Cloud Storage.
class PdfExportService {
  final StorageService _storageService;

  PdfExportService(this._storageService);

  /// Generates a formal e-Certificate PDF document
  Future<Uint8List> generateCertificatePdf(CertificateModel cert) async {
    final pdf = pw.Document();

    pw.Font? roboto;
    pw.Font? robotoBold;
    try {
      roboto = await PdfGoogleFonts.robotoRegular();
      robotoBold = await PdfGoogleFonts.robotoBold();
    } catch (_) {
      // Offline fallback: will continue with standard fonts
    }

    final hasFont = roboto != null &&
        !roboto.fontName.toLowerCase().contains('helvetica') &&
        robotoBold != null &&
        !robotoBold.fontName.toLowerCase().contains('helvetica');
    String t(String str) => hasFont ? str : ExploreViewModel.stripDiacritics(str);

    final theme = hasFont
        ? pw.ThemeData.withFont(base: roboto, bold: robotoBold)
        : null;

    pdf.addPage(
      pw.Page(
        theme: theme,
        pageFormat: PdfPageFormat.a4.landscape,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(24),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.deepPurple900, width: 4),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  children: [
                    pw.Text(
                      t('ĐẠI HỌC FPT TP. HỒ CHÍ MINH'),
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.deepPurple900,
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      t('GIẤY CHỨNG NHẬN THAM GIA SỰ KIỆN'),
                      style: pw.TextStyle(
                        fontSize: 26,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.deepPurple700,
                      ),
                    ),
                    pw.Container(
                      height: 2,
                      width: 280,
                      color: PdfColors.amber700,
                      margin: const pw.EdgeInsets.symmetric(vertical: 8),
                    ),
                  ],
                ),
                pw.Column(
                  children: [
                    pw.Text(
                      t('Chứng nhận sinh viên:'),
                      style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      t(cert.studentName.toUpperCase()),
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.black,
                      ),
                    ),
                    pw.SizedBox(height: 12),
                    pw.Text(
                      t('Đã tham gia đầy đủ và hoàn thành xuất sắc nội dung sự kiện:'),
                      style: const pw.TextStyle(fontSize: 13, color: PdfColors.grey800),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      t(cert.eventTitle),
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.deepPurple800,
                      ),
                    ),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(t('Ngày cấp: ${cert.issueDate}'), style: const pw.TextStyle(fontSize: 11)),
                        pw.Text(t('Mã xác thực: ${cert.verificationHash}'), style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                      ],
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.amber800, width: 2),
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Text(
                        'FPTU VERIFIED DIGITAL CERTIFICATE',
                        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.amber900),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Opens native print & PDF preview / save dialog directly on mobile
  Future<void> openAndDownloadCertificatePdf(CertificateModel certificate) async {
    final pdfBytes = await generateCertificatePdf(certificate);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'ChungNhan_${certificate.id}',
    );
  }

  /// Generates a PDF ticket summary for offline storage
  Future<Uint8List> generateTicketPdf(TicketModel ticket) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.deepPurple, width: 2),
              borderRadius: pw.BorderRadius.circular(12),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text(
                    'VE DIEN TU — FPTU CAMPUS EVENT',
                    style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.deepPurple900),
                  ),
                ),
                pw.Divider(thickness: 1, color: PdfColors.grey300),
                pw.SizedBox(height: 8),
                pw.Text('Ma ve: ${ticket.id}', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                pw.Text('Su kien: ${ticket.eventTitle}', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.deepPurple700)),
                pw.SizedBox(height: 6),
                pw.Text('Thoi gian: ${ticket.eventTime} — ${ticket.eventDate}'),
                pw.Text('Dia diem: ${ticket.eventLocation}'),
                pw.Text('Sinh vien: ${ticket.studentName} (${ticket.studentEmail})'),
                pw.SizedBox(height: 16),
                pw.Center(
                  child: pw.Container(
                    width: 140,
                    height: 140,
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.black, width: 1),
                    ),
                    child: pw.Center(
                      child: pw.Text('QR CODE\n${ticket.qrToken}', textAlign: pw.TextAlign.center),
                    ),
                  ),
                ),
                pw.Spacer(),
                pw.Center(
                  child: pw.Text(
                    'Vui long xuat trinh ve tai cua Hoi truong de duoc quet check-in.',
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  /// High-level method: generates Certificate PDF and uploads to Cloud Storage
  Future<UploadResult> exportAndUploadCertificate({
    required CertificateModel certificate,
    Function(double progress)? onProgress,
  }) async {
    final pdfBytes = await generateCertificatePdf(certificate);
    final fileName = 'certificate_${certificate.id}.pdf';
    return _storageService.uploadFileBytes(
      userId: certificate.userId,
      fileName: fileName,
      bytes: pdfBytes,
      folder: 'reports',
      onProgress: onProgress,
    );
  }
}
