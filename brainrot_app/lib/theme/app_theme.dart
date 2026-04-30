import 'package:flutter/material.dart';

/// Centralized Apple-inspired theme for Dopamine Tax.
///
/// Design pillars:
/// - True Black / Clean White backgrounds
/// - Single vibrant blue accent (#007AFF — iOS system blue)
/// - Zero Material drop-shadows; optional soft Cupertino-style BoxShadow
/// - Platform-native typography (SF Pro on iOS, Roboto on Android)
class AppTheme {
  AppTheme._();

  // ── Core palette ──────────────────────────────────────────────────────────
  static const Color _accentBlue = Color(0xFF1D4ED8); // Vibrant Neon Blue
  static const Color _appBackground = Color(0xFF0D0D16); // Deep midnight blue
  // ignore: unused_field
  static const Color _neonGreen = Color(0xFF39FF14);
  static const Color _pureWhite = Color(0xFFFFFFFF);
  static const Color _pureBlack = Color(0xFF000000);
  static const Color _grey100 = Color(0xFFF5F5F7);
  static const Color _grey200 = Color(0xFFE8E8ED);
  static const Color _grey400 = Color(0xFFAEAEB2);
  static const Color _grey600 = Color(0xFF636366);
  static const Color _grey800 = Color(0xFF1C1C1E);

  // ── Cupertino-style soft shadow ───────────────────────────────────────────
  static List<BoxShadow> get subtleShadow => [
    BoxShadow(
      color: _pureBlack.withValues(alpha: 0.06),
      blurRadius: 24,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get subtleShadowDark => [
    BoxShadow(
      color: _pureBlack.withValues(alpha: 0.30),
      blurRadius: 24,
      offset: const Offset(0, 4),
    ),
  ];

  // ── Light Theme ───────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: _pureWhite,
      colorScheme: const ColorScheme.light(
        primary: _accentBlue,
        onPrimary: _pureWhite,
        secondary: _accentBlue,
        onSecondary: _pureWhite,
        surface: _pureWhite,
        onSurface: _pureBlack,
        error: Color(0xFFFF3B30),
        onError: _pureWhite,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: _pureWhite,
        foregroundColor: _pureBlack,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: _pureBlack,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: _grey100,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: _accentBlue,
          foregroundColor: _pureWhite,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _accentBlue,
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.2,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: _accentBlue),
      ),
      dividerTheme: const DividerThemeData(
        color: _grey200,
        thickness: 0.5,
        space: 0,
      ),
      textTheme: _buildTextTheme(Brightness.light),
    );
  }

  // ── Dark Theme ────────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _appBackground,
      colorScheme: const ColorScheme.dark(
        primary: _accentBlue,
        onPrimary: _pureWhite,
        secondary: _accentBlue,
        onSecondary: _pureWhite,
        surface: _grey800,
        onSurface: _pureWhite,
        error: Color(0xFFFF453A),
        onError: _pureWhite,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: _pureWhite,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: _pureWhite,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: _grey800,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: _accentBlue,
          foregroundColor: _pureWhite,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _accentBlue,
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.2,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: _accentBlue),
      ),
      dividerTheme: const DividerThemeData(
        color: _grey800,
        thickness: 0.5,
        space: 0,
      ),
      textTheme: _buildTextTheme(Brightness.dark),
    );
  }

  // ── Typography ────────────────────────────────────────────────────────────
  static TextTheme _buildTextTheme(Brightness brightness) {
    final Color primary = brightness == Brightness.light
        ? _pureBlack
        : _pureWhite;
    final Color secondary = brightness == Brightness.light
        ? _grey600
        : _grey400;

    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.0,
        color: primary,
        height: 1.15,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
        color: primary,
        height: 1.2,
      ),
      headlineSmall: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        color: primary,
        height: 1.25,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.4,
        color: primary,
      ),
      titleMedium: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: primary,
      ),
      bodyLarge: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.2,
        color: primary,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.1,
        color: secondary,
        height: 1.5,
      ),
      labelLarge: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        color: primary,
      ),
    );
  }
}
