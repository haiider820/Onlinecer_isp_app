import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';

/// Minimal seam over the HTTP layer that [ConnectionRequestRepository]
/// depends on, so the request list/detail flows are unit-testable without a
/// real server.
abstract interface class ConnectionRequestNetwork {
  /// `page` is 1-based. [status] optionally narrows the queue server-side
  /// (e.g. `installation_assigned`) — omitted for the unfiltered survey view.
  Future<Map<String, dynamic>> fetchPage({required int page, String? status});

  /// `GET /connection-requests/{id}` → `{ "data": {...}, "allowed_action": ... }`.
  Future<Map<String, dynamic>> fetchDetail(String id);
}

/// Real HTTP-backed implementation calling `GET /connection-requests?page=N`
/// and `GET /connection-requests/{id}`.
class DioConnectionRequestNetwork implements ConnectionRequestNetwork {
  DioConnectionRequestNetwork(this._client);

  final ApiClient _client;

  @override
  Future<Map<String, dynamic>> fetchPage({required int page, String? status}) {
    return _client.getMap(
      Endpoints.connectionRequests(),
      query: {
        'page': page,
        if (status != null) 'status': status,
      },
    );
  }

  @override
  Future<Map<String, dynamic>> fetchDetail(String id) {
    return _client.getMap(Endpoints.connectionRequestDetail(id));
  }
}
