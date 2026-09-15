import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isp_onlinecer/core/constants/app_constants.dart';
import 'package:isp_onlinecer/core/storage/secure_storage.dart';
import 'package:isp_onlinecer/features/auth/presentation/providers.dart';
import 'package:isp_onlinecer/features/installation/data/inventory_network.dart';
import 'package:isp_onlinecer/features/installation/data/inventory_repository.dart';
import 'package:isp_onlinecer/features/installation/presentation/installation_map_providers.dart';
import 'package:isp_onlinecer/features/installation/presentation/installation_providers.dart';
import 'package:isp_onlinecer/features/installation/presentation/installation_request_detail_screen.dart';
import 'package:isp_onlinecer/features/survey/data/connection_request_network.dart';
import 'package:isp_onlinecer/features/survey/data/connection_request_repository.dart';
import 'package:isp_onlinecer/features/survey/data/dashboard_network.dart';
import 'package:isp_onlinecer/features/survey/data/dashboard_repository.dart';
import 'package:isp_onlinecer/features/survey/data/route_network.dart';
import 'package:isp_onlinecer/features/survey/data/route_repository.dart';
import 'package:isp_onlinecer/features/survey/presentation/connection_request_providers.dart';
import 'package:isp_onlinecer/features/survey/presentation/dashboard_providers.dart';
import 'package:isp_onlinecer/features/survey/presentation/route_providers.dart';
import 'package:isp_onlinecer/main.dart';
import 'package:isp_onlinecer/shared/widgets/location_map.dart';

import '../helpers/fake_tile_provider.dart';

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

// ─── Fixtures ───────────────────────────────────────────────────────────────

const _requestId = 'req_ist1';
const _requestNumber = 'CRQ-20260911-IN21';

const _requestMap = {
  'id': _requestId,
  'request_number': _requestNumber,
  'status': 'installation_assigned',
  'customer_name': 'Rahim Uddin',
  'customer_type': 'Residential',
  'customer_phone': '+8801712345678',
  'customer_area': 'Dhanmondi',
  'customer_address': 'House 12, Road 5, Dhanmondi',
};

const _dashboardMap = {
  'employee': {
    'id': 'emp_2',
    'name': 'Tanvir Installer',
    'team': {'id': 'team_2', 'name': 'Installation Team', 'functional_team_type': 'installation'},
  },
  'stats': {
    'connection_requests': {'pending': 4, 'completed': 1, 'total': 5},
  },
  'recent_connection_requests': [_requestMap],
};

const _pageMap = {
  'data': [_requestMap],
  'meta': {'current_page': 1, 'per_page': 15, 'total': 1, 'last_page': 1},
};

const _planMap = {'id': 'plan_5', 'name': 'Fiber 40 Mbps', 'price_minor': 200000};

/// Detail with a priced plan but no saved locations: the map card shows its
/// empty placeholder (no route call) and the form's DP starts blank.
const _detailNoLocations = {
  'data': {
    ..._requestMap,
    'requested_plan': _planMap,
    'current_team': {
      'id': 'team_2',
      'name': 'Installation Team',
      'functional_team_type': 'installation',
    },
  },
  'allowed_action': 'complete_installation',
};

/// Detail carrying the survey stage's previously-saved locations so the merged
/// screen seeds both map markers and triggers the debounced route call.
const _detailWithSurveyData = {
  'data': {
    ..._requestMap,
    'requested_plan': _planMap,
    'current_team': {
      'id': 'team_2',
      'name': 'Installation Team',
      'functional_team_type': 'installation',
    },
    'stage_data': {'survey_notes': 'FAT port 3 free, roof access confirmed.'},
    'locations': {
      'installation': {'latitude': 23.744, 'longitude': 90.378},
      'dp': {'latitude': 23.741, 'longitude': 90.381},
    },
  },
  'allowed_action': 'complete_installation',
};

const _fatNodesMap = {
  'data': [
    {
      'id': 'node_1',
      'name': 'FAT-A Dhanmondi',
      'node_type': 'dp',
      'latitude': 23.7444,
      'longitude': 90.3788,
    },
  ],
};

// ─── Fakes ──────────────────────────────────────────────────────────────────

class _FakeDashboardNetwork implements DashboardNetwork {
  @override
  Future<Map<String, dynamic>> fetchDashboard() async => _dashboardMap;
}

class _FakeConnectionRequestNetwork implements ConnectionRequestNetwork {
  _FakeConnectionRequestNetwork({required this.detailMap});

  final Map<String, dynamic> detailMap;

  @override
  Future<Map<String, dynamic>> fetchPage({required int page, String? status}) async => _pageMap;

  @override
  Future<Map<String, dynamic>> fetchDetail(String id) async => detailMap;
}

/// FAT nodes come from the real shape; the restored route's `points` is
/// parameterized so tests can drive the decoder (or the fallback).
class _FakeRouteNetwork implements RouteNetwork {
  _FakeRouteNetwork({this.points});

  /// The confirmed backend `points` array (objects with latitude/longitude);
  /// `null`/absent → straight-line fallback.
  final Object? points;

  @override
  Future<Map<String, dynamic>> fetchFatNodes(String connectionRequestId) async => _fatNodesMap;

  @override
  Future<Map<String, dynamic>> calculateRoute(
    String connectionRequestId, {
    required double userLatitude,
    required double userLongitude,
    required double dpLatitude,
    required double dpLongitude,
  }) async {
    return points == null
        ? {'distance_meters': 100.0}
        : {'distance_meters': 100.0, 'points': points};
  }
}

class _FakeInventoryNetwork implements InventoryNetwork {
  @override
  Future<Map<String, dynamic>> fetchInventory() async => const {'data': <Object?>[]};
}

// ─── Harness ────────────────────────────────────────────────────────────────

Future<SecureStorage> _sessionStorage() async {
  final storage = SecureStorage(_InMemoryFlutterSecureStorage());
  await storage.saveSession(
    token: 'test-token',
    tokenType: 'Bearer',
    expiresAt: null,
    employeeId: 'emp_2',
    employeeName: 'Tanvir Installer',
    employeeEmail: 'tanvir@example.com',
    functionalTeamType: 'installation',
    teamName: 'Installation Team',
  );
  return storage;
}

/// Pumps the app under a [ProviderContainer] the test can read for map state.
/// [UncontrolledProviderScope] keeps the container alive after the widget tree
/// unmounts; disposal is registered explicitly.
Future<ProviderContainer> _openDetail(
  WidgetTester tester,
  SecureStorage storage, {
  required Map<String, dynamic> detailMap,
  Object? points,
}) async {
  final container = ProviderContainer(
    overrides: [
      secureStorageProvider.overrideWithValue(storage),
      dashboardRepositoryProvider.overrideWithValue(
        DashboardRepository(network: _FakeDashboardNetwork()),
      ),
      connectionRequestRepositoryProvider.overrideWithValue(
        ConnectionRequestRepository(
          network: _FakeConnectionRequestNetwork(detailMap: detailMap),
        ),
      ),
      routeRepositoryProvider.overrideWithValue(
        RouteRepository(network: _FakeRouteNetwork(points: points)),
      ),
      inventoryRepositoryProvider.overrideWithValue(
        InventoryRepository(network: _FakeInventoryNetwork()),
      ),
      mapTileProviderProvider.overrideWithValue(FakeTileProvider()),
    ],
  );
  addTearDown(container.dispose);

  // Device-tall viewport: the dashboard's recent-request card sits below the
  // 800×600 test default now that a bottom logout bar reserves ~76px, so raise
  // the surface to a real-phone height before pumping the app.
  tester.view.physicalSize = const Size(800, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: IspOnlinecerApp(storage: storage),
    ),
  );
  await tester.pumpAndSettle();

  // Dashboard → installation detail.
  await tester.tap(find.text(_requestNumber));
  await tester.pumpAndSettle();

  return container;
}

/// The merged detail screen's own scrollable — first Scrollable under the
/// screen (its ListView), so nested TextField scrollables don't confuse
/// `scrollUntilVisible`.
Finder _detailScrollable() {
  return find
      .descendant(
        of: find.byType(InstallationRequestDetailScreen),
        matching: find.byType(Scrollable),
      )
      .first;
}

/// Fires the map controller's debounced route call and lets the route-triggered
/// refit plus flutter_map's internal tile-fade/prune timers settle. Calling
/// this before a test ends guarantees no Timer is still pending (testWidgets
/// fails otherwise) and that `route`/`routeNote` are final.
Future<void> _settleMap(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 600));
  await tester.pumpAndSettle();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pumpAndSettle();
}

// ─── Tests ──────────────────────────────────────────────────────────────────

void main() {
  testWidgets('pricing card renders the subscription amount and the connection placeholder',
      (tester) async {
    final storage = await _sessionStorage();
    await _openDetail(
      tester,
      storage,
      detailMap: _detailNoLocations,
    );

    await tester.scrollUntilVisible(
      find.text('Rs 2,000.00'),
      200,
      scrollable: _detailScrollable(),
    );

    expect(find.text('Rs 2,000.00'), findsOneWidget);
    expect(find.text(AppStrings.connectionChargePending), findsOneWidget);
    expect(find.text(AppStrings.connectionChargeNote), findsOneWidget);
  });

  testWidgets('no saved locations → the map shows its empty placeholder', (tester) async {
    final storage = await _sessionStorage();
    await _openDetail(
      tester,
      storage,
      detailMap: _detailNoLocations,
    );

    await tester.scrollUntilVisible(
      find.text(AppStrings.mapNoLocationYet),
      200,
      scrollable: _detailScrollable(),
    );
    expect(find.text(AppStrings.mapNoLocationYet), findsOneWidget);
  });

  testWidgets('selecting a FAT node auto-fills the DP marker via the map controller',
      (tester) async {
    final storage = await _sessionStorage();
    final container = await _openDetail(
      tester,
      storage,
      detailMap: _detailNoLocations,
    );

    final provider = installationMapControllerProvider(_requestId);
    expect(container.read(provider).dpLocation, isNull);

    // Scroll into the embedded form and pick the FAT node. `scrollUntilVisible`
    // stops as soon as the element is *built* (inside the cache extent) — it
    // may still be off-screen, so fully reveal it before tapping.
    await tester.scrollUntilVisible(
      find.text('Select the FAT node used'),
      300,
      scrollable: _detailScrollable(),
    );
    await tester.ensureVisible(find.text('Select the FAT node used'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Select the FAT node used'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('FAT-A Dhanmondi').last);
    await tester.pumpAndSettle();

    // The DP marker follows the selection (FAT-A Dhanmondi) and is not marked
    // manual — Phase 5 keeps the FAT auto-fill as the source of truth. Assert
    // on the controller, not the map's marker widget: the map card sits above
    // the form and is disposed once the form is scrolled into view (map
    // rendering of markers is covered by the seeded-markers test).
    final state = container.read(provider);
    expect(state.dpLocation, isNotNull);
    expect(state.dpLocation!.latitude, closeTo(23.7444, 0.00001));
    expect(state.dpLocation!.longitude, closeTo(90.3788, 0.00001));
    expect(state.dpFromManual, isFalse);

    // A single FIT still needs no route (no user point) — but the map's own
    // tile-fade timer must not outlive the test.
    await _settleMap(tester);
  });

  testWidgets('seeded saved locations render both markers and draw a decoded route',
      (tester) async {
    final storage = await _sessionStorage();
    final container = await _openDetail(
      tester,
      storage,
      detailMap: _detailWithSurveyData,
      points: <Object>[
        {'latitude': 23.744, 'longitude': 90.378},
        {'latitude': 23.7425, 'longitude': 90.3795},
        {'latitude': 23.741, 'longitude': 90.381},
      ],
    );

    // Fire the debounced route; the confirmed `points` decode into a real
    // multi-point path → route with no note.
    await _settleMap(tester);

    final state = container.read(installationMapControllerProvider(_requestId));
    expect(state.isRouteCalculating, isFalse);
    expect(state.route, isNotNull);
    expect(state.route!.length, 3); // all three points kept, not just start/end
    expect(state.routeNote, isNull);

    await tester.scrollUntilVisible(
      find.byKey(const Key('location-map-user-marker')),
      200,
      scrollable: _detailScrollable(),
    );
    expect(find.byKey(const Key('location-map-user-marker')), findsWidgets);
    expect(find.byKey(const Key('location-map-dp-marker')), findsWidgets);
    expect(find.text(AppStrings.mapNoLocationYet), findsNothing);
  });

  testWidgets('missing route points fall back to a straight-lined note',
      (tester) async {
    final storage = await _sessionStorage();
    final container = await _openDetail(
      tester,
      storage,
      detailMap: _detailWithSurveyData,
      points: null, // no points in the route response (OSRM couldn't compute)
    );

    await _settleMap(tester);

    final state = container.read(installationMapControllerProvider(_requestId));
    expect(state.isRouteCalculating, isFalse);
    // Straight-line fallback still draws two points...
    expect(state.route, isNotNull);
    expect(state.route!.length, 2);
    // ...and the graceful note explains why, instead of an empty map.
    expect(state.routeNote, AppStrings.mapRouteStraightLine);
  });
}