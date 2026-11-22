import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const purple = Color(0xFF6558D3);
  static const purpleLight = Color(0xFFA99CF0);
  static const bg = Color(0xFFEEF0FA);
  static const surface = Color(0xFFEEF0FA);
  static const inset = Color(0xFFE6E8F6);
  static const text = Color(0xFF24213D);
  static const muted = Color(0xFF85839B);
  static const shadowDark = Color(0xFFCBCEE4);
  static const danger = Color(0xFFD64545);
}

class CategoryStyle {
  final Color fg;
  final Color bg;
  const CategoryStyle(this.fg, this.bg);

  static const _styles = {
    'purple': CategoryStyle(Color(0xFF9380CE), Color(0xFFEAE5F8)),
    'blue': CategoryStyle(Color(0xFF799CC8), Color(0xFFE6EDF8)),
    'orange': CategoryStyle(Color(0xFFCDA16F), Color(0xFFF8EDDF)),
    'green': CategoryStyle(Color(0xFF65AD91), Color(0xFFE2F1EB)),
  };

  static CategoryStyle of(String color) => _styles[color] ?? _styles['purple']!;

  /// Category -> colour name stored with each task.
  static String colorFor(String category) {
    switch (category) {
      case 'Health':
        return 'green';
      case 'Personal':
        return 'orange';
      case 'Work':
      default:
        return 'purple';
    }
  }
}

List<BoxShadow> softShadow([double d = 1]) => [
      BoxShadow(
          color: AppColors.shadowDark,
          offset: Offset(8 * d, 8 * d),
          blurRadius: 20 * d),
      BoxShadow(
          color: Colors.white, offset: Offset(-8 * d, -8 * d), blurRadius: 20 * d),
    ];

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.purple,
      primary: AppColors.purple,
      surface: AppColors.surface,
    ),
    scaffoldBackgroundColor: AppColors.bg,
  );
  final body = GoogleFonts.dmSansTextTheme(base.textTheme)
      .apply(bodyColor: AppColors.text, displayColor: AppColors.text);
  final heading = GoogleFonts.manropeTextTheme(base.textTheme)
      .apply(bodyColor: AppColors.text, displayColor: AppColors.text);

  OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: c, width: w),
      );

  return base.copyWith(
    textTheme: body.copyWith(
      headlineLarge: heading.headlineLarge?.copyWith(fontWeight: FontWeight.w800),
      headlineMedium: heading.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
      headlineSmall: heading.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
      titleLarge: heading.titleLarge?.copyWith(fontWeight: FontWeight.w800),
      titleMedium: heading.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: AppColors.text,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.inset,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: border(Colors.transparent),
      enabledBorder: border(const Color(0xFFDADDF0)),
      focusedBorder: border(AppColors.purple, 1.6),
      errorBorder: border(AppColors.danger),
      focusedErrorBorder: border(AppColors.danger, 1.6),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      indicatorColor: const Color(0xFFE4E0FA),
      labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.text,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}
