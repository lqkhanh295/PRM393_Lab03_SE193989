import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'app_button.dart';

/// Giao diện hiển thị trạng thái xảy ra lỗi hoặc gián đoạn kết nối.
///
/// Tuân thủ nguyên lý Nielsen #9 (giúp người dùng nhận biết, chẩn đoán và khắc phục lỗi)
/// với thông điệp rõ ràng và nút bấm thử lại kết nối [onRetry].
class ErrorView extends StatelessWidget {
  /// Tiêu đề chẩn đoán lỗi.
  final String title;

  /// Nội dung thông báo lỗi chi tiết.
  final String errorMessage;

  /// Hàm gọi lại xử lý tải lại dữ liệu khi người dùng bấm nút "Thử lại kết nối".
  final VoidCallback? onRetry;

  /// Khởi tạo [ErrorView] với thông báo lỗi [errorMessage] và nút thử lại [onRetry].
  const ErrorView({
    super.key,
    this.title = 'Đã xảy ra sự cố',
    required this.errorMessage,
    this.onRetry,
  });

  /// Xây dựng khung hiển thị thông báo lỗi và nút thử lại.
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingScreenPadding),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 380),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            border: Border.all(color: AppTheme.errorBorder, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.errorSoft,
                  borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                  border: Border.all(color: AppTheme.errorBorder, width: 1),
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  size: 24,
                  color: AppTheme.errorInk,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.errorInk,
                  letterSpacing: -0.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                errorMessage,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.onSurface,
                  height: 1.45,
                ),
                textAlign: TextAlign.center,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 20),
                AppPrimaryButton(
                  label: 'Thử lại kết nối',
                  icon: Icons.refresh_rounded,
                  onPressed: onRetry!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
