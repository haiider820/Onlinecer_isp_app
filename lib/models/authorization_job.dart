// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'authorization_job.freezed.dart';
part 'authorization_job.g.dart';

/// Status values of an ONU authorization job (ISPFINAL §9–§10).
enum AuthorizationJobStatus {
  pending,
  running,
  succeeded,
  failed,
  unknown;

  static AuthorizationJobStatus parse(String? raw) {
    return switch (raw) {
      'pending' => AuthorizationJobStatus.pending,
      'running' => AuthorizationJobStatus.running,
      'succeeded' => AuthorizationJobStatus.succeeded,
      'failed' => AuthorizationJobStatus.failed,
      _ => AuthorizationJobStatus.unknown,
    };
  }
}

/// One ONU authorization job, from
/// `GET /connection-requests/{request}/authorization-jobs/{job}`
/// (ISPFINAL §10). Polled every 2–3 s until it reaches a terminal status
/// (`succeeded` / `failed`).
@freezed
class AuthorizationJob with _$AuthorizationJob {
  const AuthorizationJob._();

  const factory AuthorizationJob({
    required String id,
    String? status,
    @JsonKey(name: 'serial_number') String? serialNumber,
    @JsonKey(name: 'pon_port') String? ponPort,
    @JsonKey(name: 'ont_id') String? ontId,
    @JsonKey(name: 'line_profile') String? lineProfile,
    @JsonKey(name: 'service_profile') String? serviceProfile,
    int? vlan,
    @JsonKey(name: 'user_vlan') int? userVlan,
    int? gemport,
    @JsonKey(name: 'error_message') String? errorMessage,
    @JsonKey(name: 'started_at') String? startedAt,
    @JsonKey(name: 'finished_at') String? finishedAt,
  }) = _AuthorizationJob;

  factory AuthorizationJob.fromJson(Map<String, Object?> json) =>
      _$AuthorizationJobFromJson(json);

  /// Parsed status, `unknown` when the backend sends something unexpected.
  AuthorizationJobStatus get parsedStatus => AuthorizationJobStatus.parse(status);

  /// True once the job can no longer change state.
  bool get isTerminal =>
      parsedStatus == AuthorizationJobStatus.succeeded ||
      parsedStatus == AuthorizationJobStatus.failed;
}

/// Envelope returned by `GET /connection-requests/{request}/authorization-jobs/{job}`.
@freezed
class AuthorizationJobResponse with _$AuthorizationJobResponse {
  const factory AuthorizationJobResponse({
    @JsonKey(name: 'data') AuthorizationJob? data,
  }) = _AuthorizationJobResponse;

  factory AuthorizationJobResponse.fromJson(Map<String, Object?> json) =>
      _$AuthorizationJobResponseFromJson(json);
}
