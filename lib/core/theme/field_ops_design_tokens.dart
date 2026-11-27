import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens for the Onlinecer ISP app (Malik Fiber) — palette #4
/// Navy / sky / orange, per APP_BRIEF §4 and haider-design-kit DESIGN.md
/// Rules 1–14. The single source of truth for colors, typography, spacing,
/// shapes, and component constants.
///
/// [FieldOpsDesignTokens] carries the LIGHT palette; [FieldOpsDarkTokens]
/// mirrors the exact same API for DARK mode (dark is the default, kit
/// Rule 4). [AppTheme] maps each set onto a Material 3 [ColorScheme].
/// Screens must keep importing from here instead of hardcoding hex values —
/// when the palette changes, update this one file.
///
/// Typography is served through the `google_fonts` package (no bundled font
/// binaries): ONE family — Plus Jakarta Sans — for display, headline, body
/// and labels; IBM Plex Mono ONLY for instrument data (request numbers,
/// IDs, counts, coordinates).
///
/// Depth comes from surface steps + a 1px hairline (kit Rule 4): there are
/// NO shadows anywhere — every shadow list below is empty on purpose.
abstract final class FieldOpsDesignTokens {
  FieldOpsDesignTokens._();

  // ─── Color Palette (light) ────────────────────────────────────────────

  // Surfaces
  static const Color surface = Color(0xFFF4F6FA);
  static const Color surfaceDim = Color(0xFFE3E8F1);
  static const Color surfaceBright = Color(0xFFFFFFFF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFFFFFFF);
  static const Color surfaceContainer = Color(0xFFEEF3FE);
  static const Color surfaceContainerHigh = Color(0xFFE8EEF6);
  static const Color surfaceContainerHighest = Color(0xFFDFE7F2);
  static const Color onSurface = Color(0xFF10182B);
  static const Color onSurfaceVariant = Color(0xFF5C6880);
  static const Color inverseSurface = Color(0xFF0B132B);
  static const Color inverseOnSurface = Color(0xFFECF1FB);

  // Outline
  static const Color outline = Color(0xFFDCE3EE);
  static const Color outlineVariant = Color(0xFFDCE3EE);
  static const Color cardBorder = Color(0xFFDCE3EE);

  // Text-field fill / border (login + forms).
  static const Color fieldFill = Color(0xFFF6F8FC);
  static const Color fieldBorder = Color(0xFFD9DFEC);

  // ─── Liquid glass (LIGHT login only) ──────────────────────────────────
  //
  // Apple iOS 26-style glass for the light-theme login card: a translucent
  // white gradient (brighter at the top, with a soft diagonal sheen band),
  // a bright top/left rim, and one soft drop shadow. Scoped exception to
  // kit Rule 4 (no shadows) — glass needs the shadow for depth, and it
  // applies to this card only. Dark login keeps the v2 frosted card.
  // The fill stays white enough that dark text on it keeps 4.5+ contrast
  // (fill 0.55/0.40 over the navy scene is still ~5:1 for #10182B text).
  // NOTE: no borderRadius here — a borderRadius can only be given on
  // borders with uniform colors, and this border is deliberately
  // non-uniform (bright top/left rim). The rounding comes from the
  // ClipRRect in LoginScreen; the shadow lives on the outer container
  // there for the same reason (a shadow inside the clip is cut off).
  static const Color glassFillTop = Color(0x8CFFFFFF); // white, 0.55
  static const Color glassFillBottom = Color(0x66FFFFFF); // white, 0.40
  static const Color glassRimBright = Color(0xD9FFFFFF); // white, 0.85
  static const Color glassRimSoft = Color(0x73FFFFFF); // white, 0.45
  static const Color glassSheen = Color(0x8CFFFFFF); // white, 0.55 (band)
  static const Color glassShadow = Color(0x330B132B); // navy, 0.20

  static const BoxDecoration glassCardDecoration = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [glassFillTop, glassFillBottom, glassSheen, glassFillBottom],
      stops: [0.0, 0.38, 0.62, 1.0],
    ),
    border: Border(
      top: BorderSide(color: glassRimBright, width: 1.2),
      left: BorderSide(color: glassRimBright, width: 1),
      right: BorderSide(color: glassRimSoft, width: 1),
      bottom: BorderSide(color: glassRimSoft, width: 1),
    ),
  );

  /// Soft drop shadow for the glass card — applied to the OUTER container
  /// in LoginScreen, never inside the ClipRRect.
  static const BoxDecoration glassShadowDecoration = BoxDecoration(
    borderRadius: BorderRadius.all(Radius.circular(32)),
    boxShadow: [
      BoxShadow(color: glassShadow, blurRadius: 28, offset: Offset(0, 14)),
    ],
  );

  // Primary — cobalt. Every primary CTA, active indicator and focus ring.
  // Ink on top is white in light mode.
  static const Color primary = Color(0xFF1D4ED8);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFD9E4FD);
  static const Color onPrimaryContainer = Color(0xFF123280);
  static const Color inversePrimary = Color(0xFF5BC0DE);

  // Secondary — the ONE accent (orange), used for the urgent / next-action
  // accent only. Never a second CTA color on the same screen, and never
  // as light-mode text on its own (orange #D97706 on light is 2.94:1).
  static const Color secondary = Color(0xFFB45309);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFFDEBC8);
  static const Color onSecondaryContainer = Color(0xFF7A4E00);

  /// Accent alias for [secondary], for clarity at call sites.
  static const Color accent = Color(0xFFB45309);

  /// Ink on the accent, alias for [onSecondary].
  static const Color onAccent = Color(0xFFFFFFFF);

  /// Pressed state for the primary CTA (a deeper cobalt, never grey).
  static const Color buttonPressed = Color(0xFF1740B8);

  // Tertiary
  static const Color tertiary = Color(0xFF047857);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFD1FAE5);
  static const Color onTertiaryContainer = Color(0xFF065F46);

  // Error
  static const Color error = Color(0xFFB3261E);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFBDDD7);
  static const Color onErrorContainer = Color(0xFF991B1B);

  // Fixed — kept for API compatibility; repointed at palette #4 values
  // (no new hexes introduced).
  static const Color primaryFixed = Color(0xFFD9E4FD);
  static const Color primaryFixedDim = Color(0xFF1D4ED8);
  static const Color onPrimaryFixed = Color(0xFF123280);
  static const Color onPrimaryFixedVariant = Color(0xFF123280);
  static const Color secondaryFixed = Color(0xFFFDEBC8);
  static const Color secondaryFixedDim = Color(0xFFB45309);
  static const Color onSecondaryFixed = Color(0xFF7A4E00);
  static const Color onSecondaryFixedVariant = Color(0xFF7A4E00);
  static const Color tertiaryFixed = Color(0xFFD1FAE5);
  static const Color tertiaryFixedDim = Color(0xFF047857);
  static const Color onTertiaryFixed = Color(0xFF065F46);
  static const Color onTertiaryFixedVariant = Color(0xFF065F46);

  // Background (alias for surface in MD3)
  static const Color background = Color(0xFFF4F6FA);
  static const Color onBackground = Color(0xFF10182B);
  static const Color surfaceVariant = Color(0xFFDFE7F2);

  // Surface tint
  static const Color surfaceTint = Color(0xFF1D4ED8);

  // ─── Semantic Status Badge Colors ─────────────────────────────────────

  /// Assigned / In-Progress — sky/cobalt tint.
  static const Color assignedBackground = Color(0xFFD9E4FD);
  static const Color assignedForeground = Color(0xFF123280);

  /// Completed / Verified — green.
  static const Color completedBackground = Color(0xFFD9F0E2);
  static const Color completedForeground = Color(0xFF0E6B41);

  /// Pending / Scheduled — amber.
  static const Color pendingBackground = Color(0xFFFFF0D0);
  static const Color pendingForeground = Color(0xFF7A4E00);

  /// Urgent / Outage / Escalation — red.
  static const Color urgentBackground = Color(0xFFFBDDD7);
  static const Color urgentForeground = Color(0xFFA62B1B);

  /// Needs review — violet.
  static const Color reviewBackground = Color(0xFFE8E1FB);
  static const Color reviewForeground = Color(0xFF5730B8);

  /// Initials-avatar background — the primary.
  static const Color avatarBackground = Color(0xFF1D4ED8);

  // ─── Ticket Status Colors ─────────────────────────────────────────────

  /// Opened tickets → green tinted background / accent (mirrors completed).
  static const Color ticketOpenedBackground = Color(0xFFD9F0E2);
  static const Color ticketOpenedForeground = Color(0xFF0E6B41);

  /// Closed tickets → grey muted background / foreground.
  static const Color ticketClosedBackground = Color(0xFFE7E5DC);
  static const Color ticketClosedForeground = Color(0xFF575E55);

  /// In-progress tickets → sky/cobalt tinted background (mirrors assigned).
  static const Color ticketInProgressBackground = Color(0xFFD9E4FD);
  static const Color ticketInProgressForeground = Color(0xFF123280);

  /// Neutral ink colors for text hierarchy
  static const Color textPrimary = Color(0xFF10182B);
  static const Color textSubtext = Color(0xFF5C6880);

  /// Stronger muted text for the dashboard team subtitle ("Centralized
  /// Tech", D22): #5C6880 on the #F4F6FA background is 5.18:1, which reads
  /// washed out at 14px — this is 7.14:1 on the same background. Keep
  /// [onSurfaceVariant] for chrome (hints, chips, chevrons); this token
  /// is only for subtitle text that must stay readable.
  static const Color subtitleStrong = Color(0xFF47536B);

  // ─── Typography ───────────────────────────────────────────────────────
  //
  // Served via google_fonts (runtime-fetched, cached on device). In widget
  // tests the fetch is disabled — see test setup — and styles fall back
  // gracefully, so tests never touch the network.
  //
  // ONE family: Plus Jakarta Sans for display / headline / body / label.
  // IBM Plex Mono ONLY for dataLg / dataMd / dataSm (request numbers, IDs).

  static const String displayFamily = 'Plus Jakarta Sans';
  static const String bodyFamily = 'Plus Jakarta Sans';
  static const String monoFamily = 'IBM Plex Mono';

  /// 28 / 800 — hero titles, screen display.
  static TextStyle get displayLg => GoogleFonts.plusJakartaSans(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    height: 1.15,
    letterSpacing: -0.01,
  );

  /// 22 / 700 — screen titles.
  static TextStyle get headlineLg => GoogleFonts.plusJakartaSans(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.25,
  );

  /// 20 / 600 — section headers, card titles.
  static TextStyle get headlineMd => GoogleFonts.plusJakartaSans(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  /// 18 / 600 — card titles.
  static TextStyle get headlineSm => GoogleFonts.plusJakartaSans(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  /// 16 / 500 — primary content.
  static TextStyle get bodyLg => GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );

  /// 14 / 400 — secondary content.
  static TextStyle get bodyMd => GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  /// 12 / 400 — captions, timestamps only; never body copy.
  static TextStyle get bodySm => GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.45,
  );

  /// 14 / 600 — button text, emphasized labels.
  static TextStyle get labelLg => GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.01,
  );

  /// 12 / 600 — form labels.
  static TextStyle get labelMd => GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.35,
    letterSpacing: 0.02,
  );

  /// 11 / 700 — tags, captions (sentence case, no letter-spacing).
  static TextStyle get labelSm => GoogleFonts.plusJakartaSans(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    height: 1.3,
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

  // ─── Spacing (kit Rule 4 scale: 4 / 8 / 12 / 16 / 24 / 32 / 48) ──────

  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceSmMd = 12;
  static const double spaceMd = 16;
  static const double spaceLg = 24;
  static const double spaceXl = 32;
  static const double spaceXxl = 48;

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
  static const double radiusXl = 24;
  static const double radiusXxl = 24;
  static const double radiusFull = 9999;

  /// Default card border radius.
  static const double cardRadius = 16;

  /// Default input / button border radius.
  static const double controlRadius = 12;

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
  //
  // Kit Rule 4: depth from surfaces + a 1px hairline, NO shadows.
  // Every list below is intentionally empty; the names are kept so
  // existing callers still compile.

  /// Level 1: cards at rest — none (surface steps carry the depth).
  static const List<BoxShadow> shadowLevel1 = [];

  /// Level 2: raised / active cards — none.
  static const List<BoxShadow> shadowLevel2 = [];

  /// Level 3: floating modals, bottom sheets, nav bars — none.
  static const List<BoxShadow> shadowLevel3 = [];

  /// Former signature glow for primary CTAs and live indicators.
  /// Kept for compatibility; now empty — no glow (kit Rule 4).
  static const List<BoxShadow> glowCyan = [];
}

/// Dark-mode twin of [FieldOpsDesignTokens]: identical API, palette #4
/// Navy / sky / orange on a deep-navy canvas. Dark is the default
/// (kit Rule 4). NEVER white ink on the sky primary — onPrimary is
/// dark navy (#0B132B).
abstract final class FieldOpsDarkTokens {
  FieldOpsDarkTokens._();

  // Surfaces
  static const Color surface = Color(0xFF0B132B);
  static const Color surfaceDim = Color(0xFF080E20);
  static const Color surfaceBright = Color(0xFF1C2541);
  static const Color surfaceContainerLowest = Color(0xFF1C2541);
  static const Color surfaceContainerLow = Color(0xFF1C2541);
  static const Color surfaceContainer = Color(0xFF1C2541);
  static const Color surfaceContainerHigh = Color(0xFF27314A);
  static const Color surfaceContainerHighest = Color(0xFF2E3A57);
  static const Color onSurface = Color(0xFFECF1FB);
  static const Color onSurfaceVariant = Color(0xFF94A3B8);
  static const Color inverseSurface = Color(0xFFF4F6FA);
  static const Color inverseOnSurface = Color(0xFF10182B);

  // Outline
  static const Color outline = Color(0xFF3A506B);
  static const Color outlineVariant = Color(0xFF27314A);
  static const Color cardBorder = Color(0xFF3A506B);

  // Text-field fill / border (login + forms).
  static const Color fieldFill = Color(0xFF111A33);
  static const Color fieldBorder = Color(0xFF263253);

  // Primary — sky; ink on top is dark navy, NEVER white (white on sky
  // is only 2.09:1).
  static const Color primary = Color(0xFF5BC0DE);
  static const Color onPrimary = Color(0xFF0B132B);
  static const Color primaryContainer = Color(0xFF16425A);
  static const Color onPrimaryContainer = Color(0xFFBFE9F5);
  static const Color inversePrimary = Color(0xFF1D4ED8);

  // Secondary — the ONE accent (orange).
  static const Color secondary = Color(0xFFD97706);
  static const Color onSecondary = Color(0xFF0B132B);
  static const Color secondaryContainer = Color(0xFF4A2E0A);
  static const Color onSecondaryContainer = Color(0xFFFDBA74);

  /// Accent alias for [secondary], for clarity at call sites.
  static const Color accent = Color(0xFFD97706);

  /// Ink on the accent, alias for [onSecondary].
  static const Color onAccent = Color(0xFF0B132B);

  /// Pressed state for the primary CTA.
  static const Color buttonPressed = Color(0xFF8ED8EC);

  // Tertiary
  static const Color tertiary = Color(0xFF34D399);
  static const Color onTertiary = Color(0xFF04120C);
  static const Color tertiaryContainer = Color(0xFF064E3B);
  static const Color onTertiaryContainer = Color(0xFFA7F3D0);

  // Error
  static const Color error = Color(0xFFFB7185);
  static const Color onError = Color(0xFF0B132B);
  static const Color errorContainer = Color(0xFF4C1010);
  static const Color onErrorContainer = Color(0xFFFECACA);

  // Fixed — kept for API compatibility; repointed at palette #4 values
  // (no new hexes introduced).
  static const Color primaryFixed = Color(0xFF16425A);
  static const Color primaryFixedDim = Color(0xFF5BC0DE);
  static const Color onPrimaryFixed = Color(0xFFBFE9F5);
  static const Color onPrimaryFixedVariant = Color(0xFFBFE9F5);
  static const Color secondaryFixed = Color(0xFF4A2E0A);
  static const Color secondaryFixedDim = Color(0xFFD97706);
  static const Color onSecondaryFixed = Color(0xFFFDBA74);
  static const Color onSecondaryFixedVariant = Color(0xFFFDBA74);
  static const Color tertiaryFixed = Color(0xFF064E3B);
  static const Color tertiaryFixedDim = Color(0xFF34D399);
  static const Color onTertiaryFixed = Color(0xFFA7F3D0);
  static const Color onTertiaryFixedVariant = Color(0xFFA7F3D0);

  // Background (alias for surface in MD3)
  static const Color background = Color(0xFF0B132B);
  static const Color onBackground = Color(0xFFECF1FB);
  static const Color surfaceVariant = Color(0xFF2E3A57);

  // Surface tint
  static const Color surfaceTint = Color(0xFF5BC0DE);

  // ─── Semantic Status Badge Colors (dark) ──────────────────────────────

  /// Assigned / In-Progress — sky/cobalt tint.
  static const Color assignedBackground = Color(0xFF16425A);
  static const Color assignedForeground = Color(0xFF8ED8EC);

  /// Completed / Verified — green.
  static const Color completedBackground = Color(0xFF064E3B);
  static const Color completedForeground = Color(0xFF6EE7B7);

  /// Pending / Scheduled — amber.
  static const Color pendingBackground = Color(0xFF4A2E0A);
  static const Color pendingForeground = Color(0xFFFBBF24);

  /// Urgent / Outage / Escalation — red.
  static const Color urgentBackground = Color(0xFF4C1010);
  static const Color urgentForeground = Color(0xFFFCA5A5);

  /// Needs review — violet.
  static const Color reviewBackground = Color(0xFF2E1A5E);
  static const Color reviewForeground = Color(0xFFC4B5FD);

  /// Initials-avatar background — the primary.
  static const Color avatarBackground = Color(0xFF5BC0DE);

  // ─── Ticket Status Colors (dark) ──────────────────────────────────────

  /// Opened tickets → green (mirrors completed).
  static const Color ticketOpenedBackground = Color(0xFF064E3B);
  static const Color ticketOpenedForeground = Color(0xFF6EE7B7);

  /// Closed tickets → grey muted background / foreground.
  static const Color ticketClosedBackground = Color(0xFF27314A);
  static const Color ticketClosedForeground = Color(0xFF94A3B8);

  /// In-progress tickets → sky tint (mirrors assigned).
  static const Color ticketInProgressBackground = Color(0xFF16425A);
  static const Color ticketInProgressForeground = Color(0xFF8ED8EC);

  static const Color textPrimary = Color(0xFFECF1FB);
  static const Color textSubtext = Color(0xFF94A3B8);

  /// Stronger muted text for the dashboard team subtitle (D22): #94A3B8
  /// on the #0B132B background is 7.17:1 — already well above WCAG AA,
  /// so the dark value intentionally matches [onSurfaceVariant] (darkening
  /// it would only lower the contrast). The light twin is #47536B.
  static const Color subtitleStrong = Color(0xFF94A3B8);

  // ─── Typography (same scale as light) ─────────────────────────────────

  static const String displayFamily = 'Plus Jakarta Sans';
  static const String bodyFamily = 'Plus Jakarta Sans';
  static const String monoFamily = 'IBM Plex Mono';

  static TextStyle get displayLg => GoogleFonts.plusJakartaSans(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    height: 1.15,
    letterSpacing: -0.01,
  );
  static TextStyle get headlineLg => GoogleFonts.plusJakartaSans(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.25,
  );
  static TextStyle get headlineMd => GoogleFonts.plusJakartaSans(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );
  static TextStyle get headlineSm => GoogleFonts.plusJakartaSans(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );
  static TextStyle get bodyLg => GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );
  static TextStyle get bodyMd => GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  static TextStyle get bodySm => GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.45,
  );
  static TextStyle get labelLg => GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.01,
  );
  static TextStyle get labelMd => GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.35,
    letterSpacing: 0.02,
  );
  static TextStyle get labelSm => GoogleFonts.plusJakartaSans(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );
  static TextStyle get dataLg => GoogleFonts.ibmPlexMono(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );
  static TextStyle get dataMd => GoogleFonts.ibmPlexMono(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );
  static TextStyle get dataSm => GoogleFonts.ibmPlexMono(
    fontSize: 11.5,
    fontWeight: FontWeight.w500,
    height: 1.35,
  );

  // ─── Spacing (kit Rule 4 scale: 4 / 8 / 12 / 16 / 24 / 32 / 48) ──────

  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceSmMd = 12;
  static const double spaceMd = 16;
  static const double spaceLg = 24;
  static const double spaceXl = 32;
  static const double spaceXxl = 48;
  static const double pageMargin = 16;
  static const double cardGap = 12;
  static const double cardPadding = 16;

  // ─── Shapes ───────────────────────────────────────────────────────────

  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;
  static const double radiusXxl = 24;
  static const double radiusFull = 9999;
  static const double cardRadius = 16;
  static const double controlRadius = 12;

  // ─── Component Dimensions ─────────────────────────────────────────────

  static const double minTouchTarget = 48;
  static const double inputHeight = 52;
  static const double badgeHeight = 26;
  static const double badgePaddingH = 10;
  static const double badgeDotSize = 6;
  static const double badgeIconSize = 14;

  // ─── Elevation Shadows (dark) ─────────────────────────────────────────
  //
  // Kit Rule 4: depth from surfaces + a 1px hairline, NO shadows.
  // Every list below is intentionally empty; the names are kept so
  // existing callers still compile.

  static const List<BoxShadow> shadowLevel1 = [];
  static const List<BoxShadow> shadowLevel2 = [];
  static const List<BoxShadow> shadowLevel3 = [];

  /// Former signature glow (dark). Kept for compatibility; now empty.
  static const List<BoxShadow> glowCyan = [];
}
