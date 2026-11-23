/// Flow 9 (login branding) + suspects (d), (e), (f) — widget tests.
/// Real screens with faked storage/network only; never a live server.
///
/// Tests marked DEFECT-DOCUMENTING assert the correct behaviour and are
/// EXPECTED TO FAIL against the current tree — the failure is the finding.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isp_onlinecer/core/storage/secure_storage.dart';
import 'package:isp_onlinecer/features/auth/data/auth_network.dart';
import 'package:isp_onlinecer/features/auth/presentation/providers.dart';
import 'package:isp_onlinecer/features/dashboard/dashboard_shell.dart';
import 'package:isp_onlinecer/features/device_scan/data/scanner_network.dart';
import 'package:isp_onlinecer/features/device_scan/presentation/scanner_login_screen.dart';
import 'package:isp_onlinecer/features/device_scan/presentation/scanner_providers.dart';
import 'package:isp_onlinecer/features/auth/presentation/login_screen.dart';

import 'helpers.dart';

class _NeverAuthNetwork implements AuthNetwork {
  @override
  Future<Map<String, dynamic>> postLogin(Map<String, Object?> body) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> getMe() {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> postLogout() {
    throw UnimplementedError();
  }
}

class _NeverScannerNetwork implements ScannerNetwork {
  @override
  Future<Map<String, dynamic>> postLogin(Map<String, Object?> body) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> getMe() async => <String, dynamic>{};

  @override
  Future<Map<String, dynamic>> postLogout() async => <String, dynamic>{};
}

Future<void> _pump(WidgetTester tester, Widget child, SecureStorage storage) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        secureStorageProvider.overrideWithValue(storage),
        authNetworkProvider.overrideWithValue(_NeverAuthNetwork()),
        scannerNetworkProvider.overrideWithValue(_NeverScannerNetwork()),
      ],
      child: MaterialApp(home: child),
    ),
  );
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  group('Flow 9 — login branding is ISP 360 on both login screens', () {
    testWidgets('staff login: ISP 360 title, wordmark and placeholder; no Malik Fiber',
        (tester) async {
      final storage = freshStorage(InMemoryFlutterSecureStorage());
      await _pump(tester, const LoginScreen(), storage);
      expect(find.text('Log in to ISP 360'), findsOneWidget);
      expect(find.text('ISP 360'), findsWidgets);
      expect(find.text('name@isp360.com'), findsOneWidget);
      expect(find.textContaining('Malik'), findsNothing);
      expect(find.textContaining('malikfiber'), findsNothing);
    });

    testWidgets('scanner login: ISP 360 wordmark and placeholder; no Malik Fiber',
        (tester) async {
      final storage = freshStorage(InMemoryFlutterSecureStorage());
      await _pump(tester, const ScannerLoginScreen(), storage);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Scanner sign-in'), findsOneWidget);
      expect(find.text('ISP 360'), findsOneWidget);
      expect(find.text('scanner@isp360.com'), findsOneWidget);
      expect(find.textContaining('Malik'), findsNothing);
      expect(find.textContaining('malikfiber'), findsNothing);
    });
  });

  group('Suspect (e) — splash screen still brands Malik Fiber', () {
    test('DEFECT: splash source still says MALIK FIBER while login is ISP 360', () {
      // A widget pump of SplashScreen would call context.go() on boot
      // outcome with no router in the test tree; the brand strings are
      // static text, so a source check is the honest verification here.
      final source = File('lib/features/splash/presentation/splash_screen.dart')
          .readAsStringSync();
      expect(source, contains('ISP 360'),
          reason: 'splash must carry the same ISP 360 brand as login');
      expect(source, isNot(contains('MALIK FIBER')));
      expect(source, isNot(contains('Malik Telecom Infrastructure Group')));
    });
  });

  group('Suspect (d) — valid session, unknown/empty team strands the user', () {
    testWidgets('DEFECT: ComingSoon for an unassigned team offers no logout or back path',
        (tester) async {
      final backing = InMemoryFlutterSecureStorage();
      final storage = freshStorage(backing);
      await storage.saveSession(
        token: 'emp-token-1',
        tokenType: 'Bearer',
        expiresAt: '2099-10-10T11:00:00.000000Z',
        employeeId: 'e1',
        employeeName: 'Ahmed Raza',
        employeeEmail: 'a@b.pk',
        functionalTeamType: '',
        teamName: null,
      );
      await _pump(tester, const DashboardShell(), storage);
      await tester.pump(const Duration(milliseconds: 200));
      expect(
        find.text('No team is assigned to this account yet. Contact your administrator.'),
        findsOneWidget,
      );
      // A signed-in user must always be able to sign out (or go back).
      // Actual: ComingSoonScreen has no button of any kind — the only way
      // out is killing the app / clearing app data.
      expect(find.text('Log out'), findsOneWidget);
    });
  });

  group('Suspect (f) — Remember this handheld unit toggle', () {
    testWidgets('DEFECT: toggle state survives a remount: it is persisted and read back',
        (tester) async {
      final backing = InMemoryFlutterSecureStorage();
      final storage = freshStorage(backing);
      await _pump(tester, const LoginScreen(), storage);
      // Default is ON (checked). Tap it off.
      await tester.tap(find.text('Remember this handheld unit'));
      await tester.pump();
      // Tapping OFF removes the check mark on screen...
      expect(find.byIcon(Icons.check), findsNothing);
      // ...and the OFF choice is written to secure storage (D12 fix).
      expect(backing.store.keys.where((k) => k.contains('remember')).isNotEmpty, isTrue);
      expect(backing.store.values, contains('false'));
      await tester.pumpWidget(
        const MaterialApp(home: SizedBox()),
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            secureStorageProvider.overrideWithValue(storage),
            authNetworkProvider.overrideWithValue(_NeverAuthNetwork()),
            scannerNetworkProvider.overrideWithValue(_NeverScannerNetwork()),
          ],
          child: const MaterialApp(home: LoginScreen()),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      // After a fresh mount the toggle is still OFF — the choice was
      // persisted and read back, not reset to the default ON.
      expect(find.byIcon(Icons.check), findsNothing);
    });
  });
}
