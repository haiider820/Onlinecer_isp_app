import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:isp_onlinecer/core/router/app_router.dart';
import 'package:isp_onlinecer/features/survey/data/submit_survey_network.dart';
import 'package:isp_onlinecer/features/survey/data/submit_survey_repository.dart';
import 'package:isp_onlinecer/features/survey/presentation/connection_request_providers.dart';
import 'package:isp_onlinecer/features/survey/presentation/submit_survey_providers.dart';
import 'package:isp_onlinecer/features/survey/presentation/submit_survey_screen.dart';
import 'package:isp_onlinecer/models/connection_request.dart';

/// Screen-level tests for the feasibility selector (D14).
///
/// The Complete Survey screen had no way to fill the backend-required
/// `survey_feasibility_status`, so every normal submit 422d. These tests
/// drive the real screen: the selector, the reason field, the client-side
/// blocks, and the review-mode hiding — while the controller/repository
/// tests pin what is sent on each path.
class _FakeSubmitSurveyNetwork implements SubmitSurveyNetwork {
  String? lastJsonFeasibility;
  String? lastJsonReason;
  int jsonCalls = 0;

  @override
  Future<Map<String, dynamic>> completeSurveyJson(
    String id, {
    String? notes,
    String? feasibilityStatus,
    String? notFeasibleReason,
  }) async {
    jsonCalls++;
    lastJsonFeasibility = feasibilityStatus;
    lastJsonReason = notFeasibleReason;
    return _successMap;
  }

  @override
  Future<Map<String, dynamic>> completeSurveyMultipart(
    String id, {
    String? notes,
    String? feasibilityStatus,
    String? notFeasibleReason,
    required String voiceNotePath,
    required String voiceNoteMimeType,
  }) async {
    jsonCalls++;
    lastJsonFeasibility = feasibilityStatus;
    lastJsonReason = notFeasibleReason;
    return _successMap;
  }
}

const _successMap = {
  'message': 'Survey marked as completed.',
  'data': {
    'id': '101',
    'request_number': 'CRQ-20261001-ABCD',
    'status': 'installation_assigned',
    'current_team': {
      'id': 'team_uuid',
      'name': 'Installation Team',
      'functional_team_type': 'installation',
    },
    'timestamps': {'surveyed_at': '2026-09-10T11:00:00.000000Z'},
  },
};

Map<String, Object?> _detailJson() => {
  'data': {
    'id': 'req-1',
    'request_number': 'CRQ-20261001-ABCD',
    'status': 'survey_assigned',
    'customer_name': 'Test Customer',
    'current_team': {
      'id': 'team_uuid',
      'name': 'Survey Team',
      'functional_team_type': 'survey',
    },
  },
  'allowed_action': 'complete_survey',
};

Future<void> _pumpSubmitScreen(
  WidgetTester tester,
  _FakeSubmitSurveyNetwork network, {
  bool isReview = false,
}) async {
  final router = GoRouter(
    initialLocation: '/submit',
    routes: [
      GoRoute(
        path: '/submit',
        builder: (_, __) =>
            SubmitSurveyScreen(requestId: 'req-1', isReview: isReview),
      ),
      GoRoute(
        path: Routes.surveyList,
        builder: (_, __) =>
            const Scaffold(body: Center(child: Text('Survey List'))),
      ),
    ],
  );
  addTearDown(router.dispose);
  // 800px wide like the full-flow test: the test font renders ~2x wider
  // than Plus Jakarta Sans on a phone, so at 360px even the pre-existing
  // Field Notes / VoiceRecorder rows overflow in the test (they render fine
  // on a real phone — see Haider's screenshots). The 360px narrow-width
  // check lives in the detail-shelf test instead.
  tester.view.physicalSize = const Size(800, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        submitSurveyRepositoryProvider.overrideWithValue(
          SubmitSurveyRepository(network: network),
        ),
        connectionRequestDetailProvider('req-1').overrideWith(
          (ref) async => ConnectionRequestDetail.fromJson(_detailJson()),
        ),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}

/// Bounded settle: pumps frames until nothing is scheduled, but gives up
/// after a bounded number of frames. The success overlay's 1800ms
/// animation always resolves inside the bound.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 30; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (!tester.binding.hasScheduledFrame) break;
  }
}

Future<void> _tapSubmit(WidgetTester tester, String label) async {
  await tester.tap(
    find.ancestor(
      of: find.text(label),
      matching: find.bySubtype<FilledButton>(),
    ),
  );
  await _settle(tester);
}

void main() {
  testWidgets('submit without a feasibility pick is blocked, no network call',
      (tester) async {
    final network = _FakeSubmitSurveyNetwork();
    await _pumpSubmitScreen(tester, network);

    expect(find.text('Feasibility'), findsOneWidget);
    expect(find.text('Feasible'), findsOneWidget);
    expect(find.text('Not feasible'), findsOneWidget);

    await _tapSubmit(tester, 'Submit Survey');

    expect(
      find.text('Select whether the site is feasible.'),
      findsOneWidget,
    );
    expect(network.jsonCalls, 0);
  });

  testWidgets('feasible pick submits with status and no reason',
      (tester) async {
    final network = _FakeSubmitSurveyNetwork();
    await _pumpSubmitScreen(tester, network);

    await tester.tap(find.text('Feasible'));
    await _settle(tester);
    await _tapSubmit(tester, 'Submit Survey');

    expect(network.jsonCalls, 1);
    expect(network.lastJsonFeasibility, 'feasible');
    expect(network.lastJsonReason, isNull);
    expect(find.text('Survey List'), findsOneWidget);
  });

  testWidgets(
      'not-feasible pick shows the reason field; submit without a reason is blocked',
      (tester) async {
    final network = _FakeSubmitSurveyNetwork();
    await _pumpSubmitScreen(tester, network);

    await tester.tap(find.text('Not feasible'));
    await _settle(tester);

    final reasonField = find.widgetWithText(
      TextField,
      'Reason (required)',
    );
    expect(reasonField, findsOneWidget);

    await _tapSubmit(tester, 'Submit Survey');

    expect(
      find.text('Add a reason why the site is not feasible.'),
      findsOneWidget,
    );
    expect(network.jsonCalls, 0);
  });

  testWidgets('not-feasible pick with a reason submits both fields',
      (tester) async {
    final network = _FakeSubmitSurveyNetwork();
    await _pumpSubmitScreen(tester, network);

    await tester.tap(find.text('Not feasible'));
    await _settle(tester);
    await tester.enterText(
      find.widgetWithText(TextField, 'Reason (required)'),
      'No FAT port is reachable from this address',
    );
    await _settle(tester);
    await _tapSubmit(tester, 'Submit Survey');

    expect(network.jsonCalls, 1);
    expect(network.lastJsonFeasibility, 'not_feasible');
    expect(
      network.lastJsonReason,
      'No FAT port is reachable from this address',
    );
    expect(find.text('Survey List'), findsOneWidget);
  });

  testWidgets(
      'review mode hides the feasibility selector and still sends feasible',
      (tester) async {
    final network = _FakeSubmitSurveyNetwork();
    await _pumpSubmitScreen(tester, network, isReview: true);

    expect(find.text('Feasibility'), findsNothing);
    expect(find.text('Feasible'), findsNothing);
    expect(find.text('Not feasible'), findsNothing);
    expect(find.text('Confirm Review'), findsOneWidget);

    await _tapSubmit(tester, 'Confirm Review');

    expect(network.jsonCalls, 1);
    expect(network.lastJsonFeasibility, 'feasible');
    expect(network.lastJsonReason, isNull);
    expect(find.text('Survey List'), findsOneWidget);
  });
}
