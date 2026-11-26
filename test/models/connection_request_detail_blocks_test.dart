import 'package:flutter_test/flutter_test.dart';
import 'package:isp_onlinecer/features/stage_shared/models/team_stage_detail.dart';
import 'package:isp_onlinecer/models/connection_request.dart';

/// D19 (guide §6, Rev 1.0): the detail response carries `pppoe_credentials`
/// and `installation_inventory`. Both models parse them leniently —
/// missing/null/odd shapes never crash — and the screens render them
/// read-only (password shown only when `password_visible` is true).
///
/// Live shapes (verified 2026-11-26 on the new base):
/// `pppoe_credentials: {available: true, username: "test",
/// password: "...", password_visible: true}`;
/// `installation_inventory: {warehouse: null, assigned_items: [],
/// available_items: [], request_status: null, can_request: true,
/// request_endpoint: ".../inventory-request"}`.
const _livePppoe = <String, Object?>{
  'available': true,
  'username': 'test',
  'password': 's3cret',
  'password_visible': true,
};

const _liveInventory = <String, Object?>{
  'warehouse': null,
  'assigned_items': <Object?>[],
  'available_items': <Object?>[],
  'request_status': null,
  'can_request': true,
  'request_endpoint': 'https://ttsn.onlinecer.com/api/mobile/inventory-request',
};

Map<String, Object?> _requestJson({
  Object? pppoe = _livePppoe,
  Object? inventory = _liveInventory,
}) {
  return {
    'id': 'req-1',
    'request_number': 'CRQ-20261125-TEST',
    'status': 'installation_assigned',
    'customer_name': 'test',
    if (pppoe != _sentinel) 'pppoe_credentials': pppoe,
    if (inventory != _sentinel) 'installation_inventory': inventory,
  };
}

const _sentinel = Object();

void main() {
  group('ConnectionRequest pppoe_credentials + installation_inventory', () {
    test('parses the live shapes', () {
      final request = ConnectionRequest.fromJson(_requestJson());

      expect(request.pppoeCredentials, isNotNull);
      expect(request.pppoeCredentials!['available'], isTrue);
      expect(request.pppoeCredentials!['username'], 'test');
      expect(request.pppoeCredentials!['password'], 's3cret');
      expect(request.pppoeCredentials!['password_visible'], isTrue);

      expect(request.installationInventory, isNotNull);
      expect(request.installationInventory!['warehouse'], isNull);
      expect(request.installationInventory!['assigned_items'], isEmpty);
      expect(request.installationInventory!['available_items'], isEmpty);
      expect(request.installationInventory!['request_status'], isNull);
      expect(request.installationInventory!['can_request'], isTrue);
      expect(
        request.installationInventory!['request_endpoint'],
        'https://ttsn.onlinecer.com/api/mobile/inventory-request',
      );
    });

    test('absent blocks parse as null', () {
      final request = ConnectionRequest.fromJson(
        _requestJson(pppoe: _sentinel, inventory: _sentinel),
      );
      expect(request.pppoeCredentials, isNull);
      expect(request.installationInventory, isNull);
    });

    test('null blocks parse as null', () {
      final request = ConnectionRequest.fromJson(
        _requestJson(pppoe: null, inventory: null),
      );
      expect(request.pppoeCredentials, isNull);
      expect(request.installationInventory, isNull);
    });

    test('non-object blocks parse as null, never crash', () {
      final request = ConnectionRequest.fromJson(
        _requestJson(pppoe: 'not-a-map', inventory: ['not', 'a', 'map']),
      );
      expect(request.pppoeCredentials, isNull);
      expect(request.installationInventory, isNull);
    });

    test('partial blocks keep the keys that are present', () {
      final request = ConnectionRequest.fromJson(_requestJson(
        pppoe: const {'available': false},
        inventory: const {'request_status': 'approved', 'can_request': false},
      ));
      expect(request.pppoeCredentials!['available'], isFalse);
      expect(request.pppoeCredentials!['username'], isNull);
      expect(request.installationInventory!['request_status'], 'approved');
      expect(request.installationInventory!['can_request'], isFalse);
    });
  });

  group('TeamStageDetail pppoe_credentials + installation_inventory', () {
    Map<String, dynamic> envelope({
      Object? pppoe = _livePppoe,
      Object? inventory = _liveInventory,
    }) {
      return {
        'data': {
          'id': 'req-1',
          'request_number': 'CRQ-20261125-TEST',
          'status': 'installation_assigned',
          if (pppoe != _sentinel) 'pppoe_credentials': pppoe,
          if (inventory != _sentinel) 'installation_inventory': inventory,
        },
        'allowed_action': 'complete_installation',
      };
    }

    test('parses the live shapes', () {
      final detail = TeamStageDetail.fromJson(envelope());

      expect(detail.pppoeCredentials, isNotNull);
      expect(detail.pppoeCredentials!['username'], 'test');
      expect(detail.pppoeCredentials!['password_visible'], isTrue);
      expect(detail.installationInventory, isNotNull);
      expect(detail.installationInventory!['can_request'], isTrue);
      expect(detail.installationInventory!['assigned_items'], isEmpty);
    });

    test('absent blocks parse as null', () {
      final detail = TeamStageDetail.fromJson(
        envelope(pppoe: _sentinel, inventory: _sentinel),
      );
      expect(detail.pppoeCredentials, isNull);
      expect(detail.installationInventory, isNull);
    });

    test('non-object blocks parse as null, never crash', () {
      final detail = TeamStageDetail.fromJson(
        envelope(pppoe: 'not-a-map', inventory: 42),
      );
      expect(detail.pppoeCredentials, isNull);
      expect(detail.installationInventory, isNull);
    });
  });
}
