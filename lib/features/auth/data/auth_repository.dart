import '../../../core/network/api_exceptions.dart';
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

    // ISPFINAL §1: the same endpoint serves scanner accounts. A response
    // whose account_type is present and is not "employee" is NOT an
    // employee session — never save its token under the employee keys.
    // A missing account_type is treated as employee (old payloads).
    final accountType = response.accountType;
    if (accountType != null && accountType.toLowerCase() != 'employee') {
      throw ApiException(
        message: response.message.isNotEmpty
            ? response.message
            : 'Please use Scanner login for this account.',
      );
    }

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
        functionalTeamTypes: employee.team?.functionalTeamTypes,
        teamName: employee.team?.name,
        branchName: _branchName(employee.branch),
        subBranchId: _branchId(employee.subBranch),
        subBranchName: _branchName(employee.subBranch),
      );
    }
    return employee;
  }

  /// Reads the `name` out of a leniently-parsed branch/sub-branch map.
  static String? _branchName(Map<String, Object?>? branch) {
    final name = branch?['name'];
    return name is String && name.isNotEmpty ? name : null;
  }

  /// Reads the `id` out of a leniently-parsed branch/sub-branch map.
  /// Only a non-empty string counts: the id is what the sub-branch
  /// auto-default matches against the `GET /lookups/sub-branches` rows,
  /// so a wrong-typed value must never be persisted as an id.
  static String? _branchId(Map<String, Object?>? branch) {
    final id = branch?['id'];
    return id is String && id.isNotEmpty ? id : null;
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
      functionalTeamTypes: team?.functionalTeamTypes,
      teamName: team?.name,
      branchName: _branchName(employee?.branch),
      subBranchId: _branchId(employee?.subBranch),
      subBranchName: _branchName(employee?.subBranch),
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
