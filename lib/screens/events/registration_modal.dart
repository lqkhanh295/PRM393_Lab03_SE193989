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

/// Hộp thoại Bottom Sheet xác nhận thông tin đăng ký giữ chỗ sự kiện (Instant QR Registration).
///
/// Tự động kiểm tra số chỗ còn lại theo thời gian thực trên Cloud Firestore và phát hành
/// ngay vé điện tử kèm mã QR vào tài khoản sinh viên nếu còn chỗ trống.
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

  /// Tạo state quản lý tiến trình đăng ký và phát hành mã QR tức thì.
  @override
  State<RegistrationModal> createState() => _RegistrationModalState();
}

class _RegistrationModalState extends State<RegistrationModal> {
  @override
  Widget build(BuildContext context) {
    final regVM = context.watch<RegistrationViewModel>();
    final isLoading = regVM.state is StateLoading;
    final spotsLeft = widget.event.spotsRemaining;
    final canRegister = !widget.event.isPast && !widget.event.isFull;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingScreenPadding),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusSheet),
        ),
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
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textMuted,
                  height: 1.4,
                ),
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
                    _buildInfoRow('Email:', widget.user.email),
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
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Remaining spots & instant QR issuance policy
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: canRegister
                      ? AppTheme.successSoft
                      : const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                  border: Border.all(
                    color: canRegister
                        ? AppTheme.successBorder
                        : AppTheme.errorInk.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      canRegister
                          ? Icons.qr_code_2_rounded
                          : Icons.event_busy_rounded,
                      size: 20,
                      color: canRegister
                          ? AppTheme.successInk
                          : AppTheme.errorInk,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.event.isPast
                                ? 'Sự kiện đã kết thúc'
                                : (widget.event.isFull
                                    ? 'Sự kiện đã hết chỗ (${widget.event.capacity}/${widget.event.capacity})'
                                    : 'Còn $spotsLeft / ${widget.event.capacity} chỗ trống · Cấp mã QR ngay'),
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: canRegister
                                  ? AppTheme.successInk
                                  : AppTheme.errorInk,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Hệ thống sẽ phát hành vé điện tử kèm mã QR ngay lập tức vào tài khoản của bạn.',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.textMuted,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Action Buttons
              AppPrimaryButton(
                label: canRegister
                    ? 'Xác nhận đăng ký & Nhận mã QR'
                    : (widget.event.isPast ? 'Sự kiện đã kết thúc' : 'Đã hết chỗ'),
                icon: Icons.qr_code_rounded,
                isLoading: isLoading,
                onPressed: !canRegister
                    ? null
                    : () async {
                        final success = await regVM.register(
                          event: widget.event,
                          user: widget.user,
                        );
                        if (success && context.mounted) {
                          final ticket = (regVM.state as StateData).data;
                          context.read<MyTicketsViewModel>().loadUserTickets(
                            widget.user.id,
                          );
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
                              builder: (ctx) =>
                                  RegistrationResultScreen(ticket: ticket),
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
                      },
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  child: const Text(
                    'Hủy bỏ',
                    style: TextStyle(color: AppTheme.textMuted),
                  ),
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
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
        ),
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
