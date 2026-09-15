// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stage_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StageDataImpl _$$StageDataImplFromJson(Map<String, dynamic> json) =>
    _$StageDataImpl(
      surveyNotes: json['survey_notes'] as String?,
      installationNotes: json['installation_notes'] as String?,
      oltDeviceOwnership: json['olt_device_ownership'] as String?,
      totalWireUsed: json['total_wire_used'] as num?,
    );

Map<String, dynamic> _$$StageDataImplToJson(_$StageDataImpl instance) =>
    <String, dynamic>{
      'survey_notes': instance.surveyNotes,
      'installation_notes': instance.installationNotes,
      'olt_device_ownership': instance.oltDeviceOwnership,
      'total_wire_used': instance.totalWireUsed,
    };
