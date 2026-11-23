import 'package:flutter_test/flutter_test.dart';
import 'package:isp_onlinecer/models/create_data.dart';
import 'package:isp_onlinecer/models/sub_branch.dart';

void main() {
  group('SubBranch.fromJson', () {
    test('parses the full centralized shape', () {
      final json = <String, Object?>{
        'id': 'sub_branch_uuid',
        'name': 'Gulberg Sub-Branch',
        'type': 'sub_branch',
        'organization_id': 'org_uuid',
        'company_id': 'company_uuid',
        'branch_id': 'branch_uuid',
        'parent_id': 'branch_uuid',
      };

      final branch = SubBranch.fromJson(json);

      expect(branch.id, 'sub_branch_uuid');
      expect(branch.name, 'Gulberg Sub-Branch');
      expect(branch.type, 'sub_branch');
      expect(branch.organizationId, 'org_uuid');
      expect(branch.companyId, 'company_uuid');
      expect(branch.branchId, 'branch_uuid');
      expect(branch.parentId, 'branch_uuid');
    });

    test('tolerates a scoped row with only id and name', () {
      final json = <String, Object?>{
        'id': 'sub_branch_uuid',
        'name': 'Gulberg Sub-Branch',
      };

      final branch = SubBranch.fromJson(json);

      expect(branch.id, 'sub_branch_uuid');
      expect(branch.name, 'Gulberg Sub-Branch');
      expect(branch.type, isNull);
      expect(branch.organizationId, isNull);
      expect(branch.parentId, isNull);
    });
  });

  group('SubBranchList.fromJson', () {
    test('parses the centralized envelope with a selected id', () {
      final json = <String, Object?>{
        'mode': 'centralized',
        'selected_sub_branch_id': 'sub_branch_uuid',
        'data': <Object?>[
          {
            'id': 'sub_branch_uuid',
            'name': 'Gulberg Sub-Branch',
            'type': 'sub_branch',
            'organization_id': 'org_uuid',
            'company_id': 'company_uuid',
            'branch_id': 'branch_uuid',
            'parent_id': 'branch_uuid',
          },
        ],
      };

      final list = SubBranchList.fromJson(json);

      expect(list.mode, 'centralized');
      expect(list.isCentralized, isTrue);
      expect(list.selectedSubBranchId, 'sub_branch_uuid');
      expect(list.data, hasLength(1));
      expect(list.data.first.name, 'Gulberg Sub-Branch');
    });

    test('scoped mode is not centralized and an empty list parses', () {
      final json = <String, Object?>{
        'mode': 'scoped',
        'selected_sub_branch_id': null,
        'data': <Object?>[],
      };

      final list = SubBranchList.fromJson(json);

      expect(list.mode, 'scoped');
      expect(list.isCentralized, isFalse);
      expect(list.selectedSubBranchId, isNull);
      expect(list.data, isEmpty);
    });
  });

  group('CreateData.fromJson', () {
    test('parses customer_types, plans, fat_nodes and team_flows', () {
      final json = <String, Object?>{
        'customer_types': <Object?>[
          {'value': 'home', 'label': 'Home'},
          {'value': 'business', 'label': 'Business'},
        ],
        'plans': <Object?>[
          {'id': 'plan_uuid', 'name': '20 Mbps', 'price_minor': 250000},
        ],
        'fat_nodes': <Object?>[
          {'id': 'fat_uuid', 'name': 'FAT-01', 'node_type': 'fat'},
        ],
        'team_flows': <Object?>[
          {
            'id': 'flow_uuid',
            'name': 'Survey Flow',
            'functional_team_type': 'survey',
          },
        ],
      };

      final data = CreateData.fromJson(json);

      expect(data.customerTypes, hasLength(2));
      expect(data.customerTypes!.first.value, 'home');
      expect(data.customerTypes!.first.label, 'Home');
      expect(data.plans, hasLength(1));
      expect(data.plans!.first.name, '20 Mbps');
      expect(data.plans!.first.priceMinor, 250000);
      expect(data.fatNodes, hasLength(1));
      expect(data.fatNodes!.first.nodeType, 'fat');
      expect(data.teamFlows, hasLength(1));
      expect(data.teamFlows!.first.functionalTeamType, 'survey');
    });

    test('tolerates missing lists and partial list items', () {
      final json = <String, Object?>{
        'customer_types': <Object?>[
          {'value': 'home'},
        ],
      };

      final data = CreateData.fromJson(json);

      expect(data.customerTypes, hasLength(1));
      expect(data.customerTypes!.first.label, isNull);
      expect(data.plans, isNull);
      expect(data.fatNodes, isNull);
      expect(data.teamFlows, isNull);
    });

    test('parses through the data envelope', () {
      final json = <String, Object?>{
        'data': {
          'customer_types': <Object?>[
            {'value': 'home', 'label': 'Home'},
          ],
          'plans': <Object?>[],
          'fat_nodes': <Object?>[],
          'team_flows': <Object?>[],
        },
      };

      final response = CreateDataResponse.fromJson(json);

      expect(response.data?.customerTypes, hasLength(1));
      expect(response.data?.plans, isEmpty);
    });
  });
}
