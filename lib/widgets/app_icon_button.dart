import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Design System Accessible Icon Button
/// Enforces minimum 48x48dp bounding box for touch accessibility (WCAG 2.1 AA SC 2.5.5).
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;
  final Color? color;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    required this.tooltip,
    this.color,
  });

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
