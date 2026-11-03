import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// FPTU Student Activity Score Badge
class ActivityPointsBadge extends StatelessWidget {
  final int points;

  const ActivityPointsBadge({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppTheme.radiusChip),
        border: Border.all(color: AppTheme.primaryContainer.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.stars_rounded, size: 16, color: AppTheme.primary),
          const SizedBox(width: 6),
          Text(
            '+$points Điểm Rèn Luyện',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
