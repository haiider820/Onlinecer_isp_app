// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'sub_branch.freezed.dart';
part 'sub_branch.g.dart';

/// A sub-branch, returned by `GET /lookups/sub-branches` (ISPFINAL §2).
/// All fields except `id`/`name` are nullable: the scoped shape carries only
/// the assignment, and the centralized shape may omit parent links.
@freezed
class SubBranch with _$SubBranch {
  const factory SubBranch({
    required String id,
    required String name,
    String? type,
    @JsonKey(name: 'organization_id') String? organizationId,
    @JsonKey(name: 'company_id') String? companyId,
    @JsonKey(name: 'branch_id') String? branchId,
    @JsonKey(name: 'parent_id') String? parentId,
  }) = _SubBranch;

  factory SubBranch.fromJson(Map<String, Object?> json) => _$SubBranchFromJson(json);
}

/// Envelope returned by `GET /lookups/sub-branches`.
///
/// `mode` is `"centralized"` when the org has centralized inventory enabled
/// (the user must pick a sub-branch before create-data / OLT calls), or a
/// scoped mode where the list is restricted to the user's assignment.
/// `selected_sub_branch_id` is the backend's current selection, when any.
@freezed
class SubBranchList with _$SubBranchList {
  const SubBranchList._();

  const factory SubBranchList({
    String? mode,
    @JsonKey(name: 'selected_sub_branch_id') String? selectedSubBranchId,
    required List<SubBranch> data,
  }) = _SubBranchList;

  factory SubBranchList.fromJson(Map<String, Object?> json) => _$SubBranchListFromJson(json);

  /// True when the org runs centralized inventory and the user must choose.
  bool get isCentralized => mode == 'centralized';
}
