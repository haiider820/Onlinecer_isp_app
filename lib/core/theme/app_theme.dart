import 'package:flutter/material.dart';

import 'field_ops_design_tokens.dart';

/// Central app theme for the "Midnight Ops" design system.
///
/// Both [light] and [dark] are first-class: [FieldOpsDesignTokens] feeds the
/// light scheme, [FieldOpsDarkTokens] the dark scheme. Screens read
/// `Theme.of(context).colorScheme / textTheme` and the component themes below
/// instead of hardcoding hex values or radii.
abstract final class AppTheme {
  AppTheme._();

  static ThemeData light() => _build(
        brightness: Brightness.light,
        surface: FieldOpsDesignTokens.surface,
        surfaceDim: FieldOpsDesignTokens.surfaceDim,
        surfaceBright: FieldOpsDesignTokens.surfaceBright,
        surfaceLowest: FieldOpsDesignTokens.surfaceContainerLowest,
        surfaceLow: FieldOpsDesignTokens.surfaceContainerLow,
        surfaceContainer: FieldOpsDesignTokens.surfaceContainer,
        surfaceHigh: FieldOpsDesignTokens.surfaceContainerHigh,
        surfaceHighest: FieldOpsDesignTokens.surfaceContainerHighest,
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
        buttonPressed: FieldOpsDesignTokens.buttonPressed,
        glow: FieldOpsDesignTokens.glowCyan,
        cardShadow: FieldOpsDesignTokens.shadowLevel1,
      );

  static ThemeData dark() => _build(
        brightness: Brightness.dark,
        surface: FieldOpsDarkTokens.surface,
        surfaceDim: FieldOpsDarkTokens.surfaceDim,
        surfaceBright: FieldOpsDarkTokens.surfaceBright,
        surfaceLowest: FieldOpsDarkTokens.surfaceContainerLowest,
        surfaceLow: FieldOpsDarkTokens.surfaceContainerLow,
        surfaceContainer: FieldOpsDarkTokens.surfaceContainer,
        surfaceHigh: FieldOpsDarkTokens.surfaceContainerHigh,
        surfaceHighest: FieldOpsDarkTokens.surfaceContainerHighest,
        onSurface: FieldOpsDarkTokens.onSurface,
        onSurfaceVariant: FieldOpsDarkTokens.onSurfaceVariant,
        inverseSurface: FieldOpsDarkTokens.inverseSurface,
        onInverseSurface: FieldOpsDarkTokens.inverseOnSurface,
        outline: FieldOpsDarkTokens.outline,
        outlineVariant: FieldOpsDarkTokens.outlineVariant,
        surfaceTint: FieldOpsDarkTokens.surfaceTint,
        primary: FieldOpsDarkTokens.primary,
        onPrimary: FieldOpsDarkTokens.onPrimary,
        primaryContainer: FieldOpsDarkTokens.primaryContainer,
        onPrimaryContainer: FieldOpsDarkTokens.onPrimaryContainer,
        inversePrimary: FieldOpsDarkTokens.inversePrimary,
        secondary: FieldOpsDarkTokens.secondary,
        onSecondary: FieldOpsDarkTokens.onSecondary,
        secondaryContainer: FieldOpsDarkTokens.secondaryContainer,
        onSecondaryContainer: FieldOpsDarkTokens.onSecondaryContainer,
        tertiary: FieldOpsDarkTokens.tertiary,
        onTertiary: FieldOpsDarkTokens.onTertiary,
        tertiaryContainer: FieldOpsDarkTokens.tertiaryContainer,
        onTertiaryContainer: FieldOpsDarkTokens.onTertiaryContainer,
        error: FieldOpsDarkTokens.error,
        onError: FieldOpsDarkTokens.onError,
        errorContainer: FieldOpsDarkTokens.errorContainer,
        onErrorContainer: FieldOpsDarkTokens.onErrorContainer,
        buttonPressed: FieldOpsDarkTokens.buttonPressed,
        glow: FieldOpsDarkTokens.glowCyan,
        cardShadow: FieldOpsDarkTokens.shadowLevel1,
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color surface,
    required Color surfaceDim,
    required Color surfaceBright,
    required Color surfaceLowest,
    required Color surfaceLow,
    required Color surfaceContainer,
    required Color surfaceHigh,
    required Color surfaceHighest,
    required Color onSurface,
    required Color onSurfaceVariant,
    required Color inverseSurface,
    required Color onInverseSurface,
    required Color outline,
    required Color outlineVariant,
    required Color surfaceTint,
    required Color primary,
    required Color onPrimary,
    required Color primaryContainer,
    required Color onPrimaryContainer,
    required Color inversePrimary,
    required Color secondary,
    required Color onSecondary,
    required Color secondaryContainer,
    required Color onSecondaryContainer,
    required Color tertiary,
    required Color onTertiary,
    required Color tertiaryContainer,
    required Color onTertiaryContainer,
    required Color error,
    required Color onError,
    required Color errorContainer,
    required Color onErrorContainer,
    required Color buttonPressed,
    required List<BoxShadow> glow,
    required List<BoxShadow> cardShadow,
  }) {
    final scheme = ColorScheme(
      brightness: brightness,
      surface: surface,
      surfaceDim: surfaceDim,
      surfaceBright: surfaceBright,
      surfaceContainerLowest: surfaceLowest,
      surfaceContainerLow: surfaceLow,
      surfaceContainer: surfaceContainer,
      surfaceContainerHigh: surfaceHigh,
      surfaceContainerHighest: surfaceHighest,
      onSurface: onSurface,
      onSurfaceVariant: onSurfaceVariant,
      inverseSurface: inverseSurface,
      onInverseSurface: onInverseSurface,
      outline: outline,
      outlineVariant: outlineVariant,
      surfaceTint: surfaceTint,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      inversePrimary: inversePrimary,
      secondary: secondary,
      onSecondary: onSecondary,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: onSecondaryContainer,
      tertiary: tertiary,
      onTertiary: onTertiary,
      tertiaryContainer: tertiaryContainer,
      onTertiaryContainer: onTertiaryContainer,
      error: error,
      onError: onError,
      errorContainer: errorContainer,
      onErrorContainer: onErrorContainer,
    );

    final textTheme = brightness == Brightness.dark
        ? _darkTextTheme()
        : _lightTextTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: surface,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: surface,
        foregroundColor: onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: (brightness == Brightness.dark
                ? FieldOpsDarkTokens.headlineMd
                : FieldOpsDesignTokens.headlineMd)
            .copyWith(color: onSurface),
      ),
      // Ops cards: 18px radius, hairline border, soft ambient shadow.
      cardTheme: CardThemeData(
        elevation: 0,
        color: surfaceLowest,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              FieldOpsDesignTokens.cardRadius),
          side: BorderSide(color: outlineVariant),
        ),
      ),
      // 52dp inputs, 14px radius, 1.5px border, cyan focus ring.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLowest,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        hintStyle: (brightness == Brightness.dark
                ? FieldOpsDarkTokens.bodyMd
                : FieldOpsDesignTokens.bodyMd)
            .copyWith(color: onSurfaceVariant),
        labelStyle: (brightness == Brightness.dark
                ? FieldOpsDarkTokens.bodyMd
                : FieldOpsDesignTokens.bodyMd)
            .copyWith(color: onSurfaceVariant),
        floatingLabelStyle: (brightness == Brightness.dark
                ? FieldOpsDarkTokens.labelMd
                : FieldOpsDesignTokens.labelMd)
            .copyWith(color: primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
              FieldOpsDesignTokens.controlRadius),
          borderSide: BorderSide(color: outlineVariant, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
              FieldOpsDesignTokens.controlRadius),
          borderSide: BorderSide(color: outlineVariant, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
              FieldOpsDesignTokens.controlRadius),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
              FieldOpsDesignTokens.controlRadius),
          borderSide: BorderSide(color: error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
              FieldOpsDesignTokens.controlRadius),
          borderSide: BorderSide(color: error, width: 2),
        ),
      ),
      // Primary CTA: cyan fill, glowing shadow, 16px radius, 48dp height.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize:
              const Size(0, FieldOpsDesignTokens.minTouchTarget),
          backgroundColor: primary,
          foregroundColor: onPrimary,
          disabledBackgroundColor: onSurface.withValues(alpha: 0.12),
          disabledForegroundColor: onSurface.withValues(alpha: 0.38),
          shadowColor: primary.withValues(alpha: 0.45),
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: (brightness == Brightness.dark
                  ? FieldOpsDarkTokens.labelLg
                  : FieldOpsDesignTokens.labelLg)
              .copyWith(fontSize: 15),
        ).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) return buttonPressed;
            return null;
          }),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize:
              const Size(0, FieldOpsDesignTokens.minTouchTarget),
          foregroundColor: primary,
          side: BorderSide(color: primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: (brightness == Brightness.dark
                  ? FieldOpsDarkTokens.labelLg
                  : FieldOpsDesignTokens.labelLg)
              .copyWith(fontSize: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: (brightness == Brightness.dark
                  ? FieldOpsDarkTokens.labelLg
                  : FieldOpsDesignTokens.labelLg)
              .copyWith(fontSize: 14),
        ),
      ),
      // Floating pill bottom nav.
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceLowest,
        selectedItemColor: primary,
        unselectedItemColor: onSurfaceVariant,
        elevation: 12,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: (brightness == Brightness.dark
                ? FieldOpsDarkTokens.labelSm
                : FieldOpsDesignTokens.labelSm)
            .copyWith(fontSize: 10.5),
        unselectedLabelStyle: (brightness == Brightness.dark
                ? FieldOpsDarkTokens.labelSm
                : FieldOpsDesignTokens.labelSm)
            .copyWith(fontSize: 10.5),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceHigh,
        selectedColor: primary.withValues(alpha: 0.14),
        labelStyle: (brightness == Brightness.dark
                ? FieldOpsDarkTokens.labelMd
                : FieldOpsDesignTokens.labelMd)
            .copyWith(color: onSurfaceVariant),
        secondaryLabelStyle: (brightness == Brightness.dark
                ? FieldOpsDarkTokens.labelMd
                : FieldOpsDesignTokens.labelMd)
            .copyWith(color: primary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
          side: BorderSide(color: outlineVariant),
        ),
        side: BorderSide(color: outlineVariant),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: inverseSurface,
        contentTextStyle: (brightness == Brightness.dark
                ? FieldOpsDarkTokens.bodyMd
                : FieldOpsDesignTokens.bodyMd)
            .copyWith(color: onInverseSurface),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
      ),
      dividerTheme: DividerThemeData(
        color: outlineVariant,
        thickness: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceLowest,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: outlineVariant),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surfaceLowest,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(22)),
          side: BorderSide(color: outlineVariant),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: primary),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? onPrimary : null),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? primary : null),
      ),
    );
  }

  static TextTheme _lightTextTheme() {
    return TextTheme(
      displayLarge: FieldOpsDesignTokens.displayLg,
      displayMedium: FieldOpsDesignTokens.displayLg,
      headlineLarge: FieldOpsDesignTokens.headlineLg,
      headlineMedium: FieldOpsDesignTokens.headlineLg,
      headlineSmall: FieldOpsDesignTokens.headlineMd,
      titleLarge: FieldOpsDesignTokens.headlineMd,
      titleMedium: FieldOpsDesignTokens.headlineSm,
      titleSmall: FieldOpsDesignTokens.labelLg,
      bodyLarge: FieldOpsDesignTokens.bodyLg,
      bodyMedium: FieldOpsDesignTokens.bodyMd,
      bodySmall: FieldOpsDesignTokens.bodySm,
      labelLarge: FieldOpsDesignTokens.labelLg,
      labelMedium: FieldOpsDesignTokens.labelMd,
      labelSmall: FieldOpsDesignTokens.labelSm,
    );
  }

  static TextTheme _darkTextTheme() {
    return TextTheme(
      displayLarge: FieldOpsDarkTokens.displayLg,
      displayMedium: FieldOpsDarkTokens.displayLg,
      headlineLarge: FieldOpsDarkTokens.headlineLg,
      headlineMedium: FieldOpsDarkTokens.headlineLg,
      headlineSmall: FieldOpsDarkTokens.headlineMd,
      titleLarge: FieldOpsDarkTokens.headlineMd,
      titleMedium: FieldOpsDarkTokens.headlineSm,
      titleSmall: FieldOpsDarkTokens.labelLg,
      bodyLarge: FieldOpsDarkTokens.bodyLg,
      bodyMedium: FieldOpsDarkTokens.bodyMd,
      bodySmall: FieldOpsDarkTokens.bodySm,
      labelLarge: FieldOpsDarkTokens.labelLg,
      labelMedium: FieldOpsDarkTokens.labelMd,
      labelSmall: FieldOpsDarkTokens.labelSm,
    );
  }
}

/// Signature cyan glow used by ops widgets for live indicators and hero CTAs.
List<BoxShadow> opsGlow(BuildContext context) {
  final dark = Theme.of(context).brightness == Brightness.dark;
  return dark ? FieldOpsDarkTokens.glowCyan : FieldOpsDesignTokens.glowCyan;
}
