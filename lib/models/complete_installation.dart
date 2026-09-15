// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

import 'team.dart';

part 'complete_installation.freezed.dart';
part 'complete_installation.g.dart';

/// Response from `POST /connection-requests/{id}/complete-installation`.
///
/// Field names follow the documented success payload
/// `{ "message": ..., "data": { "id", "request_number", "status",
///    "current_team", "timestamps": { "installed_at" } } }`.
/// Every field except [message] is lenient because the response shape may
/// drift between environments (mirrors `complete_survey`'s response model).
@freezed
class CompleteInstallationResponse with _$CompleteInstallationResponse {
  const factory CompleteInstallationResponse({
    String? message,
    InstallationSubmissionResult? data,
  }) = _CompleteInstallationResponse;

  factory CompleteInstallationResponse.fromJson(Map<String, Object?> json) =>
      _$CompleteInstallationResponseFromJson(json);
}

/// The `data` object inside a successful completion response.
@freezed
class InstallationSubmissionResult with _$InstallationSubmissionResult {
  const factory InstallationSubmissionResult({
    String? id,
    @JsonKey(name: 'request_number') String? requestNumber,
    String? status,
    @JsonKey(name: 'current_team') Team? currentTeam,
    InstallationTimestamps? timestamps,
  }) = _InstallationSubmissionResult;

  factory InstallationSubmissionResult.fromJson(Map<String, Object?> json) =>
      _$InstallationSubmissionResultFromJson(json);
}

@freezed
class InstallationTimestamps with _$InstallationTimestamps {
  const factory InstallationTimestamps({
    @JsonKey(name: 'installed_at') String? installedAt,
  }) = _InstallationTimestamps;

  factory InstallationTimestamps.fromJson(Map<String, Object?> json) =>
      _$InstallationTimestampsFromJson(json);
}