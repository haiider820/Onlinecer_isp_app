// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CreateDataOptionImpl _$$CreateDataOptionImplFromJson(
  Map<String, dynamic> json,
) => _$CreateDataOptionImpl(
  value: json['value'] as String?,
  label: json['label'] as String?,
);

Map<String, dynamic> _$$CreateDataOptionImplToJson(
  _$CreateDataOptionImpl instance,
) => <String, dynamic>{'value': instance.value, 'label': instance.label};

_$CreateDataPlanImpl _$$CreateDataPlanImplFromJson(Map<String, dynamic> json) =>
    _$CreateDataPlanImpl(
      id: json['id'] as String?,
      name: json['name'] as String?,
      priceMinor: (json['price_minor'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$CreateDataPlanImplToJson(
  _$CreateDataPlanImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'price_minor': instance.priceMinor,
};

_$CreateDataFatNodeImpl _$$CreateDataFatNodeImplFromJson(
  Map<String, dynamic> json,
) => _$CreateDataFatNodeImpl(
  id: json['id'] as String?,
  name: json['name'] as String?,
  nodeType: json['node_type'] as String?,
);

Map<String, dynamic> _$$CreateDataFatNodeImplToJson(
  _$CreateDataFatNodeImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'node_type': instance.nodeType,
};

_$CreateDataTeamImpl _$$CreateDataTeamImplFromJson(Map<String, dynamic> json) =>
    _$CreateDataTeamImpl(
      id: json['id'] as String?,
      name: json['name'] as String?,
      code: json['code'] as String?,
      functionalTeamType: json['functional_team_type'] as String?,
      functionalTeamTypes: (json['functional_team_types'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      flowOrder: (json['flow_order'] as num?)?.toInt(),
      isActive: json['is_active'] as bool?,
    );

Map<String, dynamic> _$$CreateDataTeamImplToJson(
  _$CreateDataTeamImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'code': instance.code,
  'functional_team_type': instance.functionalTeamType,
  'functional_team_types': instance.functionalTeamTypes,
  'flow_order': instance.flowOrder,
  'is_active': instance.isActive,
};

_$CreateDataStageAssignmentImpl _$$CreateDataStageAssignmentImplFromJson(
  Map<String, dynamic> json,
) => _$CreateDataStageAssignmentImpl(
  stageKey: json['stage_key'] as String?,
  stageLabel: json['stage_label'] as String?,
  stageOrder: (json['stage_order'] as num?)?.toInt(),
  team: json['team'] == null
      ? null
      : CreateDataTeam.fromJson(json['team'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$CreateDataStageAssignmentImplToJson(
  _$CreateDataStageAssignmentImpl instance,
) => <String, dynamic>{
  'stage_key': instance.stageKey,
  'stage_label': instance.stageLabel,
  'stage_order': instance.stageOrder,
  'team': instance.team,
};

_$CreateDataTeamFlowImpl _$$CreateDataTeamFlowImplFromJson(
  Map<String, dynamic> json,
) => _$CreateDataTeamFlowImpl(
  id: json['id'] as String?,
  name: json['name'] as String?,
  functionalTeamType: json['functional_team_type'] as String?,
  stageAssignments: (json['stage_assignments'] as List<dynamic>?)
      ?.map(
        (e) => CreateDataStageAssignment.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
  teams: (json['teams'] as List<dynamic>?)
      ?.map((e) => CreateDataTeam.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$$CreateDataTeamFlowImplToJson(
  _$CreateDataTeamFlowImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'functional_team_type': instance.functionalTeamType,
  'stage_assignments': instance.stageAssignments,
  'teams': instance.teams,
};

_$CreateDataImpl _$$CreateDataImplFromJson(Map<String, dynamic> json) =>
    _$CreateDataImpl(
      customerTypes: (json['customer_types'] as List<dynamic>?)
          ?.map((e) => CreateDataOption.fromJson(e as Map<String, dynamic>))
          .toList(),
      plans: (json['plans'] as List<dynamic>?)
          ?.map((e) => CreateDataPlan.fromJson(e as Map<String, dynamic>))
          .toList(),
      fatNodes: (json['fat_nodes'] as List<dynamic>?)
          ?.map((e) => CreateDataFatNode.fromJson(e as Map<String, dynamic>))
          .toList(),
      teamFlows: (json['team_flows'] as List<dynamic>?)
          ?.map((e) => CreateDataTeamFlow.fromJson(e as Map<String, dynamic>))
          .toList(),
      defaultTeamFlowId: json['default_team_flow_id'] as String?,
    );

Map<String, dynamic> _$$CreateDataImplToJson(_$CreateDataImpl instance) =>
    <String, dynamic>{
      'customer_types': instance.customerTypes,
      'plans': instance.plans,
      'fat_nodes': instance.fatNodes,
      'team_flows': instance.teamFlows,
      'default_team_flow_id': instance.defaultTeamFlowId,
    };

_$CreateDataResponseImpl _$$CreateDataResponseImplFromJson(
  Map<String, dynamic> json,
) => _$CreateDataResponseImpl(
  data: json['data'] == null
      ? null
      : CreateData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$CreateDataResponseImplToJson(
  _$CreateDataResponseImpl instance,
) => <String, dynamic>{'data': instance.data};
