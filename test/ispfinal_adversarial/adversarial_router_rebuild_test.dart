// Suspect (a) — lib/main.dart builds the router inside build(), so every
// rebuild of IspOnlinecerApp (e.g. a theme toggle) creates a brand-new
// GoRouter at /boot and drops the user's navigation stack.
//
// Real IspOnlinecerApp + real router, faked storage/network only; never a
// live server.
//
// Tests marked DEFECT-DOCUMENTING assert the correct behaviour and are
// EXPECTED TO FAIL against the current tree — the failure is the finding.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:isp_onlinecer/core/theme/theme_mode_provider.dart';
import 'package:isp_onlinecer/features/auth/data/auth_network.dart';
import 'package:isp_onlinecer/features/auth/presentation/providers.dart';
import 'package:isp_onlinecer/features/dashboard/presentation/dashboard_tiles_providers.dart';
import 'package:isp_onlinecer/features/notifications/data/notification_network.dart';
import 'package:isp_onlinecer/features/notifications/data/notification_repository.dart';
import 'package:isp_onlinecer/features/notifications/presentation/notification_providers.dart';
import 'package:isp_onlinecer/features/survey/data/dashboard_network.dart';
import 'package:isp_onlinecer/features/survey/data/dashboard_repository.dart';
import 'package:isp_onlinecer/features/survey/presentation/connection_request_providers.dart';
import 'package:isp_onlinecer/features/survey/presentation/dashboard_providers.dart';
import 'package:isp_onlinecer/main.dart';
import 'package:isp_onlinecer/models/auth.dart';
import 'package:isp_onlinecer/models/connection_request.dart';
import 'package:isp_onlinecer/models/dashboard.dart';
import 'package:isp_onlinecer/models/team.dart';

import 'helpers.dart';

class _CountingAuthNetwork implements AuthNetwork {
  int meCalls = 0;

  @override
  Future<Map<String, dynamic>> postLogin(Map<String, Object?> body) async =>
      <String, dynamic>{};

  @override
  Future<Map<String, dynamic>> getMe() async {
    meCalls++;
    return <String, dynamic>{
      'employee': <String, Object?>{
        'id': 'employee-1',
        'name': 'Ahmed Raza',
        'email': 'ahmed@isp360.com',
        'team': <String, Object?>{
          'id': 'team-survey',
          'name': 'Survey Team',
          'functional_team_type': 'survey',
        },
      },
    };
  }

  @override
  Future<Map<String, dynamic>> postLogout() async => <String, dynamic>{};
}

class _FakeDashboardRepository extends DashboardRepository {
  _FakeDashboardRepository() : super(network: _NeverDashboardNetwork());

  @override
  Future<DashboardSummary> fetch() async {
    return DashboardSummary(
      employee: Employee(
        id: 'employee-1',
        name: 'Ahmed Raza',
        email: 'ahmed@isp360.com',
        team: Team(
          id: 'survey-team',
          name: 'Survey Team',
          functionalTeamType: 'survey',
        ),
      ),
      stats: const DashboardStats(
        connectionRequests: DashboardCounts(pending: 1, completed: 0, total: 1),
      ),
      recentConnectionRequests: const [
        ConnectionRequest(
          id: 'req-1',
          requestNumber: 'CRQ-1',
          status: 'survey',
          customerName: 'Test Customer',
        ),
      ],
    );
  }
}

class _NeverDashboardNetwork implements DashboardNetwork {
  @override
  Future<Map<String, dynamic>> fetchDashboard() {
    throw UnimplementedError();
  }
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
  Future<Map<String, dynamic>> fetchRecent({int limit = 10}) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> fetchUnreadCount() {
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

void main() {
  Future<bool> pumpUntil(WidgetTester tester, Finder finder) async {
    for (var i = 0; i < 60; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (finder.evaluate().isNotEmpty) return true;
    }
    return false;
  }

  testWidgets(
      'DEFECT: toggling the theme while deep in a flow resets navigation to the dashboard',
      (tester) async {
    final backing = InMemoryFlutterSecureStorage();
    final storage = freshStorage(backing);
    await seedEmployeeSession(storage);
    final authNetwork = _CountingAuthNetwork();
    final container = ProviderContainer(
      overrides: [
        secureStorageProvider.overrideWithValue(storage),
        authNetworkProvider.overrideWithValue(authNetwork),
        dashboardRepositoryProvider.overrideWithValue(_FakeDashboardRepository()),
        notificationRepositoryProvider.overrideWithValue(_InstantNotificationRepository()),
        // D20 dashboard tiles: deterministic counts, no real HTTP — a
        // dashboard mount here must never touch the network.
        dashboardTeamFlowCountProvider.overrideWith((ref) async => 0),
        dashboardOpenTicketCountProvider.overrideWith((ref) async => 0),
        dashboardInventoryCountProvider.overrideWith((ref) async => 0),
        dashboardWaitingOnuCountProvider.overrideWith((ref) async => 0),
        dashboardPendingAuthorizationProvider.overrideWith(
          (ref) async => const ConnectionRequestPage(
            data: [],
            meta: PaginationMeta(),
          ),
        ),
        connectionRequestsProvider.overrideWith(
          (ref, page) async => ConnectionRequestPage(
            data: const [
              ConnectionRequest(
                id: 'req-1',
                requestNumber: 'CRQ-1',
                status: 'survey',
                customerName: 'Test Customer',
              ),
            ],
            meta: PaginationMeta(currentPage: 1, perPage: 15, total: 1, lastPage: 1),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: IspOnlinecerApp(storage: storage),
      ),
    );
    // Boot verifies the session (GET /me #1) and lands on the dashboard.
    expect(await pumpUntil(tester, find.text('Survey')), isTrue);
    expect(authNetwork.meCalls, 1);

    // Go deep: the survey request list.
    final ctx = tester.element(find.text('Survey'));
    GoRouter.of(ctx).go('/survey/requests');
    expect(await pumpUntil(tester, find.text('Survey Requests')), isTrue);

    // A theme toggle rebuilds IspOnlinecerApp (it watches themeModeProvider).
    container.read(themeModeProvider.notifier).cycle();
    await tester.pump(const Duration(milliseconds: 100));
    // Correct behaviour: the user stays on /survey/requests; only the
    // theme changes. Actual: build() creates a new GoRouter at /boot, the
    // boot gate re-runs (GET /me #2 — a wasted server round-trip), and the
    // user lands back on the dashboard with the deep screen gone.
    expect(await pumpUntil(tester, find.text('Survey Requests')), isTrue,
        reason: 'theme toggle must not reset navigation');
    expect(authNetwork.meCalls, 1,
        reason: 'boot verification must not re-run on a theme change');
  });
}
