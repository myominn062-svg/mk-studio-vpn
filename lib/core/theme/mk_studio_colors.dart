import 'package:flutter/material.dart';

/// MK Studio VPN brand palette — lime → deep teal, clean light surfaces.
abstract final class MkStudioColors {
  static const lime = Color(0xFFA3E635);
  static const limeDeep = Color(0xFF84CC16);
  static const teal = Color(0xFF0D9488);
  static const tealDeep = Color(0xFF0F766E);
  static const ocean = Color(0xFF0891B2);
  static const ink = Color(0xFF0F172A);
  static const muted = Color(0xFF64748B);
  static const surface = Color(0xFFF8FAFC);
  static const surfaceElevated = Color(0xFFFFFFFF);
  static const softTealWash = Color(0xFFE6F7F4);
  static const softLimeWash = Color(0xFFF3FCE8);

  static const brandGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [lime, teal, tealDeep],
    stops: [0.0, 0.55, 1.0],
  );

  static const brandGradientHorizontal = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [tealDeep, teal, limeDeep],
  );

  static const heroBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFFFFF),
      softLimeWash,
      softTealWash,
      Color(0xFFFFFFFF),
    ],
    stops: [0.0, 0.28, 0.62, 1.0],
  );

  static ColorScheme lightScheme() {
    return ColorScheme.fromSeed(
      seedColor: teal,
      brightness: Brightness.light,
      primary: tealDeep,
      onPrimary: Colors.white,
      secondary: limeDeep,
      onSecondary: ink,
      tertiary: ocean,
      surface: surfaceElevated,
      onSurface: ink,
      surfaceContainerLowest: surface,
      surfaceContainerLow: const Color(0xFFF1F5F9),
      surfaceContainer: const Color(0xFFEEF6F4),
      surfaceContainerHigh: const Color(0xFFE2F0ED),
      outline: const Color(0xFFCBD5E1),
      error: const Color(0xFFDC2626),
    );
  }

  static ColorScheme darkScheme() {
    return ColorScheme.fromSeed(
      seedColor: teal,
      brightness: Brightness.dark,
      primary: lime,
      onPrimary: ink,
      secondary: teal,
      tertiary: ocean,
      surface: const Color(0xFF0B1220),
      onSurface: const Color(0xFFF1F5F9),
      surfaceContainer: const Color(0xFF152033),
      outline: const Color(0xFF334155),
    );
  }
}
