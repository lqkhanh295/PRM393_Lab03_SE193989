import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'app_button.dart';

/// Giao diện hiển thị trạng thái danh sách trống hoặc chưa có dữ liệu.
///
/// Tuân thủ nguyên tắc thiết kế tối giản, thông báo trung thực tình trạng dữ liệu
/// kèm nút hành động bổ sung nếu có [actionLabel] và [onAction].
class EmptyView extends StatelessWidget {
  /// Tiêu đề của thông báo trạng thái rỗng.
  final String title;

  /// Mô tả chi tiết lý do danh sách trống hoặc hướng dẫn thao tác tiếp theo.
  final String message;

  /// Nhãn hiển thị trên nút hành động đề xuất.
  final String? actionLabel;

  /// Hàm xử lý khi người dùng nhấn vào nút hành động.
  final VoidCallback? onAction;

  /// Khởi tạo [EmptyView] với thông điệp [message] và các tham số tùy chọn.
  const EmptyView({
    super.key,
    this.title = 'Chưa có dữ liệu',
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  /// Xây dựng khung hiển thị danh sách rỗng.
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingScreenPadding),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 360),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            border: Border.all(color: AppTheme.hairline, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceSubtle,
                  borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                  border: Border.all(color: AppTheme.hairline, width: 1),
                ),
                child: const Icon(
                  Icons.inbox_outlined,
                  size: 24,
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.onSurface,
                  letterSpacing: -0.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textMuted,
                  height: 1.45,
                ),
                textAlign: TextAlign.center,
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 20),
                AppPrimaryButton(
                  label: actionLabel!,
                  onPressed: onAction!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
