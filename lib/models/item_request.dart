/// Inventory item requests on a connection request
/// (`GET /connection-requests/{id}` → `data.item_requests[]`).
///
/// Returned when a request comes back to the Survey team for review
/// (status `survey_review`, `allowed_action` `review_survey`): Inventory has
/// approved (or partly approved) the items the surveyor asked for, and the
/// review screen shows what was approved before the surveyor confirms.
///
/// Plain hand-written models (no codegen): every field is parsed leniently
/// because the block is absent on older payloads and its shapes are not
/// pinned down beyond the backend doc — a missing `items` list reads as
/// empty, a non-numeric quantity reads as null, never a throw.
class ItemRequestItem {
  const ItemRequestItem({
    this.itemId,
    this.itemName,
    this.unit,
    this.quantityRequested,
    this.quantityApproved,
  });

  factory ItemRequestItem.fromJson(Map<String, Object?> json) {
    return ItemRequestItem(
      itemId: _asString(json['item_id']),
      itemName: _asString(json['item_name']),
      unit: _asString(json['unit']),
      quantityRequested: _asNum(json['quantity_requested']),
      quantityApproved: _asNum(json['quantity_approved']),
    );
  }

  final String? itemId;
  final String? itemName;
  final String? unit;
  final num? quantityRequested;
  final num? quantityApproved;

  Map<String, Object?> toJson() => {
    if (itemId != null) 'item_id': itemId,
    if (itemName != null) 'item_name': itemName,
    if (unit != null) 'unit': unit,
    if (quantityRequested != null) 'quantity_requested': quantityRequested,
    if (quantityApproved != null) 'quantity_approved': quantityApproved,
  };
}

class ItemRequest {
  const ItemRequest({
    this.id,
    this.status,
    this.approvalNotes,
    this.requestedByTeamId,
    this.requestedByTeamName,
    this.items = const [],
  });

  factory ItemRequest.fromJson(Map<String, Object?> json) {
    final team = json['requested_by_team'];
    final teamMap = team is Map<String, Object?> ? team : null;
    final items = json['items'];
    return ItemRequest(
      id: _asString(json['id']),
      status: _asString(json['status']),
      approvalNotes: _asString(json['approval_notes']),
      requestedByTeamId: _asString(teamMap?['id']),
      requestedByTeamName: _asString(teamMap?['name']),
      items: items is List
          ? items
                .whereType<Map<String, Object?>>()
                .map(ItemRequestItem.fromJson)
                .toList()
          : const [],
    );
  }

  final String? id;
  final String? status;
  final String? approvalNotes;

  /// The team that asked for the items (`requested_by_team`); only its id
  /// and name are read — the block carries no `functional_team_type`, so it
  /// is deliberately NOT parsed as a [Team].
  final String? requestedByTeamId;
  final String? requestedByTeamName;

  /// Never null: a missing / malformed `items` list reads as empty.
  final List<ItemRequestItem> items;

  Map<String, Object?> toJson() => {
    if (id != null) 'id': id,
    if (status != null) 'status': status,
    if (approvalNotes != null) 'approval_notes': approvalNotes,
    if (requestedByTeamId != null || requestedByTeamName != null)
      'requested_by_team': {
        if (requestedByTeamId != null) 'id': requestedByTeamId,
        if (requestedByTeamName != null) 'name': requestedByTeamName,
      },
    'items': items.map((item) => item.toJson()).toList(),
  };
}

String? _asString(Object? value) {
  if (value == null) return null;
  if (value is String) return value;
  return value.toString();
}

num? _asNum(Object? value) {
  if (value is num) return value;
  if (value is String) return num.tryParse(value);
  return null;
}
