import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exceptions.dart';
import '../../../models/fat_node.dart';
import '../../../models/route_result.dart';
import '../../auth/presentation/providers.dart';
import '../data/geolocator_location_service.dart';
import '../data/location_service.dart';
import '../data/route_network.dart';
import '../data/route_repository.dart';

/// Device GPS access for the route screen. Overridable in tests.
final locationServiceProvider = Provider<LocationService>((ref) {
  return const GeolocatorLocationService();
});

/// Real HTTP-backed route network.
final routeNetworkProvider = Provider<RouteNetwork>((ref) {
  return DioRouteNetwork(ref.watch(apiClientProvider));
});

/// Route repository wiring the network layer.
final routeRepositoryProvider = Provider<RouteRepository>((ref) {
  return RouteRepository(network: ref.watch(routeNetworkProvider));
});

/// Fetches the FAT nodes for a connection request, keyed by request id.
final fatNodesProvider = FutureProvider.family<FatNodeList, String>((ref, id) {
  return ref.watch(routeRepositoryProvider).fetchFatNodes(id);
});

/// Immutable route-calculation state exposed to the route screen.
class RouteCalcState {
  const RouteCalcState({
    this.isCalculating = false,
    this.errorMessage,
    this.result,
  });

  final bool isCalculating;
  final String? errorMessage;
  final RouteResult? result;

  bool get hasError => errorMessage != null;
  bool get hasResult => result != null;
}

/// Drives the route calculation. Populates [RouteCalcState.result] on success.
class RouteCalcController extends Notifier<RouteCalcState> {
  @override
  RouteCalcState build() => const RouteCalcState();

  Future<RouteResult?> calculate({
    required String connectionRequestId,
    required double userLatitude,
    required double userLongitude,
    required double dpLatitude,
    required double dpLongitude,
  }) async {
    state = const RouteCalcState(isCalculating: true);
    try {
      final repo = ref.read(routeRepositoryProvider);
      final result = await repo.calculateRoute(
        connectionRequestId,
        userLatitude: userLatitude,
        userLongitude: userLongitude,
        dpLatitude: dpLatitude,
        dpLongitude: dpLongitude,
      );
      state = RouteCalcState(result: result);
      return result;
    } on ApiException catch (e) {
      state = RouteCalcState(errorMessage: e.message);
      return null;
    } catch (e) {
      state = RouteCalcState(errorMessage: e.toString());
      return null;
    }
  }

  void clearError() {
    state = const RouteCalcState();
  }
}

final routeCalcControllerProvider =
    NotifierProvider<RouteCalcController, RouteCalcState>(
  RouteCalcController.new,
);
