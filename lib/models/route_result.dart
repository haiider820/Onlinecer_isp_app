// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';

import '../shared/maps/route_geometry_decoder.dart' show decodeRoutePointsArray, encodeRoutePointsArray;

part 'route_result.freezed.dart';
part 'route_result.g.dart';

/// Result of `POST /connection-requests/{id}/route`.
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
/// * `points` — ordered list of waypoints that trace the road-following route
///   (not a straight line). Each point uses `latitude`/`longitude` keys.
/// * `distance_meters` — real road-following distance in meters computed by
///   the backend (OSRM). Use this for any distance display; do **not** fall
///   back to a haversine/straight-line calculation when this is present.
/// * `source` — route engine identifier (e.g. `"osrm"`). Stored for diagnostic
///   purposes; not user-facing.
///
/// When `points` is absent or empty (e.g. OSRM could not compute a route),
/// the route screen draws a documented straight-line fallback between the two
/// captured points. That fallback is implemented in
/// [route_geometry_decoder]'s `straightLineFallback`, *not* here.
@freezed
class RouteResult with _$RouteResult {
  const factory RouteResult({
    @JsonKey(name: 'distance_meters') double? distanceMeters,
    @JsonKey(name: 'duration_seconds') double? durationSeconds,
    @JsonKey(
      name: 'points',
      fromJson: decodeRoutePointsArray,
      toJson: encodeRoutePointsArray,
    )
    List<LatLng>? points,
    String? source,
    String? summary,
  }) = _RouteResult;

  factory RouteResult.fromJson(Map<String, Object?> json) =>
      _$RouteResultFromJson(json);
}
