import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/ticket_model.dart';
import '../../models/screen_state.dart';
import '../../viewmodels/feedback_vm.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/rating_bar.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/certificate_card.dart';

/// S23: Event Feedback & Rating Screen
/// Anti-slop Editorial Survey: flat hairline surfaces, high-contrast star ratings, verified academic credential output.
class EventFeedbackScreen extends StatefulWidget {
  final TicketModel ticket;

  const EventFeedbackScreen({super.key, required this.ticket});

  @override
  State<EventFeedbackScreen> createState() => _EventFeedbackScreenState();
}

class _EventFeedbackScreenState extends State<EventFeedbackScreen> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feedbackVM = context.watch<FeedbackViewModel>();
    final authVM = context.watch<AuthViewModel>();
    final user = authVM.currentUser;
    final isSubmitted = feedbackVM.state is StateData;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Đánh giá sự kiện'),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: AppTheme.hairline),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingScreenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.primaryContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'PHIẾU KHẢO SÁT CHẤT LƯỢNG',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.onPrimaryContainer,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.ticket.eventTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.obsidian,
                height: 1.3,
                letterSpacing: -0.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            const Text(
              'Ý kiến đóng góp của bạn giúp BTC và CLB cải thiện chất lượng các chương trình tiếp theo.',
              style: TextStyle(fontSize: 13, color: AppTheme.textMuted, height: 1.4),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            if (!isSubmitted) ...[
              // 5-Star Rating Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                  border: Border.all(color: AppTheme.hairline, width: 1),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Bạn cảm thấy sự kiện thế nào?',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    StarRatingBar(
                      rating: feedbackVM.rating,
                      onRatingChanged: (val) => feedbackVM.setRating(val),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _getRatingDescription(feedbackVM.rating),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Comment Input
              AppTextField(
                controller: _commentController,
                label: 'Cảm nghĩ và nhận xét của bạn...',
                hintText: 'Nội dung chia sẻ của diễn giả rất hữu ích...',
              ),
              const SizedBox(height: 20),

              // Submit Button
              AppPrimaryButton(
                label: 'Gửi đánh giá & Nhận 5 Điểm Rèn Luyện',
                isLoading: feedbackVM.state is StateLoading,
                icon: Icons.send_rounded,
                onPressed: () async {
                  if (user != null) {
                    await feedbackVM.submitFeedback(
                      eventId: widget.ticket.eventId,
                      eventTitle: widget.ticket.eventTitle,
                      user: user,
                      comment: _commentController.text,
                    );
                  }
                },
              ),
            ] else ...[
              // Unlocked Certificate Result Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.successSoft,
                  borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                  border: Border.all(color: AppTheme.successBorder, width: 1),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.verified_rounded, color: AppTheme.successInk, size: 24),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Cảm ơn bạn! Đã cộng +5 Điểm rèn luyện vào hồ sơ sinh viên FPTU.',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.successInk,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'CHỨNG NHẬN ĐIỆN TỬ SẴN SÀNG',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textMuted,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              CertificateCard(
                certificate: (feedbackVM.state as StateData).data,
                onDownload: () async {
                  await feedbackVM.exportCertificatePdf((feedbackVM.state as StateData).data);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đang tạo và tải file PDF chứng nhận...')),
                    );
                  }
                },
              ),
              const SizedBox(height: 12),

              AppOutlinedButton(
                label: 'Quay lại màn hình vé',
                onPressed: () => Navigator.pop(context),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _getRatingDescription(int r) {
    switch (r) {
      case 5:
        return 'Tuyệt vời! Rất hài lòng và học được nhiều điều';
      case 4:
        return 'Hài lòng! Chương trình bổ ích và tổ chức tốt';
      case 3:
        return 'Bình thường! Nội dung tạm ổn';
      case 2:
        return 'Chưa hài lòng! Cần cải thiện khâu tổ chức';
      default:
        return 'Rất không hài lòng';
    }
  }
}
