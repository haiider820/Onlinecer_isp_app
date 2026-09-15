import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:isp_onlinecer/core/storage/secure_storage.dart';
import 'package:isp_onlinecer/features/auth/presentation/providers.dart';
import 'package:isp_onlinecer/features/survey/data/connection_request_network.dart';
import 'package:isp_onlinecer/features/survey/data/connection_request_repository.dart';
import 'package:isp_onlinecer/features/survey/data/dashboard_network.dart';
import 'package:isp_onlinecer/features/survey/data/dashboard_repository.dart';
import 'package:isp_onlinecer/features/survey/data/location_service.dart';
import 'package:isp_onlinecer/features/survey/data/route_network.dart';
import 'package:isp_onlinecer/features/survey/data/route_repository.dart';
import 'package:isp_onlinecer/features/survey/data/submit_survey_network.dart';
import 'package:isp_onlinecer/features/survey/data/submit_survey_repository.dart';
import 'package:isp_onlinecer/features/survey/presentation/connection_request_providers.dart';
import 'package:isp_onlinecer/features/survey/presentation/dashboard_providers.dart';
import 'package:isp_onlinecer/features/survey/presentation/route_providers.dart';
import 'package:isp_onlinecer/features/survey/presentation/submit_survey_providers.dart';
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

const _requestId = 'req_1';
const _requestNumber = 'CRQ-20260910-ABCD';

const _requestListMap = {
  'id': _requestId,
  'request_number': _requestNumber,
  'status': 'survey_assigned',
  'customer_name': 'Rahim Uddin',
  'customer_type': 'Residential',
  'customer_phone': '+8801712345678',
  'customer_area': 'Dhanmondi',
  'customer_address': 'House 12, Road 5, Dhanmondi',
};

const _dashboardMap = {
  'employee': {
    'id': 'emp_1',
    'name': 'Karim Surveyor',
    'team': {'id': 'team_1', 'name': 'Survey Team', 'functional_team_type': 'survey'},
  },
  'stats': {
    'connection_requests': {'pending': 2, 'completed': 1, 'total': 3},
  },
  'recent_connection_requests': [_requestListMap],
};

const _pageMap = {
  'data': [_requestListMap],
  'meta': {'current_page': 1, 'per_page': 15, 'total': 1, 'last_page': 1},
};

const _detailMap = {
  'data': {
    ..._requestListMap,
    'requested_plan': {'id': 'plan_1', 'name': 'Fiber 20 Mbps', 'price_minor': 120000},
    'current_team': {'id': 'team_1', 'name': 'Survey Team', 'functional_team_type': 'survey'},
  },
  'allowed_action': 'complete_survey',
};

const _fatNodesMap = {
  'data': [
    {'id': 'node_1', 'name': 'FAT-A Dhanmondi', 'node_type': 'dp', 'latitude': 23.7444, 'longitude': 90.3788},
  ],
};

const _routeResultMap = {
  'distance_meters': 1320.4,
  'duration_seconds': 280,
  'summary': 'Head north along Satmasjid Road.',
  // Confirmed backend shape: a real multi-point route path (not a straight
  // line), so the survey route screen draws an actual polyline through all
  // points while the summary card shows the real distance_meters.
  'points': [
    {'latitude': 23.7314, 'longitude': 90.3951},
    {'latitude': 23.733, 'longitude': 90.393},
    {'latitude': 23.7352, 'longitude': 90.391},
    {'latitude': 23.737, 'longitude': 90.3895},
    {'latitude': 23.7388, 'longitude': 90.3879},
    {'latitude': 23.7406, 'longitude': 90.3863},
  ],
  'source': 'osrm',
};

const _submitResultMap = {
  'message': 'Survey marked as completed.',
  'data': {
    'id': _requestId,
    'request_number': _requestNumber,
    'status': 'installation_assigned',
    'current_team': {'id': 'team_9', 'name': 'Installation Team', 'functional_team_type': 'installation'},
    'timestamps': {'surveyed_at': '2026-09-10T11:00:00.000000Z'},
  },
};

// ─── Fakes ──────────────────────────────────────────────────────────────────

class _FakeDashboardNetwork implements DashboardNetwork {
  @override
  Future<Map<String, dynamic>> fetchDashboard() async => _dashboardMap;
}

class _FakeConnectionRequestNetwork implements ConnectionRequestNetwork {
  @override
  Future<Map<String, dynamic>> fetchPage({required int page, String? status}) async => _pageMap;

  @override
  Future<Map<String, dynamic>> fetchDetail(String id) async => _detailMap;
}

class _FakeRouteNetwork implements RouteNetwork {
  @override
  Future<Map<String, dynamic>> fetchFatNodes(String connectionRequestId) async => _fatNodesMap;

  @override
  Future<Map<String, dynamic>> calculateRoute(
    String connectionRequestId, {
    required double userLatitude,
    required double userLongitude,
    required double dpLatitude,
    required double dpLongitude,
  }) async =>
      _routeResultMap;
}

class _FakeSubmitSurveyNetwork implements SubmitSurveyNetwork {
  @override
  Future<Map<String, dynamic>> completeSurveyJson(String id, {String? notes}) async => _submitResultMap;

  @override
  Future<Map<String, dynamic>> completeSurveyMultipart(
    String id, {
    String? notes,
    required String voiceNotePath,
    required String voiceNoteMimeType,
  }) async =>
      _submitResultMap;
}

class _FakeLocationService implements LocationService {
  _FakeLocationService({this.error});

  final Exception? error;

  @override
  Future<Position> getCurrentPosition() async {
    if (error != null) throw error!;
    return Position(
      latitude: 23.7314,
      longitude: 90.3951,
      timestamp: DateTime.now(),
      accuracy: 5.0,
      altitude: 0.0,
      altitudeAccuracy: 0.0,
      heading: 0.0,
      headingAccuracy: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
    );
  }
}

// ─── Helpers ────────────────────────────────────────────────────────────────

Future<SecureStorage> _sessionStorage() async {
  final storage = SecureStorage(_InMemoryFlutterSecureStorage());
  await storage.saveSession(
    token: 'test-token',
    tokenType: 'Bearer',
    expiresAt: null,
    employeeId: 'emp_1',
    employeeName: 'Karim Surveyor',
    employeeEmail: 'karim@example.com',
    functionalTeamType: 'survey',
    teamName: 'Survey Team',
  );
  return storage;
}

Widget _buildApp(
  SecureStorage storage, {
  LocationService? locationService,
}) {
  return ProviderScope(
    overrides: [
      secureStorageProvider.overrideWithValue(storage),
      dashboardRepositoryProvider.overrideWithValue(
        DashboardRepository(network: _FakeDashboardNetwork()),
      ),
      connectionRequestRepositoryProvider.overrideWithValue(
        ConnectionRequestRepository(network: _FakeConnectionRequestNetwork()),
      ),
      routeRepositoryProvider.overrideWithValue(
        RouteRepository(network: _FakeRouteNetwork()),
      ),
      submitSurveyRepositoryProvider.overrideWithValue(
        SubmitSurveyRepository(network: _FakeSubmitSurveyNetwork()),
      ),
      locationServiceProvider.overrideWithValue(
        locationService ?? _FakeLocationService(),
      ),
      // The survey route screen now renders a route map; the tile provider
      // must stay network-free so no tile HTTP leaves the test runner.
      mapTileProviderProvider.overrideWithValue(FakeTileProvider()),
    ],
    child: IspOnlinecerApp(storage: storage),
  );
}

// ─── Tests ──────────────────────────────────────────────────────────────────

void main() {
  testWidgets('full survey flow: dashboard → detail → route → submit', (tester) async {
    final storage = await _sessionStorage();
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_buildApp(storage));
    await tester.pumpAndSettle();

    // 1. Dashboard loads with header + recent request.
    expect(find.text('Survey'), findsOneWidget);
    expect(find.text('Karim Surveyor'), findsOneWidget);
    expect(find.text(_requestNumber), findsOneWidget);

    // 2. Tap the recent request → detail.
    await tester.tap(find.text(_requestNumber));
    await tester.pumpAndSettle();
    expect(find.text('Request Detail'), findsOneWidget);
    expect(find.text('Complete Survey'), findsOneWidget);
    expect(find.text('Plan Route'), findsOneWidget);

    // 3. Plan Route → FAT node list; calculate disabled until location known.
    await tester.tap(find.text('Plan Route'));
    await tester.pumpAndSettle();
    expect(find.text('Select FAT node'), findsOneWidget);
    expect(find.text('FAT-A Dhanmondi'), findsOneWidget);
    // FilledButton.icon lives in a private subtype, so match by subtype.
    final calcButton = tester.widget<FilledButton>(
      find.ancestor(of: find.text('Calculate Route'), matching: find.bySubtype<FilledButton>()),
    );
    expect(calcButton.onPressed, isNull);

    // 4. Pick a FAT node, use my location, calculate.
    await tester.tap(find.text('FAT-A Dhanmondi'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Use my location'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Calculate Route'));
    await tester.pumpAndSettle();
    expect(find.text('Route Summary'), findsOneWidget);
    expect(find.text('1.3 km'), findsOneWidget);

    // 5. Back to detail, then the complete-survey flow.
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Request Detail'), findsOneWidget);

    // The detail page now leads with the Navigate quick action, so the submit
    // button can sit below the fold in the test viewport — scroll to it first.
    await tester.ensureVisible(find.text('Complete Survey'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Complete Survey'));
    await tester.pumpAndSettle();
    final notesField = find.byType(TextField);
    expect(notesField, findsOneWidget);
    await tester.enterText(notesField, 'All wiring checked. FAT accessible.');
    await tester.tap(
      find.ancestor(of: find.text('Submit Survey'), matching: find.bySubtype<FilledButton>()),
    );
    await tester.pumpAndSettle();

    // 6. Success returns to the request list with the completed request.
    expect(find.text('Survey Requests'), findsOneWidget);
    expect(find.text(_requestNumber), findsOneWidget);
  });

  testWidgets('route screen shows a friendly message when location is denied', (tester) async {
    final storage = await _sessionStorage();
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_buildApp(
      storage,
      locationService: _FakeLocationService(
        error: const LocationException('Location permission denied.'),
      ),
    ));
    await tester.pumpAndSettle();

    // Navigate to the route screen via dashboard → detail → Plan Route.
    await tester.tap(find.text(_requestNumber));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Plan Route'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Use my location'));
    await tester.pumpAndSettle();

    expect(find.text('Location permission denied.'), findsOneWidget);
    // Still no position and no node selection → cannot calculate.
    final calcButton = tester.widget<FilledButton>(
      find.ancestor(of: find.text('Calculate Route'), matching: find.bySubtype<FilledButton>()),
    );
    expect(calcButton.onPressed, isNull);
  });
}