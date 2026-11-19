import 'package:material_ui/material_ui.dart';

import 'app_colors.dart';

/// Typography scale from the Obsidian Cinema design system.
abstract final class AppText {
  static const displayHero = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 36,
    fontWeight: FontWeight.w800,
    height: 44 / 36,
    letterSpacing: -1.08,
  );

  static const displayHeroMobile = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 28,
    fontWeight: FontWeight.w800,
    height: 34 / 28,
    letterSpacing: -0.56,
  );

  static const headlineLarge = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 32 / 24,
    letterSpacing: -0.48,
  );

  static const headlineMedium = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 28 / 20,
    letterSpacing: -0.2,
  );

  static const headlineSmall = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 24 / 18,
    letterSpacing: -0.2,
  );

  static const bodyLarge = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
  );

  static const bodyMedium = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
  );

  static const bodySmall = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 16 / 12,
  );

  static const labelCaps = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 10,
    fontWeight: FontWeight.w700,
    height: 12 / 10,
    letterSpacing: 0.8,
  );

  static const labelFormat = TextStyle(
    fontFamily: 'JetBrainsMono',
    fontSize: 11,
    fontWeight: FontWeight.w700,
    height: 14 / 11,
    letterSpacing: 0.66,
  );

  static const ticketCode = TextStyle(
    fontFamily: 'JetBrainsMono',
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 20 / 15,
    letterSpacing: 1.5,
  );

  static const monoSmall = TextStyle(
    fontFamily: 'JetBrainsMono',
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 16 / 11,
    letterSpacing: 0.3,
  );

  static const monoMedium = TextStyle(
    fontFamily: 'JetBrainsMono',
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 18 / 13,
    letterSpacing: 0.2,
  );

  static const monoBold = TextStyle(
    fontFamily: 'JetBrainsMono',
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 20 / 14,
    letterSpacing: 0.4,
  );
}

ThemeData buildCineGoTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'PlusJakartaSans',
    scaffoldBackgroundColor: AppColors.surface,
    canvasColor: AppColors.surface,
    colorScheme: const ColorScheme.dark(
      surface: AppColors.surface,
      surfaceContainerLowest: AppColors.surfaceLowest,
      surfaceContainerLow: AppColors.surfaceLow,
      surfaceContainer: AppColors.surfaceContainer,
      surfaceContainerHigh: AppColors.surfaceHigh,
      surfaceContainerHighest: AppColors.surfaceHighest,
      primary: AppColors.primaryContainer,
      onPrimary: Colors.white,
      secondary: AppColors.secondary,
      tertiary: AppColors.tertiary,
      error: AppColors.error,
      onSurface: AppColors.onSurface,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
    ),
  );

  return base.copyWith(
    textTheme: const TextTheme(
      displayLarge: AppText.displayHero,
      displayMedium: AppText.displayHeroMobile,
      displaySmall: AppText.headlineLarge,
      headlineLarge: AppText.headlineLarge,
      headlineMedium: AppText.headlineMedium,
      headlineSmall: AppText.headlineSmall,
      titleLarge: AppText.headlineSmall,
      titleMedium: AppText.bodyLarge,
      bodyLarge: AppText.bodyLarge,
      bodyMedium: AppText.bodyMedium,
      bodySmall: AppText.bodySmall,
      labelLarge: AppText.labelCaps,
      labelMedium: AppText.labelCaps,
      labelSmall: AppText.labelCaps,
    ).apply(bodyColor: AppColors.onSurface, displayColor: AppColors.onSurface),
    dividerColor: AppColors.white10,
    splashColor: AppColors.white06,
    highlightColor: AppColors.white06,
    iconTheme: const IconThemeData(color: AppColors.onSurface, size: 20),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.surfaceHigh,
      contentTextStyle: AppText.bodySmall.copyWith(color: AppColors.onSurface),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? Colors.white
            : AppColors.outline,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.primaryContainer
            : AppColors.surfaceHigh,
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      isDense: true,
      border: InputBorder.none,
      hintStyle: AppText.bodySmall,
    ),
  );
}
