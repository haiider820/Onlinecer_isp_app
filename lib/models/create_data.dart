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

/// One `team_flows` entry from create-data. Lenient: the guide sketches the
/// shape only.
@freezed
class CreateDataTeamFlow with _$CreateDataTeamFlow {
  const factory CreateDataTeamFlow({
    String? id,
    String? name,
    @JsonKey(name: 'functional_team_type') String? functionalTeamType,
  }) = _CreateDataTeamFlow;

  factory CreateDataTeamFlow.fromJson(Map<String, Object?> json) =>
      _$CreateDataTeamFlowFromJson(json);
}

/// Dropdown data for the create-connection-request form, from
/// `GET /connection-requests/create-data` (ISPFINAL §3).
///
/// Every list is nullable: a scoped backend may omit a list the form does
/// not need. Every list item is lenient (all fields nullable) because the
/// guide only sketches these shapes — Phase C must never assume a field.
@freezed
class CreateData with _$CreateData {
  const factory CreateData({
    @JsonKey(name: 'customer_types') List<CreateDataOption>? customerTypes,
    List<CreateDataPlan>? plans,
    @JsonKey(name: 'fat_nodes') List<CreateDataFatNode>? fatNodes,
    @JsonKey(name: 'team_flows') List<CreateDataTeamFlow>? teamFlows,
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
