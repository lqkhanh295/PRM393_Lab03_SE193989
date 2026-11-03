import 'package:flutter/material.dart';

/// Design Tokens & Theme Specification for Campus Event App
/// Built following Anti-Slop Frontend Architecture (tasteskill v2 - Accent Ladder).
/// Identity: FPT University Collegiate Tech & Event Companion.
class AppTheme {
  // Brand & Semantic Colors
  static const Color primary = Color(0xFFC2410C); // FPT Vermilion (bold accent)
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFFFF7ED); // Warm amber tint
  static const Color onPrimaryContainer = Color(0xFF9A3412);

  static const Color secondary = Color(0xFF0F172A); // Deep Slate Navy (commanding ink)
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFF1F5F9);
  static const Color onSecondaryContainer = Color(0xFF334155);

  static const Color background = Color(0xFFF8FAFC); // Slate 50 (airy, clean ground)
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceContainer = Color(0xFFF1F5F9); // Slate 100
  static const Color surfaceElevated = Color(0xFFFFFFFF);

  static const Color onSurface = Color(0xFF0F172A); // Obsidian black ink
  static const Color onSurfaceVariant = Color(0xFF475569); // Slate 600
  static const Color textMuted = Color(0xFF64748B); // Slate 500
  static const Color textSubtle = Color(0xFF94A3B8); // Slate 400

  static const Color outline = Color(0xFFCBD5E1); // Slate 300
  static const Color outlineVariant = Color(0xFFE2E8F0); // Slate 200 (hairline rule)
  static const Color divider = Color(0xFFF1F5F9);

  static const Color obsidian = Color(0xFF0F172A); // Deep Obsidian Slate
  static const Color hairline = Color(0xFFE2E8F0); // 1px Hairline Slate Border
  static const Color surfaceSubtle = Color(0xFFF1F5F9); // Slate 100 Subtle Fill
  static const Color errorBorder = Color(0xFFFECACA); // Crimson hairline
  static const Color successBorder = Color(0xFFBBF7D0); // Emerald hairline

  // Semantic Feedback States
  static const Color success = Color(0xFF15803D); // Emerald 700
  static const Color successSoft = Color(0xFFDCFCE7);
  static const Color successInk = Color(0xFF14532D);

  static const Color error = Color(0xFFB91C1C); // Crimson 700
  static const Color errorSoft = Color(0xFFFEE2E2);
  static const Color errorInk = Color(0xFF7F1D1D);

  static const Color warning = Color(0xFFB45309); // Amber 700
  static const Color warningSoft = Color(0xFFFEF3C7);
  static const Color warningInk = Color(0xFF78350F);

  static const Color info = Color(0xFF2563EB); // Royal Blue
  static const Color infoSoft = Color(0xFFDBEAFE);

  // Spacing System (8pt Grid with 4pt half-steps)
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;

  static const double spacingScreenPadding = 20.0;
  static const double spacingCardPadding = 16.0;
  static const double spacingSectionGap = 24.0;
  static const double spacingItemGap = 12.0;

  // Curated Corner Radii (Structured, deliberate, anti-bloat)
  static const double radiusButton = 10.0;
  static const double radiusInput = 8.0;
  static const double radiusCard = 12.0;
  static const double radiusSheet = 20.0;
  static const double radiusChip = 8.0;
  static const double radiusBadge = 6.0;

  // Min Tap Target Dimension (WCAG 2.1 AA)
  static const double minTouchTarget = 48.0;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: primary,
        onPrimary: onPrimary,
        primaryContainer: primaryContainer,
        onPrimaryContainer: onPrimaryContainer,
        secondary: secondary,
        onSecondary: onSecondary,
        secondaryContainer: secondaryContainer,
        onSecondaryContainer: onSecondaryContainer,
        surface: surface,
        onSurface: onSurface,
        onSurfaceVariant: onSurfaceVariant,
        outline: outline,
        outlineVariant: outlineVariant,
        error: error,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: background,
      dividerTheme: const DividerThemeData(
        color: outlineVariant,
        thickness: 1,
        space: 1,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.8,
          height: 1.2,
          color: onSurface,
        ),
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          height: 1.25,
          color: onSurface,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          height: 1.3,
          color: onSurface,
        ),
        titleLarge: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
          height: 1.35,
          color: onSurface,
        ),
        titleMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
          height: 1.4,
          color: onSurface,
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          height: 1.5,
          color: onSurface,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.45,
          color: onSurfaceVariant,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 1.4,
          color: textMuted,
        ),
        labelLarge: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          color: onSurface,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
          color: onSurfaceVariant,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
          color: textMuted,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size(double.infinity, minTouchTarget),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusButton),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: onSurface,
          backgroundColor: Colors.transparent,
          elevation: 0,
          side: const BorderSide(color: outline, width: 1.2),
          minimumSize: const Size(double.infinity, minTouchTarget),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusButton),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
          side: const BorderSide(color: outlineVariant, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusButton),
          borderSide: const BorderSide(color: outlineVariant, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusButton),
          borderSide: const BorderSide(color: outlineVariant, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusButton),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusButton),
          borderSide: const BorderSide(color: error, width: 1),
        ),
        hintStyle: const TextStyle(
          color: textSubtle,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 64,
        indicatorColor: primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: onPrimaryContainer,
              letterSpacing: -0.1,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textMuted,
            letterSpacing: -0.1,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primary, size: 22);
          }
          return const IconThemeData(color: textMuted, size: 22);
        }),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
          color: onSurface,
        ),
        iconTheme: IconThemeData(color: onSurface, size: 22),
      ),
    );
  }
}
