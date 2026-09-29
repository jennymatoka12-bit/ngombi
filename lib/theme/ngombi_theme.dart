import 'package:flutter/material.dart';

import 'ngombi_colors.dart';
import 'ngombi_typography.dart';

class NgombiTheme {
  NgombiTheme._();

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: NgombiColors.orange,
      brightness: Brightness.dark,
    ).copyWith(
      primary: NgombiColors.orange,
      secondary: NgombiColors.gold,
      surface: NgombiColors.surface,
      error: NgombiColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      fontFamily: NgombiTypography.fontFamily,

      scaffoldBackgroundColor: NgombiColors.background,

      colorScheme: colorScheme,

      appBarTheme: const AppBarTheme(
        backgroundColor: NgombiColors.background,
        foregroundColor: NgombiColors.textPrimary,
        elevation: 0,
        centerTitle: false,
      ),

      cardTheme: CardTheme(
        color: NgombiColors.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(
            color: NgombiColors.border,
          ),
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: NgombiColors.surface,
        indicatorColor: NgombiColors.orange.withOpacity(0.20),
        labelTextStyle:
            const WidgetStatePropertyAll<TextStyle>(
          NgombiTypography.label,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: NgombiColors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: NgombiColors.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: NgombiColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: NgombiColors.orange,
            width: 1.5,
          ),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: NgombiColors.orange,
          foregroundColor: Colors.black,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: 22,
            vertical: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: NgombiTypography.subtitle,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: NgombiColors.orange,
          textStyle: NgombiTypography.body.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
