import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Chip lọc danh mục sự kiện trong thanh lọc ngang.
///
/// Định dạng hình con nhộng bo tròn (stadium shape) với phản hồi xúc giác và khả năng tiếp cận ngữ nghĩa.
class AppFilterChip extends StatelessWidget {
  /// Tên nhãn danh mục (ví dụ: `Tất cả`, `Technology`, `Sports`).
  final String label;

  /// Trạng thái danh mục hiện tại có đang được chọn hay không.
  final bool isSelected;

  /// Hàm gọi lại khi trạng thái lựa chọn thay đổi.
  final ValueChanged<bool> onSelected;

  /// Khởi tạo [AppFilterChip] với nhãn [label], trạng thái [isSelected] và hàm [onSelected].
  const AppFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  /// Xây dựng giao diện chip lọc danh mục.
  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: 'Lọc $label',
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: onSelected,
        backgroundColor: Colors.white,
        selectedColor: AppTheme.primaryContainer,
        labelStyle: TextStyle(
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected ? Colors.white : AppTheme.onSurface,
        ),
        shape: const StadiumBorder(
          side: BorderSide(color: AppTheme.outlineVariant, width: 1),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        showCheckmark: false,
      ),
    );
  }
}
