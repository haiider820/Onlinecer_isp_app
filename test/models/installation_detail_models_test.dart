import 'package:flutter_test/flutter_test.dart';
import 'package:isp_onlinecer/models/connection_request.dart';
import 'package:isp_onlinecer/models/inventory_item.dart';

void main() {
  group('ConnectionRequestDetail stage_data + locations', () {
    test('parses both detail-only blocks off the detail payload', () {
      final detail = ConnectionRequestDetail.fromJson({
        'data': {
          'id': 'req_1',
          'request_number': 'CRQ-20260911-AB12',
          'status': 'installation_assigned',
          'stage_data': {
            'survey_notes': 'FAT port 3 free, roof access confirmed.',
            'installation_notes': 'Cable pulled, spliced.',
            'olt_device_ownership': 'company',
            'total_wire_used': 45,
          },
          'locations': {
            'installation': {'latitude': 23.744, 'longitude': 90.378},
            'dp': {'latitude': 23.741, 'longitude': 90.381},
            'user_device': {'node_id': 'node_1'},
          },
        },
        'allowed_action': 'complete_installation',
      });

      final stage = detail.request.stageData;
      expect(stage?.surveyNotes, 'FAT port 3 free, roof access confirmed.');
      expect(stage?.installationNotes, 'Cable pulled, spliced.');
      expect(stage?.oltDeviceOwnership, 'company');
      expect(stage?.totalWireUsed, 45);

      final locations = detail.request.locations;
      expect(locations?.installation?.latitude, 23.744);
      expect(locations?.installation?.longitude, 90.378);
      expect(locations?.dp?.latitude, 23.741);
      expect(locations?.dp?.longitude, 90.381);
      expect(locations?.userDevice?.nodeId, 'node_1');
      expect(locations?.fatNode, isNull);

      expect(detail.action, ConnectionRequestAction.completeInstallation);
    });

    test('absent stage_data / locations stay null (list-style payload)', () {
      final detail = ConnectionRequestDetail.fromJson({
        'data': {
          'id': 'req_1',
          'request_number': 'CRQ-20260911-AB12',
          'status': 'installation_assigned',
        },
        'allowed_action': null,
      });

      expect(detail.request.stageData, isNull);
      expect(detail.request.locations, isNull);
      expect(detail.action, isNull);
    });

    test('partially-filled stage_data degrades gracefully', () {
      final detail = ConnectionRequestDetail.fromJson({
        'data': {
          'id': 'req_1',
          'request_number': 'CRQ-20260911-AB12',
          'status': 'installation_assigned',
          'stage_data': {'survey_notes': 'Surveyed only.'},
        },
      });

      expect(detail.request.stageData?.surveyNotes, 'Surveyed only.');
      expect(detail.request.stageData?.installationNotes, isNull);
      expect(detail.request.stageData?.oltDeviceOwnership, isNull);
    });
  });

  group('InventoryItemList envelope', () {
    test('parses `{ data: [...] }` into inventory items', () {
      final list = InventoryItemList.fromJson({
        'data': [
          {'id': 'item_1', 'name': 'Cat6 Cable', 'unit': 'meter'},
          {'id': 'item_2', 'name': 'Fiber Pigtail'}, // unit absent
        ],
      });

      expect(list.data, hasLength(2));
      expect(list.data.first.id, 'item_1');
      expect(list.data.first.name, 'Cat6 Cable');
      expect(list.data.first.unit, 'meter');
      expect(list.data.last.unit, isNull);
    });

    test('empty data array is fine', () {
      final list = InventoryItemList.fromJson({'data': []});
      expect(list.data, isEmpty);
    });
  });
}