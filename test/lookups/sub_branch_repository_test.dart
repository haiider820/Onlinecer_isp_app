import 'package:flutter_test/flutter_test.dart';
import 'package:isp_onlinecer/core/network/api_exceptions.dart';
import 'package:isp_onlinecer/features/lookups/data/sub_branch_network.dart';
import 'package:isp_onlinecer/features/lookups/data/sub_branch_repository.dart';
import 'package:isp_onlinecer/features/lookups/presentation/sub_branch_providers.dart';
import 'package:isp_onlinecer/models/sub_branch.dart';

class _FakeSubBranchNetwork implements SubBranchNetwork {
  _FakeSubBranchNetwork(this.result, {this.error});

  final Map<String, dynamic> result;
  final Exception? error;
  String? lastSubBranchId;
  int fetchCount = 0;

  @override
  Future<Map<String, dynamic>> fetchSubBranches({String? subBranchId}) async {
    lastSubBranchId = subBranchId;
    fetchCount++;
    if (error != null) throw error!;
    return result;
  }
}

const _centralizedMap = {
  'mode': 'centralized',
  'selected_sub_branch_id': 'sb_gulberg',
  'data': [
    {
      'id': 'sb_gulberg',
      'name': 'Gulberg Sub-Branch',
      'type': 'sub_branch',
      'organization_id': 'org_1',
      'company_id': 'co_1',
      'branch_id': 'br_1',
      'parent_id': 'br_1',
    },
    {
      'id': 'sb_north',
      'name': 'North Sub-Branch',
      'type': 'sub_branch',
      'organization_id': 'org_1',
      'company_id': 'co_1',
      'branch_id': 'br_1',
      'parent_id': 'br_1',
    },
  ],
};

const _scopedSingleMap = {
  'mode': 'scoped',
  'selected_sub_branch_id': null,
  'data': [
    {'id': 'sb_only', 'name': 'Only Sub-Branch'},
  ],
};

void main() {
  group('SubBranchRepository.fetchSubBranches', () {
    test('parses the centralized envelope with mode + selected id', () async {
      final network = _FakeSubBranchNetwork(_centralizedMap);
      final repository = SubBranchRepository(network: network);

      final list = await repository.fetchSubBranches();

      expect(list.mode, 'centralized');
      expect(list.isCentralized, isTrue);
      expect(list.selectedSubBranchId, 'sb_gulberg');
      expect(list.data, hasLength(2));
      expect(list.data.first.name, 'Gulberg Sub-Branch');
      expect(list.data.first.type, 'sub_branch');
      expect(list.data.first.organizationId, 'org_1');
      expect(network.lastSubBranchId, isNull);
    });

    test('parses a scoped single-row list', () async {
      final network = _FakeSubBranchNetwork(_scopedSingleMap);
      final repository = SubBranchRepository(network: network);

      final list = await repository.fetchSubBranches();

      expect(list.mode, 'scoped');
      expect(list.isCentralized, isFalse);
      expect(list.data, hasLength(1));
      expect(list.data.first.id, 'sb_only');
      expect(list.data.first.type, isNull);
    });

    test('parses an empty list', () async {
      final network = _FakeSubBranchNetwork({
        'mode': 'scoped',
        'selected_sub_branch_id': null,
        'data': <Object?>[],
      });
      final repository = SubBranchRepository(network: network);

      final list = await repository.fetchSubBranches();

      expect(list.data, isEmpty);
      expect(list.isCentralized, isFalse);
    });

    test('forwards an optional sub_branch_id to the network', () async {
      final network = _FakeSubBranchNetwork(_scopedSingleMap);
      final repository = SubBranchRepository(network: network);

      await repository.fetchSubBranches(subBranchId: 'sb_only');

      expect(network.lastSubBranchId, 'sb_only');
    });

    test('unwraps the envelope when nested under a data key', () async {
      final network = _FakeSubBranchNetwork({'data': _centralizedMap});
      final repository = SubBranchRepository(network: network);

      final list = await repository.fetchSubBranches();

      expect(list.mode, 'centralized');
      expect(list.data, hasLength(2));
    });

    test('surfaces typed ApiException failures untouched', () async {
      const failure = NetworkException();
      final network = _FakeSubBranchNetwork(const {}, error: failure);
      final repository = SubBranchRepository(network: network);

      expect(repository.fetchSubBranches(), throwsA(isA<NetworkException>()));
    });

    test('surfaces a backend message failure untouched', () async {
      final network = _FakeSubBranchNetwork(
        const {},
        error: const ApiException(message: 'Forbidden.', statusCode: 403),
      );
      final repository = SubBranchRepository(network: network);

      expect(
        repository.fetchSubBranches(),
        throwsA(
          isA<ApiException>().having((e) => e.message, 'message', 'Forbidden.'),
        ),
      );
    });
  });

  group('effectiveSubBranchId', () {
    test('explicit selection wins when it is one of the rows', () {
      final list = SubBranchList.fromJson(_centralizedMap);

      expect(effectiveSubBranchId(list, 'sb_north'), 'sb_north');
    });

    test('ignores a selection that is not in the list', () {
      final list = SubBranchList.fromJson(_centralizedMap);

      // Backend pre-selection is the fallback; an invented id never wins.
      expect(effectiveSubBranchId(list, 'sb_invented'), 'sb_gulberg');
    });

    test('centralized with no pick and no backend selection resolves null', () {
      final list = SubBranchList.fromJson({
        'mode': 'centralized',
        'selected_sub_branch_id': null,
        'data': [
          {'id': 'sb_a', 'name': 'A'},
          {'id': 'sb_b', 'name': 'B'},
        ],
      });

      expect(effectiveSubBranchId(list, null), isNull);
    });

    test('scoped single row resolves silently without a pick', () {
      final list = SubBranchList.fromJson(_scopedSingleMap);

      expect(effectiveSubBranchId(list, null), 'sb_only');
    });

    test('scoped several rows with no pick resolves null', () {
      final list = SubBranchList.fromJson({
        'mode': 'scoped',
        'selected_sub_branch_id': null,
        'data': [
          {'id': 'sb_a', 'name': 'A'},
          {'id': 'sb_b', 'name': 'B'},
        ],
      });

      expect(effectiveSubBranchId(list, null), isNull);
    });

    test('empty list resolves null', () {
      final list = SubBranchList.fromJson({
        'mode': 'scoped',
        'selected_sub_branch_id': null,
        'data': <Object?>[],
      });

      expect(effectiveSubBranchId(list, null), isNull);
    });
  });
}
