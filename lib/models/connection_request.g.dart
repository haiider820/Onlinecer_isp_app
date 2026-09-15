// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connection_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ConnectionRequestImpl _$$ConnectionRequestImplFromJson(
  Map<String, dynamic> json,
) => _$ConnectionRequestImpl(
  id: json['id'] as String,
  requestNumber: json['request_number'] as String,
  status: json['status'] as String,
  customerName: json['customer_name'] as String?,
  customerType: json['customer_type'] as String?,
  customerPhone: json['customer_phone'] as String?,
  customerAddress: json['customer_address'] as String?,
  customerArea: json['customer_area'] as String?,
  requestedPlan: json['requested_plan'] == null
      ? null
      : Plan.fromJson(json['requested_plan'] as Map<String, dynamic>),
  currentTeam: json['current_team'] == null
      ? null
      : Team.fromJson(json['current_team'] as Map<String, dynamic>),
  stageData: json['stage_data'] == null
      ? null
      : StageData.fromJson(json['stage_data'] as Map<String, dynamic>),
  locations: json['locations'] == null
      ? null
      : Locations.fromJson(json['locations'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$ConnectionRequestImplToJson(
  _$ConnectionRequestImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'request_number': instance.requestNumber,
  'status': instance.status,
  'customer_name': instance.customerName,
  'customer_type': instance.customerType,
  'customer_phone': instance.customerPhone,
  'customer_address': instance.customerAddress,
  'customer_area': instance.customerArea,
  'requested_plan': instance.requestedPlan,
  'current_team': instance.currentTeam,
  'stage_data': instance.stageData,
  'locations': instance.locations,
};

_$ConnectionRequestDetailImpl _$$ConnectionRequestDetailImplFromJson(
  Map<String, dynamic> json,
) => _$ConnectionRequestDetailImpl(
  request: ConnectionRequest.fromJson(json['data'] as Map<String, dynamic>),
  allowedAction: json['allowed_action'] as String?,
);

Map<String, dynamic> _$$ConnectionRequestDetailImplToJson(
  _$ConnectionRequestDetailImpl instance,
) => <String, dynamic>{
  'data': instance.request,
  'allowed_action': instance.allowedAction,
};

_$ConnectionRequestPageImpl _$$ConnectionRequestPageImplFromJson(
  Map<String, dynamic> json,
) => _$ConnectionRequestPageImpl(
  data: (json['data'] as List<dynamic>)
      .map((e) => ConnectionRequest.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$ConnectionRequestPageImplToJson(
  _$ConnectionRequestPageImpl instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

_$PaginationMetaImpl _$$PaginationMetaImplFromJson(Map<String, dynamic> json) =>
    _$PaginationMetaImpl(
      currentPage: (json['current_page'] as num?)?.toInt(),
      perPage: (json['per_page'] as num?)?.toInt(),
      total: (json['total'] as num?)?.toInt(),
      lastPage: (json['last_page'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$PaginationMetaImplToJson(
  _$PaginationMetaImpl instance,
) => <String, dynamic>{
  'current_page': instance.currentPage,
  'per_page': instance.perPage,
  'total': instance.total,
  'last_page': instance.lastPage,
};
