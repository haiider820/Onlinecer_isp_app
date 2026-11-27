import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isp_onlinecer/core/router/app_router.dart';
import 'package:isp_onlinecer/core/storage/secure_storage.dart';
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
  }) async =>
      store[key];

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
  }) async =>
      store.remove(key);

  @override
  Future<void> deleteAll({
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async =>
      store.clear();

  @override
  Future<bool> containsKey({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async =>
      store.containsKey(key);
}

/// D20 dashboard (Umair, Centralized Tech): the live counts from the
/// 2026-11-27 morning check — 2 flows, 0 open tickets, 47 inventory
/// items, 0 waiting ONUs, 1 request awaiting authorization.
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
}) async {
  final storage = SecureStorage(_InMemoryFlutterSecureStorage());
  final container = ProviderContainer(
    overrides: [
      secureStorageProvider.overrideWithValue(storage),
      notificationUnreadCountProvider.overrideWith((ref) async => 0),
      dashboardSummaryProvider.overrideWith((ref) async => _summary),
      dashboardTeamFlowCountProvider.overrideWith((ref) async => 2),
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
      child: MaterialApp.router(routerConfig: _router(showNewRequest: showNewRequest)),
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

  testWidgets('renders all five tiles with live counts and labels', (tester) async {
    await _pumpDashboard(tester);

    expect(find.text('Umair Shafique'), findsOneWidget);
    expect(find.text('Centralized Tech'), findsOneWidget);
    expect(find.text('Connection Flow'), findsOneWidget);
    expect(find.text('My Tickets'), findsOneWidget);
    expect(find.text('Inventory Items'), findsOneWidget);
    expect(find.text('Waiting ONUs'), findsOneWidget);
    expect(find.text('ONU Authorization'), findsOneWidget);
    expect(find.text('2'), findsOneWidget); // flows
    expect(find.text('0'), findsNWidgets(2)); // open tickets + waiting ONUs
    expect(find.text('47'), findsOneWidget); // inventory
    expect(find.text('1'), findsOneWidget); // pending authorization
    expect(find.text('Available'), findsOneWidget);
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

  testWidgets('tiles are compact: 85% width, ~47px tall (D20 size spec)',
      (tester) async {
    await _pumpDashboard(tester);

    // The ListView carries 16dp horizontal padding, so the tile's parent
    // width is 800 - 32 = 768; 85% of that is 652.8, centred (73.6dp
    // margin on each side).
    final tile = find.byType(OpsCard).first;
    final tileSize = tester.getSize(tile);
    expect(tileSize.width, closeTo(652.8, 1.0));
    expect(tester.getTopLeft(tile).dx, closeTo(73.6, 1.0));
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
    expect(tester.widget<Text>(find.text('2')).style?.fontSize, 20);
  });

  testWidgets('a count still loading shows a dash', (tester) async {
    final pending = Completer<int>();
    await _pumpDashboard(tester, extraOverrides: [
      dashboardInventoryCountProvider.overrideWith(
        (ref) => pending.future,
      ),
    ]);

    expect(find.text('–'), findsOneWidget);
    expect(find.text('47'), findsNothing);

    pending.complete(47);
    await tester.pumpAndSettle();
    expect(find.text('47'), findsOneWidget);
    expect(find.text('–'), findsNothing);
  });

  testWidgets('a failed count falls back to 0', (tester) async {
    await _pumpDashboard(tester, extraOverrides: [
      dashboardInventoryCountProvider.overrideWith(
        (ref) async => throw Exception('boom'),
      ),
    ]);

    // Open tickets 0 + waiting ONUs 0 + failed inventory 0.
    expect(find.text('0'), findsNWidgets(3));
    expect(find.text('47'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Connection Flow opens the New Request flow step (survey team)',
      (tester) async {
    await _pumpDashboard(tester);

    await tester.tap(find.text('Connection Flow'));
    await tester.pumpAndSettle();

    expect(find.text('new-request-stub'), findsOneWidget);
  });

  testWidgets('Connection Flow opens the team list when creation is off',
      (tester) async {
    await _pumpDashboard(tester, showNewRequest: false);

    expect(find.text('New request'), findsNothing);

    await tester.tap(find.text('Connection Flow'));
    await tester.pumpAndSettle();

    expect(find.text('survey-list-stub'), findsOneWidget);
  });

  testWidgets('My Tickets opens the tickets list', (tester) async {
    await _pumpDashboard(tester);

    await tester.tap(find.text('My Tickets'));
    await tester.pumpAndSettle();

    expect(find.text('tickets-stub'), findsOneWidget);
  });

  testWidgets('Inventory Items opens the team list (no catalog screen yet)',
      (tester) async {
    await _pumpDashboard(tester);

    await tester.tap(find.text('Inventory Items'));
    await tester.pumpAndSettle();

    expect(find.text('survey-list-stub'), findsOneWidget);
  });

  testWidgets('Waiting ONUs opens the OLT list for the first pending request',
      (tester) async {
    await _pumpDashboard(tester);

    await tester.tap(find.text('Waiting ONUs'));
    await tester.pumpAndSettle();

    expect(find.text('olt-list-stub'), findsOneWidget);
  });

  testWidgets('ONU Authorization opens the first pending request detail',
      (tester) async {
    await _pumpDashboard(tester);

    await tester.tap(find.text('ONU Authorization'));
    await tester.pumpAndSettle();

    expect(find.text('installation-detail-stub'), findsOneWidget);
  });

  testWidgets('settings gear opens the theme sheet and persists the choice',
      (tester) async {
    final container = await _pumpDashboard(tester);

    expect(container.read(themeModeProvider), ThemeMode.system);

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('System'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(container.read(themeModeProvider), ThemeMode.dark);
  });

  testWidgets('logout icon asks for confirmation', (tester) async {
    await _pumpDashboard(tester);

    await tester.tap(find.byTooltip('Log out'));
    await tester.pumpAndSettle();

    expect(find.text('Log out?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Log out?'), findsNothing);
    expect(find.text('Umair Shafique'), findsOneWidget);
  });
}
