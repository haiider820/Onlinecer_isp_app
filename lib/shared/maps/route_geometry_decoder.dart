import 'package:latlong2/latlong.dart';

/// Decoder for the `points` field of the route result returned by
/// `POST /connection-requests/{id}/route`.
///
/// The backend returns a confirmed, top-level shape:
/// ```json
/// {
///   "points": [
///     {"latitude": 33.708855, "longitude": 73.059244},
///     ...
///   ],
///   "distance_meters": 769.5,
///   "source": "osrm"
/// }
/// ```
///
/// * `points` must be an array of objects, each with `"latitude"` (double)
///   and `"longitude"` (double). These map directly into [LatLng] objects for
///   the map polyline.
///
/// The decoder does NOT accept the old tolerated shapes (encoded polyline
/// strings, `"geometry"`/`"polyline"`/`"coordinates"` keys, `[lat,lng]`
/// arrays, `[lng,lat]` GeoJSON, or `"lat"`/`"lng"` keys). Those formats were
/// hypothesised but the live OSRM-backed endpoint never returns them.
///
/// When `points` is absent or empty (e.g. OSRM could not compute a route) the
/// route screens fall back to a straight line between the two captured points.
/// That fallback is NOT the default path — it is the separate, documented
/// [straightLineFallback] helper.
List<LatLng>? decodeRoutePointsArray(Object? pointsField) {
  if (pointsField is! List) return null;

  final points = <LatLng>[];
  for (final item in pointsField) {
    if (item is! Map) continue;
    final lat = _toDouble(item['latitude']);
    final lng = _toDouble(item['longitude']);
    if (lat == null || lng == null) continue;
    if (lat < -90 || lat > 90 || lng < -180 || lng > 180) continue;
    points.add(LatLng(lat, lng));
  }

  if (points.length < 2) return null;
  return points;
}

/// Whole-map entry point used by tests: decodes `json['points']`.
List<LatLng>? decodeRoutePoints(Map<String, Object?> json) =>
    decodeRoutePointsArray(json['points']);

/// Serialises [points] back to the confirmed `[{"latitude":…,"longitude":…}]`
/// shape (used by the model's `@JsonKey(toJson:)`).
List<Map<String, double>>? encodeRoutePointsArray(List<LatLng>? points) {
  if (points == null) return null;
  return [
    for (final p in points)
      {'latitude': p.latitude, 'longitude': p.longitude},
  ];
}

/// Straight-line fallback used only when a route cannot be computed (the
/// genuine empty/missing `points` case) — never the default rendering path.
List<LatLng> straightLineFallback(LatLng start, LatLng end) {
  return [start, end];
}

double? _toDouble(Object? value) =>
    value is num ? value.toDouble() : null;