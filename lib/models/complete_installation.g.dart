// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'complete_installation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CompleteInstallationResponseImpl _$$CompleteInstallationResponseImplFromJson(
  Map<String, dynamic> json,
) => _$CompleteInstallationResponseImpl(
  message: json['message'] as String?,
  data: json['data'] == null
      ? null
      : InstallationSubmissionResult.fromJson(
          json['data'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$$CompleteInstallationResponseImplToJson(
  _$CompleteInstallationResponseImpl instance,
) => <String, dynamic>{'message': instance.message, 'data': instance.data};

_$InstallationSubmissionResultImpl _$$InstallationSubmissionResultImplFromJson(
  Map<String, dynamic> json,
) => _$InstallationSubmissionResultImpl(
  id: json['id'] as String?,
  requestNumber: json['request_number'] as String?,
  status: json['status'] as String?,
  currentTeam: json['current_team'] == null
      ? null
      : Team.fromJson(json['current_team'] as Map<String, dynamic>),
  timestamps: json['timestamps'] == null
      ? null
      : InstallationTimestamps.fromJson(
          json['timestamps'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$$InstallationSubmissionResultImplToJson(
  _$InstallationSubmissionResultImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'request_number': instance.requestNumber,
  'status': instance.status,
  'current_team': instance.currentTeam,
  'timestamps': instance.timestamps,
};

_$InstallationTimestampsImpl _$$InstallationTimestampsImplFromJson(
  Map<String, dynamic> json,
) => _$InstallationTimestampsImpl(installedAt: json['installed_at'] as String?);

Map<String, dynamic> _$$InstallationTimestampsImplToJson(
  _$InstallationTimestampsImpl instance,
) => <String, dynamic>{'installed_at': instance.installedAt};
