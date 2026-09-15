import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../network/api_exceptions.dart';

/// Wraps [FlutterSecureStorage] and owns the exact keys (and their JSON
/// shape) used to persist the auth session and employee context after login.
///
/// `functional_team_type` is stored separately so the router can decide which
/// dashboard shell to show without decoding the whole employee record.
class SecureStorage {
  SecureStorage(this._storage);

  final FlutterSecureStorage _storage;

  // Keys
  static const _kToken = 'auth.token';
  static const _kTokenType = 'auth.token_type';
  static const _kExpiresAt = 'auth.expires_at';
  static const _kEmployeeId = 'employee.id';
  static const _kEmployeeName = 'employee.name';
  static const _kEmployeeEmail = 'employee.email';
  static const _kTeamType = 'employee.functional_team_type';
  static const _kTeamName = 'employee.team_name';

  // Session
  Future<void> saveSession({
    required String token,
    required String tokenType,
    required String? expiresAt,
    required String employeeId,
    required String employeeName,
    required String? employeeEmail,
    required String functionalTeamType,
    required String? teamName,
  }) async {
    await _storage.write(key: _kToken, value: token);
    await _storage.write(key: _kTokenType, value: tokenType);
    if (expiresAt != null) await _storage.write(key: _kExpiresAt, value: expiresAt);
    await _storage.write(key: _kEmployeeId, value: employeeId);
    await _storage.write(key: _kEmployeeName, value: employeeName);
    if (employeeEmail != null) await _storage.write(key: _kEmployeeEmail, value: employeeEmail);
    await _storage.write(key: _kTeamType, value: functionalTeamType);
    if (teamName != null) await _storage.write(key: _kTeamName, value: teamName);
  }

  Future<String?> getToken() => _storage.read(key: _kToken);
  Future<String?> getTokenType() => _storage.read(key: _kTokenType);
  Future<String?> getExpiresAt() => _storage.read(key: _kExpiresAt);
  Future<String?> getEmployeeId() => _storage.read(key: _kEmployeeId);
  Future<String?> getEmployeeName() => _storage.read(key: _kEmployeeName);
  Future<String?> getFunctionalTeamType() => _storage.read(key: _kTeamType);
  Future<String?> getTeamName() => _storage.read(key: _kTeamName);

  Future<void> updateEmployeeContext({
    required String employeeId,
    required String employeeName,
    required String? employeeEmail,
    required String functionalTeamType,
    required String? teamName,
  }) async {
    await _storage.write(key: _kEmployeeId, value: employeeId);
    await _storage.write(key: _kEmployeeName, value: employeeName);
    if (employeeEmail == null) {
      await _storage.delete(key: _kEmployeeEmail);
    } else {
      await _storage.write(key: _kEmployeeEmail, value: employeeEmail);
    }
    await _storage.write(key: _kTeamType, value: functionalTeamType);
    if (teamName == null) {
      await _storage.delete(key: _kTeamName);
    } else {
      await _storage.write(key: _kTeamName, value: teamName);
    }
  }

  /// True when a bearer token exists but its persisted expiry has passed.
  Future<bool> hasExpiredToken() async {
    final raw = await getExpiresAt();
    if (raw == null) return false;
    final expiry = DateTime.tryParse(raw);
    if (expiry == null) return false;
    return expiry.isBefore(DateTime.now().toUtc());
  }

  /// Round-trip persistence check for the post-login readiness gate.
  ///
  /// The login flow must not navigate to any protected screen until the token
  /// it just wrote is confirmed readable from storage. A `null`/empty read or
  /// a team-type write that did not stick throws, which the login flow treats
  /// as a failed login instead of a half-persisted session. On the platform
  /// plugins (Android Keystore / iOS Keychain) a write future completing does
  /// not guarantee the value is durable — only a read-back can confirm it.
  Future<void> verifySessionPersistence({
    required String expectedTeamType,
  }) async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      throw const SessionPersistenceException();
    }
    final teamType = await getFunctionalTeamType();
    if (teamType == null || teamType.isEmpty) {
      throw const SessionPersistenceException();
    }
  }

  Future<bool> isLoggedIn() async => (await getToken()) != null;

  Future<void> clearSession() => _storage.deleteAll();
}
