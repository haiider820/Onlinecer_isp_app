import 'package:flutter/material.dart';

import 'field_ops_design_tokens.dart';

/// Central app theme, built from the DESIGN.md design system.
///
/// `FieldOpsDesignTokens` is the single source of truth: this file maps those
/// tokens into a Material 3 `ThemeData`. Screens should reuse
/// `theme.colorScheme` / `theme.textTheme` / the component themes below rather
/// than hardcoding their own hex values or radii.
abstract final class AppTheme {
  AppTheme._();

  /// Soft neutral page background so white cards stand out.
  static const Color scaffoldBackground = FieldOpsDesignTokens.surface;

  static ThemeData light() {
    final scheme = _colorScheme();
    final textTheme = _textTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffoldBackground,
      // Inter-face design system type.
      textTheme: textTheme,
      // Headers use the deep slate-blue primary.
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: scheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 2,
      ),
      // Level-1 cards: white surface, 14px radius, hairline border, diffuse
      // ambient shadow (DESIGN.md §Elevation & Depth).
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FieldOpsDesignTokens.cardRadius),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      // 52dp inputs, 12px radius, 1.5px border, primary focus border.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FieldOpsDesignTokens.controlRadius),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FieldOpsDesignTokens.controlRadius),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FieldOpsDesignTokens.controlRadius),
          borderSide: const BorderSide(
            color: FieldOpsDesignTokens.secondary,
            width: 2,
          ),
        ),
      ),
      // 48dp minimum buttons, 12px radius, semibold 16px (DESIGN.md §Buttons).
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, FieldOpsDesignTokens.minTouchTarget),
          backgroundColor: FieldOpsDesignTokens.secondary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FieldOpsDesignTokens.controlRadius),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, FieldOpsDesignTokens.minTouchTarget),
          foregroundColor: FieldOpsDesignTokens.primary,
          side: const BorderSide(
            color: FieldOpsDesignTokens.primary,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FieldOpsDesignTokens.controlRadius),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: FieldOpsDesignTokens.secondary,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1F2A3D),
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withValues(alpha: 0.6),
      ),
    );
  }

  /// Maps the DESIGN.md color tokens onto a Material 3 [ColorScheme].
  static ColorScheme _colorScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      surface: FieldOpsDesignTokens.surface,
      surfaceDim: FieldOpsDesignTokens.surfaceDim,
      surfaceBright: FieldOpsDesignTokens.surfaceBright,
      surfaceContainerLowest: FieldOpsDesignTokens.surfaceContainerLowest,
      surfaceContainerLow: FieldOpsDesignTokens.surfaceContainerLow,
      surfaceContainer: FieldOpsDesignTokens.surfaceContainer,
      surfaceContainerHigh: FieldOpsDesignTokens.surfaceContainerHigh,
      surfaceContainerHighest: FieldOpsDesignTokens.surfaceContainerHighest,
      onSurface: FieldOpsDesignTokens.onSurface,
      onSurfaceVariant: FieldOpsDesignTokens.onSurfaceVariant,
      inverseSurface: FieldOpsDesignTokens.inverseSurface,
      onInverseSurface: FieldOpsDesignTokens.inverseOnSurface,
      outline: FieldOpsDesignTokens.outline,
      outlineVariant: FieldOpsDesignTokens.outlineVariant,
      surfaceTint: FieldOpsDesignTokens.surfaceTint,
      primary: FieldOpsDesignTokens.primary,
      onPrimary: FieldOpsDesignTokens.onPrimary,
      primaryContainer: FieldOpsDesignTokens.primaryContainer,
      onPrimaryContainer: FieldOpsDesignTokens.onPrimaryContainer,
      inversePrimary: FieldOpsDesignTokens.inversePrimary,
      secondary: FieldOpsDesignTokens.secondary,
      onSecondary: FieldOpsDesignTokens.onSecondary,
      secondaryContainer: FieldOpsDesignTokens.secondaryContainer,
      onSecondaryContainer: FieldOpsDesignTokens.onSecondaryContainer,
      tertiary: FieldOpsDesignTokens.tertiary,
      onTertiary: FieldOpsDesignTokens.onTertiary,
      tertiaryContainer: FieldOpsDesignTokens.tertiaryContainer,
      onTertiaryContainer: FieldOpsDesignTokens.onTertiaryContainer,
      error: FieldOpsDesignTokens.error,
      onError: FieldOpsDesignTokens.onError,
      errorContainer: FieldOpsDesignTokens.errorContainer,
      onErrorContainer: FieldOpsDesignTokens.onErrorContainer,
      primaryFixed: FieldOpsDesignTokens.primaryFixed,
      primaryFixedDim: FieldOpsDesignTokens.primaryFixedDim,
      onPrimaryFixed: FieldOpsDesignTokens.onPrimaryFixed,
      onPrimaryFixedVariant: FieldOpsDesignTokens.onPrimaryFixedVariant,
      secondaryFixed: FieldOpsDesignTokens.secondaryFixed,
      secondaryFixedDim: FieldOpsDesignTokens.secondaryFixedDim,
      onSecondaryFixed: FieldOpsDesignTokens.onSecondaryFixed,
      onSecondaryFixedVariant: FieldOpsDesignTokens.onSecondaryFixedVariant,
      tertiaryFixed: FieldOpsDesignTokens.tertiaryFixed,
      tertiaryFixedDim: FieldOpsDesignTokens.tertiaryFixedDim,
      onTertiaryFixed: FieldOpsDesignTokens.onTertiaryFixed,
      onTertiaryFixedVariant: FieldOpsDesignTokens.onTertiaryFixedVariant,
    );
  }

  /// Maps the DESIGN.md typography scale onto Flutter's [TextTheme].
  static TextTheme _textTheme() {
    return const TextTheme(
      displayLarge: FieldOpsDesignTokens.displayLg,
      headlineLarge: FieldOpsDesignTokens.headlineLg,
      headlineMedium: FieldOpsDesignTokens.headlineLg,
      headlineSmall: FieldOpsDesignTokens.headlineMd,
      titleLarge: FieldOpsDesignTokens.headlineMd,
      titleMedium: FieldOpsDesignTokens.labelLg,
      titleSmall: FieldOpsDesignTokens.labelMd,
      bodyLarge: FieldOpsDesignTokens.bodyLg,
      bodyMedium: FieldOpsDesignTokens.bodyMd,
      bodySmall: FieldOpsDesignTokens.bodySm,
      labelLarge: FieldOpsDesignTokens.labelLg,
      labelMedium: FieldOpsDesignTokens.labelMd,
      labelSmall: FieldOpsDesignTokens.labelSm,
    );
  }
}