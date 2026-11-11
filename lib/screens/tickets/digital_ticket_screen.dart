import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/ticket_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/ticket_card.dart';
import '../../widgets/app_button.dart';
import '../live/live_companion_screen.dart';
import '../feedback/event_feedback_screen.dart';

/// S20: Digital Ticket Screen with Dynamic QR Token
/// Enforces Business Rule BR-005: Event Feedback & +5 Training Points
/// are strictly unlocked only after a successful gate check-in.
class DigitalTicketScreen extends StatelessWidget {
  final TicketModel ticket;

  const DigitalTicketScreen({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    final firestoreService = context.watch<FirestoreService?>();

    return StreamBuilder<TicketModel?>(
      stream: firestoreService?.streamTicket(ticket.id),
      initialData: ticket,
      builder: (context, snapshot) {
        final currentTicket = snapshot.data ?? ticket;
        final isCheckedIn = currentTicket.isCheckedIn;

        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            title: const Text('Vé điện tử FPTU'),
            actions: [
              IconButton(
                icon: const Icon(Icons.brightness_high_rounded),
                tooltip: 'Tăng sáng màn hình',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã kích hoạt chế độ tăng tối đa độ sáng màn hình để quét QR dễ dàng.'),
                    ),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                TicketCard(
                  ticket: currentTicket,
                  onBoostBrightness: () {},
                ),
                const SizedBox(height: 12),

                // In-Event Live Mode Trigger Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingScreenPadding),
                  child: AppPrimaryButton(
                    label: 'Vào Chế độ Trong sự kiện (Live Companion)',
                    icon: Icons.live_tv_rounded,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LiveCompanionScreen(ticket: currentTicket),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // Post-event Feedback / Certification Gating (BR-005)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingScreenPadding),
                  child: isCheckedIn
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: AppTheme.successSoft,
                                borderRadius: BorderRadius.circular(AppTheme.radiusBadge),
                                border: Border.all(color: AppTheme.successBorder, width: 1),
                              ),
                              child: Row(
                                children: const [
                                  Icon(Icons.check_circle_rounded, size: 16, color: AppTheme.successInk),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Đã điểm danh tại cổng — Bạn đã đủ điều kiện đánh giá và nhận +5 Điểm Rèn Luyện!',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.successInk,
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            AppOutlinedButton(
                              label: 'Đánh giá sự kiện & Nhận Điểm Rèn Luyện',
                              icon: Icons.star_rate_rounded,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EventFeedbackScreen(ticket: currentTicket),
                                  ),
                                );
                              },
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AppOutlinedButton(
                              label: 'Đánh giá & Nhận Điểm Rèn Luyện (Đang khóa)',
                              icon: Icons.lock_outline_rounded,
                              borderColor: AppTheme.hairline,
                              textColor: AppTheme.textMuted,
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Chức năng đánh giá bị khóa: Bạn cần hoàn tất điểm danh (Check-in) tại cửa sự kiện trước (Quy định BR-005).',
                                    ),
                                    duration: Duration(seconds: 3),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceSubtle,
                                borderRadius: BorderRadius.circular(AppTheme.radiusBadge),
                                border: Border.all(color: AppTheme.hairline, width: 1),
                              ),
                              child: Row(
                                children: const [
                                  Icon(Icons.lock_clock_rounded, size: 16, color: AppTheme.textMuted),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Đánh giá và cấp e-Certificate chỉ mở khóa sau khi BTC quét mã check-in vé của bạn tại cổng.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textMuted,
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}
