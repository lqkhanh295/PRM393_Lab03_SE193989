import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Huy hiệu hiển thị điểm rèn luyện sinh viên FPTU tích lũy được từ sự kiện.
///
/// Thiết kế chuẩn học thuật với độ tương phản cao, số liệu dạng tabular và biểu tượng tia sét.
class ActivityPointsBadge extends StatelessWidget {
  /// Số điểm rèn luyện được cộng (ví dụ: `+5`).
  final int points;

  /// Khởi tạo [ActivityPointsBadge] với số điểm [points].
  const ActivityPointsBadge({super.key, required this.points});

  /// Xây dựng giao diện huy hiệu điểm rèn luyện.
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppTheme.radiusBadge),
        border: Border.all(color: AppTheme.hairline, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bolt_rounded, size: 15, color: AppTheme.primary),
          const SizedBox(width: 4),
          Text(
            '+$points Điểm Rèn Luyện',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
              color: AppTheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
