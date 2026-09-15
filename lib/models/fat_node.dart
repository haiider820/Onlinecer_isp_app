// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'fat_node.freezed.dart';
part 'fat_node.g.dart';

/// A FAT (Fiber Access Terminal) node, returned by `GET /lookups/fat-nodes`,
/// used for optional route calculation in the survey flow.
@freezed
class FatNode with _$FatNode {
  const factory FatNode({
    required String id,
    required String name,
    @JsonKey(name: 'node_type') required String nodeType,
    required double latitude,
    required double longitude,
  }) = _FatNode;

  factory FatNode.fromJson(Map<String, Object?> json) => _$FatNodeFromJson(json);
}

/// Envelope returned by `GET /lookups/fat-nodes?connection_request_id={id}`.
@freezed
class FatNodeList with _$FatNodeList {
  const factory FatNodeList({
    required List<FatNode> data,
  }) = _FatNodeList;

  factory FatNodeList.fromJson(Map<String, Object?> json) => _$FatNodeListFromJson(json);
}