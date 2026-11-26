import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:isp_onlinecer/core/router/app_router.dart';
import 'package:isp_onlinecer/core/router/functional_team.dart';
import 'package:isp_onlinecer/core/router/session_team_guard.dart';
import 'package:isp_onlinecer/core/storage/secure_storage.dart';
import 'package:isp_onlinecer/features/auth/presentation/providers.dart';
import 'package:isp_onlinecer/features/installation/data/inventory_network.dart';
import 'package:isp_onlinecer/features/installation/data/inventory_repository.dart';
import 'package:isp_onlinecer/features/installation/presentation/installation_providers.dart';
import 'package:isp_onlinecer/features/installation/presentation/installation_request_detail_screen.dart';
import 'package:isp_onlinecer/features/notifications/data/notification_network.dart';
import 'package:isp_onlinecer/features/notifications/data/notification_repository.dart';
import 'package:isp_onlinecer/features/notifications/presentation/notification_providers.dart';
import 'package:isp_onlinecer/features/survey/data/connection_request_network.dart';
import 'package:isp_onlinecer/features/survey/data/connection_request_repository.dart';
import 'package:isp_onlinecer/features/survey/data/dashboard_network.dart';
import 'package:isp_onlinecer/features/survey/data/dashboard_repository.dart';
import 'package:isp_onlinecer/features/survey/data/route_network.dart';
import 'package:isp_onlinecer/features/survey/data/route_repository.dart';
import 'package:isp_onlinecer/features/survey/presentation/connection_request_providers.dart';
import 'package:isp_onlinecer/features/survey/presentation/dashboard_providers.dart';
import 'package:isp_onlinecer/features/survey/presentation/route_providers.dart';
import 'package:isp_onlinecer/features/survey/presentation/survey_request_detail_screen.dart';
import 'package:isp_onlinecer/main.dart';
import 'package:isp_onlinecer/models/connection_request.dart';
import 'package:isp_onlinecer/shared/widgets/location_map.dart';

import '../helpers/fake_tile_provider.dart';
import '../ispfinal_adversarial/helpers.dart';

/// D18: after survey completion a request in `installation_assigned` must
/// open the Installation detail screen (with the Complete Installation form)
/// even when the viewer is logged in with session team "survey" — one team
/// can now own all five stages.
///
/// The list payload carries `status` but no `allowed_actions`, so card taps
/// route by status ([Routes.detailRouteForRequest]) and the detail-route
/// guard admits any stage the employee's team owns
/// ([SessionTeamGuard.stageAware] + `functional_team_types`).

// ─── Resolver table ─────────────────────────────────────────────────────────

ConnectionRequest _requestWithStatus(String status) => ConnectionRequest(
      id: 'req-1',
      requestNumber: 'CRQ-20261125-TEST',
      status: status,
      customerName: 'Test Customer',
    );

void main() {
  group('detailRouteForRequest (status → detail screen)', () {
    test('survey stages open the survey detail', () {
      const fallback = Routes.installationDetailFor;
      expect(
        Routes.detailRouteForRequest(_requestWithStatus('survey_assigned'), fallback),
        Routes.surveyDetailFor('req-1'),
      );
      expect(
        Routes.detailRouteForRequest(_requestWithStatus('survey_review'), fallback),
        Routes.surveyDetailFor('req-1'),
      );
    });

    test('inventory_pending / survey_not_feasible / survey_completed open the survey detail (D19, guide §8)', () {
      // Feasible survey + items → inventory_pending (web-only approval);
      // not-feasible → survey_not_feasible; feasible without items →
      // survey_completed. All three are read-only survey-stage states.
      const fallback = Routes.installationDetailFor;
      for (final status in [
        'inventory_pending',
        'survey_not_feasible',
        'survey_completed',
      ]) {
        expect(
          Routes.detailRouteForRequest(_requestWithStatus(status), fallback),
          Routes.surveyDetailFor('req-1'),
          reason: status,
        );
      }
    });

    test('installation_assigned opens the installation detail', () {
      expect(
        Routes.detailRouteForRequest(
          _requestWithStatus('installation_assigned'),
          Routes.surveyDetailFor,
        ),
        Routes.installationDetailFor('req-1'),
      );
    });

    test('splicing / verification / closing open their own detail screens', () {
      expect(
        Routes.detailRouteForRequest(
          _requestWithStatus('splicing_assigned'),
          Routes.surveyDetailFor,
        ),
        Routes.splicingDetailFor('req-1'),
      );
      expect(
        Routes.detailRouteForRequest(
          _requestWithStatus('verification_assigned'),
          Routes.surveyDetailFor,
        ),
        Routes.verificationDetailFor('req-1'),
      );
      expect(
        Routes.detailRouteForRequest(
          _requestWithStatus('closing_assigned'),
          Routes.surveyDetailFor,
        ),
        Routes.closingDetailFor('req-1'),
      );
    });

    test('unknown status falls back to the session-team route', () {
      expect(
        Routes.detailRouteForRequest(
          _requestWithStatus('completed'),
          Routes.surveyDetailFor,
        ),
        Routes.surveyDetailFor('req-1'),
      );
      expect(
        Routes.detailRouteForRequest(
          _requestWithStatus('something_new'),
          Routes.installationDetailFor,
        ),
        Routes.installationDetailFor('req-1'),
      );
      expect(
        Routes.detailRouteForRequest(_requestWithStatus(''), Routes.surveyDetailFor),
        Routes.surveyDetailFor('req-1'),
      );
    });
  });

  group('SessionTeamGuard stageAware', () {
    Future<SecureStorage> seedSession({
      required String teamType,
      List<String>? teamTypes,
    }) async {
      final storage = SecureStorage(InMemoryFlutterSecureStorage());
      await storage.saveSession(
        token: 'token',
        tokenType: 'Bearer',
        expiresAt: null,
        employeeId: 'employee-1',
        employeeName: 'Umair Shafique',
        employeeEmail: 'umair@gmail.com',
        functionalTeamType: teamType,
        functionalTeamTypes: teamTypes,
        teamName: 'Centralized Tech',
      );
      return storage;
    }

    GoRouter guardedRouter(SecureStorage storage) {
      return GoRouter(
        initialLocation: Routes.installationDetailFor('req-1'),
        routes: [
          GoRoute(
            path: Routes.dashboard,
            builder: (context, state) =>
                const Scaffold(body: Text('Dashboard Stub')),
          ),
          GoRoute(
            path: Routes.installationDetail,
            builder: (context, state) => SessionTeamGuard(
              expectedTeam: FunctionalTeamType.installation,
              stageAware: true,
              child: const Scaffold(body: Text('Installation Detail Stub')),
            ),
          ),
        ],
      );
    }

    Future<void> pumpRouter(WidgetTester tester, GoRouter router, SecureStorage storage) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [secureStorageProvider.overrideWithValue(storage)],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
    }

    testWidgets('admits a multi-stage user to a later stage detail', (tester) async {
      final storage = await seedSession(
        teamType: 'survey',
        teamTypes: const [
          'survey',
          'installation',
          'fiber_splicing',
          'connection_verification',
          'closing',
        ],
      );
      await pumpRouter(tester, guardedRouter(storage), storage);
      expect(find.text('Installation Detail Stub'), findsOneWidget);
      expect(find.text('Dashboard Stub'), findsNothing);
    });

    testWidgets('still bounces a single-stage user off another stage', (tester) async {
      final storage = await seedSession(
        teamType: 'survey',
        teamTypes: const ['survey'],
      );
      await pumpRouter(tester, guardedRouter(storage), storage);
      expect(find.text('Installation Detail Stub'), findsNothing);
      expect(find.text('Dashboard Stub'), findsOneWidget);
    });

    testWidgets('legacy session without a stored list falls back to the single team',
        (tester) async {
      // No functional_team_types stored: an installation user is admitted,
      // a survey user is bounced — exactly the pre-D18 behaviour.
      final admitted = await seedSession(teamType: 'installation');
      await pumpRouter(tester, guardedRouter(admitted), admitted);
      expect(find.text('Installation Detail Stub'), findsOneWidget);

      final bounced = await seedSession(teamType: 'survey');
      await pumpRouter(tester, guardedRouter(bounced), bounced);
      expect(find.text('Installation Detail Stub'), findsNothing);
      expect(find.text('Dashboard Stub'), findsOneWidget);
    });
  });

  group('dashboard tap routes by request stage (full app)', () {
    // Live payload shape for CRQ-20261125-N2ON1HQK (verified 2026-11-25):
    // status installation_assigned, top-level allowed_actions
    // ["authorize_onu", "complete_installation"], survey already feasible.
    const liveDetail = {
      'data': {
        'id': '6502031a-a826-404d-adb0-6eae69a5f1ce',
        'request_number': 'CRQ-20261125-N2ON1HQK',
        'status': 'installation_assigned',
        'customer_name': 'test',
        'customer_type': 'home',
        'customer_phone': '0307-0000001',
        'customer_address': 'test',
        'customer_area': 'test',
        'requested_plan': {
          'id': 'plan-18',
          'name': '18 MBPS Package Plan',
          'price_minor': 0,
        },
        'current_team': {
          'id': '3b2259e7-6b53-4637-a1d9-a3204d5c27dd',
          'name': 'Centralized Tech',
          'code': 'IT-003',
          'functional_team_type': 'survey',
          'functional_team_types': [
            'survey',
            'installation',
            'fiber_splicing',
            'connection_verification',
            'closing',
          ],
          'flow_order': 1,
          'is_active': true,
        },
        'stage_data': {
          'survey_feasibility_status': 'feasible',
          'survey_notes': null,
          'installation_notes': null,
        },
      },
      'allowed_action': 'complete_installation',
      'allowed_actions': ['authorize_onu', 'complete_installation'],
    };

    const liveRequestMap = {
      'id': '6502031a-a826-404d-adb0-6eae69a5f1ce',
      'request_number': 'CRQ-20261125-N2ON1HQK',
      'status': 'installation_assigned',
      'customer_name': 'test',
      'customer_type': 'home',
      'customer_phone': '0307-0000001',
      'customer_address': 'test',
      'customer_area': 'test',
    };

    const surveyDetail = {
      'data': {
        'id': 'req-survey',
        'request_number': 'CRQ-20261125-SURVEY',
        'status': 'survey_assigned',
        'customer_name': 'Survey Customer',
        'customer_type': 'home',
        'customer_phone': '0300-1111111',
        'customer_address': 'Main St',
        'customer_area': 'Blue Area',
        'current_team': {
          'id': '3b2259e7-6b53-4637-a1d9-a3204d5c27dd',
          'name': 'Centralized Tech',
          'code': 'IT-003',
          'functional_team_type': 'survey',
          'functional_team_types': [
            'survey',
            'installation',
            'fiber_splicing',
            'connection_verification',
            'closing',
          ],
          'flow_order': 1,
          'is_active': true,
        },
      },
      'allowed_action': 'complete_survey',
      'allowed_actions': ['complete_survey'],
    };

    const surveyRequestMap = {
      'id': 'req-survey',
      'request_number': 'CRQ-20261125-SURVEY',
      'status': 'survey_assigned',
      'customer_name': 'Survey Customer',
      'customer_type': 'home',
      'customer_phone': '0300-1111111',
      'customer_address': 'Main St',
      'customer_area': 'Blue Area',
    };

    Map<String, dynamic> dashboardMap(Map<String, dynamic> requestMap) => {
          'employee': {
            'id': 'employee-1',
            'name': 'Umair Shafique',
            'team': {
              'id': '3b2259e7-6b53-4637-a1d9-a3204d5c27dd',
              'name': 'Centralized Tech',
              'functional_team_type': 'survey',
            },
          },
          'stats': {
            'connection_requests': {'pending': 1, 'completed': 0, 'total': 1},
          },
          'recent_connection_requests': [requestMap],
        };

    Future<void> settle(WidgetTester tester) async {
      for (var i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    Future<void> openApp(
      WidgetTester tester, {
      required Map<String, dynamic> requestMap,
      required Map<String, dynamic> detailMap,
    }) async {
      final storage = SecureStorage(InMemoryFlutterSecureStorage());
      // Survey session team, but the team owns all five stages (D18).
      await storage.saveSession(
        token: 'token',
        tokenType: 'Bearer',
        expiresAt: null,
        employeeId: 'employee-1',
        employeeName: 'Umair Shafique',
        employeeEmail: 'umair@gmail.com',
        functionalTeamType: 'survey',
        functionalTeamTypes: const [
          'survey',
          'installation',
          'fiber_splicing',
          'connection_verification',
          'closing',
        ],
        teamName: 'Centralized Tech',
      );

      final container = ProviderContainer(
        overrides: [
          secureStorageProvider.overrideWithValue(storage),
          dashboardRepositoryProvider.overrideWithValue(
            DashboardRepository(network: _FakeDashboardNetwork(dashboardMap(requestMap))),
          ),
          connectionRequestRepositoryProvider.overrideWithValue(
            ConnectionRequestRepository(
              network: _FakeConnectionRequestNetwork(detailMap: detailMap),
            ),
          ),
          routeRepositoryProvider.overrideWithValue(
            RouteRepository(network: _FakeRouteNetwork()),
          ),
          inventoryRepositoryProvider.overrideWithValue(
            InventoryRepository(network: _FakeInventoryNetwork()),
          ),
          notificationRepositoryProvider.overrideWithValue(
            _InstantNotificationRepository(),
          ),
          mapTileProviderProvider.overrideWithValue(FakeTileProvider()),
        ],
      );
      addTearDown(container.dispose);

      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: IspOnlinecerApp(storage: storage),
        ),
      );
      await settle(tester);
    }

    testWidgets(
        'survey-session user tapping an installation_assigned card opens the Installation detail with the form',
        (tester) async {
      await openApp(
        tester,
        requestMap: liveRequestMap,
        detailMap: liveDetail,
      );
      await tester.tap(find.text('CRQ-20261125-N2ON1HQK'));
      await settle(tester);

      expect(find.byType(InstallationRequestDetailScreen), findsOneWidget);
      expect(find.byType(SurveyRequestDetailScreen), findsNothing);
      // The live payload's allowed_actions drive these (D18 end state).
      expect(find.text('Complete Installation'), findsWidgets);
      expect(find.text('Authorize ONU'), findsOneWidget);
    });

    testWidgets('survey-stage request still opens the Survey detail', (tester) async {
      await openApp(
        tester,
        requestMap: surveyRequestMap,
        detailMap: surveyDetail,
      );
      await tester.tap(find.text('CRQ-20261125-SURVEY'));
      await settle(tester);

      expect(find.byType(SurveyRequestDetailScreen), findsOneWidget);
      expect(find.byType(InstallationRequestDetailScreen), findsNothing);
    });
  });
}

// ─── Fakes (modelled on test/installation/merged_screen_test.dart) ──────────

class _FakeDashboardNetwork implements DashboardNetwork {
  _FakeDashboardNetwork(this.map);

  final Map<String, dynamic> map;

  @override
  Future<Map<String, dynamic>> fetchDashboard() async => map;
}

class _FakeConnectionRequestNetwork implements ConnectionRequestNetwork {
  _FakeConnectionRequestNetwork({required this.detailMap});

  final Map<String, dynamic> detailMap;

  @override
  Future<Map<String, dynamic>> fetchPage({required int page, String? status}) async {
    return {
      'data': [detailMap['data']],
      'meta': {'current_page': 1, 'per_page': 15, 'total': 1, 'last_page': 1},
    };
  }

  @override
  Future<Map<String, dynamic>> fetchDetail(String id) async => detailMap;
}

class _FakeRouteNetwork implements RouteNetwork {
  @override
  Future<Map<String, dynamic>> fetchFatNodes(String connectionRequestId) async =>
      const {'data': <Object?>[]};

  @override
  Future<Map<String, dynamic>> calculateRoute(
    String connectionRequestId, {
    required double userLatitude,
    required double userLongitude,
    required double dpLatitude,
    required double dpLongitude,
  }) async =>
      {'distance_meters': 100.0};
}

class _FakeInventoryNetwork implements InventoryNetwork {
  @override
  Future<Map<String, dynamic>> fetchInventory() async => const {'data': <Object?>[]};
}

class _InstantNotificationRepository extends NotificationRepository {
  _InstantNotificationRepository() : super(network: _NeverNotificationNetwork());

  @override
  Future<int> fetchUnreadCount() async => 0;
}

class _NeverNotificationNetwork implements NotificationNetwork {
  @override
  Future<Map<String, dynamic>> fetchPage({required int page, bool unreadOnly = false}) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> fetchUnreadCount() {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> fetchRecent({int limit = 10}) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> markAllRead() {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> markRead(String id) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> open(String id) {
    throw UnimplementedError();
  }
}
