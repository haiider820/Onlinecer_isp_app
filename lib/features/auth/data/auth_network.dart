import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';

/// Minimal seam over the HTTP layer that [AuthRepository] depends on, so the
/// login flow is unit-testable without a real server or dio instance.
abstract interface class AuthNetwork {
  Future<Map<String, dynamic>> postLogin(Map<String, Object?> body);
  Future<Map<String, dynamic>> getMe();
  Future<Map<String, dynamic>> postLogout();
}

/// Real [AuthNetwork] backed by [ApiClient], posting to `POST /login`.
class DioAuthNetwork implements AuthNetwork {
  DioAuthNetwork(this._client);

  final ApiClient _client;

  @override
  Future<Map<String, dynamic>> postLogin(Map<String, Object?> body) {
    return _client.postMap(Endpoints.login, data: body);
  }

  @override
  Future<Map<String, dynamic>> getMe() {
    return _client.getMap(Endpoints.me);
  }

  @override
  Future<Map<String, dynamic>> postLogout() {
    return _client.postMap(Endpoints.logout);
  }
}
