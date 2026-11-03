import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/event_model.dart';
import '../../models/user_model.dart';
import '../../models/screen_state.dart';
import '../../viewmodels/registration_vm.dart';
import '../../widgets/app_button.dart';
import 'registration_result_screen.dart';

/// S15: 1-Tap Registration Bottom Sheet Modal
class RegistrationModal extends StatelessWidget {
  final EventModel event;
  final UserModel user;

  const RegistrationModal({
    super.key,
    required this.event,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final regVM = context.watch<RegistrationViewModel>();
    final isLoading = regVM.state is StateLoading;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingScreenPadding),
      decoration: const BoxDecoration(
        color: Colors.white,
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
                  width: 44,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.outlineVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),

              Text(
                'Xác nhận đăng ký giữ chỗ',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              const Text(
                'Hệ thống tự động sử dụng thông tin tài khoản FPT có sẵn của bạn để cấp vé.',
                style: TextStyle(fontSize: 13, color: AppTheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),

              // Pre-filled Student Details Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(AppTheme.radiusButton),
                ),
                child: Column(
                  children: [
                    _buildInfoRow('Họ và tên:', user.name),
                    const SizedBox(height: 6),
                    _buildInfoRow('Email FPT:', user.email),
                    const SizedBox(height: 6),
                    _buildInfoRow('Chuyên ngành:', user.major),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Event Summary
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.outlineVariant),
                  borderRadius: BorderRadius.circular(AppTheme.radiusButton),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${event.time} · ${event.date} · ${event.location}',
                      style: const TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              AppPrimaryButton(
                label: 'Xác nhận giữ chỗ ngay',
                isLoading: isLoading,
                onPressed: () async {
                  final success = await regVM.register(event: event, user: user);
                  if (success && context.mounted) {
                    final ticket = (regVM.state as StateData).data;
                    Navigator.pop(context); // Close bottom sheet
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RegistrationResultScreen(ticket: ticket),
                      ),
                    );
                  } else if (regVM.state is StateError && context.mounted) {
                    final err = (regVM.state as StateError).error;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(err),
                        backgroundColor: AppTheme.error,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 10),
              Center(
                child: TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  child: const Text('Hủy bỏ', style: TextStyle(color: AppTheme.onSurfaceVariant)),
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
        Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.onSurfaceVariant)),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
