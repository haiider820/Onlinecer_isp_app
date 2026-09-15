// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locations.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GeoPointImpl _$$GeoPointImplFromJson(Map<String, dynamic> json) =>
    _$GeoPointImpl(
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      nodeId: json['node_id'] as String?,
      address: json['address'] as String?,
    );

Map<String, dynamic> _$$GeoPointImplToJson(_$GeoPointImpl instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'node_id': instance.nodeId,
      'address': instance.address,
    };

_$LocationsImpl _$$LocationsImplFromJson(Map<String, dynamic> json) =>
    _$LocationsImpl(
      installation: json['installation'] == null
          ? null
          : GeoPoint.fromJson(json['installation'] as Map<String, dynamic>),
      userDevice: json['user_device'] == null
          ? null
          : GeoPoint.fromJson(json['user_device'] as Map<String, dynamic>),
      dp: json['dp'] == null
          ? null
          : GeoPoint.fromJson(json['dp'] as Map<String, dynamic>),
      fatNode: json['fat_node'] == null
          ? null
          : GeoPoint.fromJson(json['fat_node'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$LocationsImplToJson(_$LocationsImpl instance) =>
    <String, dynamic>{
      'installation': instance.installation,
      'user_device': instance.userDevice,
      'dp': instance.dp,
      'fat_node': instance.fatNode,
    };
