import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Interactive Star Rating Bar
class StarRatingBar extends StatelessWidget {
  final int rating;
  final ValueChanged<int> onRatingChanged;
  final double starSize;

  const StarRatingBar({
    super.key,
    required this.rating,
    required this.onRatingChanged,
    this.starSize = 40.0,
  });

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
