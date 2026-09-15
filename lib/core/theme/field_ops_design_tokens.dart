import 'package:flutter/material.dart';

/// Design tokens extracted from `DESIGN.md` — the single source of truth for
/// colors, typography, spacing, shapes, and component constants across every
/// field-ops screen.
///
/// All screens import from here instead of hardcoding hex values or magic
/// numbers. When the DESIGN.md tokens change, update this one file and every
/// screen picks up the change on hot-reload.
abstract final class FieldOpsDesignTokens {
  FieldOpsDesignTokens._();

  // ─── Color Palette ──────────────────────────────────────────────────────

  // Surfaces
  static const Color surface = Color(0xFFF7F9FD);
  static const Color surfaceDim = Color(0xFFD8DADE);
  static const Color surfaceBright = Color(0xFFF7F9FD);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF2F4F8);
  static const Color surfaceContainer = Color(0xFFECEEF2);
  static const Color surfaceContainerHigh = Color(0xFFE6E8EC);
  static const Color surfaceContainerHighest = Color(0xFFE0E3E6);
  static const Color onSurface = Color(0xFF191C1F);
  static const Color onSurfaceVariant = Color(0xFF44474F);
  static const Color inverseSurface = Color(0xFF2D3134);
  static const Color inverseOnSurface = Color(0xFFEFF1F5);

  // Outline
  static const Color outline = Color(0xFF75777F);
  static const Color outlineVariant = Color(0xFFC5C6D0);

  // Primary
  static const Color primary = Color(0xFF223861);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF3A4F7A);
  static const Color onPrimaryContainer = Color(0xFFACC2F3);
  static const Color inversePrimary = Color(0xFFB1C6F8);

  // Secondary
  static const Color secondary = Color(0xFF0051D5);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFF316BF3);
  static const Color onSecondaryContainer = Color(0xFFFEFCFF);

  // Tertiary
  static const Color tertiary = Color(0xFF004225);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFF005C36);
  static const Color onTertiaryContainer = Color(0xFF77D59C);

  // Error
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  // Fixed
  static const Color primaryFixed = Color(0xFFD8E2FF);
  static const Color primaryFixedDim = Color(0xFFB1C6F8);
  static const Color onPrimaryFixed = Color(0xFF001A42);
  static const Color onPrimaryFixedVariant = Color(0xFF314671);
  static const Color secondaryFixed = Color(0xFFDBE1FF);
  static const Color secondaryFixedDim = Color(0xFFB4C5FF);
  static const Color onSecondaryFixed = Color(0xFF00174B);
  static const Color onSecondaryFixedVariant = Color(0xFF003EA8);
  static const Color tertiaryFixed = Color(0xFF97F6BB);
  static const Color tertiaryFixedDim = Color(0xFF7BDAA0);
  static const Color onTertiaryFixed = Color(0xFF002110);
  static const Color onTertiaryFixedVariant = Color(0xFF00522F);

  // Background (alias for surface in MD3)
  static const Color background = Color(0xFFF7F9FD);
  static const Color onBackground = Color(0xFF191C1F);
  static const Color surfaceVariant = Color(0xFFE0E3E6);

  // Surface tint
  static const Color surfaceTint = Color(0xFF495E8A);

  // ─── Semantic Status Badge Colors (DESIGN.md §Semantic Status Badges) ───

  /// Assigned / In-Progress
  static const Color assignedBackground = Color(0xFFEBF2FE);
  static const Color assignedForeground = Color(0xFF1D4ED8);

  /// Completed / Verified
  static const Color completedBackground = Color(0xFFE8F8F0);
  static const Color completedForeground = Color(0xFF0D7A4A);

  /// Pending / Scheduled
  static const Color pendingBackground = Color(0xFFFEF3C7);
  static const Color pendingForeground = Color(0xFFB45309);

  /// Urgent / Outage / Escalation
  static const Color urgentBackground = Color(0xFFFEE2E2);
  static const Color urgentForeground = Color(0xFFB91C1C);

    /// Initials-avatar background (#17b9eb — brand accent applied to every
  /// user/customer avatar that renders initials, per DESIGN.md avatar note).
  static const Color avatarBackground = Color(0xFF17B9EB);

  // ─── Ticket Status Colors (progress bar / badge tinting) ───────────────

  /// Opened tickets → green tinted background / accent.
  static const Color ticketOpenedBackground = Color(0xFFDCFCE7);
  static const Color ticketOpenedForeground = Color(0xFF166534);

  /// Closed tickets → grey muted background / foreground.
  static const Color ticketClosedBackground = Color(0xFFF1F5F9);
  static const Color ticketClosedForeground = Color(0xFF475569);

  /// In-progress tickets → amber tinted background.
  static const Color ticketInProgressBackground = Color(0xFFFEF3C7);
  static const Color ticketInProgressForeground = Color(0xFF924001);

  /// Neutral ink colors for text hierarchy
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSubtext = Color(0xFF475569);

  // ─── Typography (DESIGN.md §Typography — Inter, 10 levels) ─────────────
  //
  // Inter is not bundled with Flutter by default. Without the google_fonts
  // package the font family name resolves to the platform default (Roboto).
  // The design intent is captured in font-size / weight / height / spacing;
  // swapping in the real Inter file later is a one-line package add.

  static const String _fontFamily = 'Inter';

  /// 32 / 700 / 40 / -0.02em
  static const TextStyle displayLg = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 40 / 32,
    letterSpacing: -0.02,
  );

  /// 24 / 700 / 32 / -0.01em
  static const TextStyle headlineLg = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 32 / 24,
    letterSpacing: -0.01,
  );

  /// 20 / 600 / 28
  static const TextStyle headlineMd = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 28 / 20,
  );

  /// 18 / 600 / 24
  static const TextStyle headlineSm = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 24 / 18,
  );

  /// 16 / 500 / 24
  static const TextStyle bodyLg = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 24 / 16,
  );

  /// 14 / 400 / 20
  static const TextStyle bodyMd = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
  );

  /// 12 / 400 / 16
  static const TextStyle bodySm = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 16 / 12,
  );

  /// 14 / 600 / 20 / 0.01em
  static const TextStyle labelLg = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 20 / 14,
    letterSpacing: 0.01,
  );

  /// 12 / 600 / 16 / 0.02em
  static const TextStyle labelMd = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 16 / 12,
    letterSpacing: 0.02,
  );

  /// 11 / 700 / 14 / 0.04em
  static const TextStyle labelSm = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    height: 14 / 11,
    letterSpacing: 0.04,
  );

  // ─── Spacing (DESIGN.md §Layout & Spacing — 8pt baseline) ──────────────

  static const double spaceXs = 4; // 0.25rem
  static const double spaceSm = 8; // 0.5rem
  static const double spaceMd = 16; // 1rem
  static const double spaceLg = 24; // 1.5rem
  static const double spaceXl = 32; // 2rem

  /// Outer page margin (16px gutter).
  static const double pageMargin = 16;

  /// Vertical gap between cards.
  static const double cardGap = 16;

  /// Inner card padding.
  static const double cardPadding = 16;

  // ─── Shapes (DESIGN.md §Shapes) ────────────────────────────────────────

  /// Cards & Bottom Sheets: 12–16px
  static const double radiusSm = 4; // 0.25rem
  static const double radiusMd = 8; // 0.5rem
  static const double radiusLg = 12; // 0.75rem
  static const double radiusXl = 16; // 1rem
  static const double radiusXxl = 24; // 1.5rem
  static const double radiusFull = 9999;

  /// Default card border radius.
  static const double cardRadius = 14;

  /// Default input / button border radius.
  static const double controlRadius = 12;

  // ─── Component Dimensions (DESIGN.md §Components) ──────────────────────

  /// Minimum touch target (MD3 ergonomics).
  static const double minTouchTarget = 48;

  /// Standard input field height.
  static const double inputHeight = 52;

  /// Status badge height.
  static const double badgeHeight = 26;

  /// Status badge horizontal padding.
  static const double badgePaddingH = 10;

  /// Status badge icon size (dot).
  static const double badgeDotSize = 6;

  /// Status badge icon size.
  static const double badgeIconSize = 14;

  // ─── Elevation Shadows (DESIGN.md §Elevation & Depth) ──────────────────

  /// Level 1: Work Order & Metric Cards
  static const List<BoxShadow> shadowLevel1 = [
    BoxShadow(
      color: Color(0x0D0F172A), // 0.05
      blurRadius: 3,
      offset: Offset(0, 1),
    ),
    BoxShadow(
      color: Color(0x060F172A), // 0.025
      blurRadius: 6,
      offset: Offset(0, -2),
    ),
  ];

  /// Level 2: Active / Selected Cards
  static const List<BoxShadow> shadowLevel2 = [
    BoxShadow(
      color: Color(0x140F172A), // 0.08
      blurRadius: 15,
      offset: Offset(0, -3),
    ),
    BoxShadow(
      color: Color(0x0A0F172A), // 0.04
      blurRadius: 6,
      offset: Offset(0, -2),
    ),
  ];

  /// Level 3: Floating modals, bottom sheets, nav bars
  static const List<BoxShadow> shadowLevel3 = [
    BoxShadow(
      color: Color(0x0F0F172A), // 0.06
      blurRadius: 12,
      offset: Offset(0, -4),
    ),
  ];
}
