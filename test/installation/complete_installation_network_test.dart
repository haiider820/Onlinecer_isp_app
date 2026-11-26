import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isp_onlinecer/features/installation/data/complete_installation_network.dart';

import '../helpers/capturing_api_client.dart';

/// Wire-level tests for [DioCompleteInstallationNetwork] (D16): the exact
/// JSON body and FormData fields the app sends to
/// `POST .../complete-installation`.
///
/// The backend reads ONLY `items` — the old `inventory_items` name was
/// silently ignored, so inventory usage never landed. These tests prove the
/// JSON path sends an `items` array and the multipart path sends indexed
/// `items[i][item_id]` / `items[i][quantity]` fields, and that
/// `inventory_items` is never sent on either path.
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

const _lines = [
  (itemId: 'item_1', quantity: 12),
  (itemId: 'item_3', quantity: 2.5),
];

void main() {
  group('DioCompleteInstallationNetwork wire payloads', () {
    test('JSON: sends items array, never inventory_items', () async {
      final api = CapturingApiClient(_successMap);
      final network = DioCompleteInstallationNetwork(api.client);

      await network.completeInstallationJson(
        'req_ist1',
        oltDeviceOwnership: 'company',
        connectionFatNodeId: 'node_7',
        installedDeviceMac: 'AA:BB:CC:DD:EE:FF',
        dpLatitude: 23.7444,
        dpLongitude: 90.3788,
        inventoryLines: _lines,
      );

      final body = api.captured.data as Map<String, dynamic>;
      expect(body.containsKey('inventory_items'), isFalse);
      expect(body['items'], [
        {'item_id': 'item_1', 'quantity': 12},
        {'item_id': 'item_3', 'quantity': 2.5},
      ]);
      expect(body['olt_device_ownership'], 'company');
      expect(body['connection_fat_node_id'], 'node_7');
      // Guide §9: the installed device MAC is required on every submit.
      expect(body['installed_device_mac'], 'AA:BB:CC:DD:EE:FF');
      expect(body.containsKey('installed_device_serial'), isFalse);
    });

    test('JSON: sends installed_device_serial when provided', () async {
      final api = CapturingApiClient(_successMap);
      final network = DioCompleteInstallationNetwork(api.client);

      await network.completeInstallationJson(
        'req_ist1',
        oltDeviceOwnership: 'user',
        connectionFatNodeId: 'node_7',
        installedDeviceMac: 'AA:BB:CC:DD:EE:FF',
        installedDeviceSerial: 'FHTT-22A25980',
        dpLatitude: 23.7444,
        dpLongitude: 90.3788,
      );

      final body = api.captured.data as Map<String, dynamic>;
      expect(body['installed_device_mac'], 'AA:BB:CC:DD:EE:FF');
      expect(body['installed_device_serial'], 'FHTT-22A25980');
    });

    test('JSON: no inventory lines sends no items field', () async {
      final api = CapturingApiClient(_successMap);
      final network = DioCompleteInstallationNetwork(api.client);

      await network.completeInstallationJson(
        'req_ist1',
        oltDeviceOwnership: 'user',
        connectionFatNodeId: 'node_7',
        installedDeviceMac: 'AA:BB:CC:DD:EE:FF',
        dpLatitude: 23.7444,
        dpLongitude: 90.3788,
      );

      final body = api.captured.data as Map<String, dynamic>;
      expect(body.containsKey('items'), isFalse);
      expect(body.containsKey('inventory_items'), isFalse);
    });

    test('multipart: sends indexed items[i] fields, never inventory_items',
        () async {
      final dir = await Directory.systemTemp.createTemp('ist_net');
      addTearDown(() => dir.delete(recursive: true));
      final photo = File('${dir.path}/shot.webp')
        ..writeAsBytesSync(List.filled(100, 1));

      final api = CapturingApiClient(_successMap);
      final network = DioCompleteInstallationNetwork(api.client);

      await network.completeInstallationMultipart(
        'req_ist1',
        oltDeviceOwnership: 'user',
        connectionFatNodeId: 'node_1',
        installedDeviceMac: 'AA:BB:CC:DD:EE:FF',
        dpLatitude: 23.7444,
        dpLongitude: 90.3788,
        inventoryLines: _lines,
        photos: [(path: photo.path, mime: 'image/webp')],
      );

      final form = api.captured.data as FormData;
      final fields = formFields(form);
      expect(fields.containsKey('inventory_items'), isFalse);
      expect(fields['items[0][item_id]'], 'item_1');
      expect(fields['items[0][quantity]'], '12');
      expect(fields['items[1][item_id]'], 'item_3');
      expect(fields['items[1][quantity]'], '2.5');
      expect(formFileFields(form), contains('installation_photos[]'));
      // Guide §9: the MAC rides the multipart path too, same field name.
      expect(fields['installed_device_mac'], 'AA:BB:CC:DD:EE:FF');
    });

    test('multipart: no inventory lines sends no items fields', () async {
      final api = CapturingApiClient(_successMap);
      final network = DioCompleteInstallationNetwork(api.client);

      await network.completeInstallationMultipart(
        'req_ist1',
        oltDeviceOwnership: 'user',
        connectionFatNodeId: 'node_1',
        installedDeviceMac: 'AA:BB:CC:DD:EE:FF',
        dpLatitude: 23.7444,
        dpLongitude: 90.3788,
      );

      final form = api.captured.data as FormData;
      final fields = formFields(form);
      expect(
        fields.keys.any((key) => key.startsWith('items[')),
        isFalse,
      );
      expect(fields.containsKey('inventory_items'), isFalse);
    });
  });
}
