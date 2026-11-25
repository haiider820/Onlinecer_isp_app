// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_data.freezed.dart';
part 'create_data.g.dart';

/// One `customer_types` entry from `GET /connection-requests/create-data`
/// (ISPFINAL §3): `{ "value": "home", "label": "Home" }`.
@freezed
class CreateDataOption with _$CreateDataOption {
  const factory CreateDataOption({
    String? value,
    String? label,
  }) = _CreateDataOption;

  factory CreateDataOption.fromJson(Map<String, Object?> json) =>
      _$CreateDataOptionFromJson(json);
}

/// One `plans` entry from create-data. Kept lenient (all nullable): the
/// guide only sketches the shape, so no field is required here.
@freezed
class CreateDataPlan with _$CreateDataPlan {
  const factory CreateDataPlan({
    String? id,
    String? name,
    @JsonKey(name: 'price_minor') int? priceMinor,
  }) = _CreateDataPlan;

  factory CreateDataPlan.fromJson(Map<String, Object?> json) =>
      _$CreateDataPlanFromJson(json);
}

/// One `fat_nodes` entry from create-data. Lenient for the same reason as
/// [CreateDataPlan]: the guide sketches the shape only.
@freezed
class CreateDataFatNode with _$CreateDataFatNode {
  const factory CreateDataFatNode({
    String? id,
    String? name,
    @JsonKey(name: 'node_type') String? nodeType,
  }) = _CreateDataFatNode;

  factory CreateDataFatNode.fromJson(Map<String, Object?> json) =>
      _$CreateDataFatNodeFromJson(json);
}

/// One team inside a `team_flows` entry: the same shape the backend returns
/// both in `stage_assignments[].team` and in the flow's top-level `teams`
/// list — `{ "id", "name", "code", "functional_team_type",
/// "functional_team_types", "flow_order", "is_active" }` (live shape,
/// 2026-11-25). Lenient (all nullable): the backend may add or drop
/// fields, and a flow must never fail to parse over one team field.
@freezed
class CreateDataTeam with _$CreateDataTeam {
  const factory CreateDataTeam({
    String? id,
    String? name,
    String? code,
    @JsonKey(name: 'functional_team_type') String? functionalTeamType,
    @JsonKey(name: 'functional_team_types') List<String>? functionalTeamTypes,
    @JsonKey(name: 'flow_order') int? flowOrder,
    @JsonKey(name: 'is_active') bool? isActive,
  }) = _CreateDataTeam;

  factory CreateDataTeam.fromJson(Map<String, Object?> json) =>
      _$CreateDataTeamFromJson(json);
}

/// One `stage_assignments` entry of a team flow (live shape, 2026-11-25):
/// `{ "stage_key", "stage_label", "stage_order", "team" }`.
///
/// Workflow logic keys on [stageKey] and [stageOrder]; [stageLabel] is
/// display only. Nothing here is hardcoded: the backend owns the stage
/// set, and any stage key / order the backend sends parses generically.
@freezed
class CreateDataStageAssignment with _$CreateDataStageAssignment {
  const factory CreateDataStageAssignment({
    @JsonKey(name: 'stage_key') String? stageKey,
    @JsonKey(name: 'stage_label') String? stageLabel,
    @JsonKey(name: 'stage_order') int? stageOrder,
    CreateDataTeam? team,
  }) = _CreateDataStageAssignment;

  factory CreateDataStageAssignment.fromJson(Map<String, Object?> json) =>
      _$CreateDataStageAssignmentFromJson(json);
}

/// One `team_flows` entry from create-data (live shape, 2026-11-25):
/// `{ "id", "name", "stage_assignments", "teams" }`.
///
/// There is NO `functional_team_type` on the flow itself in the live
/// shape — the field is kept only as a lenient fallback for older payloads
/// and must never be required. The teams live on the stage assignments
/// (one team per stage) and in the top-level `teams` list.
@freezed
class CreateDataTeamFlow with _$CreateDataTeamFlow {
  const factory CreateDataTeamFlow({
    String? id,
    String? name,
    @JsonKey(name: 'functional_team_type') String? functionalTeamType,
    @JsonKey(name: 'stage_assignments')
    List<CreateDataStageAssignment>? stageAssignments,
    List<CreateDataTeam>? teams,
  }) = _CreateDataTeamFlow;

  factory CreateDataTeamFlow.fromJson(Map<String, Object?> json) =>
      _$CreateDataTeamFlowFromJson(json);
}

extension CreateDataTeamFlowStages on CreateDataTeamFlow {
  /// Stage assignments in workflow order (ascending [CreateDataStageAssignment.stageOrder];
  /// assignments with no order go last). Workflow logic reads stages from
  /// here — never from list order, never from `stage_label`.
  List<CreateDataStageAssignment> get stagesInOrder {
    final stages = <CreateDataStageAssignment>[
      ...(stageAssignments ?? const <CreateDataStageAssignment>[]),
    ];
    stages.sort(
      (a, b) => (a.stageOrder ?? 1 << 30).compareTo(b.stageOrder ?? 1 << 30),
    );
    return stages;
  }

  /// The flow's first stage by workflow order, if any.
  CreateDataStageAssignment? get firstStage =>
      stagesInOrder.isEmpty ? null : stagesInOrder.first;
}

/// Dropdown data for the create-connection-request form, from
/// `GET /connection-requests/create-data` (ISPFINAL §3).
///
/// Every list is nullable: a scoped backend may omit a list the form does
/// not need. Every list item is lenient (all fields nullable) because the
/// guide only sketches these shapes — Phase C must never assume a field.
///
/// [defaultTeamFlowId] is the backend's initial team-flow selection for
/// the logged-in employee (live shape, 2026-11-25): when present and in
/// [teamFlows], the form pre-selects it; when absent, null, or not in the
/// list, nothing is pre-selected. A scope with no flow configured returns
/// `team_flows: []` and a null default — the form shows a pending-assignment
/// note instead of failing.
@freezed
class CreateData with _$CreateData {
  const factory CreateData({
    @JsonKey(name: 'customer_types') List<CreateDataOption>? customerTypes,
    List<CreateDataPlan>? plans,
    @JsonKey(name: 'fat_nodes') List<CreateDataFatNode>? fatNodes,
    @JsonKey(name: 'team_flows') List<CreateDataTeamFlow>? teamFlows,
    @JsonKey(name: 'default_team_flow_id') String? defaultTeamFlowId,
  }) = _CreateData;

  factory CreateData.fromJson(Map<String, Object?> json) => _$CreateDataFromJson(json);
}

/// Envelope returned by `GET /connection-requests/create-data`, following the
/// app's usual `{ "data": {...} }` convention.
@freezed
class CreateDataResponse with _$CreateDataResponse {
  const factory CreateDataResponse({
    @JsonKey(name: 'data') CreateData? data,
  }) = _CreateDataResponse;

  factory CreateDataResponse.fromJson(Map<String, Object?> json) =>
      _$CreateDataResponseFromJson(json);
}
