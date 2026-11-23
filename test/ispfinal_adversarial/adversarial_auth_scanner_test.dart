/// Flow 1 (employee login) + Flow 2 (scanner login) — adversarial repo,
/// controller and router tests. Faked network only; never a live server.
///
/// Tests marked DEFECT-DOCUMENTING assert the correct behaviour and are
/// EXPECTED TO FAIL against the current tree — the failure is the finding.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:isp_onlinecer/core/network/api_exceptions.dart';
import 'package:isp_onlinecer/core/router/app_router.dart';
import 'package:isp_onlinecer/features/auth/data/auth_network.dart';
import 'package:isp_onlinecer/features/auth/data/auth_repository.dart';
import 'package:isp_onlinecer/features/auth/presentation/providers.dart';
import 'package:isp_onlinecer/features/device_scan/data/scanner_network.dart';
import 'package:isp_onlinecer/features/device_scan/data/scanner_repository.dart';
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

import 'helpers.dart';

class _ScriptedAuthNetwork implements AuthNetwork {
  _ScriptedAuthNetwork({this.loginResponse, this.loginError});

  final Map<String, Object?>? loginResponse;
  final Object? loginError;
  int loginCalls = 0;

  @override
  Future<Map<String, dynamic>> postLogin(Map<String, Object?> body) async {
    loginCalls++;
    if (loginError != null) throw loginError!;
    return Map<String, dynamic>.from(loginResponse ?? {});
  }

  @override
  Future<Map<String, dynamic>> getMe() async =>
      <String, dynamic>{'employee': employeePayload()['employee']};

  @override
  Future<Map<String, dynamic>> postLogout() async => <String, dynamic>{};
}

class _ScriptedScannerNetwork implements ScannerNetwork {
  _ScriptedScannerNetwork({this.loginResponse, this.loginError, this.meResponse, this.meError});

  final Map<String, Object?>? loginResponse;
  final Object? loginError;
  final Map<String, Object?>? meResponse;
  final Object? meError;
  int loginCalls = 0;
  int meCalls = 0;
  int logoutCalls = 0;

  @override
  Future<Map<String, dynamic>> postLogin(Map<String, Object?> body) async {
    loginCalls++;
    if (loginError != null) throw loginError!;
    return Map<String, dynamic>.from(loginResponse ?? {});
  }

  @override
  Future<Map<String, dynamic>> getMe() async {
    meCalls++;
    if (meError != null) throw meError!;
    return Map<String, dynamic>.from(
      meResponse ?? <String, Object?>{'name': 'Scanner One'},
    );
  }

  @override
  Future<Map<String, dynamic>> postLogout() async {
    logoutCalls++;
    return <String, dynamic>{};
  }
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
  group('Flow 1 — employee login (AuthRepository)', () {
    test('missing account_type falls back to employee (old payloads)', () async {
      final backing = InMemoryFlutterSecureStorage();
      final storage = freshStorage(backing);
      final repo = AuthRepository(
        network: _ScriptedAuthNetwork(
          loginResponse: employeePayload(includeAccountType: false),
        ),
        storage: storage,
      );
      final response = await repo.login(email: 'a@b.pk', password: 'pw');
      expect(response.accountType, isNull);
      expect(await storage.getToken(), 'emp-token-1');
    });

    test('explicit non-employee account_type is refused and saves nothing', () async {
      final backing = InMemoryFlutterSecureStorage();
      final storage = freshStorage(backing);
      final repo = AuthRepository(
        network: _ScriptedAuthNetwork(
          loginResponse: employeePayload(accountType: 'scanner'),
        ),
        storage: storage,
      );
      await expectLater(
        () => repo.login(email: 's@b.pk', password: 'pw'),
        throwsA(isA<ApiException>()),
      );
      expect(await storage.getToken(), isNull);
    });

    test('account_type matching is case-insensitive (EMPLOYEE accepted)', () async {
      final backing = InMemoryFlutterSecureStorage();
      final storage = freshStorage(backing);
      final repo = AuthRepository(
        network: _ScriptedAuthNetwork(
          loginResponse: employeePayload(accountType: 'EMPLOYEE'),
        ),
        storage: storage,
      );
      final response = await repo.login(email: 'a@b.pk', password: 'pw');
      expect(response.token, 'emp-token-1');
      expect(await storage.getToken(), 'emp-token-1');
    });

    test('wrong password surfaces the backend message and saves nothing', () async {
      final backing = InMemoryFlutterSecureStorage();
      final storage = freshStorage(backing);
      final repo = AuthRepository(
        network: _ScriptedAuthNetwork(
          loginError: const InvalidCredentialsException(),
        ),
        storage: storage,
      );
      await expectLater(
        () => repo.login(email: 'a@b.pk', password: 'wrong'),
        throwsA(
          isA<InvalidCredentialsException>().having(
            (e) => e.message,
            'message',
            'The provided credentials are incorrect.',
          ),
        ),
      );
      expect(await storage.getToken(), isNull);
    });

    test('offline login fails as NetworkException and saves nothing', () async {
      final backing = InMemoryFlutterSecureStorage();
      final storage = freshStorage(backing);
      final repo = AuthRepository(
        network: _ScriptedAuthNetwork(loginError: const NetworkException()),
        storage: storage,
      );
      await expectLater(
        () => repo.login(email: 'a@b.pk', password: 'pw'),
        throwsA(isA<NetworkException>()),
      );
      expect(await storage.getToken(), isNull);
    });

    test('double-tap login: second submit while first is in flight is blocked by the controller',
        () async {
      // D13 (fixed): AuthController holds the in-flight login future and
      // returns it to a second caller instead of firing a second POST.
      // Both callers still receive the one login response.
      final backing = InMemoryFlutterSecureStorage();
      final storage = freshStorage(backing);
      final network = _ScriptedAuthNetwork(
        loginResponse: employeePayload(),
      );
      final container = ProviderContainer(
        overrides: [
          secureStorageProvider.overrideWithValue(storage),
          authNetworkProvider.overrideWithValue(network),
        ],
      );
      addTearDown(container.dispose);
      final controller = container.read(authControllerProvider.notifier);
      final results = await Future.wait([
        controller.login(email: 'a@b.pk', password: 'pw'),
        controller.login(email: 'a@b.pk', password: 'pw'),
      ]);
      expect(results.whereType<LoginResponse>().length, 2);
      expect(network.loginCalls, 1,
          reason: 'Second tap while a login is in flight must not POST again');
      expect(container.read(authControllerProvider).isSubmitting, isFalse);
    });

    test('failed login clears the in-flight guard so a retry can POST again',
        () async {
      // D13 edge case: the guard must clear on completion/error, not stick
      // — two sequential failed attempts must reach the network twice.
      final backing = InMemoryFlutterSecureStorage();
      final storage = freshStorage(backing);
      final network = _ScriptedAuthNetwork(
        loginError: const InvalidCredentialsException(),
      );
      final container = ProviderContainer(
        overrides: [
          secureStorageProvider.overrideWithValue(storage),
          authNetworkProvider.overrideWithValue(network),
        ],
      );
      addTearDown(container.dispose);
      final controller = container.read(authControllerProvider.notifier);
      expect(await controller.login(email: 'a@b.pk', password: 'wrong'), isNull);
      expect(await controller.login(email: 'a@b.pk', password: 'wrong'), isNull);
      expect(network.loginCalls, 2);
      expect(container.read(authControllerProvider).errorMessage, isNotNull);
    });
  });

  group('Flow 2 — scanner login (ScannerRepository)', () {
    test('missing account_type is ACCEPTED on scanner login (judgement call)', () async {
      final backing = InMemoryFlutterSecureStorage();
      final storage = freshStorage(backing);
      final repo = ScannerRepository(
        network: _ScriptedScannerNetwork(
          loginResponse: scannerPayload(includeAccountType: false),
        ),
        storage: storage,
      );
      final response = await repo.login(email: 's@b.pk', password: 'pw');
      expect(response.token, 'scanner-token-1');
      expect(await storage.getScannerToken(), 'scanner-token-1');
      expect(await storage.getToken(), isNull,
          reason: 'scanner token must never land in employee keys');
    });

    test('explicit employee account_type is refused on scanner login', () async {
      final backing = InMemoryFlutterSecureStorage();
      final storage = freshStorage(backing);
      final repo = ScannerRepository(
        network: _ScriptedScannerNetwork(
          loginResponse: scannerPayload(accountType: 'employee'),
        ),
        storage: storage,
      );
      await expectLater(
        () => repo.login(email: 'a@b.pk', password: 'pw'),
        throwsA(isA<ApiException>()),
      );
      expect(await storage.getScannerToken(), isNull);
    });

    test('scanner login never overwrites an existing employee session', () async {
      final backing = InMemoryFlutterSecureStorage();
      final storage = freshStorage(backing);
      await seedEmployeeSession(storage);
      final repo = ScannerRepository(
        network: _ScriptedScannerNetwork(loginResponse: scannerPayload(accountType: 'scanner')),
        storage: storage,
      );
      await repo.login(email: 's@b.pk', password: 'pw');
      expect(await storage.getToken(), 'emp-token-1');
      expect(await storage.getScannerToken(), 'scanner-token-1');
    });

    test('employee login never overwrites an existing scanner session', () async {
      final backing = InMemoryFlutterSecureStorage();
      final storage = freshStorage(backing);
      await seedScannerSession(storage);
      final repo = AuthRepository(
        network: _ScriptedAuthNetwork(loginResponse: employeePayload()),
        storage: storage,
      );
      await repo.login(email: 'a@b.pk', password: 'pw');
      expect(await storage.getScannerToken(), 'scanner-token-1');
      expect(await storage.getToken(), 'emp-token-1');
    });

    test('restore: 401 clears the stale scanner token and yields null', () async {
      final backing = InMemoryFlutterSecureStorage();
      final storage = freshStorage(backing);
      await seedScannerSession(storage);
      final repo = ScannerRepository(
        network: _ScriptedScannerNetwork(
          meError: const ApiException(message: 'Unauthenticated.', statusCode: 401),
        ),
        storage: storage,
      );
      expect(await repo.restoreSession(), isNull);
      expect(await storage.getScannerToken(), isNull);
    });

    test('restore: offline keeps the stored scanner identity (never strands)', () async {
      final backing = InMemoryFlutterSecureStorage();
      final storage = freshStorage(backing);
      await seedScannerSession(storage);
      final repo = ScannerRepository(
        network: _ScriptedScannerNetwork(meError: const NetworkException()),
        storage: storage,
      );
      final session = await repo.restoreSession();
      expect(session, isNotNull);
      expect(session!.accountName, 'Scanner One');
      expect(await storage.getScannerToken(), 'scanner-token-1');
    });

    test('restore: no stored token never touches the network', () async {
      final backing = InMemoryFlutterSecureStorage();
      final storage = freshStorage(backing);
      final network = _ScriptedScannerNetwork();
      final repo = ScannerRepository(network: network, storage: storage);
      expect(await repo.restoreSession(), isNull);
      expect(network.meCalls, 0);
    });

    test('double-tap scanner login: second submit while first is in flight is blocked',
        () async {
      // D13, scanner side: ScannerAuthController has the same in-flight
      // guard as AuthController — one POST /login, both callers get the
      // one response.
      final backing = InMemoryFlutterSecureStorage();
      final storage = freshStorage(backing);
      final network = _ScriptedScannerNetwork(
        loginResponse: scannerPayload(accountType: 'scanner'),
      );
      final container = ProviderContainer(
        overrides: [
          secureStorageProvider.overrideWithValue(storage),
          scannerNetworkProvider.overrideWithValue(network),
        ],
      );
      addTearDown(container.dispose);
      final controller = container.read(scannerAuthControllerProvider.notifier);
      final results = await Future.wait([
        controller.login(email: 's@b.pk', password: 'pw'),
        controller.login(email: 's@b.pk', password: 'pw'),
      ]);
      expect(results.whereType<LoginResponse>().length, 2);
      expect(network.loginCalls, 1,
          reason: 'Second tap while a scanner login is in flight must not POST again');
      expect(container.read(scannerAuthControllerProvider).isSubmitting, isFalse);
    });

    test('failed scanner login clears the in-flight guard so a retry can POST again',
        () async {
      final backing = InMemoryFlutterSecureStorage();
      final storage = freshStorage(backing);
      final network = _ScriptedScannerNetwork(
        loginError: const InvalidCredentialsException(),
      );
      final container = ProviderContainer(
        overrides: [
          secureStorageProvider.overrideWithValue(storage),
          scannerNetworkProvider.overrideWithValue(network),
        ],
      );
      addTearDown(container.dispose);
      final controller = container.read(scannerAuthControllerProvider.notifier);
      expect(await controller.login(email: 's@b.pk', password: 'wrong'), isNull);
      expect(await controller.login(email: 's@b.pk', password: 'wrong'), isNull);
      expect(network.loginCalls, 2);
      expect(container.read(scannerAuthControllerProvider).errorMessage, isNotNull);
    });
  });

  group('Flow 2 — scanner logout stickiness (DEFECT-DOCUMENTING)', () {
    test(
        'DEFECT: after scanner logout, scannerSessionProvider still returns the old session',
        () async {
      final backing = InMemoryFlutterSecureStorage();
      final storage = freshStorage(backing);
      await seedScannerSession(storage);
      final network = _ScriptedScannerNetwork();
      final container = ProviderContainer(
        overrides: [
          secureStorageProvider.overrideWithValue(storage),
          scannerNetworkProvider.overrideWithValue(network),
          scannerRepositoryProvider.overrideWithValue(
            ScannerRepository(network: network, storage: storage),
          ),
        ],
      );
      addTearDown(container.dispose);

      // Warm the cache exactly as the home screen does.
      final before = await container.read(scannerSessionProvider.future);
      expect(before, isNotNull);
      expect(network.meCalls, 1);

      final ok = await container
          .read(scannerAuthControllerProvider.notifier)
          .logout();
      expect(ok, isTrue);
      expect(await storage.getScannerToken(), isNull,
          reason: 'storage itself IS cleared');

      // Correct behaviour: the provider must re-run restore (network) and
      // yield null. Actual: the cached FutureProvider value is returned
      // with NO new network call — the app still believes a scanner
      // session exists after sign-out.
      final after = await container.read(scannerSessionProvider.future);
      expect(after, isNull,
          reason: 'stale cached session must not survive logout');
      expect(network.meCalls, 2,
          reason: 'restore must re-run after logout instead of serving cache');
    });
  });

  group('Flow 2 — scanner bounce fix holds (router)', () {
    Future<bool> pumpUntil(WidgetTester tester, Finder finder) async {
      for (var i = 0; i < 100; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        if (finder.evaluate().isNotEmpty) return true;
      }
      return false;
    }

    testWidgets('employee session seeded: scanner link still reaches the scanner form',
        (tester) async {
      final backing = InMemoryFlutterSecureStorage();
      final storage = freshStorage(backing);
      final router = buildAppRouter(storage: storage);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            secureStorageProvider.overrideWithValue(storage),
            scannerNetworkProvider.overrideWithValue(_ScriptedScannerNetwork()),
            dashboardRepositoryProvider.overrideWithValue(_FakeDashboardRepository()),
            notificationRepositoryProvider.overrideWithValue(_InstantNotificationRepository()),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      expect(await pumpUntil(tester, find.text('Log in to ISP 360')), isTrue);
      // Seed AFTER boot settles, exactly as the original repro test does,
      // so the boot gate never fires a real GET /me in this test.
      await seedEmployeeSession(storage);
      await tester.tap(find.text('Device scanner? Sign in here'));
      expect(await pumpUntil(tester, find.text('Scanner sign-in')), isTrue);
      expect(find.text('scanner@isp360.com'), findsOneWidget);
      expect(find.text('Staff login? Sign in here'), findsOneWidget);
    });

    testWidgets('scanner login: back link returns to staff login', (tester) async {
      final backing = InMemoryFlutterSecureStorage();
      final storage = freshStorage(backing);
      final router = buildAppRouter(storage: storage);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            secureStorageProvider.overrideWithValue(storage),
            scannerNetworkProvider.overrideWithValue(_ScriptedScannerNetwork()),
            dashboardRepositoryProvider.overrideWithValue(_FakeDashboardRepository()),
            notificationRepositoryProvider.overrideWithValue(_InstantNotificationRepository()),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      expect(await pumpUntil(tester, find.text('Log in to ISP 360')), isTrue);
      await tester.tap(find.text('Device scanner? Sign in here'));
      expect(await pumpUntil(tester, find.text('Scanner sign-in')), isTrue);
      await tester.tap(find.text('Staff login? Sign in here'));
      expect(await pumpUntil(tester, find.text('Log in to ISP 360')), isTrue);
    });

    testWidgets(
        'DEFECT: after scanner sign-out, the scanner form is unreachable until app restart',
        (tester) async {
      final backing = InMemoryFlutterSecureStorage();
      final storage = freshStorage(backing);
      await seedScannerSession(storage);
      final network = _ScriptedScannerNetwork();
      final router = buildAppRouter(storage: storage);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            secureStorageProvider.overrideWithValue(storage),
            scannerNetworkProvider.overrideWithValue(network),
            dashboardRepositoryProvider.overrideWithValue(_FakeDashboardRepository()),
            notificationRepositoryProvider.overrideWithValue(_InstantNotificationRepository()),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      // Boot lands scanner-only users on the scanner home (via /login redirect).
      expect(await pumpUntil(tester, find.text('Signed in as scanner')), isTrue);
      await tester.tap(find.text('Sign out'));
      // Sign-out clears storage, but the stale cached scannerSessionProvider
      // makes the login screen bounce away from its own form; the router
      // redirect chain drops the user on the STAFF login instead.
      expect(await pumpUntil(tester, find.text('Log in to ISP 360')), isTrue);
      // And the form stays unreachable: tapping the scanner link runs the
      // same stale restore and bounces straight back to the staff login.
      await tester.tap(find.text('Device scanner? Sign in here'));
      expect(await pumpUntil(tester, find.text('Scanner sign-in')), isTrue);
    });
  });
}
