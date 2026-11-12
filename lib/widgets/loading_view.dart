import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Giao diện hiển thị trạng thái đang tải dữ liệu đồng nhất toàn hệ thống.
///
/// Thể hiện vòng xoay tiến trình [CircularProgressIndicator] kèm thông điệp giải thích tiến độ [message].
class LoadingView extends StatelessWidget {
  /// Thông điệp mô tả nội dung đang tải.
  final String? message;

  /// Khởi tạo [LoadingView] với thông điệp tùy chọn [message].
  const LoadingView({super.key, this.message});

  /// Xây dựng khung hiển thị trạng thái đang tải.
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingScreenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message ?? 'Đang tải dữ liệu...',
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.1,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
