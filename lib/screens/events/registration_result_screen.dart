import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/ticket_model.dart';
import '../../widgets/app_button.dart';
import '../../widgets/ticket_card.dart';
import '../tickets/digital_ticket_screen.dart';

/// Màn hình Kết quả đăng ký thành công kèm vé QR tức thì (Instant QR Result Screen).
///
/// Hiển thị trực tiếp thẻ vé điện tử ([TicketCard]) cùng mã QR ngay sau khi đăng ký
/// thành công khi sự kiện còn chỗ, không cần qua bước xét duyệt thủ công.
class RegistrationResultScreen extends StatelessWidget {
  /// Thông tin vé điện tử vừa được cấp [TicketModel].
  final TicketModel ticket;

  /// Khởi tạo [RegistrationResultScreen] với thông tin vé [ticket].
  const RegistrationResultScreen({super.key, required this.ticket});

  /// Xây dựng giao diện thông báo đăng ký thành công kèm mã QR vé điện tử ngay lập tức.
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent physical back re-submit
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Vé điện tử của bạn'),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingScreenPadding,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.successSoft,
                          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                          border: Border.all(
                            color: AppTheme.successBorder,
                            width: 1,
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              color: AppTheme.successInk,
                              size: 28,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ĐĂNG KÝ THÀNH CÔNG · VÉ QR ĐÃ SẴN SÀNG',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.successInk,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                  SizedBox(height: 3),
                                  Text(
                                    'Mã QR đã được cấp ngay lập tức và lưu vào mục Vé của tôi để quét check-in tại cổng.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.onSurface,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Immediate Digital Ticket Card with Live QR Code
                    TicketCard(ticket: ticket),

                    const SizedBox(height: 8),

                    // Google Calendar Sync Banner + Actions
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingScreenPadding,
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceSubtle,
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusInput,
                              ),
                              border: Border.all(
                                color: AppTheme.hairline,
                                width: 1,
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.event_available,
                                  color: AppTheme.obsidian,
                                  size: 16,
                                ),
                                SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'Đã tự động đồng bộ vào Google Calendar và ví vé của bạn',
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
                          const SizedBox(height: 16),

                          // Action Buttons
                          AppPrimaryButton(
                            label: 'Mở chi tiết vé & Live Companion',
                            icon: Icons.live_tv_rounded,
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (ctx) =>
                                      DigitalTicketScreen(ticket: ticket),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 10),
                          AppOutlinedButton(
                            label: 'Về trang chủ',
                            onPressed: () {
                              Navigator.popUntil(
                                context,
                                (route) => route.isFirst,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
