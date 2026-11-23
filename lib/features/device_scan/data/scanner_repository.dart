import '../../../core/network/api_exceptions.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../models/auth.dart';
import 'scanner_network.dart';

/// The signed-in scanner account, as restored from storage and (when the
/// network allows) enriched by `GET /me`.
class ScannerSession {
  const ScannerSession({
    required this.accountId,
    required this.accountName,
    this.organizationName,
  });

  final String? accountId;
  final String? accountName;

  /// Organisation name when the `/me` payload carried one; otherwise null.
  /// Never faked — when the backend does not send it, the home screen says
  /// so instead of guessing.
  final String? organizationName;
}

/// Handles scanner sign-in through the SAME `POST /login` as employees
/// (ISPFINAL §1 — no scanner-only endpoint exists) and persists the session
/// under the `scanner.*` keys only, so it can never overwrite the employee
/// session. Failures surface as typed [ApiException]s.
class ScannerRepository {
  ScannerRepository({required ScannerNetwork network, required SecureStorage storage})
      : _network = network,
        _storage = storage;

  final ScannerNetwork _network;
  final SecureStorage _storage;

  /// Authenticates the scanner account and persists the scanner token +
  /// account identity. A response whose `account_type` is explicitly
  /// "employee" is refused here — staff accounts sign in on the employee
  /// screen. A missing `account_type` is accepted: the user deliberately
  /// opened the scanner login, and the backend may not send the field yet.
  Future<LoginResponse> login({
    required String email,
    required String password,
    String? deviceName,
  }) async {
    final body = <String, Object?>{
      'email': email.trim(),
      'password': password,
      if (deviceName != null && deviceName.isNotEmpty) 'device_name': deviceName,
    };

    final map = await _network.postLogin(body);
    final response = LoginResponse.fromJson(map);

    final accountType = response.accountType;
    if (accountType != null && accountType.toLowerCase() == 'employee') {
      throw ApiException(
        message: response.message.isNotEmpty
            ? response.message
            : 'Please use the staff login for this account.',
      );
    }

    final user = response.user;
    await _storage.saveScannerSession(
      token: response.token,
      tokenType: response.tokenType,
      expiresAt: response.expiresAt,
      accountId: user != null ? user.id.toString() : response.employee?.id,
      accountName: user?.name ?? response.employee?.name,
    );

    // Readiness gate (mirror of the employee login): the scanner login only
    // succeeds once the token is confirmed readable from storage.
    await _storage.verifyScannerSessionPersistence();
    return response;
  }

  /// Silent restore for the scanner login screen: no stored token → null
  /// (show the form). A successful `GET /me` enriches the stored identity
  /// with the organisation name when the payload carries one. A 401 drops
  /// the stale scanner session and returns null; a network failure keeps
  /// the stored identity (same offline rule as the employee boot gate) so
  /// the user is never stranded by a flaky connection.
  Future<ScannerSession?> restoreSession() async {
    final token = await _storage.getScannerToken();
    if (token == null || token.isEmpty) return null;

    final accountId = await _storage.getScannerAccountId();
    final accountName = await _storage.getScannerAccountName();
    try {
      final map = await _network.getMe();
      final data = map['data'] is Map ? Map<String, Object?>.from(map['data'] as Map) : map;
      final name = _nameFromMe(data);
      final organizationName = _organizationNameFromMe(data);
      if (name != null || organizationName != null) {
        await _storage.updateScannerAccount(
          accountId: accountId,
          accountName: name ?? accountName,
        );
      }
      return ScannerSession(
        accountId: accountId,
        accountName: name ?? accountName,
        organizationName: organizationName,
      );
    } on ApiException catch (e) {
      if (e.isUnauthorized) {
        await _storage.clearScannerSession();
        return null;
      }
      return ScannerSession(accountId: accountId, accountName: accountName);
    }
  }

  /// Deletes the server-side scanner token, then clears ONLY the scanner
  /// session. The employee session and theme choice are untouched.
  Future<void> logout() async {
    try {
      await _network.postLogout();
    } finally {
      await _storage.clearScannerSession();
    }
  }

  /// Best-effort account name out of a `/me` payload, whatever shape it
  /// arrives in. Never throws — an unknown shape just yields null.
  static String? _nameFromMe(Map<String, Object?> data) {
    final user = data['user'];
    if (user is Map && user['name'] is String) return user['name'] as String;
    final employee = data['employee'];
    if (employee is Map && employee['name'] is String) {
      return employee['name'] as String;
    }
    if (data['name'] is String) return data['name'] as String;
    return null;
  }

  /// Best-effort organisation name out of a `/me` payload. Never throws.
  static String? _organizationNameFromMe(Map<String, Object?> data) {
    final organization = data['organization'];
    if (organization is Map && organization['name'] is String) {
      return organization['name'] as String;
    }
    final employee = data['employee'];
    if (employee is Map) {
      final employeeOrg = employee['organization'];
      if (employeeOrg is Map && employeeOrg['name'] is String) {
        return employeeOrg['name'] as String;
      }
    }
    return null;
  }
}
