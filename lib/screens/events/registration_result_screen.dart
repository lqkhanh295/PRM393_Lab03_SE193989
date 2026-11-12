import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/ticket_model.dart';
import '../../widgets/app_button.dart';
import '../tickets/digital_ticket_screen.dart';

/// Màn hình Kết quả đăng ký thành công (Registration Result Screen).
///
/// Thể hiện mã vé vừa khởi tạo, tóm tắt thông tin sự kiện và các tùy chọn:
/// xem vé điện tử ngay hoặc quay về trang chủ.
class RegistrationResultScreen extends StatelessWidget {
  /// Thông tin vé điện tử vừa được cấp [TicketModel].
  final TicketModel ticket;

  /// Khởi tạo [RegistrationResultScreen] với thông tin vé [ticket].
  const RegistrationResultScreen({super.key, required this.ticket});

  /// Xây dựng giao diện thông báo đăng ký thành công.
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent physical back re-submit
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacingScreenPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // High contrast Success Icon
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppTheme.successSoft,
                      borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                      border: Border.all(color: AppTheme.successBorder, width: 1),
                    ),
                    child: const Icon(
                      Icons.check_circle_outline_rounded,
                      color: AppTheme.successInk,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 18),

                  const Text(
                    'ĐĂNG KÝ THÀNH CÔNG',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.obsidian,
                      letterSpacing: -0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Vé điện tử của bạn đã được khởi tạo và lưu trữ an toàn trong ví vé cá nhân.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textMuted,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Ticket Mini Summary Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                      border: Border.all(color: AppTheme.hairline, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'MÃ VÉ ĐIỆN TỬ FPTU',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textMuted,
                                letterSpacing: 0.8,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.successSoft,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'ACTIVE',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.successInk,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          ticket.id,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                            color: AppTheme.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1, thickness: 1, color: AppTheme.hairline),
                        const SizedBox(height: 12),
                        Text(
                          ticket.eventTitle,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${ticket.eventTime} · ${ticket.eventDate}',
                          style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Google Calendar Sync Shortcut
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceSubtle,
                      borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                      border: Border.all(color: AppTheme.hairline, width: 1),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_available, color: AppTheme.obsidian, size: 16),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Đã tự động đồng bộ vào Google Calendar của bạn',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  AppPrimaryButton(
                    label: 'Xem vé điện tử QR ngay',
                    icon: Icons.qr_code_rounded,
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (ctx) => DigitalTicketScreen(ticket: ticket),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  AppOutlinedButton(
                    label: 'Về trang chủ',
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
