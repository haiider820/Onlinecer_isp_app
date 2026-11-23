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
  static const _kBranchName = 'employee.branch_name';
  static const _kSubBranchName = 'employee.sub_branch_name';
  static const _kThemeMode = 'ui.theme_mode';
  static const _kRememberDevice = 'ui.remember_device';

  // Scanner session keys (ISPFINAL §1): a separate session that must NEVER
  // share keys with the employee session. Employee logout must never wipe
  // these, and scanner logout must never wipe the employee session.
  static const _kScannerToken = 'scanner.token';
  static const _kScannerTokenType = 'scanner.token_type';
  static const _kScannerExpiresAt = 'scanner.expires_at';
  static const _kScannerAccountId = 'scanner.account_id';
  static const _kScannerAccountName = 'scanner.account_name';

  /// Every key owned by the employee session. [clearSession] deletes exactly
  /// these — never `deleteAll()`, which would also wipe `scanner.*` keys and
  /// `ui.theme_mode`.
  static const _employeeKeys = <String>[
    _kToken,
    _kTokenType,
    _kExpiresAt,
    _kEmployeeId,
    _kEmployeeName,
    _kEmployeeEmail,
    _kTeamType,
    _kTeamName,
    _kBranchName,
    _kSubBranchName,
  ];

  /// Every key owned by the scanner session.
  static const _scannerKeys = <String>[
    _kScannerToken,
    _kScannerTokenType,
    _kScannerExpiresAt,
    _kScannerAccountId,
    _kScannerAccountName,
  ];

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
    String? branchName,
    String? subBranchName,
  }) async {
    await _storage.write(key: _kToken, value: token);
    await _storage.write(key: _kTokenType, value: tokenType);
    if (expiresAt != null) await _storage.write(key: _kExpiresAt, value: expiresAt);
    await _storage.write(key: _kEmployeeId, value: employeeId);
    await _storage.write(key: _kEmployeeName, value: employeeName);
    if (employeeEmail != null) await _storage.write(key: _kEmployeeEmail, value: employeeEmail);
    await _storage.write(key: _kTeamType, value: functionalTeamType);
    if (teamName != null) await _storage.write(key: _kTeamName, value: teamName);
    // A null branch/sub-branch clears any stale value from a previous login.
    if (branchName == null) {
      await _storage.delete(key: _kBranchName);
    } else {
      await _storage.write(key: _kBranchName, value: branchName);
    }
    if (subBranchName == null) {
      await _storage.delete(key: _kSubBranchName);
    } else {
      await _storage.write(key: _kSubBranchName, value: subBranchName);
    }
  }

  Future<String?> getToken() => _storage.read(key: _kToken);
  Future<String?> getTokenType() => _storage.read(key: _kTokenType);
  Future<String?> getExpiresAt() => _storage.read(key: _kExpiresAt);
  Future<String?> getEmployeeId() => _storage.read(key: _kEmployeeId);
  Future<String?> getEmployeeName() => _storage.read(key: _kEmployeeName);
  Future<String?> getFunctionalTeamType() => _storage.read(key: _kTeamType);
  Future<String?> getTeamName() => _storage.read(key: _kTeamName);
  Future<String?> getBranchName() => _storage.read(key: _kBranchName);
  Future<String?> getSubBranchName() => _storage.read(key: _kSubBranchName);

  // Scanner session (mirrors the employee session above, own keys only).
  Future<void> saveScannerSession({
    required String token,
    required String tokenType,
    required String? expiresAt,
    required String? accountId,
    required String? accountName,
  }) async {
    await _storage.write(key: _kScannerToken, value: token);
    await _storage.write(key: _kScannerTokenType, value: tokenType);
    if (expiresAt != null) await _storage.write(key: _kScannerExpiresAt, value: expiresAt);
    if (accountId != null) await _storage.write(key: _kScannerAccountId, value: accountId);
    if (accountName != null) await _storage.write(key: _kScannerAccountName, value: accountName);
  }

  Future<String?> getScannerToken() => _storage.read(key: _kScannerToken);
  Future<String?> getScannerTokenType() => _storage.read(key: _kScannerTokenType);
  Future<String?> getScannerExpiresAt() => _storage.read(key: _kScannerExpiresAt);
  Future<String?> getScannerAccountId() => _storage.read(key: _kScannerAccountId);
  Future<String?> getScannerAccountName() => _storage.read(key: _kScannerAccountName);

  /// True when a scanner bearer token exists AND its persisted expiry has
  /// not passed. An expired scanner token is not a live session (D3) —
  /// the router guard and scanner restore must see `false`, never admit
  /// a dead token. Unparseable / missing `expires_at` is lenient (not
  /// expired), mirroring [hasExpiredToken].
  Future<bool> isScannerLoggedIn() async {
    final token = await getScannerToken();
    if (token == null) return false;
    return !(await hasExpiredScannerToken());
  }

  /// Scanner counterpart of [hasExpiredToken]: true when the stored
  /// scanner token's persisted expiry has passed.
  Future<bool> hasExpiredScannerToken() async {
    final raw = await getScannerExpiresAt();
    if (raw == null) return false;
    final expiry = DateTime.tryParse(raw);
    if (expiry == null) return false;
    return expiry.isBefore(DateTime.now().toUtc());
  }

  /// Refreshes the stored scanner account identity without touching the
  /// token (mirror of [updateEmployeeContext]).
  Future<void> updateScannerAccount({
    required String? accountId,
    required String? accountName,
  }) async {
    if (accountId == null) {
      await _storage.delete(key: _kScannerAccountId);
    } else {
      await _storage.write(key: _kScannerAccountId, value: accountId);
    }
    if (accountName == null) {
      await _storage.delete(key: _kScannerAccountName);
    } else {
      await _storage.write(key: _kScannerAccountName, value: accountName);
    }
  }

  /// Round-trip persistence check for the scanner session (mirror of
  /// [verifySessionPersistence]).
  Future<void> verifyScannerSessionPersistence() async {
    final token = await getScannerToken();
    if (token == null || token.isEmpty) {
      throw const SessionPersistenceException();
    }
  }

  /// Deletes ONLY the scanner session keys. The employee session and the
  /// theme choice are untouched.
  Future<void> clearScannerSession() async {
    for (final key in _scannerKeys) {
      await _storage.delete(key: key);
    }
  }

  /// Persisted UI theme choice: 'light', 'dark', or null/'system'.
  Future<String?> getThemeMode() => _storage.read(key: _kThemeMode);

  Future<void> setThemeMode(String? value) {
    if (value == null) return _storage.delete(key: _kThemeMode);
    return _storage.write(key: _kThemeMode, value: value);
  }

  /// Persisted "remember this handheld unit" choice on the employee login
  /// (D12). `null` = never chosen; the login screen defaults to ON then.
  /// A `ui.*` key, so employee logout / 401 never wipes it.
  Future<bool?> getRememberDevice() async {
    final raw = await _storage.read(key: _kRememberDevice);
    if (raw == null) return null;
    return raw == 'true';
  }

  Future<void> setRememberDevice(bool value) =>
      _storage.write(key: _kRememberDevice, value: value ? 'true' : 'false');

  Future<void> updateEmployeeContext({
    required String employeeId,
    required String employeeName,
    required String? employeeEmail,
    required String functionalTeamType,
    required String? teamName,
    String? branchName,
    String? subBranchName,
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
    if (branchName == null) {
      await _storage.delete(key: _kBranchName);
    } else {
      await _storage.write(key: _kBranchName, value: branchName);
    }
    if (subBranchName == null) {
      await _storage.delete(key: _kSubBranchName);
    } else {
      await _storage.write(key: _kSubBranchName, value: subBranchName);
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

  /// True when a bearer token exists AND its persisted expiry has not
  /// passed. An expired token is not a live session (D3) — the router
  /// guard must see `false`, never admit a dead token. Unparseable /
  /// missing `expires_at` is lenient (not expired), mirroring
  /// [hasExpiredToken]; the boot gate still consults [hasExpiredToken]
  /// directly and clears the expired token itself.
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    if (token == null) return false;
    return !(await hasExpiredToken());
  }

  /// Listeners notified when the employee session is cleared via
  /// [clearSession] (manual logout, central 401 handling, boot-gate
  /// expiry drop). The storage layer cannot invalidate Riverpod
  /// providers directly, so per-session in-memory state (D5: the
  /// sub-branch scope) subscribes here instead of being moved into
  /// secure storage — the scope stays in-memory-only, it just learns
  /// when its session ends. Scanner clears deliberately do NOT notify:
  /// the sub-branch scope belongs to the employee session only.
  final Set<void Function()> _sessionClearedListeners = <void Function()>{};

  void addSessionClearedListener(void Function() listener) {
    _sessionClearedListeners.add(listener);
  }

  void removeSessionClearedListener(void Function() listener) {
    _sessionClearedListeners.remove(listener);
  }

  /// Deletes ONLY the employee session keys (`auth.*` / `employee.*`).
  /// Scanner keys (`scanner.*`) and the theme choice (`ui.theme_mode`) are
  /// deliberately left alone, so an employee logout/401 never signs the
  /// scanner out and never resets the theme.
  Future<void> clearSession() async {
    for (final key in _employeeKeys) {
      await _storage.delete(key: key);
    }
    for (final listener in _sessionClearedListeners.toList()) {
      listener();
    }
  }
}
