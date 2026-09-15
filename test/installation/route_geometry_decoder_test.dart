import 'package:flutter_test/flutter_test.dart';
import 'package:isp_onlinecer/shared/maps/route_geometry_decoder.dart';
import 'package:latlong2/latlong.dart';

/// Builds the exact response shape the live backend confirmed:
/// `{"points": [{"latitude":…, "longitude":…}, …], "distance_meters":…, "source":…}`.
/// Two of the points are the real captured endpoints (33.708855,73.059244 →
/// 33.708801,73.059163); the remaining 25 are interpolated along that segment
/// so the fixture has the same 27-point count as the real 769.5 m response.
Map<String, Object?> _realRouteResponse({int pointCount = 27}) {
  final start = const [33.708855, 73.059244];
  final end = const [33.708801, 73.059163];
  final points = <Map<String, double>>[];
  for (var i = 0; i < pointCount; i++) {
    final t = pointCount == 1 ? 0.0 : i / (pointCount - 1);
    points.add({
      'latitude': start[0] + (end[0] - start[0]) * t,
      'longitude': start[1] + (end[1] - start[1]) * t,
    });
  }
  return {
    'points': points,
    'distance_meters': 769.5,
    'source': 'osrm',
  };
}

void main() {
  group('decodeRoutePoints (whole-map entry point)', () {
    test('parses the real live /route response: 27 points + distance', () {
      final json = _realRouteResponse();

      final points = decodeRoutePoints(json);

      expect(points, isNotNull);
      expect(points, hasLength(27));
      expect(points![0].latitude, closeTo(33.708855, 0.0000001));
      expect(points[0].longitude, closeTo(73.059244, 0.0000001));
      expect(points[26].latitude, closeTo(33.708801, 0.0000001));
      expect(points[26].longitude, closeTo(73.059163, 0.0000001));
      // Every point stays inside the valid LatLng ranges.
      expect(points.every((p) => p.latitude >= -90 && p.latitude <= 90), isTrue);
      expect(points.every((p) => p.longitude >= -180 && p.longitude <= 180), isTrue);
    });

    test('returns null when points is absent or empty', () {
      expect(decodeRoutePoints(const {}), isNull);
      expect(decodeRoutePoints(const {'points': <Object?>[]}), isNull);
    });

    test('returns null when points is not a list', () {
      expect(decodeRoutePoints(const {'points': 'FAT-A Dhanmondi'}), isNull);
      expect(decodeRoutePoints(const {'points': 42}), isNull);
    });

    test('returns null when fewer than two valid points decode', () {
      expect(
        decodeRoutePoints(const {
          'points': [
            {'latitude': 33.708855, 'longitude': 73.059244},
          ],
        }),
        isNull,
      );
      expect(
        decodeRoutePoints(const {
          'points': [
            {'lat': 33.708855, 'lng': 73.059244}, // old keys → not parsed
          ],
        }),
        isNull,
      );
    });

    test('skips junk entries and out-of-range coords, then decodes the rest', () {
      final points = decodeRoutePoints({
        'points': [
          42,
          {'latitude': 200, 'longitude': 73.05}, // lat out of range → skipped
          {'latitude': 33.708855, 'longitude': 73.059244},
          'junk',
          {'latitude': 33.708801, 'longitude': 73.059163},
        ],
      });

      expect(points, isNotNull);
      expect(points, hasLength(2));
    });
  });

  group('decodeRoutePointsArray (field-level converter)', () {
    test('decodes the confirmed shape directly from the points field', () {
      final points = decodeRoutePointsArray(<Object>[
        {'latitude': 23.744, 'longitude': 90.3788},
        {'latitude': 23.745, 'longitude': 90.38},
      ]);

      expect(points, isNotNull);
      expect(points, hasLength(2));
      expect(points![0].latitude, closeTo(23.744, 0.00001));
      expect(points[0].longitude, closeTo(90.3788, 0.00001));
    });

    test('does not accept the old key spellings (lat/lng)', () {
      // Old-format keys are deliberately not supported: the real backend never
      // returns them, so a list of only lat/lng objects yields no points.
      final points = decodeRoutePointsArray(<Object>[
        {'lat': 23.744, 'lng': 90.3788},
        {'lat': 23.745, 'lng': 90.38},
      ]);

      expect(points, isNull);
    });

    test('returns null for non-list input', () {
      expect(decodeRoutePointsArray(null), isNull);
      expect(decodeRoutePointsArray('nope'), isNull);
      expect(
        decodeRoutePointsArray(<Object>[<Object>[23.744, 90.3788]]), // [lat,lng] pair not accepted
        isNull,
      );
    });
  });

  group('encodeRoutePointsArray (round trip)', () {
    test('serialises LatLng back to the confirmed shape', () {
      const sample = [
        LatLng(33.708855, 73.059244),
        LatLng(33.708801, 73.059163),
      ];

      final json = encodeRoutePointsArray(sample);

      expect(json, hasLength(2));
      expect(json![0]['latitude'], 33.708855);
      expect(json[0]['longitude'], 73.059244);
      expect(json[1]['latitude'], 33.708801);

      // round-trip: encode then decode reproduces the points.
      final decoded = decodeRoutePointsArray(json);
      expect(decoded, isNotNull);
      expect(decoded![0].latitude, closeTo(33.708855, 0.0000001));
      expect(decoded[0].longitude, closeTo(73.059244, 0.0000001));
    });

    test('returns null for null input', () {
      expect(encodeRoutePointsArray(null), isNull);
    });
  });

  group('straightLineFallback', () {
    test('returns exactly the start/end pair (genuine no-route case only)', () {
      const start = LatLng(33.708855, 73.059244);
      const end = LatLng(33.708801, 73.059163);

      final line = straightLineFallback(start, end);

      expect(line, hasLength(2));
      expect(line[0], start);
      expect(line[1], end);
    });
  });
}