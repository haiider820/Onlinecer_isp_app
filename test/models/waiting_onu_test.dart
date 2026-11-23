import 'package:flutter_test/flutter_test.dart';
import 'package:isp_onlinecer/models/waiting_onu.dart';

void main() {
  group('WaitingOnu.fromJson', () {
    test('parses the full waiting shape', () {
      final json = <String, Object?>{
        'id': 'onu_uuid',
        'serial_number': 'HWTC12345678',
        'pon_port': '0/1/1',
        'detected_onu_type': 'HG8245H',
        'authorization_status': 'waiting_authorization',
        'authorization_reason': null,
        'last_discovered_at': '2026-11-23T10:00:00Z',
      };

      final onu = WaitingOnu.fromJson(json);

      expect(onu.id, 'onu_uuid');
      expect(onu.serialNumber, 'HWTC12345678');
      expect(onu.ponPort, '0/1/1');
      expect(onu.detectedOnuType, 'HG8245H');
      expect(onu.authorizationStatus, 'waiting_authorization');
      expect(onu.authorizationReason, isNull);
      expect(onu.lastDiscoveredAt, '2026-11-23T10:00:00Z');
    });

    test('parses a failed row with its reason', () {
      final json = <String, Object?>{
        'id': 'onu_uuid',
        'serial_number': 'VSOL87654321',
        'pon_port': '1/0/2',
        'detected_onu_type': 'V2801SG',
        'authorization_status': 'failed',
        'authorization_reason': 'Serial already authorized on another OLT',
        'last_discovered_at': '2026-11-23T09:30:00Z',
      };

      final onu = WaitingOnu.fromJson(json);

      expect(onu.authorizationStatus, 'failed');
      expect(onu.authorizationReason, 'Serial already authorized on another OLT');
    });
  });

  group('WaitingOnuList.fromJson', () {
    test('parses the cached-list envelope', () {
      final json = <String, Object?>{
        'data': <Object?>[
          {
            'id': 'onu_uuid',
            'serial_number': 'HWTC12345678',
            'pon_port': '0/1/1',
            'detected_onu_type': 'HG8245H',
            'authorization_status': 'waiting_authorization',
            'authorization_reason': null,
            'last_discovered_at': '2026-11-23T10:00:00Z',
          },
        ],
      };

      final list = WaitingOnuList.fromJson(json);

      expect(list.data, hasLength(1));
      expect(list.data.first.serialNumber, 'HWTC12345678');
    });
  });

  group('DiscoverWaitingOnusResponse.fromJson', () {
    test('parses the discover envelope with source and seen_count', () {
      final json = <String, Object?>{
        'message': 'Discovery complete',
        'source': 'olt',
        'seen_count': 2,
        'data': <Object?>[
          {
            'id': 'onu_uuid',
            'serial_number': 'HWTC12345678',
            'pon_port': '0/1/1',
            'detected_onu_type': 'HG8245H',
            'authorization_status': 'waiting_authorization',
            'authorization_reason': null,
            'last_discovered_at': '2026-11-23T10:00:00Z',
          },
          {
            'id': 'onu_uuid_2',
            'serial_number': 'HWTC99999999',
            'pon_port': '0/1/2',
            'detected_onu_type': 'HG8245H',
            'authorization_status': 'waiting_authorization',
            'authorization_reason': null,
            'last_discovered_at': '2026-11-23T10:00:00Z',
          },
        ],
      };

      final response = DiscoverWaitingOnusResponse.fromJson(json);

      expect(response.message, 'Discovery complete');
      expect(response.source, 'olt');
      expect(response.seenCount, 2);
      expect(response.data, hasLength(2));
    });

    test('tolerates an empty discovery', () {
      final json = <String, Object?>{
        'message': 'No waiting ONUs found',
        'source': 'cache',
        'seen_count': 0,
        'data': <Object?>[],
      };

      final response = DiscoverWaitingOnusResponse.fromJson(json);

      expect(response.source, 'cache');
      expect(response.seenCount, 0);
      expect(response.data, isEmpty);
    });
  });
}
