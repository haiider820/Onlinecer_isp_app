// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'inventory_item.freezed.dart';
part 'inventory_item.g.dart';

/// An inventory item used in an installation, returned by
/// `GET /lookups/inventory-items`.
///
/// Mirrors the `FatNode` shape convention (string `id`, display `name`).
/// Catalog extras are nullable so the model survives unknown payloads; if the
/// backend turns out to use integer ids, the field type is the only change.
@freezed
class InventoryItem with _$InventoryItem {
  const factory InventoryItem({
    required String id,
    required String name,
    String? unit,
    String? category,
    @JsonKey(name: 'stock_quantity') num? stockQuantity,
  }) = _InventoryItem;

  factory InventoryItem.fromJson(Map<String, Object?> json) => _$InventoryItemFromJson(json);
}

/// Envelope returned by `GET /lookups/inventory-items`.
@freezed
class InventoryItemList with _$InventoryItemList {
  const factory InventoryItemList({
    required List<InventoryItem> data,
  }) = _InventoryItemList;

  factory InventoryItemList.fromJson(Map<String, Object?> json) => _$InventoryItemListFromJson(json);
}