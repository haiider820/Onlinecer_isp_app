// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

import 'team.dart';

part 'survey_submission.freezed.dart';
part 'survey_submission.g.dart';

/// Response from `POST /connection-requests/{id}/complete-survey`.
///
/// Field names follow the documented success payload:
/// `{ "message": ..., "data": { "id", "request_number", "status",
///    "current_team", "timestamps": { "surveyed_at" } } }`.
/// Every field except [message] is lenient because the response shape may
/// drift between environments.
@freezed
class CompleteSurveyResponse with _$CompleteSurveyResponse {
  const factory CompleteSurveyResponse({
    String? message,
    SurveySubmissionResult? data,
  }) = _CompleteSurveyResponse;

  factory CompleteSurveyResponse.fromJson(Map<String, Object?> json) =>
      _$CompleteSurveyResponseFromJson(json);
}

/// The `data` object inside a successful completion response.
@freezed
class SurveySubmissionResult with _$SurveySubmissionResult {
  const factory SurveySubmissionResult({
    String? id,
    @JsonKey(name: 'request_number') String? requestNumber,
    String? status,
    @JsonKey(name: 'current_team') Team? currentTeam,
    SurveyTimestamps? timestamps,
  }) = _SurveySubmissionResult;

  factory SurveySubmissionResult.fromJson(Map<String, Object?> json) =>
      _$SurveySubmissionResultFromJson(json);
}

@freezed
class SurveyTimestamps with _$SurveyTimestamps {
  const factory SurveyTimestamps({
    @JsonKey(name: 'surveyed_at') String? surveyedAt,
  }) = _SurveyTimestamps;

  factory SurveyTimestamps.fromJson(Map<String, Object?> json) =>
      _$SurveyTimestampsFromJson(json);
}