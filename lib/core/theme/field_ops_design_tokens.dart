import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens for the "Midnight Ops" design system — the single source of
/// truth for colors, typography, spacing, shapes, and component constants.
///
/// [FieldOpsDesignTokens] carries the LIGHT palette; [FieldOpsDarkTokens]
/// mirrors the exact same API for DARK mode. [AppTheme] maps each set onto a
/// Material 3 [ColorScheme]. Screens must keep importing from here instead of
/// hardcoding hex values — when the palette changes, update this one file.
///
/// Typography is served through the `google_fonts` package (no bundled font
/// binaries): Space Grotesk for display, Inter for body/labels, IBM Plex Mono
/// for instrument data (request numbers, IDs, counts, coordinates).
abstract final class FieldOpsDesignTokens {
  FieldOpsDesignTokens._();

  // ─── Color Palette (light) ────────────────────────────────────────────

  // Surfaces
  static const Color surface = Color(0xFFEDF1F7);
  static const Color surfaceDim = Color(0xFFD8DEE9);
  static const Color surfaceBright = Color(0xFFF7F9FD);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF7F9FD);
  static const Color surfaceContainer = Color(0xFFF0F4F9);
  static const Color surfaceContainerHigh = Color(0xFFE8EEF6);
  static const Color surfaceContainerHighest = Color(0xFFDFE7F2);
  static const Color onSurface = Color(0xFF0B1220);
  static const Color onSurfaceVariant = Color(0xFF5B6B8C);
  static const Color inverseSurface = Color(0xFF0B1220);
  static const Color inverseOnSurface = Color(0xFFF2F6FF);

  // Outline
  static const Color outline = Color(0xFF9AA9C4);
  static const Color outlineVariant = Color(0xFFD9E2F0);
  static const Color cardBorder = Color(0xFFD9E2F0);

  // Primary — signal cyan. Every primary CTA, active indicator and focus
  // ring. Ink on top is white in light mode.
  static const Color primary = Color(0xFF0891B2);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFCFFAFE);
  static const Color onPrimaryContainer = Color(0xFF0E7490);
  static const Color inversePrimary = Color(0xFF22D3EE);

  // Secondary — violet, used for gradients, internal-note accents and
  // secondary highlights. Never a second CTA color on the same screen.
  static const Color secondary = Color(0xFF7C3AED);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFEDE9FE);
  static const Color onSecondaryContainer = Color(0xFF5B21B6);

  /// Pressed state for the primary CTA (a deeper cyan, never grey).
  static const Color buttonPressed = Color(0xFF0E7490);

  // Tertiary
  static const Color tertiary = Color(0xFF047857);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFD1FAE5);
  static const Color onTertiaryContainer = Color(0xFF065F46);

  // Error
  static const Color error = Color(0xFFDC2626);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFEE2E2);
  static const Color onErrorContainer = Color(0xFF991B1B);

  // Fixed
  static const Color primaryFixed = Color(0xFFCFFAFE);
  static const Color primaryFixedDim = Color(0xFFA5F3FC);
  static const Color onPrimaryFixed = Color(0xFF083344);
  static const Color onPrimaryFixedVariant = Color(0xFF0E7490);
  static const Color secondaryFixed = Color(0xFFEDE9FE);
  static const Color secondaryFixedDim = Color(0xFFDDD6FE);
  static const Color onSecondaryFixed = Color(0xFF2E1065);
  static const Color onSecondaryFixedVariant = Color(0xFF6D28D9);
  static const Color tertiaryFixed = Color(0xFFA7F3D0);
  static const Color tertiaryFixedDim = Color(0xFF6EE7B7);
  static const Color onTertiaryFixed = Color(0xFF064E3B);
  static const Color onTertiaryFixedVariant = Color(0xFF047857);

  // Background (alias for surface in MD3)
  static const Color background = Color(0xFFEDF1F7);
  static const Color onBackground = Color(0xFF0B1220);
  static const Color surfaceVariant = Color(0xFFDFE7F2);

  // Surface tint
  static const Color surfaceTint = Color(0xFF0891B2);

  // ─── Semantic Status Badge Colors ─────────────────────────────────────

  /// Assigned / In-Progress — signal cyan.
  static const Color assignedBackground = Color(0xFFCFFAFE);
  static const Color assignedForeground = Color(0xFF0E7490);

  /// Completed / Verified — green.
  static const Color completedBackground = Color(0xFFD1FAE5);
  static const Color completedForeground = Color(0xFF047857);

  /// Pending / Scheduled — amber.
  static const Color pendingBackground = Color(0xFFFEF3C7);
  static const Color pendingForeground = Color(0xFFB45309);

  /// Urgent / Outage / Escalation — red.
  static const Color urgentBackground = Color(0xFFFEE2E2);
  static const Color urgentForeground = Color(0xFFB91C1C);

  /// Needs review — violet.
  static const Color reviewBackground = Color(0xFFEDE9FE);
  static const Color reviewForeground = Color(0xFF6D28D9);

  /// Initials-avatar gradient base (cyan → violet painted by widgets).
  static const Color avatarBackground = Color(0xFF0891B2);

  // ─── Ticket Status Colors ─────────────────────────────────────────────

  /// Opened tickets → green tinted background / accent.
  static const Color ticketOpenedBackground = Color(0xFFD1FAE5);
  static const Color ticketOpenedForeground = Color(0xFF047857);

  /// Closed tickets → grey muted background / foreground.
  static const Color ticketClosedBackground = Color(0xFFE8EEF6);
  static const Color ticketClosedForeground = Color(0xFF5B6B8C);

  /// In-progress tickets → cyan tinted background.
  static const Color ticketInProgressBackground = Color(0xFFCFFAFE);
  static const Color ticketInProgressForeground = Color(0xFF0E7490);

  /// Neutral ink colors for text hierarchy
  static const Color textPrimary = Color(0xFF0B1220);
  static const Color textSubtext = Color(0xFF5B6B8C);

  // ─── Typography ───────────────────────────────────────────────────────
  //
  // Served via google_fonts (runtime-fetched, cached on device). In widget
  // tests the fetch is disabled — see test setup — and styles fall back
  // gracefully, so tests never touch the network.

  static const String displayFamily = 'Space Grotesk';
  static const String bodyFamily = 'Inter';
  static const String monoFamily = 'IBM Plex Mono';

  /// 30 / 700 — hero titles, screen display.
  static TextStyle get displayLg => GoogleFonts.spaceGrotesk(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        height: 1.15,
        letterSpacing: -0.01,
      );

  /// 22 / 700 — screen titles.
  static TextStyle get headlineLg => GoogleFonts.spaceGrotesk(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.25,
      );

  /// 19 / 600 — section headers, card titles.
  static TextStyle get headlineMd => GoogleFonts.spaceGrotesk(
        fontSize: 19,
        fontWeight: FontWeight.w600,
        height: 1.3,
      );

  /// 17 / 600 — card titles.
  static TextStyle get headlineSm => GoogleFonts.spaceGrotesk(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        height: 1.3,
      );

  /// 15 / 500 — primary content.
  static TextStyle get bodyLg => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        height: 1.5,
      );

  /// 14 / 400 — secondary content.
  static TextStyle get bodyMd => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  /// 12 / 400 — captions, timestamps.
  static TextStyle get bodySm => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.45,
      );

  /// 13.5 / 700 — button text, emphasized labels.
  static TextStyle get labelLg => GoogleFonts.inter(
        fontSize: 13.5,
        fontWeight: FontWeight.w700,
        height: 1.4,
        letterSpacing: 0.01,
      );

  /// 12 / 700 — form labels.
  static TextStyle get labelMd => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        height: 1.35,
        letterSpacing: 0.02,
      );

  /// 11 / 700 — tags, eyebrows (sentence case).
  static TextStyle get labelSm => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        height: 1.3,
        letterSpacing: 0.04,
      );

  /// 22 / 700 mono — hero instrument readouts.
  static TextStyle get dataLg => GoogleFonts.ibmPlexMono(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.2,
      );

  /// 14 / 600 mono — request numbers, IDs, inline values.
  static TextStyle get dataMd => GoogleFonts.ibmPlexMono(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.35,
      );

  /// 11.5 / 500 mono — captions, coordinates, timestamps.
  static TextStyle get dataSm => GoogleFonts.ibmPlexMono(
        fontSize: 11.5,
        fontWeight: FontWeight.w500,
        height: 1.35,
      );

  // ─── Spacing (8pt baseline) ───────────────────────────────────────────

  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 16;
  static const double spaceLg = 24;
  static const double spaceXl = 32;

  /// Outer page margin (16px gutter).
  static const double pageMargin = 16;

  /// Vertical gap between cards.
  static const double cardGap = 12;

  /// Inner card padding.
  static const double cardPadding = 16;

  // ─── Shapes ───────────────────────────────────────────────────────────

  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 18;
  static const double radiusXxl = 24;
  static const double radiusFull = 9999;

  /// Default card border radius.
  static const double cardRadius = 18;

  /// Default input / button border radius.
  static const double controlRadius = 14;

  // ─── Component Dimensions ─────────────────────────────────────────────

  /// Minimum touch target.
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

  // ─── Elevation Shadows ────────────────────────────────────────────────

  /// Level 1: cards at rest.
  static const List<BoxShadow> shadowLevel1 = [
    BoxShadow(
      color: Color(0x140B1220), // 0.08
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  /// Level 2: raised / active cards.
  static const List<BoxShadow> shadowLevel2 = [
    BoxShadow(
      color: Color(0x1F0B1220), // 0.12
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  /// Level 3: floating modals, bottom sheets, nav bars.
  static const List<BoxShadow> shadowLevel3 = [
    BoxShadow(
      color: Color(0x290B1220), // 0.16
      blurRadius: 32,
      offset: Offset(0, 12),
    ),
  ];

  /// Signature cyan glow for primary CTAs and live indicators (light).
  static const List<BoxShadow> glowCyan = [
    BoxShadow(
      color: Color(0x590891B2), // 0.35
      blurRadius: 22,
      offset: Offset(0, 0),
    ),
  ];
}

/// Dark-mode twin of [FieldOpsDesignTokens]: identical API, "Midnight Ops"
/// night palette — near-black blue canvas, glowing signal cyan, violet depth.
abstract final class FieldOpsDarkTokens {
  FieldOpsDarkTokens._();

  // Surfaces
  static const Color surface = Color(0xFF05080F);
  static const Color surfaceDim = Color(0xFF030509);
  static const Color surfaceBright = Color(0xFF0E1524);
  static const Color surfaceContainerLowest = Color(0xFF0B101D);
  static const Color surfaceContainerLow = Color(0xFF0A0F1E);
  static const Color surfaceContainer = Color(0xFF0D1424);
  static const Color surfaceContainerHigh = Color(0xFF111A2E);
  static const Color surfaceContainerHighest = Color(0xFF16203A);
  static const Color onSurface = Color(0xFFF2F6FF);
  static const Color onSurfaceVariant = Color(0xFF8B98B8);
  static const Color inverseSurface = Color(0xFFF2F6FF);
  static const Color inverseOnSurface = Color(0xFF0B1220);

  // Outline
  static const Color outline = Color(0xFF3A4A6B);
  static const Color outlineVariant = Color(0xFF1B2540);
  static const Color cardBorder = Color(0xFF1B2540);

  // Primary — glowing signal cyan; ink on top is near-black.
  static const Color primary = Color(0xFF22D3EE);
  static const Color onPrimary = Color(0xFF04121A);
  static const Color primaryContainer = Color(0xFF0E3A46);
  static const Color onPrimaryContainer = Color(0xFFA5F3FC);
  static const Color inversePrimary = Color(0xFF0891B2);

  // Secondary — violet.
  static const Color secondary = Color(0xFF8B5CF6);
  static const Color onSecondary = Color(0xFF0B0620);
  static const Color secondaryContainer = Color(0xFF2E1A5E);
  static const Color onSecondaryContainer = Color(0xFFDDD6FE);

  /// Pressed state for the primary CTA.
  static const Color buttonPressed = Color(0xFF67E8F9);

  // Tertiary
  static const Color tertiary = Color(0xFF34D399);
  static const Color onTertiary = Color(0xFF04120C);
  static const Color tertiaryContainer = Color(0xFF064E3B);
  static const Color onTertiaryContainer = Color(0xFFA7F3D0);

  // Error
  static const Color error = Color(0xFFF87171);
  static const Color onError = Color(0xFF1A0505);
  static const Color errorContainer = Color(0xFF4C1010);
  static const Color onErrorContainer = Color(0xFFFECACA);

  // Fixed
  static const Color primaryFixed = Color(0xFF0E3A46);
  static const Color primaryFixedDim = Color(0xFF155E75);
  static const Color onPrimaryFixed = Color(0xFFECFEFF);
  static const Color onPrimaryFixedVariant = Color(0xFFA5F3FC);
  static const Color secondaryFixed = Color(0xFF2E1A5E);
  static const Color secondaryFixedDim = Color(0xFF4C1D95);
  static const Color onSecondaryFixed = Color(0xFFF5F3FF);
  static const Color onSecondaryFixedVariant = Color(0xFFDDD6FE);
  static const Color tertiaryFixed = Color(0xFF064E3B);
  static const Color tertiaryFixedDim = Color(0xFF047857);
  static const Color onTertiaryFixed = Color(0xFFECFDF5);
  static const Color onTertiaryFixedVariant = Color(0xFFA7F3D0);

  // Background (alias for surface in MD3)
  static const Color background = Color(0xFF05080F);
  static const Color onBackground = Color(0xFFF2F6FF);
  static const Color surfaceVariant = Color(0xFF16203A);

  // Surface tint
  static const Color surfaceTint = Color(0xFF22D3EE);

  // ─── Semantic Status Badge Colors (dark) ──────────────────────────────

  static const Color assignedBackground = Color(0xFF0E3A46);
  static const Color assignedForeground = Color(0xFF67E8F9);

  static const Color completedBackground = Color(0xFF064E3B);
  static const Color completedForeground = Color(0xFF6EE7B7);

  static const Color pendingBackground = Color(0xFF4A2E0A);
  static const Color pendingForeground = Color(0xFFFBBF24);

  static const Color urgentBackground = Color(0xFF4C1010);
  static const Color urgentForeground = Color(0xFFFCA5A5);

  static const Color reviewBackground = Color(0xFF2E1A5E);
  static const Color reviewForeground = Color(0xFFC4B5FD);

  static const Color avatarBackground = Color(0xFF22D3EE);

  // ─── Ticket Status Colors (dark) ──────────────────────────────────────

  static const Color ticketOpenedBackground = Color(0xFF064E3B);
  static const Color ticketOpenedForeground = Color(0xFF6EE7B7);

  static const Color ticketClosedBackground = Color(0xFF16203A);
  static const Color ticketClosedForeground = Color(0xFF8B98B8);

  static const Color ticketInProgressBackground = Color(0xFF0E3A46);
  static const Color ticketInProgressForeground = Color(0xFF67E8F9);

  static const Color textPrimary = Color(0xFFF2F6FF);
  static const Color textSubtext = Color(0xFF8B98B8);

  // ─── Typography (same scale as light) ─────────────────────────────────

  static const String displayFamily = 'Space Grotesk';
  static const String bodyFamily = 'Inter';
  static const String monoFamily = 'IBM Plex Mono';

  static TextStyle get displayLg => GoogleFonts.spaceGrotesk(
      fontSize: 30, fontWeight: FontWeight.w700, height: 1.15, letterSpacing: -0.01);
  static TextStyle get headlineLg => GoogleFonts.spaceGrotesk(
      fontSize: 22, fontWeight: FontWeight.w700, height: 1.25);
  static TextStyle get headlineMd => GoogleFonts.spaceGrotesk(
      fontSize: 19, fontWeight: FontWeight.w600, height: 1.3);
  static TextStyle get headlineSm => GoogleFonts.spaceGrotesk(
      fontSize: 17, fontWeight: FontWeight.w600, height: 1.3);
  static TextStyle get bodyLg =>
      GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, height: 1.5);
  static TextStyle get bodyMd =>
      GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5);
  static TextStyle get bodySm =>
      GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, height: 1.45);
  static TextStyle get labelLg => GoogleFonts.inter(
      fontSize: 13.5, fontWeight: FontWeight.w700, height: 1.4, letterSpacing: 0.01);
  static TextStyle get labelMd => GoogleFonts.inter(
      fontSize: 12, fontWeight: FontWeight.w700, height: 1.35, letterSpacing: 0.02);
  static TextStyle get labelSm => GoogleFonts.inter(
      fontSize: 11, fontWeight: FontWeight.w700, height: 1.3, letterSpacing: 0.04);
  static TextStyle get dataLg => GoogleFonts.ibmPlexMono(
      fontSize: 22, fontWeight: FontWeight.w700, height: 1.2);
  static TextStyle get dataMd => GoogleFonts.ibmPlexMono(
      fontSize: 14, fontWeight: FontWeight.w600, height: 1.35);
  static TextStyle get dataSm => GoogleFonts.ibmPlexMono(
      fontSize: 11.5, fontWeight: FontWeight.w500, height: 1.35);

  // ─── Spacing ──────────────────────────────────────────────────────────

  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 16;
  static const double spaceLg = 24;
  static const double spaceXl = 32;
  static const double pageMargin = 16;
  static const double cardGap = 12;
  static const double cardPadding = 16;

  // ─── Shapes ───────────────────────────────────────────────────────────

  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 18;
  static const double radiusXxl = 24;
  static const double radiusFull = 9999;
  static const double cardRadius = 18;
  static const double controlRadius = 14;

  // ─── Component Dimensions ─────────────────────────────────────────────

  static const double minTouchTarget = 48;
  static const double inputHeight = 52;
  static const double badgeHeight = 26;
  static const double badgePaddingH = 10;
  static const double badgeDotSize = 6;
  static const double badgeIconSize = 14;

  // ─── Elevation Shadows (dark) ─────────────────────────────────────────

  static const List<BoxShadow> shadowLevel1 = [
    BoxShadow(color: Color(0x66000000), blurRadius: 16, offset: Offset(0, 4)),
  ];
  static const List<BoxShadow> shadowLevel2 = [
    BoxShadow(color: Color(0x80000000), blurRadius: 24, offset: Offset(0, 8)),
  ];
  static const List<BoxShadow> shadowLevel3 = [
    BoxShadow(color: Color(0x99000000), blurRadius: 32, offset: Offset(0, 12)),
  ];

  /// Signature cyan glow (dark) — primary CTAs, live indicators.
  static const List<BoxShadow> glowCyan = [
    BoxShadow(color: Color(0x5922D3EE), blurRadius: 24, offset: Offset(0, 0)),
  ];
}
