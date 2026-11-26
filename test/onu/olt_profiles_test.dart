import 'package:flutter_test/flutter_test.dart';
import 'package:isp_onlinecer/features/onu/data/olt_network.dart';
import 'package:isp_onlinecer/features/onu/data/olt_repository.dart';
import 'package:isp_onlinecer/models/olt_profiles.dart';

/// D19 (guide §15): `GET /lookups/direct-olts/{olt}/profiles` returns the
/// line/service profiles + VLANs for the authorize form. Live shape
/// (2026-11-26): 8 line profiles, 3 service profiles, 113 VLANs.
/// `value` goes in the authorize payload, `label` is shown in the dropdown.
Map<String, dynamic> _profilesPayload({
  int lineCount = 8,
  int serviceCount = 3,
  int vlanCount = 113,
}) {
  return {
    'olt': {'id': 'olt-1', 'name': 'Wah OLT - Private Access', 'vendor': 'Huawei'},
    'line_profiles': [
      for (var i = 0; i < lineCount; i++)
        {
          'value': 'Line-$i',
          'label': '${10 + i} - Line-$i',
          'huawei_profile_id': 10 + i,
        },
    ],
    'service_profiles': [
      for (var i = 0; i < serviceCount; i++)
        {
          'value': 'HSI-$i',
          'label': '${20 + i} - HSI-$i',
          'huawei_profile_id': 20 + i,
        },
    ],
    'vlans': [
      for (var i = 0; i < vlanCount; i++)
        {
          'value': 300 + i,
          'vlan_id': 300 + i,
          'name': 'VLAN ${300 + i}',
          'label': 'VLAN ${300 + i}',
        },
    ],
    'authorization_preset': {'ready': false, 'gemport': 1},
  };
}

class _FakeOltNetwork implements OltNetwork {
  _FakeOltNetwork(this.profilesResult);

  final Map<String, dynamic> profilesResult;
  String? lastOltId;
  String? lastSubBranchId;

  @override
  Future<Map<String, dynamic>> fetchDirectOlts({String? subBranchId}) async =>
      const {'data': []};

  @override
  Future<Map<String, dynamic>> discoverWaitingOnus(
    String oltId, {
    String? subBranchId,
  }) async =>
      const {'data': []};

  @override
  Future<Map<String, dynamic>> fetchWaitingOnus(
    String oltId, {
    String? subBranchId,
  }) async =>
      const {'data': []};

  @override
  Future<Map<String, dynamic>> fetchProfiles(
    String oltId, {
    String? subBranchId,
  }) async {
    lastOltId = oltId;
    lastSubBranchId = subBranchId;
    return profilesResult;
  }
}

void main() {
  group('OltProfiles.fromJson', () {
    test('parses the live 8 line / 3 service / 113 VLAN shape', () {
      final profiles = OltProfiles.fromJson(_profilesPayload());

      expect(profiles.lineProfiles, hasLength(8));
      expect(profiles.serviceProfiles, hasLength(3));
      expect(profiles.vlans, hasLength(113));

      // Value → payload, label → display.
      expect(profiles.lineProfiles.first.value, 'Line-0');
      expect(profiles.lineProfiles.first.label, '10 - Line-0');
      expect(profiles.lineProfiles.first.huaweiProfileId, 10);
      expect(profiles.serviceProfiles.first.value, 'HSI-0');
      expect(profiles.vlans.first.value, 300);
      expect(profiles.vlans.first.vlanId, 300);
      expect(profiles.vlans.first.label, 'VLAN 300');
      expect(profiles.vlans.last.value, 412);

      expect(profiles.olt?.name, 'Wah OLT - Private Access');
      expect(profiles.olt?.vendor, 'Huawei');
      expect(profiles.authorizationPreset?.ready, isFalse);
      expect(profiles.authorizationPreset?.gemport, 1);
    });

    test('both VLAN dropdowns use the same vlans array', () {
      final profiles = OltProfiles.fromJson(_profilesPayload());
      // The two dropdowns are independent selections over one list — the
      // model hands both the same array; the screen keeps two controllers.
      expect(profiles.vlans, hasLength(113));
      expect(profiles.vlans.map((v) => v.value).toSet(), hasLength(113));
    });

    test('missing lists parse as empty, never crash', () {
      final profiles = OltProfiles.fromJson(const {'olt': {'id': 'olt-1'}});
      expect(profiles.lineProfiles, isEmpty);
      expect(profiles.serviceProfiles, isEmpty);
      expect(profiles.vlans, isEmpty);
      expect(profiles.authorizationPreset, isNull);
    });

    test('entries without a usable value are dropped', () {
      final profiles = OltProfiles.fromJson({
        'line_profiles': [
          {'value': 'Good', 'label': 'Good'},
          {'label': 'no value at all'},
          {'value': '', 'label': 'empty value'},
        ],
        'vlans': [
          {'value': 346, 'label': 'VLAN 346'},
          {'value': 'not-a-number', 'label': 'bad'},
          {'value': '347', 'label': 'VLAN 347'},
        ],
      });
      expect(profiles.lineProfiles.map((o) => o.value), ['Good']);
      // String-encoded VLAN values are accepted.
      expect(profiles.vlans.map((o) => o.value), [346, 347]);
    });

    test('nested data envelope is unwrapped defensively', () {
      final profiles = OltProfiles.fromJson({
        'data': _profilesPayload(lineCount: 1, serviceCount: 1, vlanCount: 1),
      });
      expect(profiles.lineProfiles, hasLength(1));
      expect(profiles.vlans, hasLength(1));
    });
  });

  group('OltRepository.fetchProfiles', () {
    test('calls the profiles endpoint with the OLT id + sub-branch scope', () async {
      final network = _FakeOltNetwork(_profilesPayload());
      final repository = OltRepository(network: network);

      final profiles = await repository.fetchProfiles(
        'olt-1',
        subBranchId: 'sub-9',
      );

      expect(network.lastOltId, 'olt-1');
      expect(network.lastSubBranchId, 'sub-9');
      expect(profiles.lineProfiles, hasLength(8));
      expect(profiles.vlans, hasLength(113));
    });

    test('works without a sub-branch scope', () async {
      final network = _FakeOltNetwork(_profilesPayload());
      final repository = OltRepository(network: network);

      final profiles = await repository.fetchProfiles('olt-1');

      expect(network.lastOltId, 'olt-1');
      expect(network.lastSubBranchId, isNull);
      expect(profiles.serviceProfiles, hasLength(3));
    });
  });
}
