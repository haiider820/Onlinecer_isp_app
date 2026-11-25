import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isp_onlinecer/core/storage/secure_storage.dart';
import 'package:isp_onlinecer/features/auth/presentation/providers.dart';
import 'package:isp_onlinecer/features/connection_requests/data/create_request_network.dart';
import 'package:isp_onlinecer/features/connection_requests/data/create_request_repository.dart';
import 'package:isp_onlinecer/features/connection_requests/presentation/create_request_providers.dart';
import 'package:isp_onlinecer/features/connection_requests/presentation/create_request_screen.dart';
import 'package:isp_onlinecer/features/lookups/data/sub_branch_network.dart';
import 'package:isp_onlinecer/features/lookups/data/sub_branch_repository.dart';
import 'package:isp_onlinecer/features/lookups/presentation/sub_branch_providers.dart';
import 'package:isp_onlinecer/models/create_data.dart';

import '../ispfinal_adversarial/helpers.dart';

/// Live create-data shape (2026-11-25, umair@gmail.com, centralized scope,
/// sub_branch c348df56-736f-4fa9-bd45-1f20635c11d7): two flows, the default
/// id IS one of the listed flows, stage assignments carry stage_key /
/// stage_label / stage_order + the assigned team, and the flow itself has
/// NO functional_team_type field. Stage assignments are deliberately
/// out of order here so the ordering logic is exercised, not assumed.
const _liveCreateDataMap = {
  'data': {
    'customer_types': [
      {'value': 'home', 'label': 'Home'},
    ],
    'plans': [
      {'id': 'plan_1', 'name': 'Fiber 20 Mbps', 'price_minor': 120000},
    ],
    'fat_nodes': [
      {'id': 'node_1', 'name': 'FAT-A Gulberg', 'node_type': 'dp'},
    ],
    'team_flows': [
      {
        'id': '763419f4-be54-4b7d-9855-b1cc0af8a547',
        'name': 'Installation',
        'stage_assignments': [
          {
            'stage_key': 'closing',
            'stage_label': 'Closing',
            'stage_order': 5,
            'team': {
              'id': 'team-main-test',
              'name': 'Main Team Test',
              'code': 'MAIN-TEST',
              'functional_team_type': 'closing',
              'functional_team_types': ['closing'],
              'flow_order': 5,
              'is_active': true,
            },
          },
          {
            'stage_key': 'survey',
            'stage_label': 'Survey',
            'stage_order': 1,
            'team': {
              'id': 'team-long-haul',
              'name': 'Long Haul Team',
              'code': 'LONG-HAUL',
              'functional_team_type': 'survey',
              'functional_team_types': ['survey'],
              'flow_order': 1,
              'is_active': true,
            },
          },
          {
            'stage_key': 'fiber_splicing',
            'stage_label': 'Fiber Splicing',
            'stage_order': 3,
            'team': {
              'id': 'team-long-haul',
              'name': 'Long Haul Team',
              'code': 'LONG-HAUL',
              'functional_team_type': 'survey',
              'functional_team_types': ['survey'],
              'flow_order': 1,
              'is_active': true,
            },
          },
          {
            'stage_key': 'installation',
            'stage_label': 'Installation',
            'stage_order': 2,
            'team': {
              'id': 'team-long-haul',
              'name': 'Long Haul Team',
              'code': 'LONG-HAUL',
              'functional_team_type': 'survey',
              'functional_team_types': ['survey'],
              'flow_order': 1,
              'is_active': true,
            },
          },
          {
            'stage_key': 'connection_verification',
            'stage_label': 'Connection Verification',
            'stage_order': 4,
            'team': {
              'id': 'team-long-haul',
              'name': 'Long Haul Team',
              'code': 'LONG-HAUL',
              'functional_team_type': 'survey',
              'functional_team_types': ['survey'],
              'flow_order': 1,
              'is_active': true,
            },
          },
        ],
        'teams': [
          {
            'id': 'team-long-haul',
            'name': 'Long Haul Team',
            'code': 'LONG-HAUL',
            'functional_team_type': 'survey',
            'functional_team_types': ['survey'],
            'flow_order': 1,
            'is_active': true,
          },
          {
            'id': 'team-main-test',
            'name': 'Main Team Test',
            'code': 'MAIN-TEST',
            'functional_team_type': 'closing',
            'functional_team_types': ['closing'],
            'flow_order': 5,
            'is_active': true,
          },
        ],
      },
      {
        'id': '12218cba-88b3-4f84-9578-421af30f6a0d',
        'name': 'Cent-Tech Support',
        'stage_assignments': [
          {
            'stage_key': 'survey',
            'stage_label': 'Survey',
            'stage_order': 1,
            'team': {
              'id': 'team-central',
              'name': 'Centralized Tech',
              'code': 'CENT-TECH',
              'functional_team_type': 'survey',
              'functional_team_types': ['survey'],
              'flow_order': 1,
              'is_active': true,
            },
          },
          {
            'stage_key': 'installation',
            'stage_label': 'Installation',
            'stage_order': 2,
            'team': {
              'id': 'team-central',
              'name': 'Centralized Tech',
              'code': 'CENT-TECH',
              'functional_team_type': 'survey',
              'functional_team_types': ['survey'],
              'flow_order': 1,
              'is_active': true,
            },
          },
          {
            'stage_key': 'fiber_splicing',
            'stage_label': 'Fiber Splicing',
            'stage_order': 3,
            'team': {
              'id': 'team-central',
              'name': 'Centralized Tech',
              'code': 'CENT-TECH',
              'functional_team_type': 'survey',
              'functional_team_types': ['survey'],
              'flow_order': 1,
              'is_active': true,
            },
          },
          {
            'stage_key': 'connection_verification',
            'stage_label': 'Connection Verification',
            'stage_order': 4,
            'team': {
              'id': 'team-central',
              'name': 'Centralized Tech',
              'code': 'CENT-TECH',
              'functional_team_type': 'survey',
              'functional_team_types': ['survey'],
              'flow_order': 1,
              'is_active': true,
            },
          },
          {
            'stage_key': 'closing',
            'stage_label': 'Closing',
            'stage_order': 5,
            'team': {
              'id': 'team-central',
              'name': 'Centralized Tech',
              'code': 'CENT-TECH',
              'functional_team_type': 'survey',
              'functional_team_types': ['survey'],
              'flow_order': 1,
              'is_active': true,
            },
          },
        ],
        'teams': [
          {
            'id': 'team-central',
            'name': 'Centralized Tech',
            'code': 'CENT-TECH',
            'functional_team_type': 'survey',
            'functional_team_types': ['survey'],
            'flow_order': 1,
            'is_active': true,
          },
        ],
      },
    ],
    'default_team_flow_id': '12218cba-88b3-4f84-9578-421af30f6a0d',
  },
};

/// Survey scope (live shape, 2026-11-25): no flow configured — empty list,
/// null default. The form must show the pending-assignment note, not fail.
const _emptyFlowsCreateDataMap = {
  'data': {
    'customer_types': [
      {'value': 'home', 'label': 'Home'},
    ],
    'plans': [
      {'id': 'plan_1', 'name': 'Fiber 20 Mbps', 'price_minor': 120000},
    ],
    'fat_nodes': [
      {'id': 'node_1', 'name': 'FAT-A Gulberg', 'node_type': 'dp'},
    ],
    'team_flows': [],
    'default_team_flow_id': null,
  },
};

const _scopedSingleMap = {
  'mode': 'scoped',
  'selected_sub_branch_id': null,
  'data': [
    {'id': 'sb_only', 'name': 'Only Sub-Branch'},
  ],
};

const _centralizedMap = {
  'mode': 'centralized',
  'selected_sub_branch_id': null,
  'data': [
    {'id': 'sb_gulberg', 'name': 'Gulberg Sub-Branch', 'type': 'sub_branch'},
    {'id': 'sb_north', 'name': 'North Sub-Branch', 'type': 'sub_branch'},
  ],
};

const _createdMap = {
  'message': 'Connection request created.',
  'data': {
    'id': 'req_9',
    'request_number': 'CRQ-20261123-0001',
    'status': 'survey_assigned',
    'customer_name': 'Rahim Uddin',
    'sub_branch': {'id': 'sb_only', 'name': 'Only Sub-Branch'},
    'requested_plan': {'id': 'plan_1', 'name': 'Fiber 20 Mbps'},
  },
  'allowed_action': 'complete_survey',
  'allowed_actions': ['complete_survey'],
};

class _FakeSubBranchNetwork implements SubBranchNetwork {
  _FakeSubBranchNetwork([this.result = _scopedSingleMap]);

  final Map<String, dynamic> result;

  @override
  Future<Map<String, dynamic>> fetchSubBranches({String? subBranchId}) async =>
      result;
}

class _FakeCreateRequestNetwork implements CreateRequestNetwork {
  _FakeCreateRequestNetwork({
    this.createDataResult = _liveCreateDataMap,
    Map<String, Map<String, dynamic>>? createDataBySubBranch,
  }) : createDataBySubBranch = createDataBySubBranch ?? const {},
       createResult = _createdMap;

  final Map<String, dynamic> createDataResult;
  final Map<String, Map<String, dynamic>> createDataBySubBranch;
  final Map<String, dynamic> createResult;

  int createCount = 0;

  /// The fields of the last create call (FormData.fields), for asserting
  /// whether `team_flow_id` was sent and with what value.
  Map<String, String> lastCreateFields = {};

  @override
  Future<Map<String, dynamic>> fetchCreateData({String? subBranchId}) async =>
      createDataBySubBranch[subBranchId] ?? createDataResult;

  @override
  Future<Map<String, dynamic>> createConnectionRequest(FormData form) async {
    createCount++;
    lastCreateFields = Map<String, String>.fromEntries(form.fields);
    return createResult;
  }
}

Widget _buildApp(
  _FakeCreateRequestNetwork network, {
  Map<String, dynamic> subBranchMap = _scopedSingleMap,
  SecureStorage? storage,
}) {
  return ProviderScope(
    overrides: [
      if (storage != null) secureStorageProvider.overrideWithValue(storage),
      subBranchRepositoryProvider.overrideWithValue(
        SubBranchRepository(network: _FakeSubBranchNetwork(subBranchMap)),
      ),
      createRequestRepositoryProvider.overrideWithValue(
        CreateRequestRepository(network: network),
      ),
    ],
    child: const MaterialApp(home: CreateRequestScreen()),
  );
}

/// Bounded settle: pumps frames until nothing is scheduled, but gives up
/// after a bounded number of frames (mirrors the create-request flow test
/// — never an unbounded `pumpAndSettle`).
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 30; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (!tester.binding.hasScheduledFrame) break;
  }
}

void main() {
  late Directory tempDir;
  late File frontImage;
  late File backImage;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('create_request_team_flow');
    frontImage = File('${tempDir.path}/front.jpg')
      ..writeAsBytesSync(List.filled(1024, 0));
    backImage = File('${tempDir.path}/back.jpg')
      ..writeAsBytesSync(List.filled(1024, 0));
  });

  tearDown(() => tempDir.deleteSync(recursive: true));

  /// Tall viewport so the whole (long) form builds: a ListView only builds
  /// visible children, and below-fold rows would otherwise never be found.
  void setViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  ProviderContainer containerOf(WidgetTester tester) =>
      ProviderScope.containerOf(
        tester.element(find.byType(CreateRequestScreen)),
      );

  /// Attaches both required ID-card images through the controller (the
  /// picker itself needs a platform channel, so tests drive the same
  /// controller method the picker calls).
  void attachIdCards(WidgetTester tester) {
    final notifier = containerOf(
      tester,
    ).read(createRequestControllerProvider.notifier);
    notifier.setFile(
      CreateRequestFileSlot.idCardFront,
      (path: frontImage.path, mime: 'image/jpeg'),
    );
    notifier.setFile(
      CreateRequestFileSlot.idCardBack,
      (path: backImage.path, mime: 'image/jpeg'),
    );
  }

  Future<void> fillRequiredFields(WidgetTester tester) async {
    await tester.enterText(find.byType(TextField).at(0), 'Rahim Uddin');
    await tester.enterText(find.byType(TextField).at(1), '+92 300 1234567');
  }

  Future<void> tapSubmit(WidgetTester tester) async {
    await tester.ensureVisible(find.text('Create request'));
    await tester.tap(find.text('Create request'));
  }

  group('create-data parsing (live shape)', () {
    test('parses default_team_flow_id, flows, stages and teams', () {
      final response = CreateDataResponse.fromJson(_liveCreateDataMap);
      final data = response.data!;
      expect(
        data.defaultTeamFlowId,
        '12218cba-88b3-4f84-9578-421af30f6a0d',
      );
      expect(data.teamFlows, hasLength(2));

      final installation = data.teamFlows!.firstWhere(
        (f) => f.name == 'Installation',
      );
      // The live shape has NO functional_team_type on the flow itself.
      expect(installation.functionalTeamType, isNull);
      expect(installation.stageAssignments, hasLength(5));
      expect(installation.teams, hasLength(2));

      // Workflow order comes from stage_order, not list order: the JSON
      // above lists closing first, but stagesInOrder must start at survey.
      final orderedKeys = installation.stagesInOrder
          .map((s) => s.stageKey)
          .toList();
      expect(orderedKeys, [
        'survey',
        'installation',
        'fiber_splicing',
        'connection_verification',
        'closing',
      ]);
      expect(installation.firstStage?.stageLabel, 'Survey');
      expect(installation.firstStage?.team?.name, 'Long Haul Team');
      expect(
        installation.stagesInOrder.last.team?.name,
        'Main Team Test',
      );
      final surveyStage = installation.stagesInOrder.first;
      expect(surveyStage.stageOrder, 1);
      expect(surveyStage.team?.code, 'LONG-HAUL');
      expect(surveyStage.team?.functionalTeamTypes, ['survey']);
      expect(surveyStage.team?.isActive, isTrue);

      final support = data.teamFlows!.firstWhere(
        (f) => f.name == 'Cent-Tech Support',
      );
      expect(support.stageAssignments, hasLength(5));
      expect(
        support.stagesInOrder.map((s) => s.team?.name).toSet(),
        {'Centralized Tech'},
      );
    });

    test('parses an empty team_flows list with a null default', () {
      final response = CreateDataResponse.fromJson(_emptyFlowsCreateDataMap);
      final data = response.data!;
      expect(data.teamFlows, isEmpty);
      expect(data.defaultTeamFlowId, isNull);
    });

    test('round-trips the new fields through toJson', () {
      final response = CreateDataResponse.fromJson(_liveCreateDataMap);
      final json = response.data!.toJson();
      expect(
        json['default_team_flow_id'],
        '12218cba-88b3-4f84-9578-421af30f6a0d',
      );
      // Without explicitToJson the generated toJson keeps nested models as
      // objects (jsonEncode calls their toJson recursively) — assert on
      // the models, not on maps.
      final flows = json['team_flows'] as List;
      expect(flows, hasLength(2));
      final installation = flows.firstWhere(
        (f) => (f as CreateDataTeamFlow).name == 'Installation',
      ) as CreateDataTeamFlow;
      expect(installation.stageAssignments, hasLength(5));
      expect(installation.teams, hasLength(2));
    });
  });

  testWidgets('default_team_flow_id is pre-selected when in the list',
      (tester) async {
    setViewport(tester);
    final network = _FakeCreateRequestNetwork();
    await tester.pumpWidget(_buildApp(network));
    await _settle(tester);

    // The backend default ("Cent-Tech Support") shows as the selected
    // value without any tap.
    expect(find.text('Cent-Tech Support'), findsOneWidget);
    expect(find.text('Choose a team flow'), findsNothing);
    expect(
      containerOf(tester).read(createRequestControllerProvider).teamFlowId,
      '12218cba-88b3-4f84-9578-421af30f6a0d',
    );
  });

  testWidgets('no pre-selection when the default id is not in the list',
      (tester) async {
    setViewport(tester);
    final createData = Map<String, dynamic>.from(_liveCreateDataMap);
    final data = Map<String, dynamic>.from(
      _liveCreateDataMap['data'] as Map<String, dynamic>,
    )..['default_team_flow_id'] = 'no-such-flow';
    createData['data'] = data;
    final network = _FakeCreateRequestNetwork(createDataResult: createData);
    await tester.pumpWidget(_buildApp(network));
    await _settle(tester);

    expect(find.text('Choose a team flow'), findsOneWidget);
    expect(
      containerOf(tester).read(createRequestControllerProvider).teamFlowId,
      isNull,
    );
  });

  testWidgets('no pre-selection when there is no default at all',
      (tester) async {
    setViewport(tester);
    final createData = Map<String, dynamic>.from(_liveCreateDataMap);
    final data = Map<String, dynamic>.from(
      _liveCreateDataMap['data'] as Map<String, dynamic>,
    )..remove('default_team_flow_id');
    createData['data'] = data;
    final network = _FakeCreateRequestNetwork(createDataResult: createData);
    await tester.pumpWidget(_buildApp(network));
    await _settle(tester);

    expect(find.text('Choose a team flow'), findsOneWidget);
    expect(
      containerOf(tester).read(createRequestControllerProvider).teamFlowId,
      isNull,
    );
  });

  testWidgets('empty team_flows shows the pending-assignment note',
      (tester) async {
    setViewport(tester);
    final network = _FakeCreateRequestNetwork(
      createDataResult: _emptyFlowsCreateDataMap,
    );
    await tester.pumpWidget(_buildApp(network));
    await _settle(tester);

    // No dropdown, no silent hide — the note explains the situation.
    expect(find.text('Choose a team flow'), findsNothing);
    expect(
      find.text(
        'No team flow is configured for this sub-branch. The request will stay pending for flow assignment.',
      ),
      findsOneWidget,
    );
    // The rest of the form still works.
    expect(find.text('Customer name *'), findsOneWidget);
    expect(find.text('Create request'), findsOneWidget);
  });

  testWidgets('submit sends team_flow_id for the pre-selected default',
      (tester) async {
    setViewport(tester);
    final network = _FakeCreateRequestNetwork();
    await tester.pumpWidget(_buildApp(network));
    await _settle(tester);

    await fillRequiredFields(tester);
    attachIdCards(tester);
    await tester.pump();
    await tapSubmit(tester);
    await _settle(tester);

    expect(network.createCount, 1);
    expect(
      network.lastCreateFields['team_flow_id'],
      '12218cba-88b3-4f84-9578-421af30f6a0d',
    );
    expect(find.text('Request created'), findsOneWidget);
  });

  testWidgets('submit omits team_flow_id when no flow is configured',
      (tester) async {
    setViewport(tester);
    final network = _FakeCreateRequestNetwork(
      createDataResult: _emptyFlowsCreateDataMap,
    );
    await tester.pumpWidget(_buildApp(network));
    await _settle(tester);

    await fillRequiredFields(tester);
    attachIdCards(tester);
    await tester.pump();
    await tapSubmit(tester);
    await _settle(tester);

    expect(network.createCount, 1);
    expect(network.lastCreateFields.containsKey('team_flow_id'), isFalse);
    expect(find.text('Request created'), findsOneWidget);
  });

  testWidgets('sub-branch change re-applies the new scope default',
      (tester) async {
    setViewport(tester);
    Map<String, dynamic> flowsFor(String flowId, String name) {
      return {
        'data': {
          'customer_types': [
            {'value': 'home', 'label': 'Home'},
          ],
          'plans': [],
          'fat_nodes': [],
          'team_flows': [
            {'id': flowId, 'name': name, 'stage_assignments': [], 'teams': []},
          ],
          'default_team_flow_id': flowId,
        },
      };
    }

    final network = _FakeCreateRequestNetwork(
      createDataBySubBranch: {
        'sb_gulberg': flowsFor('flow_g1', 'Flow Gulberg 1'),
        'sb_north': flowsFor('flow_n2', 'Flow North 2'),
      },
    );
    final storage = freshStorage(InMemoryFlutterSecureStorage());
    await seedEmployeeSession(
      storage,
      subBranchId: 'sb_gulberg',
      subBranchName: 'Gulberg Sub-Branch',
    );
    await tester.pumpWidget(
      _buildApp(network, subBranchMap: _centralizedMap, storage: storage),
    );
    await _settle(tester);

    // Gulberg scope default is pre-selected.
    expect(find.text('Flow Gulberg 1'), findsOneWidget);
    expect(
      containerOf(tester).read(createRequestControllerProvider).teamFlowId,
      'flow_g1',
    );

    // Switch sub-branch: the stale Gulberg pre-selection must go, the
    // North scope default takes over (not the old id, not nothing).
    containerOf(tester).read(subBranchStateProvider.notifier).select('sb_north');
    await _settle(tester);

    expect(find.text('Flow North 2'), findsOneWidget);
    expect(find.text('Flow Gulberg 1'), findsNothing);
    expect(
      containerOf(tester).read(createRequestControllerProvider).teamFlowId,
      'flow_n2',
    );
  });
}
