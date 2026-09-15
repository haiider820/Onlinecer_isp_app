import '../../../models/fat_node.dart';
import '../../../models/route_result.dart';
import 'route_network.dart';

/// Fetches FAT-node lists and calculates routes for a connection request.
class RouteRepository {
  RouteRepository({required this.network});

  final RouteNetwork network;

  /// Fetches the FAT nodes near a connection request.
  Future<FatNodeList> fetchFatNodes(String connectionRequestId) async {
    final map = await network.fetchFatNodes(connectionRequestId);
    return FatNodeList.fromJson(map);
  }

  /// Calculates a route from the user's position to a FAT node.
  Future<RouteResult> calculateRoute(
    String connectionRequestId, {
    required double userLatitude,
    required double userLongitude,
    required double dpLatitude,
    required double dpLongitude,
  }) async {
    final map = await network.calculateRoute(
      connectionRequestId,
      userLatitude: userLatitude,
      userLongitude: userLongitude,
      dpLatitude: dpLatitude,
      dpLongitude: dpLongitude,
    );
    return RouteResult.fromJson(map);
  }
}
