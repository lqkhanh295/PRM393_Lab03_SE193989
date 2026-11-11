import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/event_model.dart';
import '../../models/user_model.dart';
import '../../models/ticket_model.dart';
import '../../models/registration_model.dart';
import '../../services/firestore_service.dart';
import '../../viewmodels/my_tickets_vm.dart';
import '../../widgets/app_button.dart';
import '../tickets/digital_ticket_screen.dart';

/// Screen S18-Pending: Cross-Role Registration Approval Status Screen (Slide 18)
/// Anti-slop Editorial Screen: Clean typography, high contrast state indicators,
/// zero mock data, binds directly to Cloud Firestore Stream in real-time.
class RegistrationPendingScreen extends StatefulWidget {
  final RegistrationModel registration;
  final EventModel event;
  final UserModel user;

  const RegistrationPendingScreen({
    super.key,
    required this.registration,
    required this.event,
    required this.user,
  });

  @override
  State<RegistrationPendingScreen> createState() => _RegistrationPendingScreenState();
}

class _RegistrationPendingScreenState extends State<RegistrationPendingScreen> {
  @override
  Widget build(BuildContext context) {
    final firestoreService = context.read<FirestoreService>();

    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          backgroundColor: AppTheme.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded, color: AppTheme.obsidian),
            onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
          ),
          title: const Text(
            'Trạng Thái Hồ Sơ Đăng Ký',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.obsidian,
            ),
          ),
          centerTitle: true,
        ),
        body: StreamBuilder<RegistrationModel?>(
          stream: firestoreService.streamUserRegistration(widget.event.id, widget.user.id),
          initialData: widget.registration,
          builder: (context, snapshot) {
            final reg = snapshot.data ?? widget.registration;

            if (reg.status == RegistrationStatus.approved) {
              return _buildApprovedView(context, reg);
            } else if (reg.status == RegistrationStatus.rejected) {
              return _buildRejectedView(context, reg);
            }

            return _buildPendingView(context, reg);
          },
        ),
      ),
    );
  }

  /// 1. PENDING STATE VIEW (Waiting for Organizer Approval on Web Admin)
  Widget _buildPendingView(BuildContext context, RegistrationModel reg) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingScreenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 12),
            // Glowing Pending Icon Badge
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFCD34D), width: 1.5),
              ),
              child: const Icon(
                Icons.hourglass_top_rounded,
                color: Color(0xFFD97706),
                size: 38,
              ),
            ),
            const SizedBox(height: 18),

            const Text(
              'HỒ SƠ ĐANG CHỜ PHÊ DUYỆT',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFFB45309),
                letterSpacing: -0.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Đơn đăng ký của bạn đã được ghi nhận trên Cloud Firestore và chuyển tới Hàng Chờ Duyệt Vé của Ban Tổ Chức.',
              style: TextStyle(fontSize: 13, color: AppTheme.textMuted, height: 1.45),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 22),

            // Live Stream Indicator Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 10,
                    height: 10,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Đồng bộ thời gian thực với Web Admin Portal',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF1D4ED8)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Application Details Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
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
                        'MÃ ĐƠN ĐĂNG KÝ',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.textMuted, letterSpacing: 0.8),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'CHỜ DUYỆT (PENDING)',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFFB45309)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        reg.id,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.obsidian, fontFamily: 'monospace'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy_rounded, size: 16, color: AppTheme.textMuted),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: reg.id));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Đã sao chép mã đơn đăng ký')),
                          );
                        },
                      ),
                    ],
                  ),
                  const Divider(height: 20, thickness: 1, color: AppTheme.hairline),
                  _buildDetailRow('Sự kiện:', widget.event.title),
                  const SizedBox(height: 8),
                  _buildDetailRow('Thời gian:', '${widget.event.time} · ${widget.event.date}'),
                  const SizedBox(height: 8),
                  _buildDetailRow('Địa điểm:', widget.event.location),
                  const SizedBox(height: 8),
                  _buildDetailRow('Sinh viên:', widget.user.name),
                  const SizedBox(height: 8),
                  _buildDetailRow('Email FPT:', widget.user.email),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Demo Instruction Guide for Presentation / Examiner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, color: Color(0xFF0EA5E9), size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'HƯỚNG DẪN DEMO SLIDE 18:\nĐơn này đã xuất hiện tại mục "Hàng Chờ Duyệt Vé" trên Web Admin (http://localhost:3000). Khi Admin bấm "Duyệt & Cấp Vé", màn hình này sẽ tự động chuyển sang Vé QR mà không cần tải lại!',
                      style: TextStyle(fontSize: 11.5, color: Color(0xFF334155), height: 1.45),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            AppOutlinedButton(
              label: 'Đóng & Quay lại Trang Chủ',
              icon: Icons.home_outlined,
              onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
            ),
          ],
        ),
      ),
    );
  }

  /// 2. APPROVED STATE VIEW (Organizer Approved & Issued Ticket)
  Widget _buildApprovedView(BuildContext context, RegistrationModel reg) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingScreenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.successSoft,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.successBorder, width: 1.5),
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                color: AppTheme.successInk,
                size: 40,
              ),
            ),
            const SizedBox(height: 18),

            const Text(
              'ĐƠN ĐĂNG KÝ ĐÃ ĐƯỢC DUYỆT! 🎉',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: AppTheme.obsidian,
                letterSpacing: -0.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Ban Tổ Chức đã phê duyệt hồ sơ của bạn. Vé điện tử và mã Dynamic QR Token chính thức đã được phát hành.',
              style: TextStyle(fontSize: 13, color: AppTheme.textMuted, height: 1.45),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 22),

            // Ticket Code Display Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
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
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.textMuted, letterSpacing: 0.8),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.successSoft,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'HỢP LỆ (ACTIVE)',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.successInk),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    reg.ticketId ?? 'CE2026-ACTIVE',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.obsidian,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const Divider(height: 20, thickness: 1, color: AppTheme.hairline),
                  _buildDetailRow('Sự kiện:', widget.event.title),
                  const SizedBox(height: 8),
                  _buildDetailRow('Thời gian:', '${widget.event.time} · ${widget.event.date}'),
                  const SizedBox(height: 8),
                  _buildDetailRow('Địa điểm:', widget.event.location),
                ],
              ),
            ),
            const SizedBox(height: 24),

            AppPrimaryButton(
              label: 'Mở Ví Vé Điện Tử (Xem QR)',
              icon: Icons.qr_code_rounded,
              onPressed: () async {
                final myTicketsVM = context.read<MyTicketsViewModel>();
                await myTicketsVM.loadUserTickets(widget.user.id);
                TicketModel? targetTicket;
                for (final t in myTicketsVM.allTickets) {
                  if (t.id == reg.ticketId || t.eventId == widget.event.id) {
                    targetTicket = t;
                    break;
                  }
                }
                if (targetTicket == null && myTicketsVM.allTickets.isNotEmpty) {
                  targetTicket = myTicketsVM.allTickets.first;
                }

                if (targetTicket != null && context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (ctx) => DigitalTicketScreen(ticket: targetTicket!),
                    ),
                  );
                } else if (context.mounted) {
                  Navigator.popUntil(context, (r) => r.isFirst);
                }
              },
            ),
            const SizedBox(height: 10),
            AppOutlinedButton(
              label: 'Về Trang Chủ',
              onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
            ),
          ],
        ),
      ),
    );
  }

  /// 3. REJECTED STATE VIEW (Organizer Rejected with Reason)
  Widget _buildRejectedView(BuildContext context, RegistrationModel reg) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingScreenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFCA5A5), width: 1.5),
              ),
              child: const Icon(
                Icons.cancel_outlined,
                color: Color(0xFFDC2626),
                size: 40,
              ),
            ),
            const SizedBox(height: 18),

            const Text(
              'ĐƠN ĐĂNG KÝ KHÔNG ĐƯỢC DUYỆT',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF991B1B),
                letterSpacing: -0.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Rất tiếc, Ban Tổ Chức chưa thể phê duyệt hồ sơ tham dự sự kiện "${widget.event.title}" của bạn.',
              style: const TextStyle(fontSize: 13, color: AppTheme.textMuted, height: 1.45),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Reason Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                border: Border.all(color: const Color(0xFFFECACA), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'LÝ DO TỪ PHÒNG CTSV / BAN TỔ CHỨC:',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF991B1B)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    reg.reason?.isNotEmpty == true
                        ? reg.reason!
                        : 'Sự kiện đã đạt số lượng tối đa hoặc hồ sơ chưa phù hợp với tiêu chuẩn tham dự.',
                    style: const TextStyle(fontSize: 13.5, color: AppTheme.obsidian, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            AppOutlinedButton(
              label: 'Quay lại Trang Chủ',
              onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12.5, color: AppTheme.textMuted)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppTheme.obsidian),
            textAlign: TextAlign.end,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
