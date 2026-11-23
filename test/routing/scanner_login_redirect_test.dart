import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:isp_onlinecer/core/network/api_exceptions.dart';
import 'package:isp_onlinecer/core/router/app_router.dart';
import 'package:isp_onlinecer/core/storage/secure_storage.dart';
import 'package:isp_onlinecer/features/auth/presentation/providers.dart';
import 'package:isp_onlinecer/features/device_scan/data/scanner_network.dart';
import 'package:isp_onlinecer/features/device_scan/presentation/scanner_providers.dart';
import 'package:isp_onlinecer/features/notifications/data/notification_network.dart';
import 'package:isp_onlinecer/features/notifications/data/notification_repository.dart';
import 'package:isp_onlinecer/features/notifications/presentation/notification_providers.dart';
import 'package:isp_onlinecer/features/survey/data/dashboard_network.dart';
import 'package:isp_onlinecer/features/survey/data/dashboard_repository.dart';
import 'package:isp_onlinecer/features/survey/presentation/dashboard_providers.dart';
import 'package:isp_onlinecer/models/auth.dart';
import 'package:isp_onlinecer/models/connection_request.dart';
import 'package:isp_onlinecer/models/dashboard.dart';
import 'package:isp_onlinecer/models/team.dart';

/// Repro for the 2026-11-23 bounce: tapping "Device scanner? Sign in here"
/// on the employee login page must land on the scanner login form — even
/// when an employee session already exists in storage.
///
/// The two login screens are independent entry points for two independent
/// sessions (employee `auth.*` keys vs scanner `scanner.*` keys). A user
/// who is not signed in *as a scanner* must be able to REACH the scanner
/// form; the old redirect bounced them to the dashboard instead, so the
/// scanner form was unreachable whenever any employee token existed.
///
/// Real [GoRouter] ([buildAppRouter]) + the real [LoginScreen] /
/// [ScannerLoginScreen]; only storage and network are faked — never a live
/// server. Bounded pumps only: the login screens run repeating animations,
/// so `pumpAndSettle` can never settle.
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
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async =>
      _store.remove(key);

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
          id: 'survey-team',
          name: 'Survey Team',
          functionalTeamType: 'survey',
        ),
      ),
      stats: const DashboardStats(
        connectionRequests: DashboardCounts(pending: 1, completed: 0, total: 1),
      ),
      // Non-empty list avoids the empty-state Lottie whose internal timer
      // is never cancelled, causing "A Timer is still pending" at disposal.
      recentConnectionRequests: const [
        ConnectionRequest(
          id: 'req-1',
          requestNumber: 'CRQ-20260910-0001',
          status: 'survey',
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

/// Notification repo that resolves instantly without Dio: the dashboard
/// header watches [notificationUnreadCountProvider], whose default path goes
/// through the real Dio client.
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

class _FakeScannerNetwork implements ScannerNetwork {
  _FakeScannerNetwork({this.meResponse, this.meError});

  final Map<String, Object?>? meResponse;
  final Object? meError;

  @override
  Future<Map<String, dynamic>> postLogin(Map<String, Object?> body) async =>
      <String, dynamic>{};

  @override
  Future<Map<String, dynamic>> getMe() async {
    if (meError != null) throw meError!;
    return meResponse ?? <String, dynamic>{};
  }

  @override
  Future<Map<String, dynamic>> postLogout() async => <String, dynamic>{};
}

void main() {
  late _InMemoryFlutterSecureStorage backing;
  late SecureStorage storage;

  setUp(() {
    backing = _InMemoryFlutterSecureStorage();
    storage = SecureStorage(backing);
  });

  Future<void> seedEmployeeSession() => storage.saveSession(
        token: 'employee_token_here',
        tokenType: 'Bearer',
        expiresAt: '2099-10-10T11:00:00.000000Z',
        employeeId: 'employee_uuid',
        employeeName: 'Ahmed Raza',
        employeeEmail: 'a@b.pk',
        functionalTeamType: 'survey',
        teamName: 'Survey Team',
      );

  Future<void> seedScannerSession() => storage.saveScannerSession(
        token: 'scanner_token_here',
        tokenType: 'Bearer',
        expiresAt: '2099-10-10T11:00:00.000000Z',
        accountId: '7',
        accountName: 'Scanner One',
      );

  /// Pumps the real router and waits (bounded) until [finder] matches.
  Future<bool> pumpUntil(WidgetTester tester, Finder finder) async {
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (finder.evaluate().isNotEmpty) return true;
    }
    return false;
  }

  /// Pumps the real router with the given scanner-network fake. The boot
  /// gate settles on the employee login when no employee session exists.
  /// When a scanner session is seeded before pumping, boot's own
  /// `go(Routes.login)` is itself redirected to the scanner home (the
  /// `onLogin` branch), so those tests wait for [waitFor] instead.
  Future<GoRouter> pumpApp(
    WidgetTester tester, {
    required ScannerNetwork scannerNetwork,
    Finder? waitFor,
  }) async {
    final router = buildAppRouter(storage: storage);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          secureStorageProvider.overrideWithValue(storage),
          scannerNetworkProvider.overrideWithValue(scannerNetwork),
          dashboardRepositoryProvider.overrideWithValue(_FakeDashboardRepository()),
          notificationRepositoryProvider.overrideWithValue(_InstantNotificationRepository()),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    final target = waitFor ?? find.text('Log in to ISP 360');
    expect(
      await pumpUntil(tester, target),
      isTrue,
      reason: 'boot must settle on the expected landing screen',
    );
    return router;
  }

  /// Taps the scanner link on the employee login page.
  Future<void> tapScannerLink(WidgetTester tester) async {
    await tester.tap(find.text('Device scanner? Sign in here'));
  }

  group('scanner-login redirect bounce (2026-11-23)', () {
    testWidgets('(a) no session: tap reaches the scanner form', (tester) async {
      await pumpApp(tester, scannerNetwork: _FakeScannerNetwork());
      await tapScannerLink(tester);

      expect(await pumpUntil(tester, find.text('Scanner sign-in')), isTrue);
    });

    testWidgets(
        '(b) employee-only session present at tap time: tap MUST still reach '
        'the scanner form, not the dashboard', (tester) async {
      await pumpApp(tester, scannerNetwork: _FakeScannerNetwork());
      // The employee token exists in storage when the link is tapped (e.g.
      // a previous employee login, or a pre-redesign scanner token stored
      // under the employee keys). Seeded after boot so the boot gate itself
      // never fires a real GET /me in this test.
      await seedEmployeeSession();
      await tapScannerLink(tester);

      expect(await pumpUntil(tester, find.text('Scanner sign-in')), isTrue);
      expect(find.text('Survey'), findsNothing,
          reason: 'the tap must not bounce to the employee dashboard');
    });

    testWidgets(
        '(c) employee session + stale scanner token that 401s on GET /me: '
        'tap MUST reach the scanner form and the employee session must survive',
        (tester) async {
      await pumpApp(
        tester,
        scannerNetwork: _FakeScannerNetwork(
          meError: const ApiException(message: 'Unauthenticated.', statusCode: 401),
        ),
      );
      await seedEmployeeSession();
      await seedScannerSession();
      await tapScannerLink(tester);

      expect(await pumpUntil(tester, find.text('Scanner sign-in')), isTrue);
      expect(await storage.getToken(), 'employee_token_here',
          reason: 'a scanner 401 during restore must not wipe the employee session');
      expect(await storage.getScannerToken(), isNull,
          reason: 'the rejected scanner token must be dropped');
    });
  });

  group('redirect regressions (must keep working)', () {
    testWidgets('scanner-only session: scanner login goes to scanner home', (tester) async {
      await seedScannerSession();
      final router = await pumpApp(
        tester,
        scannerNetwork: _FakeScannerNetwork(),
        waitFor: find.text('Device Scanner'),
      );
      router.go(Routes.scannerLogin);

      expect(await pumpUntil(tester, find.text('Device Scanner')), isTrue);
      expect(find.text('Signed in as scanner'), findsOneWidget);
    });

    testWidgets('scanner-only session: employee dashboard goes to scanner home',
        (tester) async {
      await seedScannerSession();
      final router = await pumpApp(
        tester,
        scannerNetwork: _FakeScannerNetwork(),
        waitFor: find.text('Device Scanner'),
      );
      router.go(Routes.dashboard);

      expect(await pumpUntil(tester, find.text('Device Scanner')), isTrue);
    });

    testWidgets('employee session: staff login goes to the dashboard', (tester) async {
      final router = await pumpApp(tester, scannerNetwork: _FakeScannerNetwork());
      await seedEmployeeSession();
      router.go(Routes.login);

      expect(await pumpUntil(tester, find.text('Survey')), isTrue);
    });
  });
}
