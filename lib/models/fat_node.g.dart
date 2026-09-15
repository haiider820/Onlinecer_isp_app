// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fat_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FatNodeImpl _$$FatNodeImplFromJson(Map<String, dynamic> json) =>
    _$FatNodeImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      nodeType: json['node_type'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );

Map<String, dynamic> _$$FatNodeImplToJson(_$FatNodeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'node_type': instance.nodeType,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };

_$FatNodeListImpl _$$FatNodeListImplFromJson(Map<String, dynamic> json) =>
    _$FatNodeListImpl(
      data: (json['data'] as List<dynamic>)
          .map((e) => FatNode.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$FatNodeListImplToJson(_$FatNodeListImpl instance) =>
    <String, dynamic>{'data': instance.data};
