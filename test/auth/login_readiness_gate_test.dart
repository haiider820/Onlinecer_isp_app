import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isp_onlinecer/core/network/api_exceptions.dart';
import 'package:isp_onlinecer/core/storage/secure_storage.dart';
import 'package:isp_onlinecer/features/auth/data/auth_network.dart';
import 'package:isp_onlinecer/features/auth/data/auth_repository.dart';
import 'package:isp_onlinecer/features/auth/presentation/providers.dart';
import 'package:isp_onlinecer/features/splash/presentation/boot_providers.dart';

/// In-memory [FlutterSecureStorage] so [SecureStorage] can be tested headlessly.
class _FakeFlutterSecureStorage extends FlutterSecureStorage {
  final Map<String, String> store = <String, String>{};

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
  Future<void> deleteAll({
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    store.clear();
  }
}

/// Storage whose token write stalls until the test releases it — models a
/// slow Keystore/Keychain write racing the first protected request.
class _DelayedWriteStorage extends _FakeFlutterSecureStorage {
  final Completer<void> tokenWriteGate = Completer<void>();

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
    if (key == 'auth.token') {
      await tokenWriteGate.future;
    }
    await super.write(key: key, value: value);
  }
}

/// Storage that silently drops the token write — models a Keystore failure
/// where the write future completes but nothing persisted.
class _DroppingTokenStorage extends _FakeFlutterSecureStorage {
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
    if (key == 'auth.token') return;
    await super.write(key: key, value: value);
  }
}

class _FakeAuthNetwork implements AuthNetwork {
  _FakeAuthNetwork(this.loginResponse);

  final Map<String, Object?> loginResponse;
  int meCalls = 0;
  Object? meError;

  @override
  Future<Map<String, dynamic>> postLogin(Map<String, Object?> body) async {
    return loginResponse;
  }

  @override
  Future<Map<String, dynamic>> getMe() async {
    meCalls++;
    if (meError != null) throw meError!;
    return <String, Object?>{
      'data': <String, Object?>{
        'employee': <String, Object?>{
          'id': 'employee_uuid',
          'name': 'Ahmed Raza',
          'email': 'a@b.pk',
          'team': <String, Object?>{
            'id': 'team_uuid',
            'name': 'Survey Team',
            'functional_team_type': 'survey',
          },
        },
      },
    };
  }

  @override
  Future<Map<String, dynamic>> postLogout() async => <String, dynamic>{};
}

Map<String, Object?> loginJson() => <String, Object?>{
      'message': 'Login successful.',
      'token_type': 'Bearer',
      'token': 'plain_token_here',
      'expires_at': '2099-10-10T11:00:00.000000Z',
      'user': <String, Object?>{'id': 25, 'name': 'Ahmed Raza', 'email': 'a@b.pk'},
      'employee': <String, Object?>{
        'id': 'employee_uuid',
        'user_id': 25,
        'name': 'Ahmed Raza',
        'email': 'a@b.pk',
        'team': <String, Object?>{
          'id': 'team_uuid',
          'name': 'Survey Team',
          'functional_team_type': 'survey',
        },
      },
      'permissions': <Object?>[],
      'permission_labels': <Object?>[],
    };

void main() {
  group('login readiness gate (delayed token write)', () {
    test(
      'login() does not complete until the token write has settled — '
      'so navigation (which awaits login) cannot outrun persistence',
      () async {
        final backing = _DelayedWriteStorage();
        final storage = SecureStorage(backing);
        final network = _FakeAuthNetwork(loginJson());
        final repo = AuthRepository(network: network, storage: storage);

        var loginSettled = false;
        final loginFuture = repo
            .login(email: 'a@b.pk', password: 'pw')
            .then((_) => loginSettled = true);

        // Give the login flow every chance to "finish" without the write.
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        expect(
          loginSettled,
          isFalse,
          reason: 'login() must stay pending while the token write is pending; '
              'the UI navigates only after login() completes',
        );

        // The storage write completes only now (simulating a slow Keystore).
        backing.tokenWriteGate.complete();

        await expectLater(loginFuture, completes);
        expect(loginSettled, isTrue);
        expect(await storage.getToken(), 'plain_token_here');
        expect(await storage.getFunctionalTeamType(), 'survey');
      },
    );

    test('a silently-dropped token write fails login instead of navigating '
        'into an unauthenticated session', () async {
      final storage = SecureStorage(_DroppingTokenStorage());
      final network = _FakeAuthNetwork(loginJson());
      final repo = AuthRepository(network: network, storage: storage);

      await expectLater(
        repo.login(email: 'a@b.pk', password: 'pw'),
        throwsA(isA<SessionPersistenceException>()),
      );
    });
  });

  group('BootController (readiness gate)', () {
    late _FakeFlutterSecureStorage backing;
    late SecureStorage storage;
    late _FakeAuthNetwork network;
    late ProviderContainer container;

    setUp(() {
      backing = _FakeFlutterSecureStorage();
      storage = SecureStorage(backing);
      network = _FakeAuthNetwork(loginJson());
      container = ProviderContainer(
        overrides: [
          secureStorageProvider.overrideWithValue(storage),
          authRepositoryProvider.overrideWithValue(
            AuthRepository(network: network, storage: storage),
          ),
        ],
      );
      addTearDown(container.dispose);
    });

    test('no stored session → needsLogin, /me never called', () async {
      await container.read(bootControllerProvider.notifier).run();

      final state = container.read(bootControllerProvider);
      expect(state.outcome, BootOutcome.needsLogin);
      expect(network.meCalls, 0);
      expect(state.step(BootStage.session).status, BootStepStatus.skipped);
    });

    test('stored token + successful /me → ready, profile refreshed', () async {
      await storage.saveSession(
        token: 'tok',
        tokenType: 'Bearer',
        expiresAt: '2099-10-10T11:00:00.000000Z',
        employeeId: 'e1',
        employeeName: 'Old Name',
        employeeEmail: 'old@b.pk',
        functionalTeamType: 'survey',
        teamName: 'Survey Team',
      );

      await container.read(bootControllerProvider.notifier).run();

      final state = container.read(bootControllerProvider);
      expect(state.outcome, BootOutcome.ready);
      expect(network.meCalls, 1);
      expect(state.step(BootStage.verify).status, BootStepStatus.done);
      expect(state.step(BootStage.team).status, BootStepStatus.done);
      // /me refreshed the employee context from the server payload.
      expect(await storage.getEmployeeName(), 'Ahmed Raza');
    });

    test('/me returning 401 clears the session and routes to login', () async {
      await storage.saveSession(
        token: 'stale',
        tokenType: 'Bearer',
        expiresAt: '2099-10-10T11:00:00.000000Z',
        employeeId: 'e1',
        employeeName: 'Ahmed Raza',
        employeeEmail: 'a@b.pk',
        functionalTeamType: 'survey',
        teamName: 'Survey Team',
      );
      network.meError = const ApiException(message: 'Unauthenticated.', statusCode: 401);

      await container.read(bootControllerProvider.notifier).run();

      final state = container.read(bootControllerProvider);
      expect(state.outcome, BootOutcome.needsLogin);
      expect(state.step(BootStage.verify).status, BootStepStatus.failed);
      expect(await storage.getToken(), isNull, reason: 'rejected token must be dropped');
    });

    test('network failure on /me keeps the saved session but still gates',
        () async {
      await storage.saveSession(
        token: 'tok',
        tokenType: 'Bearer',
        expiresAt: '2099-10-10T11:00:00.000000Z',
        employeeId: 'e1',
        employeeName: 'Ahmed Raza',
        employeeEmail: 'a@b.pk',
        functionalTeamType: 'survey',
        teamName: 'Survey Team',
      );
      network.meError = const NetworkException();

      await container.read(bootControllerProvider.notifier).run();

      final state = container.read(bootControllerProvider);
      expect(state.outcome, BootOutcome.ready);
      expect(state.step(BootStage.verify).status, BootStepStatus.skipped);
      expect(await storage.getToken(), 'tok',
          reason: 'offline must NOT wipe a session that may still be valid');
    });

    test('expired token is dropped before any network call', () async {
      await storage.saveSession(
        token: 'old',
        tokenType: 'Bearer',
        expiresAt: '2000-01-01T00:00:00.000000Z',
        employeeId: 'e1',
        employeeName: 'Ahmed Raza',
        employeeEmail: 'a@b.pk',
        functionalTeamType: 'survey',
        teamName: 'Survey Team',
      );

      await container.read(bootControllerProvider.notifier).run();

      final state = container.read(bootControllerProvider);
      expect(state.outcome, BootOutcome.needsLogin);
      expect(network.meCalls, 0);
      expect(await storage.getToken(), isNull);
    });
  });
}
