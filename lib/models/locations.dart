// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'locations.freezed.dart';
part 'locations.g.dart';

/// A geographic point captured during a connection-request stage.
///
/// Fields are nullable to stay tolerant of real payloads whose point blocks
/// carry only a subset (e.g. a FAT node reference instead of raw coordinates).
@freezed
class GeoPoint with _$GeoPoint {
  const factory GeoPoint({
    double? latitude,
    double? longitude,
    @JsonKey(name: 'node_id') String? nodeId,
    String? address,
  }) = _GeoPoint;

  factory GeoPoint.fromJson(Map<String, Object?> json) => _$GeoPointFromJson(json);
}

/// The detail response's `locations` block: where each action happened.
///
/// All points are nullable — a request early in its lifecycle has none
/// recorded yet. `installation` and `dp` are written by the installation
/// stage; `user_device`/`fat_node` may be populated from earlier stages.
@freezed
class Locations with _$Locations {
  const factory Locations({
    GeoPoint? installation,
    @JsonKey(name: 'user_device') GeoPoint? userDevice,
    GeoPoint? dp,
    @JsonKey(name: 'fat_node') GeoPoint? fatNode,
  }) = _Locations;

  factory Locations.fromJson(Map<String, Object?> json) => _$LocationsFromJson(json);
}