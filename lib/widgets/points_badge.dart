import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// FPTU Student Activity Score Badge
/// Anti-Slop Architecture: High-contrast, tabular figures, collegiate badge style.
class ActivityPointsBadge extends StatelessWidget {
  final int points;

  const ActivityPointsBadge({super.key, required this.points});

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
