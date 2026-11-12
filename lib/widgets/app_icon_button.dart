import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Nút biểu tượng hỗ trợ tiếp cận chuẩn WCAG 2.1 AA SC 2.5.5.
///
/// Bắt buộc vùng tương tác tối thiểu 48x48dp để tránh bấm nhầm trên màn hình cảm ứng di động.
class AppIconButton extends StatelessWidget {
  /// Biểu tượng [IconData] cần hiển thị.
  final IconData icon;

  /// Hàm gọi lại khi bấm vào nút biểu tượng.
  final VoidCallback? onPressed;

  /// Chú thích công cụ (Tooltip) giải thích hành động phục vụ người dùng và trình đọc màn hình.
  final String tooltip;

  /// Màu sắc tùy chỉnh của biểu tượng.
  final Color? color;

  /// Khởi tạo [AppIconButton] với [icon], chú thích [tooltip] và hàm xử lý [onPressed].
  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    required this.tooltip,
    this.color,
  });

  /// Xây dựng nút bấm biểu tượng với kích thước tối thiểu bảo đảm khả năng tiếp cận.
  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: tooltip,
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppTheme.radiusButton),
          child: Container(
            constraints: const BoxConstraints(
              minWidth: AppTheme.minTouchTarget,
              minHeight: AppTheme.minTouchTarget,
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 24,
              color: color ?? AppTheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
