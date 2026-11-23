/// Flow 8 (security) + pre-flagged suspects (b) and (c).
/// Faked storage only; never a live server.
///
/// Tests marked DEFECT-DOCUMENTING assert the correct behaviour and are
/// EXPECTED TO FAIL against the current tree — the failure is the finding.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isp_onlinecer/core/storage/secure_storage.dart';

import 'helpers.dart';

void main() {
  group('Suspect (c) — isLoggedIn / isScannerLoggedIn ignore expires_at', () {
    test('DEFECT: employee session with an EXPIRED token still reports logged in', () async {
      final backing = InMemoryFlutterSecureStorage();
      final storage = freshStorage(backing);
      await seedEmployeeSession(
        storage,
        expiresAt: '2020-01-01T00:00:00.000000Z',
      );
      expect(await storage.hasExpiredToken(), isTrue);
      // Correct behaviour: an expired token is not a live session — the
      // router guard and every isLoggedIn() caller should see false.
      // Actual: isLoggedIn() only checks token presence.
      expect(await storage.isLoggedIn(), isFalse);
    });

    test('DEFECT: scanner session with an EXPIRED token still reports logged in', () async {
      final backing = InMemoryFlutterSecureStorage();
      final storage = freshStorage(backing);
      await seedScannerSession(
        storage,
        expiresAt: '2020-01-01T00:00:00.000000Z',
      );
      expect(await storage.isScannerLoggedIn(), isFalse);
    });

    test('unparseable expires_at is treated as not-expired (lenient, documented)', () async {
      final backing = InMemoryFlutterSecureStorage();
      final storage = freshStorage(backing);
      await seedEmployeeSession(storage, expiresAt: 'not-a-date');
      expect(await storage.hasExpiredToken(), isFalse);
      expect(await storage.isLoggedIn(), isTrue);
    });

    test('session with no expires_at at all still reports logged in', () async {
      final backing = InMemoryFlutterSecureStorage();
      final storage = freshStorage(backing);
      await storage.saveSession(
        token: 'emp-token-1',
        tokenType: 'Bearer',
        expiresAt: null,
        employeeId: 'e1',
        employeeName: 'A',
        employeeEmail: null,
        functionalTeamType: 'survey',
        teamName: null,
      );
      expect(await storage.hasExpiredToken(), isFalse);
      expect(await storage.isLoggedIn(), isTrue);
    });
  });

  group('Flow 8 — session scoping (clearSession / clearScannerSession)', () {
    test('employee clearSession leaves scanner keys AND theme untouched', () async {
      final backing = InMemoryFlutterSecureStorage();
      final storage = freshStorage(backing);
      await seedEmployeeSession(storage);
      await seedScannerSession(storage);
      await storage.setThemeMode('dark');
      await storage.clearSession();
      expect(await storage.getToken(), isNull);
      expect(await storage.getScannerToken(), 'scanner-token-1');
      expect(await storage.getThemeMode(), 'dark');
    });

    test('scanner clearScannerSession leaves employee keys AND theme untouched', () async {
      final backing = InMemoryFlutterSecureStorage();
      final storage = freshStorage(backing);
      await seedEmployeeSession(storage);
      await seedScannerSession(storage);
      await storage.setThemeMode('light');
      await storage.clearScannerSession();
      expect(await storage.getScannerToken(), isNull);
      expect(await storage.getToken(), 'emp-token-1');
      expect(await storage.getThemeMode(), 'light');
    });
  });

  group('Flow 8 — token never logged (static source check)', () {
    test('ApiClient LogInterceptor has headers OFF on both clients', () {
      final source = File('lib/core/network/api_client.dart').readAsStringSync();
      // Scope the check to the actual LogInterceptor(...) constructor call:
      // the doc comment above it legitimately mentions the dio defaults
      // (`requestHeader: true`) as the thing being avoided.
      final start = source.indexOf('dio.interceptors.add(LogInterceptor(');
      final end = source.indexOf(');', start);
      final call = source.substring(start, end);
      expect(call, contains('requestHeader: false'));
      expect(call, contains('responseHeader: false'));
      expect(call, isNot(contains('requestHeader: true')));
      expect(call, isNot(contains('responseHeader: true')));
    });

    test('no print/logger call anywhere in lib/ interpolates a token', () {
      final offenders = <String>[];
      for (final file in Directory('lib').listSync(recursive: true).whereType<File>()) {
        if (!file.path.endsWith('.dart')) continue;
        final src = file.readAsStringSync();
        for (final line in src.split('\n')) {
          final lower = line.toLowerCase();
          if ((lower.contains('print(') || lower.contains('log(') || lower.contains('logger.')) &&
              lower.contains('token')) {
            offenders.add('${file.path}: $line');
          }
        }
      }
      expect(offenders, isEmpty, reason: offenders.join('\n'));
    });
  });

  group('Suspect (b) — _loggingOut guard (static source check)', () {
    test('DEFECT-DOCUMENTING: the guard is reset synchronously, before the async clear finishes',
        () {
      // api_client.dart _mapDioError does:
      //   _loggingOut = true;
      //   unawaited(_onUnauthorized());
      //   _loggingOut = false;
      // The flag is false again before the clearSession future completes,
      // so two 401s arriving together BOTH pass the guard and BOTH clear.
      // A correct guard must stay true until the clear future completes
      // (e.g. `await` it or reset it in .whenComplete). This test pins the
      // current (broken) shape so the fix is visible in the diff.
      final source = File('lib/core/network/api_client.dart').readAsStringSync();
      final guardBlock = source.substring(
        source.indexOf('if (exception.isUnauthorized'),
        source.indexOf('return exception;', source.indexOf('if (exception.isUnauthorized')),
      );
      expect(
        guardBlock,
        isNot(contains('unawaited(_onUnauthorized());\n      _loggingOut = false;')),
        reason: 'guard must not be reset synchronously after a fire-and-forget clear',
      );
    });
  });
}
