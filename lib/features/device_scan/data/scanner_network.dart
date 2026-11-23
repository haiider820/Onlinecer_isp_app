import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';

/// Minimal seam over the HTTP layer that [ScannerRepository] depends on, so
/// the scanner flow is unit-testable without a real server or dio instance.
///
/// Mirrors AuthNetwork: the scanner flow authenticates through the SAME
/// `POST /login` (ISPFINAL §1 — there is no scanner-only endpoint); only
/// the [ApiClient] instance differs (it reads `scanner.token`).
abstract interface class ScannerNetwork {
  Future<Map<String, dynamic>> postLogin(Map<String, Object?> body);
  Future<Map<String, dynamic>> getMe();
  Future<Map<String, dynamic>> postLogout();
}

/// Real [ScannerNetwork] backed by the scanner [ApiClient].
class DioScannerNetwork implements ScannerNetwork {
  DioScannerNetwork(this._client);

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
