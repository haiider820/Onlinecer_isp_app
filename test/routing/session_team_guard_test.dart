import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:isp_onlinecer/core/router/app_router.dart';
import 'package:isp_onlinecer/core/router/functional_team.dart';
import 'package:isp_onlinecer/core/router/session_team_guard.dart';
import 'package:isp_onlinecer/core/storage/secure_storage.dart';
import 'package:isp_onlinecer/features/auth/presentation/providers.dart';
import 'package:isp_onlinecer/features/dashboard/dashboard_shell.dart';
import 'package:isp_onlinecer/features/notifications/data/notification_network.dart';
import 'package:isp_onlinecer/features/notifications/data/notification_repository.dart';
import 'package:isp_onlinecer/features/notifications/presentation/notification_providers.dart';
import 'package:isp_onlinecer/features/survey/data/dashboard_network.dart';
import 'package:isp_onlinecer/features/survey/data/dashboard_repository.dart';
import 'package:isp_onlinecer/features/splicing/presentation/splicing_request_detail_screen.dart';
import 'package:isp_onlinecer/features/survey/presentation/dashboard_providers.dart';
import 'package:isp_onlinecer/models/auth.dart';
import 'package:isp_onlinecer/models/connection_request.dart';
import 'package:isp_onlinecer/models/dashboard.dart';
import 'package:isp_onlinecer/models/team.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class _InMemoryFlutterSecureStorage extends FlutterSecureStorage {
  final Map<String, String> _store = {};

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
      _store.remove(key);
    } else {
      _store[key] = value;
    }
  }

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
      _store[key];

  @override
  Future<void> deleteAll({
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async =>
      _store.clear();
}

class _FakeDashboardRepository extends DashboardRepository {
  _FakeDashboardRepository() : super(network: _NeverDashboardNetwork());

  @override
  Future<DashboardSummary> fetch() async {
    return DashboardSummary(
      employee: Employee(
        id: 'employee-1',
        name: 'Hassan Tariq',
        email: 'hassan.tariq@malikfiber.pk',
        team: Team(
          id: 'verification-team',
          name: 'Connection Verification Team',
          functionalTeamType: 'connection_verification',
        ),
      ),
      stats: const DashboardStats(
        connectionRequests: DashboardCounts(pending: 1, completed: 0, total: 1),
      ),
      // Non-empty list avoids the empty-state Lottie (`repeat: true`) whose
      // internal timer is never cancelled, causing "A Timer is still pending"
      // at test disposal.
      recentConnectionRequests: const [
        ConnectionRequest(
          id: 'req-1',
          requestNumber: 'CRQ-20260910-0001',
          status: 'connection_verification',
          customerName: 'Test Customer',
          customerType: 'Residential',
          customerPhone: '+923001234567',
          customerArea: 'Gulberg',
          customerAddress: '123 Main Blvd',
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

/// Notification repo that resolves instantly without Dio.
///
/// The dashboard's header watches [notificationUnreadCountProvider], which by
/// default goes through the real Dio client — `DioMixin.fetch` schedules a
/// zero-duration Timer that, if created on the final pump's frame, is still
/// pending at widget-tree disposal and fails the test.
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

void main() {
  testWidgets('mismatched team route redirects to the session dashboard', (tester) async {
    final storage = SecureStorage(_InMemoryFlutterSecureStorage());
    await storage.saveSession(
      token: 'token',
      tokenType: 'Bearer',
      expiresAt: null,
      employeeId: 'employee-1',
      employeeName: 'Hassan Tariq',
      employeeEmail: 'hassan.tariq@malikfiber.pk',
      functionalTeamType: 'connection_verification',
      teamName: 'Connection Verification Team',
    );

    final router = GoRouter(
      initialLocation: Routes.splicingDetailFor('request-1'),
      routes: [
        GoRoute(
          path: Routes.dashboard,
          builder: (context, state) => const DashboardShell(),
        ),
        GoRoute(
          path: Routes.splicingDetail,
          builder: (context, state) => SessionTeamGuard(
            expectedTeam: FunctionalTeamType.fiberSplicing,
            child: SplicingRequestDetailScreen(
              requestId: state.pathParameters['id'] ?? '',
            ),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          secureStorageProvider.overrideWithValue(storage),
          dashboardRepositoryProvider.overrideWithValue(_FakeDashboardRepository()),
          // The header's notification bell never goes through real Dio: Dio's
          // fetch schedules a zero-duration Timer that outlives the test.
          notificationRepositoryProvider.overrideWithValue(_InstantNotificationRepository()),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Splicing Detail'), findsNothing);
    expect(find.text('Verification'), findsOneWidget);
  });
}
