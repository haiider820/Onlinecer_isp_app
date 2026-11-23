// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'direct_olt.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AuthorizationPresetImpl _$$AuthorizationPresetImplFromJson(
  Map<String, dynamic> json,
) => _$AuthorizationPresetImpl(
  ready: json['ready'] as bool?,
  lineProfile: json['line_profile'] as String?,
  serviceProfile: json['service_profile'] as String?,
  vlan: (json['vlan'] as num?)?.toInt(),
  userVlan: (json['user_vlan'] as num?)?.toInt(),
  gemport: (json['gemport'] as num?)?.toInt(),
);

Map<String, dynamic> _$$AuthorizationPresetImplToJson(
  _$AuthorizationPresetImpl instance,
) => <String, dynamic>{
  'ready': instance.ready,
  'line_profile': instance.lineProfile,
  'service_profile': instance.serviceProfile,
  'vlan': instance.vlan,
  'user_vlan': instance.userVlan,
  'gemport': instance.gemport,
};

_$DirectOltImpl _$$DirectOltImplFromJson(Map<String, dynamic> json) =>
    _$DirectOltImpl(
      id: json['id'] as String,
      name: json['name'] as String?,
      vendor: json['vendor'] as String?,
      model: json['model'] as String?,
      managementIp: json['management_ip'] as String?,
      connectionStatus: json['connection_status'] as String?,
      companyId: json['company_id'] as String?,
      branchId: json['branch_id'] as String?,
      subBranchId: json['sub_branch_id'] as String?,
      authorizationPreset: json['authorization_preset'] == null
          ? null
          : AuthorizationPreset.fromJson(
              json['authorization_preset'] as Map<String, dynamic>,
            ),
      runningAuthorizationsCount: (json['running_authorizations_count'] as num?)
          ?.toInt(),
    );

Map<String, dynamic> _$$DirectOltImplToJson(_$DirectOltImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'vendor': instance.vendor,
      'model': instance.model,
      'management_ip': instance.managementIp,
      'connection_status': instance.connectionStatus,
      'company_id': instance.companyId,
      'branch_id': instance.branchId,
      'sub_branch_id': instance.subBranchId,
      'authorization_preset': instance.authorizationPreset,
      'running_authorizations_count': instance.runningAuthorizationsCount,
    };

_$DirectOltListImpl _$$DirectOltListImplFromJson(Map<String, dynamic> json) =>
    _$DirectOltListImpl(
      data: (json['data'] as List<dynamic>)
          .map((e) => DirectOlt.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$DirectOltListImplToJson(_$DirectOltListImpl instance) =>
    <String, dynamic>{'data': instance.data};
