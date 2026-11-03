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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingScreenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            Text(
              widget.ticket.eventTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            const Text(
              'Ý kiến đóng góp của bạn giúp BTC và CLB cải thiện chất lượng các chương trình tiếp theo.',
              style: TextStyle(fontSize: 13, color: AppTheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            if (!isSubmitted) ...[
              // 5-Star Rating Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                  border: Border.all(color: AppTheme.outlineVariant),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Bạn cảm thấy sự kiện thế nào?',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 16),
                    StarRatingBar(
                      rating: feedbackVM.rating,
                      onRatingChanged: (val) => feedbackVM.setRating(val),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _getRatingDescription(feedbackVM.rating),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Comment Input
              AppTextField(
                controller: _commentController,
                label: 'Cảm nghĩ và nhận xét của bạn...',
                hintText: 'Nội dung chia sẻ của diễn giả rất hữu ích...',
              ),
              const SizedBox(height: 24),

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
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.stars_rounded, color: AppTheme.success, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Cảm ơn bạn! Đã cộng +5 Điểm rèn luyện vào hồ sơ sinh viên FPTU.',
                        style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.success),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Chứng nhận số của bạn đã sẵn sàng',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 14),

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
              const SizedBox(height: 16),

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
