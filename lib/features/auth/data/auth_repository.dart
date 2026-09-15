import '../../../core/storage/secure_storage.dart';
import '../../../models/auth.dart';
import 'auth_network.dart';

/// Handles `POST /login` and persists the session on success.
///
/// Failures surface as typed [ApiException]s (see `api_exceptions.dart`) so
/// the UI can show the backend's exact message (invalid credentials, inactive
/// account, network error) without parsing strings itself.
class AuthRepository {
  AuthRepository({required AuthNetwork network, required SecureStorage storage})
      : _network = network,
        _storage = storage;

  final AuthNetwork _network;
  final SecureStorage _storage;

  /// Authenticates the employee and persists the auth token + employee
  /// context needed by the router and subsequent API calls.
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

    await _saveSession(response);
    return response;
  }

  /// Fetches the current mobile profile and refreshes the locally stored
  /// employee/team context without replacing the bearer token.
  Future<Employee?> fetchMeAndRefreshSession() async {
    final map = await _network.getMe();
    final data = map['data'] is Map ? Map<String, Object?>.from(map['data'] as Map) : null;
    final employeeMap = map['employee'] ?? data?['employee'] ?? data;
    final employee = employeeMap is Map
        ? Employee.fromJson(Map<String, Object?>.from(employeeMap))
        : null;

    if (employee != null) {
      await _storage.updateEmployeeContext(
        employeeId: employee.id,
        employeeName: employee.name,
        employeeEmail: employee.email,
        functionalTeamType: employee.team?.functionalTeamType ?? '',
        teamName: employee.team?.name,
      );
    }
    return employee;
  }

  /// Deletes the server-side mobile token, then clears the local session.
  Future<void> logout() async {
    try {
      await _network.postLogout();
    } finally {
      await _storage.clearSession();
    }
  }

  Future<void> _saveSession(LoginResponse response) async {
    final employee = response.employee;
    final team = employee?.team;

    await _storage.saveSession(
      token: response.token,
      tokenType: response.tokenType,
      expiresAt: response.expiresAt,
      employeeId: employee?.id ?? '',
      employeeName: employee?.name ?? response.user?.name ?? '',
      employeeEmail: employee?.email,
      functionalTeamType: team?.functionalTeamType ?? '',
      teamName: team?.name,
    );

    // Readiness gate: the login is only successful once the token (and team
    // context) are confirmed readable from storage. Until this returns, the
    // AuthInterceptor's next read could still miss the token and send the
    // first protected request unauthenticated, so callers must treat a throw
    // here as a failed login — never navigate on a half-persisted session.
    await _storage.verifySessionPersistence(
      expectedTeamType: team?.functionalTeamType ?? '',
    );
  }
}
