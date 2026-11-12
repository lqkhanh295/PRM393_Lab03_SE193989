import 'package:flutter/material.dart';
import '../models/certificate_model.dart';
import '../theme/app_theme.dart';
import 'app_button.dart';

/// Thẻ hiển thị chứng nhận điện tử (e-Certificate) của sinh viên.
///
/// Thể hiện chứng chỉ hoàn thành sự kiện với đường viền mảnh học thuật,
/// mã băm xác thực chống làm giả và nút tải hoặc xem trước tài liệu PDF.
class CertificateCard extends StatelessWidget {
  /// Đối tượng chứng nhận điện tử [CertificateModel].
  final CertificateModel certificate;

  /// Hàm gọi lại khi sinh viên bấm nút tải chứng chỉ PDF.
  final VoidCallback onDownload;

  /// Khởi tạo [CertificateCard] với dữ liệu [certificate] và hành động tải [onDownload].
  const CertificateCard({
    super.key,
    required this.certificate,
    required this.onDownload,
  });

  /// Xây dựng giao diện thẻ chứng nhận.
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(AppTheme.spacingCardPadding),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: AppTheme.hairline, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceSubtle,
                  borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                  border: Border.all(color: AppTheme.hairline, width: 1),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.verified_outlined,
                  color: AppTheme.successInk,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.successSoft,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'CHỨNG NHẬN ĐIỆN TỬ FPTU',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.successInk,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      certificate.eventTitle,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                        color: AppTheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, thickness: 1, color: AppTheme.hairline),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Sinh viên thụ hưởng',
                style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
              ),
              Text(
                certificate.studentName,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ngày phát hành',
                style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
              ),
              Text(
                certificate.issueDate,
                style: const TextStyle(
                  fontSize: 12,
                  fontFeatures: [FontFeature.tabularFigures()],
                  fontWeight: FontWeight.w500,
                  color: AppTheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.surfaceSubtle,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppTheme.hairline, width: 1),
            ),
            child: Row(
              children: [
                const Icon(Icons.fingerprint, size: 14, color: AppTheme.textMuted),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'HASH: ${certificate.verificationHash}',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: AppTheme.textMuted,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          AppOutlinedButton(
            label: 'Tải Giấy Chứng Nhận (PDF)',
            icon: Icons.download_rounded,
            onPressed: onDownload,
          ),
        ],
      ),
    );
  }
}
