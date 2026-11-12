import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Ô nhập liệu văn bản chuẩn của hệ thống Campus Event.
///
/// Độ tương phản cao khi focus, đường viền sắc nét, hỗ trợ nhãn, gợi ý mờ,
/// biểu tượng đầu/cuối ô và bộ kiểm tra tính hợp lệ [validator].
class AppTextField extends StatelessWidget {
  /// Bộ điều khiển trường nhập liệu [TextEditingController].
  final TextEditingController? controller;

  /// Nhãn hiển thị của trường nhập liệu.
  final String label;

  /// Văn bản gợi ý mờ khi ô nhập còn trống.
  final String? hintText;

  /// Biểu tượng hiển thị ở đầu trường nhập.
  final IconData? prefixIcon;

  /// Widget hiển thị ở cuối trường nhập (ví dụ: nút ẩn/hiện mật khẩu).
  final Widget? suffixIcon;

  /// Ẩn nội dung văn bản nhập (sử dụng cho mật khẩu).
  final bool obscureText;

  /// Hàm kiểm tra tính hợp lệ của dữ liệu nhập.
  final String? Function(String?)? validator;

  /// Hàm gọi lại khi nội dung văn bản thay đổi.
  final ValueChanged<String>? onChanged;

  /// Kiểu bàn phím hiển thị trên thiết bị di động.
  final TextInputType? keyboardType;

  /// Khởi tạo [AppTextField] với nhãn [label] và các cấu hình nhập liệu.
  const AppTextField({
    super.key,
    this.controller,
    required this.label,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.validator,
    this.onChanged,
    this.keyboardType,
  });

  /// Xây dựng trường nhập liệu [TextFormField].
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      onChanged: onChanged,
      keyboardType: keyboardType,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppTheme.onSurface,
        height: 1.4,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppTheme.textMuted,
        ),
        hintText: hintText,
        hintStyle: const TextStyle(
          fontSize: 14,
          color: AppTheme.textSubtle,
        ),
        filled: true,
        fillColor: AppTheme.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20, color: AppTheme.textMuted) : null,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusButton),
          borderSide: const BorderSide(color: AppTheme.outlineVariant, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusButton),
          borderSide: const BorderSide(color: AppTheme.outlineVariant, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusButton),
          borderSide: const BorderSide(color: AppTheme.secondary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusButton),
          borderSide: const BorderSide(color: AppTheme.error, width: 1.2),
        ),
      ),
    );
  }
}
