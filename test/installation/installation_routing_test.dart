import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isp_onlinecer/core/constants/app_constants.dart';
import 'package:isp_onlinecer/core/storage/secure_storage.dart';
import 'package:isp_onlinecer/features/auth/presentation/providers.dart';
import 'package:isp_onlinecer/features/installation/data/inventory_network.dart';
import 'package:isp_onlinecer/features/installation/data/inventory_repository.dart';
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

/// Detail payload carrying the survey stage's notes and prior locations.
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

// ─── Fakes ──────────────────────────────────────────────────────────────────

class _FakeDashboardNetwork implements DashboardNetwork {
  @override
  Future<Map<String, dynamic>> fetchDashboard() async => _dashboardMap;
}

/// Returns no route geometry — the map must degrade to the straight-line note
/// without failing (the saved survey locations seed both markers).
class _FakeRouteNetwork implements RouteNetwork {
  @override
  Future<Map<String, dynamic>> fetchFatNodes(String connectionRequestId) async {
    return const {'data': <Object?>[]};
  }

  @override
  Future<Map<String, dynamic>> calculateRoute(
    String connectionRequestId, {
    required double userLatitude,
    required double userLongitude,
    required double dpLatitude,
    required double dpLongitude,
  }) async {
    return {'distance_meters': 100.0};
  }
}

class _FakeConnectionRequestNetwork implements ConnectionRequestNetwork {
  _FakeConnectionRequestNetwork({Map<String, dynamic>? detailMap})
      : detailMap = detailMap ?? _detailWithSurveyData;

  String? lastStatus;
  final Map<String, dynamic> detailMap;

  @override
  Future<Map<String, dynamic>> fetchPage({required int page, String? status}) async {
    lastStatus = status;
    return _pageMap;
  }

  @override
  Future<Map<String, dynamic>> fetchDetail(String id) async => detailMap;
}

/// Empty inventory catalog — the embedded form watches this provider, so it
/// must resolve deterministically (no real HTTP).
class _FakeInventoryNetwork implements InventoryNetwork {
  @override
  Future<Map<String, dynamic>> fetchInventory() async => const {'data': <Object?>[]};
}

// ─── Helpers ────────────────────────────────────────────────────────────────

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

Widget _buildApp(SecureStorage storage, _FakeConnectionRequestNetwork network) {
  return ProviderScope(
    overrides: [
      secureStorageProvider.overrideWithValue(storage),
      dashboardRepositoryProvider.overrideWithValue(
        DashboardRepository(network: _FakeDashboardNetwork()),
      ),
      connectionRequestRepositoryProvider.overrideWithValue(
        ConnectionRequestRepository(network: network),
      ),
      routeRepositoryProvider.overrideWithValue(
        RouteRepository(network: _FakeRouteNetwork()),
      ),
      inventoryRepositoryProvider.overrideWithValue(
        InventoryRepository(network: _FakeInventoryNetwork()),
      ),
      mapTileProviderProvider.overrideWithValue(FakeTileProvider()),
    ],
    child: IspOnlinecerApp(storage: storage),
  );
}

/// The merged detail screen's own scrollable — the first Scrollable under the
/// screen (its ListView), scoped to the screen so nested TextField scrollables
/// and any scrollable on the route beneath don't confuse `scrollUntilVisible`.
Finder _detailScrollable() {
  return find
      .descendant(
        of: find.byType(InstallationRequestDetailScreen),
        matching: find.byType(Scrollable),
      )
      .first;
}

/// Pumps the app with a tall viewport so the dashboard's recent-request card
/// is built within the test window (the bottom logout bar shaves ~76px from
/// the body, pushing the card below the sliver build window at 600px).
Future<void> _pumpDashboard(WidgetTester tester, SecureStorage storage,
    _FakeConnectionRequestNetwork network) async {
  tester.view.physicalSize = const Size(800, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(_buildApp(storage, network));
  await tester.pumpAndSettle();
}

// ─── Tests ──────────────────────────────────────────────────────────────────

void main() {
  testWidgets('installation employee lands on the installation dashboard', (tester) async {
    final storage = await _sessionStorage();
    await _pumpDashboard(tester, storage, _FakeConnectionRequestNetwork());

    expect(find.text('Installation'), findsOneWidget);
    expect(find.text('Tanvir Installer'), findsOneWidget);
    expect(find.text('Installation Team'), findsOneWidget);
    expect(find.text(_requestNumber), findsOneWidget);
  });

  testWidgets('View All loads the status-filtered installation queue', (tester) async {
    final storage = await _sessionStorage();
    final network = _FakeConnectionRequestNetwork();
    await _pumpDashboard(tester, storage, network);

    // The "View All" button is the last section of the dashboard ListView, so
    // it starts below the 600px test viewport and is not built by the lazy
    // list — reveal it (as the other dashboard flows do) before tapping.
    await tester.scrollUntilVisible(
      find.text('View All Installation Requests'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('View All Installation Requests'));
    await tester.pumpAndSettle();

    expect(find.text('Installation Requests'), findsOneWidget);
    expect(find.text(_requestNumber), findsOneWidget);
    expect(network.lastStatus, ConnectionStatus.installationAssigned);
  });

  testWidgets('installation detail shows customer/plan/team and read-only survey notes',
      (tester) async {
    final storage = await _sessionStorage();
    await _pumpDashboard(tester, storage, _FakeConnectionRequestNetwork());

    // Go dashboard → detail via the recent request.
    await tester.tap(find.text(_requestNumber));
    await tester.pumpAndSettle();

    expect(find.text('Installation Detail'), findsOneWidget);
    expect(find.text('Fiber 40 Mbps'), findsOneWidget);
    expect(find.text('Installation Team'), findsOneWidget);

    // The ref.listen seed scheduled a 500 ms debounced route call from the
    // saved survey locations; fire it and let the resulting map refit +
    // flutter_map's internal tile-fade timer settle too, so nothing is
    // pending at teardown (a pending Timer fails testWidgets).
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    // Survey-stage notes and prior locations sit below the (now longer) merged
    // scroll — the pricing and map cards push them under the fold, so reveal
    // them before asserting.
    await tester.scrollUntilVisible(
      find.text('Survey Notes'),
      200,
      scrollable: _detailScrollable(),
    );
    expect(find.text('Survey Notes'), findsOneWidget);
    expect(find.text('FAT port 3 free, roof access confirmed.'), findsOneWidget);

    // Prior locations are shown read-only.
    expect(find.text('Saved Locations'), findsOneWidget);
    expect(find.text('23.744000, 90.378000'), findsOneWidget);

    // allowed_action == complete_installation embeds the completion form. Its
    // submit button sits below the fold in the merged scroll, so scroll the
    // detail screen's own list into view first (the merged form adds nested
    // TextField scrollables, so an explicit scrollable is required).
    await tester.scrollUntilVisible(
      find.text('Complete Installation'),
      300,
      scrollable: _detailScrollable(),
    );
    expect(find.text('Complete Installation'), findsOneWidget);
  });

  testWidgets('saved survey locations seed both markers and the route fallback note',
      (tester) async {
    final storage = await _sessionStorage();
    await _pumpDashboard(tester, storage, _FakeConnectionRequestNetwork());

    await tester.tap(find.text(_requestNumber));
    await tester.pumpAndSettle();

    // The ref.listen seed fills both markers from the saved survey locations
    // and schedules the 500 ms debounced route call. Fire the timer and let
    // the route-triggered map refit + tile-fade timer settle so none is
    // pending at teardown.
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    // The fake route response carries no geometry → graceful straight-line
    // fallback note, never a crash or a stuck loading state.
    await tester.scrollUntilVisible(
      find.text(AppStrings.mapRouteStraightLine),
      200,
      scrollable: _detailScrollable(),
    );
    expect(find.text(AppStrings.mapRouteStraightLine), findsOneWidget);
  });

  testWidgets('installation detail hides the action when allowed_action is absent',
      (tester) async {
    final storage = await _sessionStorage();
    final network = _FakeConnectionRequestNetwork(
      detailMap: {
        'data': _requestMap,
        'allowed_action': null,
      },
    );
    await _pumpDashboard(tester, storage, network);

    await tester.tap(find.text(_requestNumber));
    await tester.pumpAndSettle();

    expect(find.text('Installation Detail'), findsOneWidget);

    // The read-only notice sits at the bottom of the merged scroll — the
    // pricing card + map placeholder push it under the fold, so reveal it
    // first (the no-action fixture seeds no locations → no map route timer).
    await tester.scrollUntilVisible(
      find.text('No action available for this request.'),
      200,
      scrollable: _detailScrollable(),
    );
    expect(find.text('Complete Installation'), findsNothing);
    expect(find.text('No action available for this request.'), findsOneWidget);
  });
}