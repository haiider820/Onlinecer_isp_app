// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RouteResultImpl _$$RouteResultImplFromJson(Map<String, dynamic> json) =>
    _$RouteResultImpl(
      distanceMeters: (json['distance_meters'] as num?)?.toDouble(),
      durationSeconds: (json['duration_seconds'] as num?)?.toDouble(),
      points: decodeRoutePointsArray(json['points']),
      source: json['source'] as String?,
      summary: json['summary'] as String?,
    );

Map<String, dynamic> _$$RouteResultImplToJson(_$RouteResultImpl instance) =>
    <String, dynamic>{
      'distance_meters': instance.distanceMeters,
      'duration_seconds': instance.durationSeconds,
      'points': encodeRoutePointsArray(instance.points),
      'source': instance.source,
      'summary': instance.summary,
    };
