import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';

/// Minimal seam over the HTTP layer for FAT-node lookups and route
/// calculation, so the route flow is unit-testable without a real server.
abstract interface class RouteNetwork {
  /// `GET /lookups/fat-nodes?connection_request_id={id}`.
  Future<Map<String, dynamic>> fetchFatNodes(String connectionRequestId);

  /// `POST /connection-requests/{id}/route`.
  Future<Map<String, dynamic>> calculateRoute(
    String connectionRequestId, {
    required double userLatitude,
    required double userLongitude,
    required double dpLatitude,
    required double dpLongitude,
  });
}

/// Real HTTP-backed implementation calling the lookups and route endpoints.
class DioRouteNetwork implements RouteNetwork {
  DioRouteNetwork(this._client);

  final ApiClient _client;

  @override
  Future<Map<String, dynamic>> fetchFatNodes(String connectionRequestId) {
    return _client.getMap(Endpoints.fatNodes(connectionRequestId));
  }

  @override
  Future<Map<String, dynamic>> calculateRoute(
    String connectionRequestId, {
    required double userLatitude,
    required double userLongitude,
    required double dpLatitude,
    required double dpLongitude,
  }) {
    return _client.postMap(
      Endpoints.calculateRoute(connectionRequestId),
      data: {
        'user_latitude': userLatitude,
        'user_longitude': userLongitude,
        'dp_latitude': dpLatitude,
        'dp_longitude': dpLongitude,
      },
    );
  }
}
