import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/event_model.dart';
import '../../models/user_model.dart';
import '../../models/screen_state.dart';
import '../../viewmodels/registration_vm.dart';
import '../../viewmodels/my_tickets_vm.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../viewmodels/event_detail_vm.dart';
import '../../widgets/app_button.dart';
import 'registration_result_screen.dart';
import 'registration_pending_screen.dart';

/// Hộp thoại Bottom Sheet xác nhận thông tin đăng ký giữ chỗ sự kiện (1-Tap Registration).
///
/// Hỗ trợ cả hai chế độ: Cấp vé điện tử ngay lập tức hoặc nộp hồ sơ chờ cán bộ thẩm định
/// (Cross-Role Approval Flow), hiển thị thông tin sinh viên đã xác thực.
class RegistrationModal extends StatefulWidget {
  /// Thông tin sự kiện [EventModel].
  final EventModel event;

  /// Thông tin hồ sơ sinh viên nộp đơn [UserModel].
  final UserModel user;

  /// Khởi tạo [RegistrationModal] với [event] và [user].
  const RegistrationModal({
    super.key,
    required this.event,
    required this.user,
  });

  /// Tạo state quản lý tùy chọn duyệt đơn và tiến trình gửi đăng ký.
  @override
  State<RegistrationModal> createState() => _RegistrationModalState();
}

class _RegistrationModalState extends State<RegistrationModal> {
  // Whether to use Cross-Role approval flow (Slide 18) or 1-Tap instant ticket
  bool _requireApproval = false;

  @override
  Widget build(BuildContext context) {
    final regVM = context.watch<RegistrationViewModel>();
    final isLoading = regVM.state is StateLoading;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingScreenPadding),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusSheet)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.hairline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              const Text(
                'Xác nhận đăng ký giữ chỗ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.obsidian,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Hệ thống tự động sử dụng thông tin tài khoản FPT có sẵn của bạn để cấp vé.',
                style: TextStyle(fontSize: 13, color: AppTheme.textMuted, height: 1.4),
              ),
              const SizedBox(height: 16),

              // Pre-filled Student Details Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceSubtle,
                  borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                  border: Border.all(color: AppTheme.hairline, width: 1),
                ),
                child: Column(
                  children: [
                    _buildInfoRow('Họ và tên:', widget.user.name),
                    const SizedBox(height: 8),
                    _buildInfoRow('Email FPT:', widget.user.email),
                    const SizedBox(height: 8),
                    _buildInfoRow('Chuyên ngành:', widget.user.major),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Event Summary
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  border: Border.all(color: AppTheme.hairline, width: 1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.event.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.event.time} · ${widget.event.date} · ${widget.event.location}',
                      style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Mode Selector: 1-Tap vs Cross-Role Approval (Slide 18)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceSubtle,
                  borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                  border: Border.all(color: AppTheme.hairline, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.how_to_reg_outlined, size: 16, color: AppTheme.obsidian),
                            SizedBox(width: 6),
                            Text(
                              'Hình thức cấp vé:',
                              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppTheme.obsidian),
                            ),
                          ],
                        ),
                        if (_requireApproval)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Quy trình CTSV',
                              style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFFB45309)),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _requireApproval = false),
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: !_requireApproval ? AppTheme.obsidian : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: !_requireApproval ? AppTheme.obsidian : AppTheme.hairline,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Cấp Vé Ngay (1-Tap)',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: !_requireApproval ? Colors.white : AppTheme.textMuted,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _requireApproval = true),
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: _requireApproval ? AppTheme.obsidian : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: _requireApproval ? AppTheme.obsidian : AppTheme.hairline,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Đăng Ký Chờ Phê Duyệt',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: _requireApproval ? Colors.white : AppTheme.textMuted,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _requireApproval
                          ? 'Đơn sẽ chuyển tới Hàng Chờ Duyệt (Web Admin Portal) để BTC phê duyệt trước khi cấp mã QR.'
                          : 'Cấp vé điện tử mã QR tức thì vào mục "Vé của tôi".',
                      style: const TextStyle(fontSize: 11, color: AppTheme.textMuted, height: 1.3),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Action Buttons
              AppPrimaryButton(
                label: _requireApproval ? 'Nộp đơn chờ BTC xét duyệt' : 'Xác nhận giữ chỗ ngay',
                icon: _requireApproval ? Icons.send_rounded : Icons.check_circle_outline_rounded,
                isLoading: isLoading,
                onPressed: () async {
                  if (_requireApproval) {
                    final reg = await regVM.submitPendingRegistration(
                      event: widget.event,
                      user: widget.user,
                    );
                    if (reg != null && context.mounted) {
                      Navigator.pop(context); // Close bottom sheet
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (ctx) => RegistrationPendingScreen(
                            registration: reg,
                            event: widget.event,
                            user: widget.user,
                          ),
                        ),
                      );
                    } else if (regVM.state is StateError && context.mounted) {
                      final err = (regVM.state as StateError).error;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(err), backgroundColor: AppTheme.errorInk),
                      );
                    }
                  } else {
                    final success = await regVM.register(event: widget.event, user: widget.user);
                    if (success && context.mounted) {
                      final ticket = (regVM.state as StateData).data;
                      context.read<MyTicketsViewModel>().loadUserTickets(widget.user.id);
                      context.read<HomeViewModel>().loadHomeScreenData();
                      try {
                        final detailVM = context.read<EventDetailViewModel>();
                        detailVM.incrementRegistration();
                        detailVM.refreshEvent(widget.event.id);
                      } catch (_) {}
                      Navigator.pop(context); // Close bottom sheet
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (ctx) => RegistrationResultScreen(ticket: ticket),
                        ),
                      );
                    } else if (regVM.state is StateError && context.mounted) {
                      final err = (regVM.state as StateError).error;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(err),
                          backgroundColor: AppTheme.errorInk,
                        ),
                      );
                    }
                  }
                },
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  child: const Text('Hủy bỏ', style: TextStyle(color: AppTheme.textMuted)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textMuted)),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.onSurface,
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
