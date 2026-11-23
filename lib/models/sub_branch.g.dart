// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sub_branch.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SubBranchImpl _$$SubBranchImplFromJson(Map<String, dynamic> json) =>
    _$SubBranchImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String?,
      organizationId: json['organization_id'] as String?,
      companyId: json['company_id'] as String?,
      branchId: json['branch_id'] as String?,
      parentId: json['parent_id'] as String?,
    );

Map<String, dynamic> _$$SubBranchImplToJson(_$SubBranchImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'organization_id': instance.organizationId,
      'company_id': instance.companyId,
      'branch_id': instance.branchId,
      'parent_id': instance.parentId,
    };

_$SubBranchListImpl _$$SubBranchListImplFromJson(Map<String, dynamic> json) =>
    _$SubBranchListImpl(
      mode: json['mode'] as String?,
      selectedSubBranchId: json['selected_sub_branch_id'] as String?,
      data: (json['data'] as List<dynamic>)
          .map((e) => SubBranch.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$SubBranchListImplToJson(_$SubBranchListImpl instance) =>
    <String, dynamic>{
      'mode': instance.mode,
      'selected_sub_branch_id': instance.selectedSubBranchId,
      'data': instance.data,
    };
