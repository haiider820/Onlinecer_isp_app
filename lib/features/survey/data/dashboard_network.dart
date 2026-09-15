import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';

/// Minimal seam over the HTTP layer that [DashboardRepository] depends on,
/// so the dashboard flow is unit-testable without a real server.
abstract interface class DashboardNetwork {
  Future<Map<String, dynamic>> fetchDashboard();
}

/// Real [DashboardNetwork] backed by [ApiClient], calling `GET /dashboard`.
class DioDashboardNetwork implements DashboardNetwork {
  DioDashboardNetwork(this._client);

  final ApiClient _client;

  @override
  Future<Map<String, dynamic>> fetchDashboard() async {
    return _client.getMap(Endpoints.dashboard);
  }
}