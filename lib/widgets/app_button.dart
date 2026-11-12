import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Nút bấm hành động chính (Primary Action Button) trong toàn bộ ứng dụng.
///
/// Độ tương phản cao, vùng chạm tối thiểu 48dp chuẩn tiếp cận WCAG 2.1 AA SC 2.5.5,
/// hỗ trợ hiển thị vòng xoay tiến trình [isLoading] và biểu tượng đi kèm [icon].
class AppPrimaryButton extends StatelessWidget {
  /// Nhãn văn bản hiển thị trên nút.
  final String label;

  /// Hàm gọi lại khi người dùng bấm nút (vô hiệu hóa nếu null hoặc đang tải).
  final VoidCallback? onPressed;

  /// Cho biết nút có đang trong trạng thái tải tiến trình hay không.
  final bool isLoading;

  /// Biểu tượng tùy chọn hiển thị trước nhãn văn bản.
  final IconData? icon;

  /// Màu nền tùy chỉnh của nút (mặc định lấy theo [AppTheme.primary]).
  final Color? backgroundColor;

  /// Màu chữ và biểu tượng tùy chỉnh (mặc định lấy theo [AppTheme.onPrimary]).
  final Color? foregroundColor;

  /// Khởi tạo [AppPrimaryButton] với nhãn [label] và các thuộc tính tương tác.
  const AppPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
  });

  /// Xây dựng giao diện nút bấm chính.
  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? AppTheme.primary;
    final fg = foregroundColor ?? AppTheme.onPrimary;

    return Semantics(
      button: true,
      enabled: onPressed != null && !isLoading,
      label: label,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          disabledBackgroundColor: AppTheme.surfaceContainer,
          disabledForegroundColor: AppTheme.textSubtle,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          minimumSize: const Size(double.infinity, AppTheme.minTouchTarget),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusButton),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(fg),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Nút bấm dạng đường viền (Outlined Action Button) cho các tác vụ phụ hoặc điều hướng thứ cấp.
class AppOutlinedButton extends StatelessWidget {
  /// Nhãn văn bản hiển thị trên nút.
  final String label;

  /// Hàm gọi lại khi bấm nút.
  final VoidCallback? onPressed;

  /// Biểu tượng tùy chọn hiển thị trước nhãn.
  final IconData? icon;

  /// Widget tùy biến hiển thị phía trước thay cho [icon] (ví dụ: Google logo).
  final Widget? leadingWidget;

  /// Cho biết nút có đang trong trạng thái xử lý tiến trình hay không.
  final bool isLoading;

  /// Màu đường viền tùy chỉnh.
  final Color? borderColor;

  /// Màu chữ tùy chỉnh.
  final Color? textColor;

  /// Khởi tạo [AppOutlinedButton] với nhãn [label] và các tham số cấu hình.
  const AppOutlinedButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.leadingWidget,
    this.isLoading = false,
    this.borderColor,
    this.textColor,
  });

  /// Xây dựng giao diện nút viền phụ.
  @override
  Widget build(BuildContext context) {
    final border = borderColor ?? AppTheme.outline;
    final text = textColor ?? AppTheme.onSurface;

    return Semantics(
      button: true,
      enabled: onPressed != null && !isLoading,
      label: label,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: text,
          backgroundColor: Colors.transparent,
          disabledForegroundColor: AppTheme.textSubtle,
          elevation: 0,
          side: BorderSide(color: border, width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          minimumSize: const Size(double.infinity, AppTheme.minTouchTarget),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusButton),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(text),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (leadingWidget != null) ...[
                    leadingWidget!,
                    const SizedBox(width: 10),
                  ] else if (icon != null) ...[
                    Icon(icon, size: 18, color: text),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                        color: text,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
