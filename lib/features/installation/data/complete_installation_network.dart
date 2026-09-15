import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';

/// One line in the complete-installation `inventory_items` payload: a catalog
/// item id plus the quantity used on this installation.
///
/// Stored as a Dart record so tests can build lines without a JSON dependency.
typedef InventoryLine = ({String itemId, num quantity});

/// One attached installation photo: a local image path plus its reported MIME
/// type (used for the multipart content-type and for the size/type guards).
typedef InstallationPhoto = ({String path, String mime});

/// Minimal seam over the HTTP layer that [CompleteInstallationRepository]
/// depends on, so the completion flow is unit-testable without a real server.
abstract interface class CompleteInstallationNetwork {
  /// Plain-JSON call: `POST .../complete-installation` with
  /// `{ olt_device_ownership, connection_fat_node_id, dp_latitude,
  ///    dp_longitude, total_wire_used?, installation_notes?,
  ///    inventory_items? }`.
  ///
  /// `dp_latitude`/`dp_longitude` are the selected FAT node's coordinates
  /// (backend decision: the DP location is the FAT node, no separate GPS
  /// read). `inventory_items` is an array of `{ item_id, quantity }` objects.
  Future<Map<String, dynamic>> completeInstallationJson(
    String id, {
    required String oltDeviceOwnership,
    required String connectionFatNodeId,
    required double dpLatitude,
    required double dpLongitude,
    num? totalWireUsed,
    String? notes,
    List<InventoryLine>? inventoryLines,
  });

  /// Multipart call for the same payload when the submission carries photo
  /// attachments or a voice note: identical text fields, plus
  /// `installation_photos[]` under one field name and an optional `voice_note`.
  Future<Map<String, dynamic>> completeInstallationMultipart(
    String id, {
    required String oltDeviceOwnership,
    required String connectionFatNodeId,
    required double dpLatitude,
    required double dpLongitude,
    num? totalWireUsed,
    String? notes,
    List<InventoryLine>? inventoryLines,
    List<InstallationPhoto>? photos,
    String? voiceNotePath,
    String? voiceNoteMimeType,
  });
}

/// Real HTTP-backed implementation for the complete-installation flow.
class DioCompleteInstallationNetwork implements CompleteInstallationNetwork {
  DioCompleteInstallationNetwork(this._client);

  final ApiClient _client;

  @override
  Future<Map<String, dynamic>> completeInstallationJson(
    String id, {
    required String oltDeviceOwnership,
    required String connectionFatNodeId,
    required double dpLatitude,
    required double dpLongitude,
    num? totalWireUsed,
    String? notes,
    List<InventoryLine>? inventoryLines,
  }) {
    return _client.postMap(
      Endpoints.completeInstallation(id),
      data: {
        'olt_device_ownership': oltDeviceOwnership,
        'connection_fat_node_id': connectionFatNodeId,
        'dp_latitude': dpLatitude,
        'dp_longitude': dpLongitude,
        if (totalWireUsed != null) 'total_wire_used': totalWireUsed,
        if (notes != null && notes.isNotEmpty) 'installation_notes': notes,
        if (inventoryLines != null && inventoryLines.isNotEmpty)
          'inventory_items': [
            for (final line in inventoryLines)
              {'item_id': line.itemId, 'quantity': line.quantity},
          ],
      },
    );
  }

  @override
  Future<Map<String, dynamic>> completeInstallationMultipart(
    String id, {
    required String oltDeviceOwnership,
    required String connectionFatNodeId,
    required double dpLatitude,
    required double dpLongitude,
    num? totalWireUsed,
    String? notes,
    List<InventoryLine>? inventoryLines,
    List<InstallationPhoto>? photos,
    String? voiceNotePath,
    String? voiceNoteMimeType,
  }) {
    final form = FormData.fromMap({
      'olt_device_ownership': oltDeviceOwnership,
      'connection_fat_node_id': connectionFatNodeId,
      'dp_latitude': dpLatitude,
      'dp_longitude': dpLongitude,
      if (totalWireUsed != null) 'total_wire_used': totalWireUsed,
      if (notes != null && notes.isNotEmpty) 'installation_notes': notes,
      if (inventoryLines != null && inventoryLines.isNotEmpty)
        'inventory_items': jsonEncode([
          for (final line in inventoryLines)
            {'item_id': line.itemId, 'quantity': line.quantity},
        ]),
      if (photos != null && photos.isNotEmpty)
        'installation_photos[]': [
          for (final photo in photos)
            MultipartFile.fromFileSync(
              photo.path,
              contentType: MediaType.parse(photo.mime),
            ),
        ],
      if (voiceNotePath != null)
        'voice_note': MultipartFile.fromFileSync(
          voiceNotePath,
          contentType: MediaType.parse(voiceNoteMimeType ?? 'audio/mp4'),
        ),
    });
    return _client.postMultipart(
      Endpoints.completeInstallation(id),
      data: form,
    );
  }
}