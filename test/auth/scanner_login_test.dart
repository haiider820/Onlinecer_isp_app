import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isp_onlinecer/core/network/api_exceptions.dart';
import 'package:isp_onlinecer/core/storage/secure_storage.dart';
import 'package:isp_onlinecer/features/auth/data/auth_network.dart';
import 'package:isp_onlinecer/features/auth/data/auth_repository.dart';
import 'package:isp_onlinecer/features/device_scan/data/scanner_network.dart';
import 'package:isp_onlinecer/features/device_scan/data/scanner_repository.dart';
import 'package:isp_onlinecer/models/auth.dart';

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
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    store.remove(key);
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

class _FakeAuthNetwork implements AuthNetwork {
  _FakeAuthNetwork(this.loginResponse);

  final Map<String, Object?> loginResponse;

  @override
  Future<Map<String, dynamic>> postLogin(Map<String, Object?> body) async {
    return loginResponse;
  }

  @override
  Future<Map<String, dynamic>> getMe() async => <String, dynamic>{};

  @override
  Future<Map<String, dynamic>> postLogout() async => <String, dynamic>{};
}

class _FakeScannerNetwork implements ScannerNetwork {
  _FakeScannerNetwork({required this.loginResponse, this.meResponse, this.meError});

  final Map<String, Object?> loginResponse;
  final Map<String, Object?>? meResponse;
  final Object? meError;
  int meCalls = 0;

  @override
  Future<Map<String, dynamic>> postLogin(Map<String, Object?> body) async {
    return loginResponse;
  }

  @override
  Future<Map<String, dynamic>> getMe() async {
    meCalls++;
    if (meError != null) throw meError!;
    return meResponse ?? <String, dynamic>{};
  }

  @override
  Future<Map<String, dynamic>> postLogout() async => <String, dynamic>{};
}

Map<String, Object?> employeeLoginJson({
  String? accountType,
  bool withBranch = false,
}) =>
    <String, Object?>{
      'message': 'Login successful.',
      'token_type': 'Bearer',
      'token': 'employee_token_here',
      'expires_at': '2099-10-10T11:00:00.000000Z',
      if (accountType != null) 'account_type': accountType,
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
        if (withBranch) 'branch': <String, Object?>{'id': 'b1', 'name': 'Gulshan Branch'},
        if (withBranch)
          'sub_branch': <String, Object?>{'id': 'sb1', 'name': 'Gulshan Sub'},
      },
      'permissions': <Object?>[],
      'permission_labels': <Object?>[],
    };

Map<String, Object?> scannerLoginJson({String? accountType}) => <String, Object?>{
      'message': 'Login successful.',
      'token_type': 'Bearer',
      'token': 'scanner_token_here',
      'expires_at': '2099-10-10T11:00:00.000000Z',
      if (accountType != null) 'account_type': accountType,
      'user': <String, Object?>{'id': 7, 'name': 'Scanner One', 'email': 'scan@malikfiber.pk'},
      'permissions': <Object?>[],
      'permission_labels': <Object?>[],
    };

void main() {
  late _FakeFlutterSecureStorage backing;
  late SecureStorage storage;

  setUp(() {
    backing = _FakeFlutterSecureStorage();
    storage = SecureStorage(backing);
  });

  Future<void> seedScannerSession() => storage.saveScannerSession(
        token: 'scanner_token_here',
        tokenType: 'Bearer',
        expiresAt: '2099-10-10T11:00:00.000000Z',
        accountId: '7',
        accountName: 'Scanner One',
      );

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

  group('account_type parsing', () {
    test('parses account_type when present', () {
      final response = LoginResponse.fromJson(scannerLoginJson(accountType: 'scanner'));
      expect(response.accountType, 'scanner');
    });

    test('missing account_type parses as null (never fails parsing)', () {
      final response = LoginResponse.fromJson(scannerLoginJson());
      expect(response.accountType, isNull);
    });

    test('parses employee.branch / employee.sub_branch leniently', () {
      final response =
          LoginResponse.fromJson(employeeLoginJson(accountType: 'employee', withBranch: true));
      expect(response.employee?.branch?['name'], 'Gulshan Branch');
      expect(response.employee?.subBranch?['name'], 'Gulshan Sub');
    });

    test('branch with an unexpected shape parses as null, never breaks login', () {
      final json = employeeLoginJson(accountType: 'employee');
      (json['employee'] as Map<String, Object?>)['branch'] = 'not-an-object';
      final response = LoginResponse.fromJson(json);
      expect(response.employee?.branch, isNull);
      expect(response.employee?.name, 'Ahmed Raza');
    });
  });

  group('employee login (AuthRepository) vs account_type', () {
    test('refuses a scanner account_type and saves nothing', () async {
      final repo = AuthRepository(
        network: _FakeAuthNetwork(employeeLoginJson(accountType: 'scanner')),
        storage: storage,
      );

      await expectLater(
        repo.login(email: 'scan@malikfiber.pk', password: 'pw'),
        throwsA(isA<ApiException>()),
      );
      expect(await storage.getToken(), isNull);
      expect(await storage.getScannerToken(), isNull);
    });

    test('missing account_type falls back to employee (current behaviour)', () async {
      final repo = AuthRepository(
        network: _FakeAuthNetwork(employeeLoginJson()),
        storage: storage,
      );

      final response = await repo.login(email: 'a@b.pk', password: 'pw');
      expect(response.accountType, isNull);
      expect(await storage.getToken(), 'employee_token_here');
      expect(await storage.getFunctionalTeamType(), 'survey');
    });

    test('stores branch_name / sub_branch_name when present', () async {
      final repo = AuthRepository(
        network: _FakeAuthNetwork(
          employeeLoginJson(accountType: 'employee', withBranch: true),
        ),
        storage: storage,
      );

      await repo.login(email: 'a@b.pk', password: 'pw');
      expect(await storage.getBranchName(), 'Gulshan Branch');
      expect(await storage.getSubBranchName(), 'Gulshan Sub');
    });

    test('clears stale branch names when a later login omits them', () async {
      final repo = AuthRepository(
        network: _FakeAuthNetwork(
          employeeLoginJson(accountType: 'employee', withBranch: true),
        ),
        storage: storage,
      );
      await repo.login(email: 'a@b.pk', password: 'pw');
      expect(await storage.getBranchName(), 'Gulshan Branch');

      final repoWithoutBranch = AuthRepository(
        network: _FakeAuthNetwork(employeeLoginJson(accountType: 'employee')),
        storage: storage,
      );
      await repoWithoutBranch.login(email: 'a@b.pk', password: 'pw');
      expect(await storage.getBranchName(), isNull);
      expect(await storage.getSubBranchName(), isNull);
    });
  });

  group('token separation', () {
    test('scanner login saves scanner.token and leaves auth.token intact', () async {
      await seedEmployeeSession();
      final repo = ScannerRepository(
        network: _FakeScannerNetwork(loginResponse: scannerLoginJson(accountType: 'scanner')),
        storage: storage,
      );

      await repo.login(email: 'scan@malikfiber.pk', password: 'pw');

      expect(await storage.getScannerToken(), 'scanner_token_here');
      expect(await storage.getScannerAccountId(), '7');
      expect(await storage.getScannerAccountName(), 'Scanner One');
      expect(await storage.getToken(), 'employee_token_here',
          reason: 'scanner login must never overwrite the employee token');
    });

    test('employee login after scanner login leaves scanner.token intact', () async {
      await seedScannerSession();
      final repo = AuthRepository(
        network: _FakeAuthNetwork(employeeLoginJson(accountType: 'employee')),
        storage: storage,
      );

      await repo.login(email: 'a@b.pk', password: 'pw');

      expect(await storage.getToken(), 'employee_token_here');
      expect(await storage.getScannerToken(), 'scanner_token_here',
          reason: 'employee login must never overwrite the scanner token');
    });

    test('employee logout does not wipe scanner keys or the theme key', () async {
      await seedEmployeeSession();
      await seedScannerSession();
      await storage.setThemeMode('dark');
      final repo = AuthRepository(
        network: _FakeAuthNetwork(employeeLoginJson(accountType: 'employee')),
        storage: storage,
      );

      await repo.logout();

      expect(await storage.getToken(), isNull);
      expect(await storage.getFunctionalTeamType(), isNull);
      expect(await storage.getScannerToken(), 'scanner_token_here');
      expect(await storage.getScannerAccountName(), 'Scanner One');
      expect(await storage.getThemeMode(), 'dark');
    });

    test('scanner logout does not wipe employee keys or the theme key', () async {
      await seedEmployeeSession();
      await seedScannerSession();
      await storage.setThemeMode('light');
      final repo = ScannerRepository(
        network: _FakeScannerNetwork(loginResponse: scannerLoginJson(accountType: 'scanner')),
        storage: storage,
      );

      await repo.logout();

      expect(await storage.getScannerToken(), isNull);
      expect(await storage.getScannerAccountName(), isNull);
      expect(await storage.getToken(), 'employee_token_here');
      expect(await storage.getFunctionalTeamType(), 'survey');
      expect(await storage.getThemeMode(), 'light');
    });

    test('clearSession deletes employee keys only', () async {
      await seedEmployeeSession();
      await seedScannerSession();
      await storage.setThemeMode('dark');

      await storage.clearSession();

      expect(await storage.getToken(), isNull);
      expect(await storage.getEmployeeName(), isNull);
      expect(await storage.getBranchName(), isNull);
      expect(await storage.getScannerToken(), 'scanner_token_here');
      expect(await storage.getThemeMode(), 'dark');
    });
  });

  group('scanner login (ScannerRepository)', () {
    test('success path with mocked network persists the scanner session', () async {
      final repo = ScannerRepository(
        network: _FakeScannerNetwork(loginResponse: scannerLoginJson(accountType: 'scanner')),
        storage: storage,
      );

      final response = await repo.login(email: 'scan@malikfiber.pk', password: 'pw');

      expect(response.accountType, 'scanner');
      expect(await storage.getScannerToken(), 'scanner_token_here');
      expect(await storage.isScannerLoggedIn(), isTrue);
    });

    test('missing account_type is accepted on the scanner screen', () async {
      final repo = ScannerRepository(
        network: _FakeScannerNetwork(loginResponse: scannerLoginJson()),
        storage: storage,
      );

      await repo.login(email: 'scan@malikfiber.pk', password: 'pw');
      expect(await storage.getScannerToken(), 'scanner_token_here');
    });

    test('refuses an explicit employee account_type and saves nothing', () async {
      final repo = ScannerRepository(
        network: _FakeScannerNetwork(
          loginResponse: scannerLoginJson(accountType: 'employee'),
        ),
        storage: storage,
      );

      await expectLater(
        repo.login(email: 'a@b.pk', password: 'pw'),
        throwsA(isA<ApiException>()),
      );
      expect(await storage.getScannerToken(), isNull);
    });

    test('scanner 401 on restore clears only the scanner session', () async {
      await seedEmployeeSession();
      await seedScannerSession();
      await storage.setThemeMode('dark');
      final repo = ScannerRepository(
        network: _FakeScannerNetwork(
          loginResponse: scannerLoginJson(accountType: 'scanner'),
          meError: const ApiException(message: 'Unauthenticated.', statusCode: 401),
        ),
        storage: storage,
      );

      final session = await repo.restoreSession();

      expect(session, isNull);
      expect(await storage.getScannerToken(), isNull,
          reason: 'rejected scanner token must be dropped');
      expect(await storage.getToken(), 'employee_token_here',
          reason: 'scanner 401 must not wipe the employee session');
      expect(await storage.getThemeMode(), 'dark');
    });

    test('network failure on restore keeps the stored scanner identity', () async {
      await seedScannerSession();
      final repo = ScannerRepository(
        network: _FakeScannerNetwork(
          loginResponse: scannerLoginJson(accountType: 'scanner'),
          meError: const NetworkException(),
        ),
        storage: storage,
      );

      final session = await repo.restoreSession();

      expect(session, isNotNull);
      expect(session!.accountName, 'Scanner One');
      expect(await storage.getScannerToken(), 'scanner_token_here',
          reason: 'offline must NOT wipe a session that may still be valid');
    });

    test('restore with no stored token returns null without a network call', () async {
      final network = _FakeScannerNetwork(
        loginResponse: scannerLoginJson(accountType: 'scanner'),
      );
      final repo = ScannerRepository(network: network, storage: storage);

      final session = await repo.restoreSession();

      expect(session, isNull);
      expect(network.meCalls, 0);
    });
  });
}
