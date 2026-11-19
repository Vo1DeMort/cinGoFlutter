import 'package:flutter/material.dart';

/// Obsidian Cinema palette — the single source of truth for CineGo colours.
abstract final class AppColors {
  static const surface = Color(0xFF0F131C);
  static const surfaceDim = Color(0xFF0F131C);
  static const surfaceLowest = Color(0xFF0A0E17);
  static const surfaceLow = Color(0xFF181B25);
  static const surfaceContainer = Color(0xFF1C1F29);
  static const surfaceHigh = Color(0xFF262A34);
  static const surfaceHighest = Color(0xFF31353F);

  static const onSurface = Color(0xFFDFE2EF);
  static const onSurfaceVariant = Color(0xFFC2C6D6);
  static const outline = Color(0xFF8C909F);
  static const outlineVariant = Color(0xFF424754);

  static const primary = Color(0xFFADC6FF);
  static const onPrimary = Color(0xFF002E6A);
  static const primaryContainer = Color(0xFF4D8EFF);
  static const inversePrimary = Color(0xFF005AC2);

  static const secondary = Color(0xFFC0C1FF);
  static const secondaryContainer = Color(0xFF3131C0);
  static const onSecondaryContainer = Color(0xFFB0B2FF);

  static const tertiary = Color(0xFF47D6FF);
  static const onTertiary = Color(0xFF003543);
  static const tertiaryContainer = Color(0xFF009EC0);

  static const error = Color(0xFFFFB4AB);
  static const errorContainer = Color(0xFF93000A);

  static const amber = Color(0xFFF59E0B);
  static const success = Color(0xFF4ADE80);
  static const tomato = Color(0xFFFA320A);

  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF94A3B8);

  static const white10 = Color(0x1AFFFFFF);
  static const white12 = Color(0x1FFFFFFF);
  static const white06 = Color(0x0FFFFFFF);
  static const white24 = Color(0x3DFFFFFF);

  static const filmGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3B82F6), Color(0xFF6366F1)],
  );

  static const electricGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4D8EFF), Color(0xFF6366F1), Color(0xFF00D2FF)],
  );

  static const cyanGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4D8EFF), Color(0xFF00D2FF)],
  );

  static const heroScrim = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x000A0E17),
      Color(0x400A0E17),
      Color(0xE60A0E17),
      Color(0xFF0A0E17),
    ],
    stops: [0.0, 0.45, 0.78, 1.0],
  );
}
