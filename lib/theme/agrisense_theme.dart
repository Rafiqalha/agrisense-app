import 'package:flutter/material.dart';

abstract final class AgriColors {
  static const ink = Color(0xFF20201E);
  static const muted = Color(0xFF6F706B);
  static const canvas = Color(0xFFF7F7F5);
  static const surface = Color(0xFFFFFFFF);
  static const line = Color(0xFFE8E8E4);
  static const green = Color(0xFF1F6B46);
  static const darkGreen = Color(0xFF174F35);
  static const softGreen = Color(0xFFEAF3EC);
  static const lime = Color(0xFFB8D97A);
  static const amber = Color(0xFFB86A17);
  static const softAmber = Color(0xFFFFF3DE);
  static const blue = Color(0xFF2F6FA3);
  static const softBlue = Color(0xFFEAF2F8);
  static const red = Color(0xFFA94343);
  static const softRed = Color(0xFFFBEDED);
}

abstract final class AgriSenseTheme {
  static ThemeData get light {
    const scheme = ColorScheme.light(
      primary: AgriColors.green,
      onPrimary: Colors.white,
      secondary: AgriColors.lime,
      onSecondary: AgriColors.ink,
      surface: AgriColors.surface,
      onSurface: AgriColors.ink,
      error: AgriColors.red,
      outline: AgriColors.line,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AgriColors.canvas,
      splashFactory: InkSparkle.splashFactory,
      textTheme: const TextTheme(
        displaySmall: TextStyle(
          fontSize: 34,
          height: 1.08,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.1,
          color: AgriColors.ink,
        ),
        headlineLarge: TextStyle(
          fontSize: 28,
          height: 1.15,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.7,
          color: AgriColors.ink,
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          height: 1.2,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.35,
          color: AgriColors.ink,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          height: 1.3,
          fontWeight: FontWeight.w700,
          color: AgriColors.ink,
        ),
        titleMedium: TextStyle(
          fontSize: 15,
          height: 1.35,
          fontWeight: FontWeight.w600,
          color: AgriColors.ink,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          height: 1.5,
          fontWeight: FontWeight.w400,
          color: AgriColors.ink,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          height: 1.45,
          color: AgriColors.muted,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          height: 1.4,
          color: AgriColors.muted,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AgriColors.ink,
        ),
      ),
      cardTheme: const CardThemeData(
        color: AgriColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
          side: BorderSide(color: AgriColors.line),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AgriColors.line,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: AgriColors.surface,
        hintStyle: TextStyle(color: Color(0xFF9B9C97)),
        prefixIconColor: AgriColors.muted,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: AgriColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: AgriColors.green, width: 1.5),
        ),
      ),
      chipTheme: const ChipThemeData(
        backgroundColor: AgriColors.surface,
        selectedColor: AgriColors.softGreen,
        side: BorderSide(color: AgriColors.line),
        shape: StadiumBorder(),
        labelStyle: TextStyle(
          color: AgriColors.ink,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        elevation: 0,
        backgroundColor: AgriColors.surface,
        indicatorColor: AgriColors.softGreen,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            color: states.contains(WidgetState.selected)
                ? AgriColors.green
                : AgriColors.muted,
            fontSize: 11,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 22,
            color: states.contains(WidgetState.selected)
                ? AgriColors.green
                : AgriColors.muted,
          ),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AgriColors.ink,
        contentTextStyle: TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }
}
