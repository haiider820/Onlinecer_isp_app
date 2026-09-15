import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isp_onlinecer/core/constants/app_constants.dart';
import 'package:isp_onlinecer/features/installation/data/complete_installation_network.dart';
import 'package:isp_onlinecer/features/installation/data/complete_installation_repository.dart';

class _FakeCompleteInstallationNetwork implements CompleteInstallationNetwork {
  _FakeCompleteInstallationNetwork(this.result, {this.error});

  final Map<String, dynamic> result;
  final Exception? error;

  String? lastId;
  String? lastOwnership;
  String? lastFatNodeId;
  double? lastDpLatitude;
  double? lastDpLongitude;
  num? lastWire;
  String? lastNotes;
  List<InventoryLine>? lastInventoryLines;
  List<InstallationPhoto>? lastPhotos;
  String? lastVoiceNotePath;
  String? lastVoiceNoteMimeType;

  int jsonCalls = 0;
  int multipartCalls = 0;

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
  }) async {
    if (error != null) throw error!;
    jsonCalls++;
    lastId = id;
    lastOwnership = oltDeviceOwnership;
    lastFatNodeId = connectionFatNodeId;
    lastDpLatitude = dpLatitude;
    lastDpLongitude = dpLongitude;
    lastWire = totalWireUsed;
    lastNotes = notes;
    lastInventoryLines = inventoryLines;
    return result;
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
  }) async {
    if (error != null) throw error!;
    multipartCalls++;
    lastId = id;
    lastOwnership = oltDeviceOwnership;
    lastFatNodeId = connectionFatNodeId;
    lastDpLatitude = dpLatitude;
    lastDpLongitude = dpLongitude;
    lastWire = totalWireUsed;
    lastNotes = notes;
    lastInventoryLines = inventoryLines;
    lastPhotos = photos;
    lastVoiceNotePath = voiceNotePath;
    lastVoiceNoteMimeType = voiceNoteMimeType;
    return result;
  }
}

const _successMap = {
  'message': 'Installation marked as completed.',
  'data': {
    'id': '102',
    'request_number': 'CRQ-20260911-IN21',
    'status': 'splicing_assigned',
    'current_team': {
      'id': 'team_5',
      'name': 'Splicing Team',
      'functional_team_type': 'splicing',
    },
    'timestamps': {'installed_at': '2026-09-12T10:00:00.000000Z'},
  },
};

/// Matches a [CompleteInstallationNetwork] call with the DP coordinates always
/// sent (they come from the selected FAT node).
const _dpLatitude = 23.7444;
const _dpLongitude = 90.3788;

void main() {
  group('CompleteInstallationRepository.submit', () {
    test('sends required fields (incl. DP coords) and parses the new status',
        () async {
      final network = _FakeCompleteInstallationNetwork(_successMap);
      final repository = CompleteInstallationRepository(network: network);

      final response = await repository.submit(
        id: 'req_ist1',
        oltDeviceOwnership: 'company',
        connectionFatNodeId: 'node_7',
        dpLatitude: _dpLatitude,
        dpLongitude: _dpLongitude,
      );

      expect(network.lastId, 'req_ist1');
      expect(network.lastOwnership, 'company');
      expect(network.lastFatNodeId, 'node_7');
      expect(network.lastDpLatitude, _dpLatitude);
      expect(network.lastDpLongitude, _dpLongitude);
      expect(network.lastWire, isNull);
      expect(network.lastNotes, isNull);
      expect(network.lastInventoryLines, isNull);
      expect(response.message, 'Installation marked as completed.');
      expect(response.data?.status, 'splicing_assigned');
      expect(response.data?.currentTeam?.functionalTeamType, 'splicing');
      // No attachments → the repository must call the JSON branch.
      expect(network.jsonCalls, 1);
      expect(network.multipartCalls, 0);
    });

    test('includes optional wire usage and notes when provided', () async {
      final network = _FakeCompleteInstallationNetwork(_successMap);
      final repository = CompleteInstallationRepository(network: network);

      await repository.submit(
        id: 'req_ist1',
        oltDeviceOwnership: 'user',
        connectionFatNodeId: 'node_7',
        dpLatitude: _dpLatitude,
        dpLongitude: _dpLongitude,
        totalWireUsed: 35.5,
        notes: 'Drop cable pulled to the DP.',
      );

      expect(network.lastWire, 35.5);
      expect(network.lastNotes, 'Drop cable pulled to the DP.');
    });

    test('treats zero wire as a real (non-null) value', () async {
      final network = _FakeCompleteInstallationNetwork(_successMap);
      final repository = CompleteInstallationRepository(network: network);

      await repository.submit(
        id: 'req_ist1',
        oltDeviceOwnership: 'user',
        connectionFatNodeId: 'node_7',
        dpLatitude: _dpLatitude,
        dpLongitude: _dpLongitude,
        totalWireUsed: 0,
      );

      expect(network.lastWire, 0);
    });

    test('sends inventory item lines when provided', () async {
      final network = _FakeCompleteInstallationNetwork(_successMap);
      final repository = CompleteInstallationRepository(network: network);

      await repository.submit(
        id: 'req_ist1',
        oltDeviceOwnership: 'user',
        connectionFatNodeId: 'node_1',
        dpLatitude: _dpLatitude,
        dpLongitude: _dpLongitude,
        inventoryLines: const [
          (itemId: 'item_1', quantity: 12),
          (itemId: 'item_3', quantity: 2.5),
        ],
      );

      expect(network.lastInventoryLines, hasLength(2));
      expect(network.lastInventoryLines?[0].itemId, 'item_1');
      expect(network.lastInventoryLines?[0].quantity, 12);
      expect(network.lastInventoryLines?[1].itemId, 'item_3');
      expect(network.lastInventoryLines?[1].quantity, 2.5);
    });

    test('propagates network failures to the caller', () async {
      final network = _FakeCompleteInstallationNetwork(
        const {},
        error: Exception('server unreachable'),
      );
      final repository = CompleteInstallationRepository(network: network);

      expect(
        () => repository.submit(
          id: 'req_ist1',
          oltDeviceOwnership: 'user',
          connectionFatNodeId: 'node_7',
          dpLatitude: _dpLatitude,
          dpLongitude: _dpLongitude,
        ),
        throwsException,
      );
    });

    test('sends multipart and forwards photo + voice details', () async {
      final dir = await Directory.systemTemp.createTemp('ist_multipart');
      addTearDown(() => dir.delete(recursive: true));
      final photo = File('${dir.path}/shot.webp');
      await photo.writeAsBytes(List<int>.filled(100, 1));
      final voice = File('${dir.path}/note.m4a');
      await voice.writeAsBytes(List<int>.filled(100, 2));

      final network = _FakeCompleteInstallationNetwork(_successMap);
      final repository = CompleteInstallationRepository(network: network);

      await repository.submit(
        id: 'req_ist1',
        oltDeviceOwnership: 'user',
        connectionFatNodeId: 'node_1',
        dpLatitude: _dpLatitude,
        dpLongitude: _dpLongitude,
        totalWireUsed: 40,
        inventoryLines: const [(itemId: 'item_1', quantity: 12)],
        photos: [(path: photo.path, mime: 'image/webp')],
        voiceNotePath: voice.path,
        voiceNoteMimeType: 'audio/mp4',
      );

      expect(network.multipartCalls, 1);
      expect(network.jsonCalls, 0);
      expect(network.lastOwnership, 'user');
      expect(network.lastFatNodeId, 'node_1');
      expect(network.lastDpLatitude, _dpLatitude);
      expect(network.lastDpLongitude, _dpLongitude);
      expect(network.lastWire, 40);
      expect(network.lastInventoryLines, hasLength(1));
      expect(network.lastPhotos, hasLength(1));
      expect(network.lastPhotos?[0].path, photo.path);
      expect(network.lastPhotos?[0].mime, 'image/webp');
      expect(network.lastVoiceNotePath, voice.path);
      expect(network.lastVoiceNoteMimeType, 'audio/mp4');
    });

    test('rejects a photo larger than the 2 MB limit', () async {
      final dir = await Directory.systemTemp.createTemp('ist_photo');
      addTearDown(() => dir.delete(recursive: true));
      final photo = File('${dir.path}/big.png');
      await photo.writeAsBytes(List<int>.filled(maxInstallationPhotoBytes + 1, 0));

      final repository =
          CompleteInstallationRepository(network: _FakeCompleteInstallationNetwork(_successMap));

      expect(
        () => repository.submit(
          id: 'req_ist1',
          oltDeviceOwnership: 'user',
          connectionFatNodeId: 'node_1',
          dpLatitude: _dpLatitude,
          dpLongitude: _dpLongitude,
          photos: [(path: photo.path, mime: 'image/png')],
        ),
        throwsA(isA<InstallationPhotoTooLargeException>()),
      );
    });

    test('rejects a photo with an unsupported MIME type', () async {
      final dir = await Directory.systemTemp.createTemp('ist_photo');
      addTearDown(() => dir.delete(recursive: true));
      final photo = File('${dir.path}/shot.bmp');
      await photo.writeAsBytes(List<int>.filled(100, 0));

      final repository =
          CompleteInstallationRepository(network: _FakeCompleteInstallationNetwork(_successMap));

      expect(
        () => repository.submit(
          id: 'req_ist1',
          oltDeviceOwnership: 'user',
          connectionFatNodeId: 'node_1',
          dpLatitude: _dpLatitude,
          dpLongitude: _dpLongitude,
          photos: [(path: photo.path, mime: 'image/bmp')],
        ),
        throwsA(isA<UnsupportedInstallationPhotoException>()),
      );
    });

    test('branches to JSON (not multipart) when no photos or voice note',
        () async {
      final network = _FakeCompleteInstallationNetwork(_successMap);
      final repository = CompleteInstallationRepository(network: network);

      await repository.submit(
        id: 'req_ist1',
        oltDeviceOwnership: 'user',
        connectionFatNodeId: 'node_1',
        dpLatitude: _dpLatitude,
        dpLongitude: _dpLongitude,
      );

      expect(network.jsonCalls, 1);
      expect(network.multipartCalls, 0);
      expect(network.lastPhotos, isNull);
      expect(network.lastVoiceNotePath, isNull);
    });
  });
}