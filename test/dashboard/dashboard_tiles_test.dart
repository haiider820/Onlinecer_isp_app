import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isp_onlinecer/core/router/app_router.dart';
import 'package:isp_onlinecer/core/storage/secure_storage.dart';
import 'package:isp_onlinecer/core/theme/app_theme.dart';
import 'package:isp_onlinecer/core/theme/field_ops_design_tokens.dart';
import 'package:isp_onlinecer/core/theme/theme_mode_provider.dart';
import 'package:isp_onlinecer/features/auth/presentation/providers.dart';
import 'package:isp_onlinecer/features/dashboard/presentation/dashboard_tiles_providers.dart';
import 'package:isp_onlinecer/features/notifications/presentation/notification_providers.dart';
import 'package:isp_onlinecer/features/survey/presentation/dashboard_providers.dart';
import 'package:isp_onlinecer/models/auth.dart';
import 'package:isp_onlinecer/models/connection_request.dart';
import 'package:isp_onlinecer/models/dashboard.dart';
import 'package:isp_onlinecer/models/team.dart';
import 'package:isp_onlinecer/shared/widgets/ops_widgets.dart';
import 'package:isp_onlinecer/shared/widgets/team_dashboard_screen.dart';

/// In-memory [FlutterSecureStorage] so widget tests don't hit the platform
/// channel. Only the keys [SecureStorage] uses are needed.
class _InMemoryFlutterSecureStorage extends FlutterSecureStorage {
  final Map<String, String> store = {};

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => store[key];

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      store.remove(key);
    } else {
      store[key] = value;
    }
  }

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => store.remove(key);

  @override
  Future<void> deleteAll({
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => store.clear();

  @override
  Future<bool> containsKey({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => store.containsKey(key);
}

/// D20 dashboard (Umair, Centralized Tech): the live counts from the
/// 2026-11-27 morning check — 3 requests across all stages (D25: the
/// Connection Flow tile counts the unfiltered queue now, not team flows),
/// 0 open tickets, 47 inventory items, 0 waiting ONUs, 1 request awaiting
/// authorization.
const _summary = DashboardSummary(
  employee: Employee(
    id: 'emp-1',
    name: 'Umair Shafique',
    team: Team(
      id: 'team-1',
      name: 'Centralized Tech',
      functionalTeamType: 'survey',
    ),
  ),
);

const Map<String, Object?> _pendingPageMap = {
  'data': [
    {
      'id': 'req-1',
      'request_number': 'CRQ-20261125-N2ON1HQK',
      'status': 'installation_assigned',
      'customer_name': 'test',
    },
  ],
  'meta': {'current_page': 1, 'per_page': 15, 'total': 1, 'last_page': 1},
};

const Map<String, Object?> _emptyPendingPageMap = {
  'data': [],
  'meta': {'current_page': 1, 'per_page': 15, 'total': 0, 'last_page': 1},
};

GoRouter _router({bool showNewRequest = true}) {
  return GoRouter(
    initialLocation: Routes.dashboard,
    routes: [
      GoRoute(
        path: Routes.dashboard,
        builder: (context, state) => TeamDashboardScreen(
          featureName: 'Survey',
          defaultEmployeeLabel: 'Survey Employee',
          defaultTeamLabel: 'Survey Team',
          listRoute: Routes.surveyList,
          detailRouteFor: Routes.surveyDetailFor,
          showNewRequest: showNewRequest,
        ),
      ),
      GoRoute(
        path: Routes.ticketsList,
        builder: (context, state) => const Text('tickets-stub'),
      ),
      GoRoute(
        path: Routes.newRequest,
        builder: (context, state) => const Text('new-request-stub'),
      ),
      GoRoute(
        path: Routes.surveyList,
        builder: (context, state) => const Text('survey-list-stub'),
      ),
      GoRoute(
        path: Routes.allRequests,
        builder: (context, state) => const Text('all-requests-stub'),
      ),
      GoRoute(
        path: Routes.inventory,
        builder: (context, state) => const Text('inventory-stub'),
      ),
      GoRoute(
        path: Routes.waitingOnusGlobal,
        builder: (context, state) => const Text('waiting-global-stub'),
      ),
      GoRoute(
        path: Routes.pendingAuthorization,
        builder: (context, state) => const Text('pending-auth-stub'),
      ),
      GoRoute(
        path: Routes.surveyDetail,
        builder: (context, state) => const Text('survey-detail-stub'),
      ),
      GoRoute(
        path: Routes.installationDetail,
        builder: (context, state) => const Text('installation-detail-stub'),
      ),
      GoRoute(
        path: Routes.oltList,
        builder: (context, state) => const Text('olt-list-stub'),
      ),
    ],
  );
}

Future<ProviderContainer> _pumpDashboard(
  WidgetTester tester, {
  bool showNewRequest = true,
  List<Override> extraOverrides = const [],
  ThemeMode themeMode = ThemeMode.light,
}) async {
  final storage = SecureStorage(_InMemoryFlutterSecureStorage());
  final container = ProviderContainer(
    overrides: [
      secureStorageProvider.overrideWithValue(storage),
      notificationUnreadCountProvider.overrideWith((ref) async => 0),
      dashboardSummaryProvider.overrideWith((ref) async => _summary),
      dashboardAllRequestsCountProvider.overrideWith((ref) async => 3),
      dashboardOpenTicketCountProvider.overrideWith((ref) async => 0),
      dashboardInventoryCountProvider.overrideWith((ref) async => 47),
      dashboardWaitingOnuCountProvider.overrideWith((ref) async => 0),
      dashboardPendingAuthorizationProvider.overrideWith(
        (ref) async => ConnectionRequestPage.fromJson(_pendingPageMap),
      ),
      ...extraOverrides,
    ],
  );
  addTearDown(container.dispose);

  // Tall viewport: all five tiles + the primary button must be built
  // (the ListView is lazy, so a 600px window would leave the last tiles
  // unbuilt and the assertions would miss them).
  tester.view.physicalSize = const Size(800, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        routerConfig: _router(showNewRequest: showNewRequest),
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: themeMode,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  // google_fonts serves typefaces via runtime HTTP fetch; disable that in
  // tests so widget pumps never touch the network (styles fall back to the
  // platform default, which is fine for assertions).
  GoogleFonts.config.allowRuntimeFetching = false;

  testWidgets('renders all five tiles with live counts and labels', (
    tester,
  ) async {
    await _pumpDashboard(tester);

    expect(find.text('Umair Shafique'), findsOneWidget);
    expect(find.text('Centralized Tech'), findsOneWidget);
    expect(find.text('Connection Flow'), findsOneWidget);
    expect(find.text('My Tickets'), findsOneWidget);
    expect(find.text('Inventory Items'), findsOneWidget);
    expect(find.text('Waiting ONUs'), findsOneWidget);
    expect(find.text('ONU Authorization'), findsOneWidget);
    expect(find.text('3'), findsOneWidget); // all requests across stages
    expect(find.text('0'), findsNWidgets(2)); // open tickets + waiting ONUs
    expect(find.text('47'), findsOneWidget); // inventory
    expect(find.text('1'), findsOneWidget); // pending authorization
    expect(find.text('Requests'), findsOneWidget);
    expect(find.text('Open'), findsOneWidget);
    expect(find.text('Total'), findsOneWidget);
    expect(find.text('Waiting'), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);
    expect(find.text('New request'), findsOneWidget);

    expect(tester.takeException(), isNull);
  });

  testWidgets('Recent Requests is gone (D20 removal)', (tester) async {
    await _pumpDashboard(tester);

    expect(find.text('Recent Requests'), findsNothing);
    expect(find.text('View All'), findsNothing);
    expect(find.text('GPS SIGNAL ACTIVE'), findsNothing);
    expect(find.text('Good morning'), findsNothing);
    expect(find.text('Good afternoon'), findsNothing);
    expect(find.text('Good evening'), findsNothing);
    // The tiles and the primary button stay.
    expect(find.text('Connection Flow'), findsOneWidget);
    expect(find.text('New request'), findsOneWidget);
  });

  testWidgets('tiles are full width, ~47px tall (D25 size spec)', (
    tester,
  ) async {
    await _pumpDashboard(tester);

    // D25: tiles are as wide as the "+ New request" button — the full
    // ListView content width (800 − 32 padding = 768), left edge at 16.
    // The 85% width (652.8, 73.6 margins) truncated titles on a 360dp
    // phone ("Connecti...").
    final tile = find.byType(OpsCard).first;
    final tileSize = tester.getSize(tile);
    expect(tileSize.width, closeTo(768, 1.0));
    expect(tester.getTopLeft(tile).dx, closeTo(16, 1.0));
    // 7 + 20 (number) + 2 + 11 (label) + 7 = 47dp tall — compact, not
    // the ~80dp preview tile. A small tolerance covers font-metric
    // variance; the point is the tile is slim, roughly half the preview.
    expect(tileSize.height, greaterThan(40));
    expect(tileSize.height, lessThan(52));

    // Component sizes from the spec: 32px icon chip (proven by the 47px
    // tile height above — a 48px chip would make the tile ~62px tall),
    // 20px icon glyph, 14px title, 20px number.
    expect(tester.widget<Icon>(find.byIcon(Icons.link)).size, 20);
    expect(
      tester.widget<Text>(find.text('Connection Flow')).style?.fontSize,
      14,
    );
    expect(tester.widget<Text>(find.text('3')).style?.fontSize, 20);
  });

  testWidgets('a count still loading shows a dash', (tester) async {
    final pending = Completer<int>();
    await _pumpDashboard(
      tester,
      extraOverrides: [
        dashboardInventoryCountProvider.overrideWith((ref) => pending.future),
      ],
    );

    expect(find.text('–'), findsOneWidget);
    expect(find.text('47'), findsNothing);

    pending.complete(47);
    await tester.pumpAndSettle();
    expect(find.text('47'), findsOneWidget);
    expect(find.text('–'), findsNothing);
  });

  testWidgets('a failed count falls back to 0', (tester) async {
    await _pumpDashboard(
      tester,
      extraOverrides: [
        dashboardInventoryCountProvider.overrideWith(
          (ref) async => throw Exception('boom'),
        ),
      ],
    );

    // Open tickets 0 + waiting ONUs 0 + failed inventory 0.
    expect(find.text('0'), findsNWidgets(3));
    expect(find.text('47'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Connection Flow opens the all-requests list (D25)', (
    tester,
  ) async {
    await _pumpDashboard(tester);

    await tester.tap(find.text('Connection Flow'));
    await tester.pumpAndSettle();

    expect(find.text('all-requests-stub'), findsOneWidget);
    expect(find.text('new-request-stub'), findsNothing);
  });

  testWidgets('Connection Flow opens the all-requests list when creation is off', (
    tester,
  ) async {
    await _pumpDashboard(tester, showNewRequest: false);

    expect(find.text('New request'), findsNothing);

    await tester.tap(find.text('Connection Flow'));
    await tester.pumpAndSettle();

    expect(find.text('all-requests-stub'), findsOneWidget);
  });

  testWidgets('My Tickets opens the tickets list', (tester) async {
    await _pumpDashboard(tester);

    await tester.tap(find.text('My Tickets'));
    await tester.pumpAndSettle();

    expect(find.text('tickets-stub'), findsOneWidget);
  });

  testWidgets('Inventory Items opens the catalog (D25)', (tester) async {
    await _pumpDashboard(tester);

    await tester.tap(find.text('Inventory Items'));
    await tester.pumpAndSettle();

    expect(find.text('inventory-stub'), findsOneWidget);
  });

  testWidgets('Waiting ONUs opens the global waiting screen (D25)', (
    tester,
  ) async {
    await _pumpDashboard(tester);

    await tester.tap(find.text('Waiting ONUs'));
    await tester.pumpAndSettle();

    expect(find.text('waiting-global-stub'), findsOneWidget);
  });

  testWidgets('ONU Authorization opens the first pending request detail', (
    tester,
  ) async {
    await _pumpDashboard(tester);

    await tester.tap(find.text('ONU Authorization'));
    await tester.pumpAndSettle();

    expect(find.text('installation-detail-stub'), findsOneWidget);
  });

  testWidgets(
    'ONU Authorization falls back to the pending-authorization list when nothing is pending (D25)',
    (tester) async {
      await _pumpDashboard(
        tester,
        extraOverrides: [
          dashboardPendingAuthorizationProvider.overrideWith(
            (ref) async => ConnectionRequestPage.fromJson(
              _emptyPendingPageMap,
            ),
          ),
        ],
      );

      await tester.tap(find.text('ONU Authorization'));
      await tester.pumpAndSettle();

      // The survey list is NOT the fallback any more (D20–D24 bug).
      expect(find.text('pending-auth-stub'), findsOneWidget);
      expect(find.text('survey-list-stub'), findsNothing);
    },
  );

  testWidgets('settings gear opens the theme sheet and persists the choice', (
    tester,
  ) async {
    final container = await _pumpDashboard(tester);

    expect(container.read(themeModeProvider), ThemeMode.system);

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('System'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);
    // D22: the sheet also carries the Log out row now.
    expect(find.text('Log out'), findsOneWidget);

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(container.read(themeModeProvider), ThemeMode.dark);
  });

  testWidgets('logout lives in the settings sheet and asks for confirmation', (
    tester,
  ) async {
    await _pumpDashboard(tester);

    // D22: no logout affordance on the dashboard itself any more — the
    // red-tinted logout circle in the compact header is gone.
    expect(find.byTooltip('Log out'), findsNothing);

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();

    expect(find.text('Log out?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Log out?'), findsNothing);
    expect(find.text('Umair Shafique'), findsOneWidget);
  });

  testWidgets('action icons are grouped in the app bar (D22)', (tester) async {
    await _pumpDashboard(tester);

    // Theme toggle, bell, settings — all three in the BrandedHeader.
    expect(find.byIcon(Icons.brightness_auto_outlined), findsOneWidget);
    expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    // And nothing else actionable in the compact header below the bar.
    expect(find.byIcon(Icons.logout), findsNothing);
  });

  testWidgets('count block is centered, min-width 76; title ellipsizes (D25)', (
    tester,
  ) async {
    await _pumpDashboard(tester);

    // One count column per tile: min-width 76dp since D25 (was 88dp — see
    // the D25 comment in _DashboardTile: on a real phone every label fits
    // in 76dp; the wide test fallback font grows the column instead of
    // wrapping).
    final countBlocks = find.byWidgetPredicate(
      (widget) => widget is ConstrainedBox && widget.constraints.minWidth == 76,
    );
    expect(countBlocks, findsNWidgets(5));

    // Number and label share one center line inside every tile's block
    // (scoped per block — two tiles show '0', so a bare text lookup
    // would pair the wrong number with a label).
    for (final block in countBlocks.evaluate()) {
      final texts = find.descendant(
        of: find.byWidget(block.widget),
        matching: find.byType(Text),
      );
      expect(texts, findsNWidgets(2));
      final numberCenter = tester.getCenter(texts.at(0));
      final labelCenter = tester.getCenter(texts.at(1));
      expect(numberCenter.dx, closeTo(labelCenter.dx, 0.5));
    }

    // Long title never collides with the count block: maxLines 1 +
    // ellipsis, and at least 12dp between the title text and its tile's
    // count column.
    final title = tester.widget<Text>(find.text('ONU Authorization'));
    expect(title.maxLines, 1);
    expect(title.overflow, TextOverflow.ellipsis);
    final titleRect = tester.getRect(find.text('ONU Authorization'));
    final onuBlock = countBlocks.evaluate().firstWhere((block) {
      final pending = find.descendant(
        of: find.byWidget(block.widget),
        matching: find.text('Pending'),
      );
      return pending.evaluate().isNotEmpty;
    });
    final blockRect = tester.getRect(find.byWidget(onuBlock.widget));
    expect(blockRect.left - titleRect.right, greaterThanOrEqualTo(12));
  });

  testWidgets('titles render fully at 768dp viewport width (D25)', (
    tester,
  ) async {
    await _pumpDashboard(tester);

    // D25: full-width tiles must show every title whole — the 85% width
    // truncated "Connection Flow" to "Connecti..." on a 360dp phone.
    // RenderParagraph.didExceedMaxLines is the honest assertion here: the
    // Text widgets still carry maxLines 1 + ellipsis, so only a real
    // layout overflow flips this flag.
    //
    // NOTE on 360dp: this does NOT prove the phone fits — the widget-test
    // fallback font is ~2x wider than Plus Jakarta Sans, so a 360dp pump
    // would ellipsize even when the phone is fine. The layout math at
    // 768dp (523dp of title room) plus the 360dp arithmetic in the D25
    // entry (~140dp of title room vs ~124dp for "ONU Authorization") is
    // the argument; the phone check stays open.
    for (final title in [
      'Connection Flow',
      'My Tickets',
      'Inventory Items',
      'Waiting ONUs',
      'ONU Authorization',
    ]) {
      final paragraph = tester.renderObject<RenderParagraph>(
        find.text(title),
      );
      expect(paragraph.didExceedMaxLines, isFalse, reason: title);
    }
  });

  testWidgets('all five tiles have identical height and padding (D22)', (
    tester,
  ) async {
    await _pumpDashboard(tester);

    final cards = find.byType(OpsCard);
    expect(cards, findsNWidgets(5));
    final heights = cards
        .evaluate()
        .map((e) => tester.getSize(find.byWidget(e.widget)).height)
        .toList();
    for (final height in heights) {
      expect(height, closeTo(heights.first, 0.5));
    }
    for (final element in cards.evaluate()) {
      expect(
        (element.widget as OpsCard).padding,
        const EdgeInsets.symmetric(vertical: 7, horizontal: 12),
      );
    }
  });

  testWidgets('New request button is pinned at the bottom (D22)', (
    tester,
  ) async {
    await _pumpDashboard(tester);

    // Viewport 800×1400, 16dp bottom margin: the button's bottom edge
    // sits at 1400 − 16 = 1384 (the 64dp app bar is above the body, so
    // it does not subtract from the button position). byWidgetPredicate
    // with `is` — not find.byType — because FilledButton.icon builds
    // the private _FilledButtonWithIcon subclass.
    final buttonRect = tester.getRect(
      find.byWidgetPredicate((widget) => widget is FilledButton),
    );
    expect(buttonRect.bottom, closeTo(1384, 2));
    // The last tile ends above the button — it does not scroll away
    // with the list.
    final lastTile = tester.getRect(find.byType(OpsCard).last);
    expect(lastTile.bottom, lessThan(buttonRect.top));
  });

  testWidgets('logo renders at 32dp in the dashboard header (D22)', (
    tester,
  ) async {
    await _pumpDashboard(tester);

    final logo = tester.widget<Image>(find.byType(Image).first);
    expect(logo.height, 32);
  });

  testWidgets('team subtitle uses the high-contrast tone, light theme (D22)', (
    tester,
  ) async {
    await _pumpDashboard(tester);

    final subtitle = tester.widget<Text>(find.text('Centralized Tech'));
    expect(subtitle.style?.color, FieldOpsDesignTokens.subtitleStrong);
  });

  testWidgets('dashboard renders in dark theme with the dark subtitle (D22)', (
    tester,
  ) async {
    await _pumpDashboard(tester, themeMode: ThemeMode.dark);

    // Same tiles, counts and header in dark mode.
    expect(find.text('Umair Shafique'), findsOneWidget);
    expect(find.text('Centralized Tech'), findsOneWidget);
    expect(find.text('Connection Flow'), findsOneWidget);
    expect(find.text('ONU Authorization'), findsOneWidget);
    expect(find.text('47'), findsOneWidget);
    expect(find.text('New request'), findsOneWidget);

    final subtitle = tester.widget<Text>(find.text('Centralized Tech'));
    expect(subtitle.style?.color, FieldOpsDarkTokens.subtitleStrong);
    expect(tester.takeException(), isNull);
  });

  test('subtitle contrast is WCAG AA (4.5:1) in both themes (D22)', () {
    // Light: subtitleStrong #47536B on #F4F6FA = 7.14:1 (was 5.18:1
    // with onSurfaceVariant #5C6880). Dark: subtitleStrong #94A3B8 on
    // #0B132B = 7.17:1 (same value as onSurfaceVariant, kept deliberately
    // — darkening it would only lower the contrast).
    expect(
      _contrastRatio(
        FieldOpsDesignTokens.subtitleStrong,
        FieldOpsDesignTokens.background,
      ),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      _contrastRatio(
        FieldOpsDarkTokens.subtitleStrong,
        FieldOpsDarkTokens.background,
      ),
      greaterThanOrEqualTo(4.5),
    );
  });
}

/// WCAG 2.x relative-luminance contrast ratio between two opaque colors.
double _contrastRatio(Color foreground, Color background) {
  double luminance(Color color) {
    double channel(double c) {
      return c <= 0.04045
          ? c / 12.92
          : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
    }

    return 0.2126 * channel(color.r) +
        0.7152 * channel(color.g) +
        0.0722 * channel(color.b);
  }

  final light = luminance(foreground);
  final dark = luminance(background);
  final brightest = math.max(light, dark);
  final darkest = math.min(light, dark);
  return (brightest + 0.05) / (darkest + 0.05);
}
