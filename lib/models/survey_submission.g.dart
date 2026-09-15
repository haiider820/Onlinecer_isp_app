// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'survey_submission.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CompleteSurveyResponseImpl _$$CompleteSurveyResponseImplFromJson(
  Map<String, dynamic> json,
) => _$CompleteSurveyResponseImpl(
  message: json['message'] as String?,
  data: json['data'] == null
      ? null
      : SurveySubmissionResult.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$CompleteSurveyResponseImplToJson(
  _$CompleteSurveyResponseImpl instance,
) => <String, dynamic>{'message': instance.message, 'data': instance.data};

_$SurveySubmissionResultImpl _$$SurveySubmissionResultImplFromJson(
  Map<String, dynamic> json,
) => _$SurveySubmissionResultImpl(
  id: json['id'] as String?,
  requestNumber: json['request_number'] as String?,
  status: json['status'] as String?,
  currentTeam: json['current_team'] == null
      ? null
      : Team.fromJson(json['current_team'] as Map<String, dynamic>),
  timestamps: json['timestamps'] == null
      ? null
      : SurveyTimestamps.fromJson(json['timestamps'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$SurveySubmissionResultImplToJson(
  _$SurveySubmissionResultImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'request_number': instance.requestNumber,
  'status': instance.status,
  'current_team': instance.currentTeam,
  'timestamps': instance.timestamps,
};

_$SurveyTimestampsImpl _$$SurveyTimestampsImplFromJson(
  Map<String, dynamic> json,
) => _$SurveyTimestampsImpl(surveyedAt: json['surveyed_at'] as String?);

Map<String, dynamic> _$$SurveyTimestampsImplToJson(
  _$SurveyTimestampsImpl instance,
) => <String, dynamic>{'surveyed_at': instance.surveyedAt};
