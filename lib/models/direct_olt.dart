// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'direct_olt.freezed.dart';
part 'direct_olt.g.dart';

/// The OLT's saved ONU-authorization defaults, from
/// `GET /lookups/direct-olts` (ISPFINAL §5).
///
/// `ready == false` means the OLT has no saved defaults and the authorize
/// form must ask for line/service profiles manually (Phase F). All profile
/// fields are nullable for the same reason.
@freezed
class AuthorizationPreset with _$AuthorizationPreset {
  const factory AuthorizationPreset({
    bool? ready,
    @JsonKey(name: 'line_profile') String? lineProfile,
    @JsonKey(name: 'service_profile') String? serviceProfile,
    int? vlan,
    @JsonKey(name: 'user_vlan') int? userVlan,
    int? gemport,
  }) = _AuthorizationPreset;

  factory AuthorizationPreset.fromJson(Map<String, Object?> json) =>
      _$AuthorizationPresetFromJson(json);
}

/// A directly-managed OLT, returned by `GET /lookups/direct-olts`
/// (ISPFINAL §5). Only Huawei + VSOL OLTs support the waiting-ONU flow.
@freezed
class DirectOlt with _$DirectOlt {
  const factory DirectOlt({
    required String id,
    String? name,
    String? vendor,
    String? model,
    @JsonKey(name: 'management_ip') String? managementIp,
    @JsonKey(name: 'connection_status') String? connectionStatus,
    @JsonKey(name: 'company_id') String? companyId,
    @JsonKey(name: 'branch_id') String? branchId,
    @JsonKey(name: 'sub_branch_id') String? subBranchId,
    @JsonKey(name: 'authorization_preset') AuthorizationPreset? authorizationPreset,
    @JsonKey(name: 'running_authorizations_count') int? runningAuthorizationsCount,
  }) = _DirectOlt;

  factory DirectOlt.fromJson(Map<String, Object?> json) => _$DirectOltFromJson(json);
}

/// Envelope returned by `GET /lookups/direct-olts`.
@freezed
class DirectOltList with _$DirectOltList {
  const factory DirectOltList({
    required List<DirectOlt> data,
  }) = _DirectOltList;

  factory DirectOltList.fromJson(Map<String, Object?> json) => _$DirectOltListFromJson(json);
}
