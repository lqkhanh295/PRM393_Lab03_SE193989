import 'package:flutter/material.dart';
import '../models/certificate_model.dart';
import '../theme/app_theme.dart';
import 'app_button.dart';

/// Digital Certificate Card
class CertificateCard extends StatelessWidget {
  final CertificateModel certificate;
  final VoidCallback onDownload;

  const CertificateCard({
    super.key,
    required this.certificate,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(AppTheme.spacingCardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: const Color(0xFFD4AF37), width: 1.5), // Gold border
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.workspace_premium_rounded, color: Color(0xFFB78103), size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CHỨNG NHẬN SỐ HOÀN THÀNH',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFB78103),
                        letterSpacing: 0.8,
                      ),
                    ),
                    Text(
                      certificate.eventTitle,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Học viên: ${certificate.studentName}',
            style: const TextStyle(fontSize: 13, color: AppTheme.onSurfaceVariant),
          ),
          Text(
            'Ngày cấp: ${certificate.issueDate} · Mã: ${certificate.verificationHash}',
            style: const TextStyle(fontSize: 11, color: AppTheme.outline),
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
