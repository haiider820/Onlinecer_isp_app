// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'authorization_job.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AuthorizationJobImpl _$$AuthorizationJobImplFromJson(
  Map<String, dynamic> json,
) => _$AuthorizationJobImpl(
  id: json['id'] as String,
  status: json['status'] as String?,
  serialNumber: json['serial_number'] as String?,
  ponPort: json['pon_port'] as String?,
  ontId: json['ont_id'] as String?,
  lineProfile: json['line_profile'] as String?,
  serviceProfile: json['service_profile'] as String?,
  vlan: (json['vlan'] as num?)?.toInt(),
  userVlan: (json['user_vlan'] as num?)?.toInt(),
  gemport: (json['gemport'] as num?)?.toInt(),
  errorMessage: json['error_message'] as String?,
  startedAt: json['started_at'] as String?,
  finishedAt: json['finished_at'] as String?,
);

Map<String, dynamic> _$$AuthorizationJobImplToJson(
  _$AuthorizationJobImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'status': instance.status,
  'serial_number': instance.serialNumber,
  'pon_port': instance.ponPort,
  'ont_id': instance.ontId,
  'line_profile': instance.lineProfile,
  'service_profile': instance.serviceProfile,
  'vlan': instance.vlan,
  'user_vlan': instance.userVlan,
  'gemport': instance.gemport,
  'error_message': instance.errorMessage,
  'started_at': instance.startedAt,
  'finished_at': instance.finishedAt,
};

_$AuthorizationJobResponseImpl _$$AuthorizationJobResponseImplFromJson(
  Map<String, dynamic> json,
) => _$AuthorizationJobResponseImpl(
  data: json['data'] == null
      ? null
      : AuthorizationJob.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$AuthorizationJobResponseImplToJson(
  _$AuthorizationJobResponseImpl instance,
) => <String, dynamic>{'data': instance.data};
