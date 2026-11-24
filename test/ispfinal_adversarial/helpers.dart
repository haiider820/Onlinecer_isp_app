/// Shared fakes for the ISPFINAL adversarial suite (test/ispfinal_adversarial).
///
/// Everything here is in-memory / scripted — no live server is ever touched.
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:isp_onlinecer/core/storage/secure_storage.dart';

class InMemoryFlutterSecureStorage extends FlutterSecureStorage {
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

SecureStorage freshStorage(InMemoryFlutterSecureStorage backing) =>
    SecureStorage(backing);

Map<String, Object?> employeePayload({
  String accountType = 'employee',
  bool includeAccountType = true,
}) {
  return <String, Object?>{
    'message': 'Logged in',
    'token_type': 'Bearer',
    'token': 'emp-token-1',
    'expires_at': '2099-10-10T11:00:00.000000Z',
    if (includeAccountType) 'account_type': accountType,
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

Map<String, Object?> scannerPayload({
  String? accountType,
  bool includeAccountType = true,
}) {
  return <String, Object?>{
    'message': 'Logged in',
    'token_type': 'Bearer',
    'token': 'scanner-token-1',
    'expires_at': '2099-10-10T11:00:00.000000Z',
    if (includeAccountType && accountType != null) 'account_type': accountType,
    'user': <String, Object?>{'id': 7, 'name': 'Scanner One', 'email': 'scanner@isp360.com'},
  };
}

Future<void> seedEmployeeSession(
  SecureStorage storage, {
  String expiresAt = '2099-10-10T11:00:00.000000Z',
  String teamType = 'survey',
  String? subBranchId,
  String? subBranchName,
}) =>
    storage.saveSession(
      token: 'emp-token-1',
      tokenType: 'Bearer',
      expiresAt: expiresAt,
      employeeId: 'employee-1',
      employeeName: 'Ahmed Raza',
      employeeEmail: 'ahmed@isp360.com',
      functionalTeamType: teamType,
      teamName: 'Survey Team',
      subBranchId: subBranchId,
      subBranchName: subBranchName,
    );

Future<void> seedScannerSession(
  SecureStorage storage, {
  String expiresAt = '2099-10-10T11:00:00.000000Z',
}) =>
    storage.saveScannerSession(
      token: 'scanner-token-1',
      tokenType: 'Bearer',
      expiresAt: expiresAt,
      accountId: '7',
      accountName: 'Scanner One',
    );
