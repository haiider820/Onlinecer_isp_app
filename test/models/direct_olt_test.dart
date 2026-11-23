import 'package:flutter_test/flutter_test.dart';
import 'package:isp_onlinecer/models/direct_olt.dart';

void main() {
  group('DirectOlt.fromJson', () {
    test('parses the full shape with a ready authorization preset', () {
      final json = <String, Object?>{
        'id': 'olt_uuid',
        'name': 'OLT-Gulberg-01',
        'vendor': 'huawei',
        'model': 'MA5608T',
        'management_ip': '192.168.1.10',
        'connection_status': 'online',
        'company_id': 'company_uuid',
        'branch_id': 'branch_uuid',
        'sub_branch_id': 'sub_branch_uuid',
        'authorization_preset': {
          'ready': true,
          'line_profile': 'FTTH-100M',
          'service_profile': 'IPTV-DATA',
          'vlan': 100,
          'user_vlan': 101,
          'gemport': 1,
        },
        'running_authorizations_count': 2,
      };

      final olt = DirectOlt.fromJson(json);

      expect(olt.id, 'olt_uuid');
      expect(olt.name, 'OLT-Gulberg-01');
      expect(olt.vendor, 'huawei');
      expect(olt.model, 'MA5608T');
      expect(olt.managementIp, '192.168.1.10');
      expect(olt.connectionStatus, 'online');
      expect(olt.companyId, 'company_uuid');
      expect(olt.branchId, 'branch_uuid');
      expect(olt.subBranchId, 'sub_branch_uuid');
      expect(olt.authorizationPreset?.ready, isTrue);
      expect(olt.authorizationPreset?.lineProfile, 'FTTH-100M');
      expect(olt.authorizationPreset?.serviceProfile, 'IPTV-DATA');
      expect(olt.authorizationPreset?.vlan, 100);
      expect(olt.authorizationPreset?.userVlan, 101);
      expect(olt.authorizationPreset?.gemport, 1);
      expect(olt.runningAuthorizationsCount, 2);
    });

    test('parses authorization_preset.ready false with no saved profiles', () {
      final json = <String, Object?>{
        'id': 'olt_uuid',
        'name': 'OLT-Gulberg-02',
        'vendor': 'vsol',
        'model': 'V1600D',
        'management_ip': '192.168.1.11',
        'connection_status': 'online',
        'company_id': 'company_uuid',
        'branch_id': 'branch_uuid',
        'sub_branch_id': 'sub_branch_uuid',
        'authorization_preset': {
          'ready': false,
          'line_profile': null,
          'service_profile': null,
          'vlan': null,
          'user_vlan': null,
          'gemport': null,
        },
        'running_authorizations_count': 0,
      };

      final olt = DirectOlt.fromJson(json);

      expect(olt.authorizationPreset?.ready, isFalse);
      expect(olt.authorizationPreset?.lineProfile, isNull);
      expect(olt.authorizationPreset?.serviceProfile, isNull);
      expect(olt.authorizationPreset?.vlan, isNull);
      expect(olt.authorizationPreset?.userVlan, isNull);
      expect(olt.authorizationPreset?.gemport, isNull);
      expect(olt.runningAuthorizationsCount, 0);
    });

    test('tolerates a missing authorization_preset', () {
      final json = <String, Object?>{
        'id': 'olt_uuid',
        'name': 'OLT-Gulberg-03',
        'vendor': 'huawei',
      };

      final olt = DirectOlt.fromJson(json);

      expect(olt.authorizationPreset, isNull);
      expect(olt.runningAuthorizationsCount, isNull);
    });
  });

  group('DirectOltList.fromJson', () {
    test('parses the data envelope', () {
      final json = <String, Object?>{
        'data': <Object?>[
          {'id': 'olt_uuid', 'name': 'OLT-01', 'vendor': 'huawei'},
        ],
      };

      final list = DirectOltList.fromJson(json);

      expect(list.data, hasLength(1));
      expect(list.data.first.vendor, 'huawei');
    });
  });
}
