import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Thanh đánh giá tương tác bằng hệ thống xếp hạng 5 sao.
///
/// Hỗ trợ chấm điểm từ 1 đến 5 sao với khả năng truy cập ngữ nghĩa (Semantics) cho trợ năng màn hình.
class StarRatingBar extends StatelessWidget {
  /// Số sao hiện tại đang được chọn (từ 1 đến 5).
  final int rating;

  /// Callback được gọi khi người dùng bấm chọn số sao mới.
  final ValueChanged<int> onRatingChanged;

  /// Kích thước hiển thị của từng ngôi sao (mặc định 40.0 dp).
  final double starSize;

  /// Khởi tạo [StarRatingBar] với giá trị đánh giá [rating] và hàm gọi lại [onRatingChanged].
  const StarRatingBar({
    super.key,
    required this.rating,
    required this.onRatingChanged,
    this.starSize = 40.0,
  });

  /// Xây dựng hàng biểu tượng ngôi sao tương tác.
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        final isFilled = starIndex <= rating;

        return Semantics(
          button: true,
          label: '$starIndex sao',
          child: InkWell(
            onTap: () => onRatingChanged(starIndex),
            borderRadius: BorderRadius.circular(30),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Icon(
                isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                size: starSize,
                color: isFilled ? AppTheme.warning : AppTheme.outlineVariant,
              ),
            ),
          ),
        );
      }),
    );
  }
}
