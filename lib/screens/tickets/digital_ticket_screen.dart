import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/ticket_model.dart';
import '../../widgets/ticket_card.dart';
import '../../widgets/app_button.dart';
import '../live/live_companion_screen.dart';
import '../feedback/event_feedback_screen.dart';

/// S20: Digital Ticket Screen with Dynamic QR Token
class DigitalTicketScreen extends StatelessWidget {
  final TicketModel ticket;

  const DigitalTicketScreen({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
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
                const SnackBar(content: Text('Đã kích hoạt chế độ tăng tối đa độ sáng màn hình để quét QR dễ dàng.')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TicketCard(
              ticket: ticket,
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
                      builder: (_) => LiveCompanionScreen(ticket: ticket),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Post-event Feedback / Certification Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingScreenPadding),
              child: AppOutlinedButton(
                label: 'Đánh giá sự kiện & Nhận Điểm Rèn Luyện',
                icon: Icons.star_rate_rounded,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EventFeedbackScreen(ticket: ticket),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
