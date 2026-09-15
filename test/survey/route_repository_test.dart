import 'package:flutter_test/flutter_test.dart';
import 'package:isp_onlinecer/features/survey/data/route_network.dart';
import 'package:isp_onlinecer/features/survey/data/route_repository.dart';

class _FakeRouteNetwork implements RouteNetwork {
  _FakeRouteNetwork(this.result, {this.error});

  final Map<String, dynamic> result;
  final Exception? error;

  String? lastFatNodesId;
  String? lastRouteId;
  double? lastUserLat;
  double? lastUserLng;
  double? lastDpLat;
  double? lastDpLng;

  @override
  Future<Map<String, dynamic>> fetchFatNodes(String connectionRequestId) async {
    lastFatNodesId = connectionRequestId;
    if (error != null) throw error!;
    return result;
  }

  @override
  Future<Map<String, dynamic>> calculateRoute(
    String connectionRequestId, {
    required double userLatitude,
    required double userLongitude,
    required double dpLatitude,
    required double dpLongitude,
  }) async {
    lastRouteId = connectionRequestId;
    lastUserLat = userLatitude;
    lastUserLng = userLongitude;
    lastDpLat = dpLatitude;
    lastDpLng = dpLongitude;
    if (error != null) throw error!;
    return result;
  }
}

void main() {
  group('RouteRepository.fetchFatNodes', () {
    test('parses the {data:[...]} wrapper into a FatNodeList', () async {
      final network = _FakeRouteNetwork({
        'data': [
          {
            'id': 'node_1',
            'name': 'FAT-A Dhanmondi',
            'node_type': 'dp',
            'latitude': 23.7444,
            'longitude': 90.3788,
          },
          {
            'id': 'node_2',
            'name': 'FAT-B Mirpur',
            'node_type': 'p2p',
            'latitude': 23.8103,
            'longitude': 90.4125,
          },
        ],
      });

      final repository = RouteRepository(network: network);
      final list = await repository.fetchFatNodes('101');

      expect(network.lastFatNodesId, '101');
      expect(list.data, hasLength(2));
      expect(list.data.first.id, 'node_1');
      expect(list.data.first.name, 'FAT-A Dhanmondi');
      expect(list.data.first.nodeType, 'dp');
      expect(list.data.first.latitude, 23.7444);
      expect(list.data.first.longitude, 90.3788);
    });

    test('parses an empty list', () async {
      final network = _FakeRouteNetwork({'data': <dynamic>[]});
      final repository = RouteRepository(network: network);

      final list = await repository.fetchFatNodes('101');

      expect(list.data, isEmpty);
    });

    test('propagates network failures to the caller', () async {
      final network = _FakeRouteNetwork(
        const {},
        error: Exception('server unreachable'),
      );
      final repository = RouteRepository(network: network);

      expect(repository.fetchFatNodes('101'), throwsException);
    });
  });

  group('RouteRepository.calculateRoute', () {
    test('sends user + dp coordinates and parses a RouteResult', () async {
      final network = _FakeRouteNetwork({
        'distance_meters': 769.5,
        'source': 'osrm',
        'points': [
          {'latitude': 33.708855, 'longitude': 73.059244},
          {'latitude': 33.708801, 'longitude': 73.059163},
          {'latitude': 33.7087, 'longitude': 73.0591},
        ],
      });

      final repository = RouteRepository(network: network);
      final result = await repository.calculateRoute(
        '101',
        userLatitude: 33.708855,
        userLongitude: 73.059244,
        dpLatitude: 33.70873,
        dpLongitude: 73.05912,
      );

      expect(network.lastRouteId, '101');
      expect(network.lastUserLat, 33.708855);
      expect(network.lastUserLng, 73.059244);
      expect(network.lastDpLat, 33.70873);
      expect(network.lastDpLng, 73.05912);
      // Confirmed top-level shape: real road-following distance + multi-point path.
      expect(result.distanceMeters, 769.5);
      expect(result.source, 'osrm');
      expect(result.points, isNotNull);
      expect(result.points, hasLength(3));
      expect(result.points![0].latitude, closeTo(33.708855, 0.0000001));
      expect(result.points![0].longitude, closeTo(73.059244, 0.0000001));
      expect(result.points![2].longitude, closeTo(73.0591, 0.0001));
    });

    test('tolerates an unknown response shape (all fields nullable)', () async {
      // The route endpoint's response format is unverified — it may return
      // something the model doesn't recognise. Parsing must not throw.
      final network = _FakeRouteNetwork({'route': [1, 2, 3]});
      final repository = RouteRepository(network: network);

      final result = await repository.calculateRoute(
        '101',
        userLatitude: 0,
        userLongitude: 0,
        dpLatitude: 0,
        dpLongitude: 0,
      );

      expect(result.distanceMeters, isNull);
      expect(result.durationSeconds, isNull);
    });

    test('propagates network failures to the caller', () async {
      final network = _FakeRouteNetwork(
        const {},
        error: Exception('server unreachable'),
      );
      final repository = RouteRepository(network: network);

      expect(
        repository.calculateRoute(
          '101',
          userLatitude: 0,
          userLongitude: 0,
          dpLatitude: 0,
          dpLongitude: 0,
        ),
        throwsException,
      );
    });
  });
}