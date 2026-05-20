/// VoiceLedger Material 3 Theme
/// 直接从 design_tokens.dart 映射到 ThemeData
///
/// 用法：
///   MaterialApp(
///     theme: AppTheme.light,
///     darkTheme: AppTheme.dark,
///     themeMode: settingsProvider.themeMode,
///   )

import 'package:flutter/material.dart';
import 'design_tokens.dart';

class AppTheme {
  AppTheme._();

  // ── Light Theme ───────────────────────────────────

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.accent,
      brightness: Brightness.light,
      primary: AppColors.accent,
      onPrimary: Colors.white,
      surface: AppColors.surface,
      onSurface: AppColors.fg,
      onSurfaceVariant: AppColors.muted,
      outline: AppColors.border,
      error: AppColors.danger,
    ),

    // ── AppBar ──
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.fg,
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: AppText.displaySm,
        fontWeight: FontWeight.w600,
        color: AppColors.fg,
        letterSpacing: -0.02,
      ),
    ),

    // ── Text Theme ──
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'displayFont',
        fontSize: AppText.displayLg,
        fontWeight: FontWeight.w700,
        color: AppColors.fg,
        letterSpacing: -0.02,
        height: 1.1,
      ),
      displayMedium: TextStyle(
        fontFamily: 'displayFont',
        fontSize: AppText.displayMd,
        fontWeight: FontWeight.w700,
        color: AppColors.fg,
        letterSpacing: -0.02,
        height: 1.2,
      ),
      displaySmall: TextStyle(
        fontFamily: 'displayFont',
        fontSize: AppText.displaySm,
        fontWeight: FontWeight.w600,
        color: AppColors.fg,
        letterSpacing: -0.02,
        height: 1.3,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'bodyFont',
        fontSize: AppText.bodyLg,
        fontWeight: FontWeight.w500,
        color: AppColors.fg,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'bodyFont',
        fontSize: AppText.bodyMd,
        fontWeight: FontWeight.w500,
        color: AppColors.fg,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontFamily: 'bodyFont',
        fontSize: AppText.bodySm,
        fontWeight: FontWeight.w400,
        color: AppColors.muted,
        height: 1.5,
      ),
      labelLarge: TextStyle(
        fontFamily: 'bodyFont',
        fontSize: AppText.bodyMd,
        fontWeight: FontWeight.w600,
        color: AppColors.fg,
      ),
      labelSmall: TextStyle(
        fontFamily: 'bodyFont',
        fontSize: AppText.label,
        fontWeight: FontWeight.w500,
        color: AppColors.muted,
        letterSpacing: 0.04,
      ),
    ),

    // ── Card ──
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.mdAll,
        side: const BorderSide(color: AppColors.border),
      ),
    ),

    // ── Input ──
    inputDecorationTheme: InputDecorationTheme(
      filled: false,
      border: OutlineInputBorder(
        borderRadius: AppRadius.mdAll,
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.mdAll,
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.mdAll,
        borderSide: const BorderSide(color: AppColors.accent, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppRadius.mdAll,
        borderSide: const BorderSide(color: AppColors.danger),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 4,
      ),
    ),

    // ── Elevated Button ──
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md - 2,
        ),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
        textStyle: const TextStyle(
          fontSize: AppText.bodyLg,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // ── Outlined Button ──
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.fg,
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
      ),
    ),

    // ── Switch ──
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.accent;
        return AppColors.muted;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.accent.withOpacity(0.4);
        }
        return AppColors.border;
      }),
    ),

    // ── Dialog ──
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
    ),

    // ── SnackBar ──
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.fg,
      contentTextStyle: const TextStyle(
        color: AppColors.surface,
        fontSize: AppText.bodySm,
      ),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
      behavior: SnackBarBehavior.floating,
    ),

    // ── Bottom Sheet ──
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
    ),

    // ── Divider ──
    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 1,
      space: 0,
    ),
  );

  // ── Dark Theme ────────────────────────────────────

  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF121317),
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.accent,
      brightness: Brightness.dark,
      primary: AppColors.accent,
      onPrimary: Colors.white,
      surface: const Color(0xFF1C1E25),
      onSurface: const Color(0xFFE8EAEF),
      onSurfaceVariant: const Color(0xFF9298A4),
      outline: const Color(0xFF2E3139),
      error: const Color(0xFFE06060),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1C1E25),
      foregroundColor: Color(0xFFE8EAEF),
      elevation: 0,
    ),
  );
}