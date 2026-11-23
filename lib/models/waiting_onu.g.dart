// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'waiting_onu.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WaitingOnuImpl _$$WaitingOnuImplFromJson(Map<String, dynamic> json) =>
    _$WaitingOnuImpl(
      id: json['id'] as String,
      serialNumber: json['serial_number'] as String?,
      ponPort: json['pon_port'] as String?,
      detectedOnuType: json['detected_onu_type'] as String?,
      authorizationStatus: json['authorization_status'] as String?,
      authorizationReason: json['authorization_reason'] as String?,
      lastDiscoveredAt: json['last_discovered_at'] as String?,
    );

Map<String, dynamic> _$$WaitingOnuImplToJson(_$WaitingOnuImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'serial_number': instance.serialNumber,
      'pon_port': instance.ponPort,
      'detected_onu_type': instance.detectedOnuType,
      'authorization_status': instance.authorizationStatus,
      'authorization_reason': instance.authorizationReason,
      'last_discovered_at': instance.lastDiscoveredAt,
    };

_$WaitingOnuListImpl _$$WaitingOnuListImplFromJson(Map<String, dynamic> json) =>
    _$WaitingOnuListImpl(
      data: (json['data'] as List<dynamic>)
          .map((e) => WaitingOnu.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$WaitingOnuListImplToJson(
  _$WaitingOnuListImpl instance,
) => <String, dynamic>{'data': instance.data};

_$DiscoverWaitingOnusResponseImpl _$$DiscoverWaitingOnusResponseImplFromJson(
  Map<String, dynamic> json,
) => _$DiscoverWaitingOnusResponseImpl(
  message: json['message'] as String?,
  source: json['source'] as String?,
  seenCount: (json['seen_count'] as num?)?.toInt(),
  data: (json['data'] as List<dynamic>?)
      ?.map((e) => WaitingOnu.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$$DiscoverWaitingOnusResponseImplToJson(
  _$DiscoverWaitingOnusResponseImpl instance,
) => <String, dynamic>{
  'message': instance.message,
  'source': instance.source,
  'seen_count': instance.seenCount,
  'data': instance.data,
};
