// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InventoryItemImpl _$$InventoryItemImplFromJson(Map<String, dynamic> json) =>
    _$InventoryItemImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      unit: json['unit'] as String?,
      category: json['category'] as String?,
      stockQuantity: json['stock_quantity'] as num?,
    );

Map<String, dynamic> _$$InventoryItemImplToJson(_$InventoryItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'unit': instance.unit,
      'category': instance.category,
      'stock_quantity': instance.stockQuantity,
    };

_$InventoryItemListImpl _$$InventoryItemListImplFromJson(
  Map<String, dynamic> json,
) => _$InventoryItemListImpl(
  data: (json['data'] as List<dynamic>)
      .map((e) => InventoryItem.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$$InventoryItemListImplToJson(
  _$InventoryItemListImpl instance,
) => <String, dynamic>{'data': instance.data};
