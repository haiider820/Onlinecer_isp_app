// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

import 'locations.dart';
import 'plan.dart';
import 'stage_data.dart';
import 'team.dart';

part 'connection_request.freezed.dart';
part 'connection_request.g.dart';

/// Allowed actions a team member may perform, surfaced by the backend as the
/// detail response's `allowed_action` field. A `null`/absent `allowed_action`
/// means the request is not actionable by the current team.
enum ConnectionRequestAction {
  completeSurvey,
  completeInstallation,
  completeSplicing,
  completeVerification,
  completeClosing,
  unknown;

  static ConnectionRequestAction parse(String? raw) {
    return switch (raw) {
      'complete_survey' => ConnectionRequestAction.completeSurvey,
      'complete_installation' => ConnectionRequestAction.completeInstallation,
      'complete_splicing' => ConnectionRequestAction.completeSplicing,
      'complete_verification' => ConnectionRequestAction.completeVerification,
      'complete_closing' => ConnectionRequestAction.completeClosing,
      _ => ConnectionRequestAction.unknown,
    };
  }

  /// Maps back to the backend snake_case string.
  String get wireValue => switch (this) {
        ConnectionRequestAction.completeSurvey => 'complete_survey',
        ConnectionRequestAction.completeInstallation => 'complete_installation',
        ConnectionRequestAction.completeSplicing => 'complete_splicing',
        ConnectionRequestAction.completeVerification => 'complete_verification',
        ConnectionRequestAction.completeClosing => 'complete_closing',
        ConnectionRequestAction.unknown => '',
      };
}

/// A connection request as returned by the list endpoint
/// (`GET /dashboard`, `GET /connection-requests`).
@freezed
class ConnectionRequest with _$ConnectionRequest {
  const factory ConnectionRequest({
    required String id,
    @JsonKey(name: 'request_number') required String requestNumber,
    required String status,
    @JsonKey(name: 'customer_name') String? customerName,
    @JsonKey(name: 'customer_type') String? customerType,
    @JsonKey(name: 'customer_phone') String? customerPhone,
    @JsonKey(name: 'customer_address') String? customerAddress,
    @JsonKey(name: 'customer_area') String? customerArea,
    @JsonKey(name: 'requested_plan') Plan? requestedPlan,
    @JsonKey(name: 'current_team') Team? currentTeam,
    // Detail-only blocks: the list endpoint omits them, the detail endpoint
    // populates them progressively across stages (null until the relevant
    // stage has run).
    @JsonKey(name: 'stage_data') StageData? stageData,
    Locations? locations,
  }) = _ConnectionRequest;

  factory ConnectionRequest.fromJson(Map<String, Object?> json) => _$ConnectionRequestFromJson(json);
}

/// Full detail response for `GET /connection-requests/{id}` —
/// `{ "data": {...}, "allowed_action": "complete_survey" }`.
@freezed
class ConnectionRequestDetail with _$ConnectionRequestDetail {
  const ConnectionRequestDetail._();

  const factory ConnectionRequestDetail({
    @JsonKey(name: 'data') required ConnectionRequest request,
    @JsonKey(name: 'allowed_action') String? allowedAction,
  }) = _ConnectionRequestDetail;

  factory ConnectionRequestDetail.fromJson(Map<String, Object?> json) =>
      _$ConnectionRequestDetailFromJson(json);

  /// Parsed action, or `null` when the backend offers none.
  ConnectionRequestAction? get action {
    final parsed = ConnectionRequestAction.parse(allowedAction);
    return parsed == ConnectionRequestAction.unknown ? null : parsed;
  }
}

/// Paginated envelope returned by `GET /connection-requests`.
@freezed
class ConnectionRequestPage with _$ConnectionRequestPage {
  const factory ConnectionRequestPage({
    required List<ConnectionRequest> data,
    @JsonKey(name: 'meta') required PaginationMeta meta,
  }) = _ConnectionRequestPage;

  factory ConnectionRequestPage.fromJson(Map<String, Object?> json) =>
      _$ConnectionRequestPageFromJson(json);
}

@freezed
class PaginationMeta with _$PaginationMeta {
  const factory PaginationMeta({
    @JsonKey(name: 'current_page') int? currentPage,
    @JsonKey(name: 'per_page') int? perPage,
    int? total,
    @JsonKey(name: 'last_page') int? lastPage,
  }) = _PaginationMeta;

  factory PaginationMeta.fromJson(Map<String, Object?> json) => _$PaginationMetaFromJson(json);
}