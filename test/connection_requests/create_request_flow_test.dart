import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isp_onlinecer/core/network/api_exceptions.dart';
import 'package:isp_onlinecer/features/connection_requests/data/create_request_network.dart';
import 'package:isp_onlinecer/features/connection_requests/data/create_request_repository.dart';
import 'package:isp_onlinecer/features/connection_requests/presentation/create_request_providers.dart';
import 'package:isp_onlinecer/features/connection_requests/presentation/create_request_screen.dart';
import 'package:isp_onlinecer/features/lookups/data/sub_branch_network.dart';
import 'package:isp_onlinecer/features/lookups/data/sub_branch_repository.dart';
import 'package:isp_onlinecer/features/lookups/presentation/sub_branch_providers.dart';

const _scopedSingleMap = {
  'mode': 'scoped',
  'selected_sub_branch_id': null,
  'data': [
    {'id': 'sb_only', 'name': 'Only Sub-Branch'},
  ],
};

const _createDataMap = {
  'data': {
    'customer_types': [
      {'value': 'home', 'label': 'Home'},
      {'value': 'business', 'label': 'Business'},
    ],
    'plans': [
      {'id': 'plan_1', 'name': 'Fiber 20 Mbps', 'price_minor': 120000},
    ],
    'fat_nodes': [
      {'id': 'node_1', 'name': 'FAT-A Gulberg', 'node_type': 'dp'},
    ],
    'team_flows': [
      {'id': 'flow_1', 'name': 'Standard', 'functional_team_type': 'survey'},
    ],
  },
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
  @override
  Future<Map<String, dynamic>> fetchSubBranches({String? subBranchId}) async =>
      _scopedSingleMap;
}

class _FakeCreateRequestNetwork implements CreateRequestNetwork {
  _FakeCreateRequestNetwork({
    this.createDataResult = _createDataMap,
    this.createResult = _createdMap,
  });

  final Map<String, dynamic> createDataResult;
  final Map<String, dynamic> createResult;

  /// Fails the next [failCreates] create calls with a network error.
  int failCreates = 0;

  /// When set, create calls wait on this instead of answering immediately.
  Completer<Map<String, dynamic>>? pendingCreate;

  int createCount = 0;

  @override
  Future<Map<String, dynamic>> fetchCreateData({String? subBranchId}) async =>
      createDataResult;

  @override
  Future<Map<String, dynamic>> createConnectionRequest(FormData form) async {
    createCount++;
    if (failCreates > 0) {
      failCreates--;
      throw const NetworkException();
    }
    if (pendingCreate != null) return pendingCreate!.future;
    return createResult;
  }
}

Widget _buildApp(_FakeCreateRequestNetwork network) {
  return ProviderScope(
    overrides: [
      subBranchRepositoryProvider.overrideWithValue(
        SubBranchRepository(network: _FakeSubBranchNetwork()),
      ),
      createRequestRepositoryProvider.overrideWithValue(
        CreateRequestRepository(network: network),
      ),
    ],
    child: const MaterialApp(home: CreateRequestScreen()),
  );
}

/// Bounded settle: pumps frames until nothing is scheduled, but gives up
/// after a bounded number of frames (mirrors the survey flow test — never
/// an unbounded `pumpAndSettle`).
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
    tempDir = Directory.systemTemp.createTempSync('create_request_flow_test');
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

  /// Attaches both required ID-card images through the controller (the
  /// picker itself needs a platform channel, so tests drive the same
  /// controller method the picker calls).
  void attachIdCards(WidgetTester tester) {
    final container = ProviderScope.containerOf(
      tester.element(find.byType(CreateRequestScreen)),
    );
    final notifier = container.read(createRequestControllerProvider.notifier);
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

  testWidgets('form renders from create-data', (tester) async {
    setViewport(tester);
    final network = _FakeCreateRequestNetwork();
    await tester.pumpWidget(_buildApp(network));
    await _settle(tester);

    // Sub-branch resolved silently (scoped single row).
    expect(find.text('Only Sub-Branch'), findsOneWidget);
    // Required fields + pickers.
    expect(find.text('Customer name *'), findsOneWidget);
    expect(find.text('Customer phone *'), findsOneWidget);
    expect(find.text('ID card — front *'), findsOneWidget);
    expect(find.text('ID card — back *'), findsOneWidget);
    expect(find.text('Create request'), findsOneWidget);

    // Plan dropdown is fed by create-data, not hardcoded: open it and the
    // backend's plan is there.
    await tester.tap(find.text('Choose a plan'));
    await _settle(tester);
    expect(find.text('Fiber 20 Mbps'), findsOneWidget);
    await tester.tap(find.text('Fiber 20 Mbps'));
    await _settle(tester);

    // Same for team flows.
    await tester.tap(find.text('Choose a team flow'));
    await _settle(tester);
    expect(find.text('Standard'), findsOneWidget);
  });

  testWidgets('empty submit shows inline errors and does not call the API',
      (tester) async {
    setViewport(tester);
    final network = _FakeCreateRequestNetwork();
    await tester.pumpWidget(_buildApp(network));
    await _settle(tester);

    await tapSubmit(tester);
    await _settle(tester);

    expect(find.text('Customer name is required.'), findsOneWidget);
    expect(find.text('Customer phone is required.'), findsOneWidget);
    expect(
      find.text('Front photo of the ID card is required.'),
      findsOneWidget,
    );
    expect(
      find.text('Back photo of the ID card is required.'),
      findsOneWidget,
    );
    expect(network.createCount, 0);
  });

  testWidgets('submit button is disabled while submitting', (tester) async {
    setViewport(tester);
    final network = _FakeCreateRequestNetwork();
    network.pendingCreate = Completer<Map<String, dynamic>>();
    await tester.pumpWidget(_buildApp(network));
    await _settle(tester);

    await fillRequiredFields(tester);
    attachIdCards(tester);
    await tester.pump();

    await tapSubmit(tester);
    await tester.pump();

    // While submitting the button shows a spinner instead of its label, so
    // find it by type: it is the only FilledButton on the form.
    final button = tester.widget<FilledButton>(
      find.bySubtype<FilledButton>(),
    );
    expect(button.onPressed, isNull);

    // Finish the pending request: success view with the request number.
    network.pendingCreate!.complete(_createdMap);
    await _settle(tester);
    expect(find.text('Request created'), findsOneWidget);
    expect(find.text('CRQ-20261123-0001'), findsOneWidget);
  });

  testWidgets('draft is kept on network error, Retry resubmits it',
      (tester) async {
    setViewport(tester);
    final network = _FakeCreateRequestNetwork()..failCreates = 1;
    await tester.pumpWidget(_buildApp(network));
    await _settle(tester);

    await fillRequiredFields(tester);
    attachIdCards(tester);
    await tester.pump();

    await tapSubmit(tester);
    await _settle(tester);

    // No queued-offline claim: the error says the entries are still here.
    expect(
      find.text("Couldn't send — your entries are still here. Retry."),
      findsOneWidget,
    );
    // The draft survived: text + picked files are still on screen.
    final nameField = tester.widget<TextField>(find.byType(TextField).at(0));
    expect(nameField.controller?.text, 'Rahim Uddin');
    expect(find.text('front.jpg'), findsOneWidget);
    expect(find.text('back.jpg'), findsOneWidget);
    expect(network.createCount, 1);

    // Retry sends the same draft and lands on the success view.
    await tester.ensureVisible(find.text('Retry'));
    await tester.tap(find.text('Retry'));
    await _settle(tester);

    expect(find.text('Request created'), findsOneWidget);
    expect(find.text('CRQ-20261123-0001'), findsOneWidget);
    expect(find.text('survey_assigned'), findsOneWidget);
    expect(find.text('complete_survey'), findsOneWidget);
    expect(network.createCount, 2);
  });

  testWidgets('success view offers Open request for a survey request',
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

    expect(find.text('Request created'), findsOneWidget);
    expect(find.text('Open request'), findsOneWidget);
  });
}
