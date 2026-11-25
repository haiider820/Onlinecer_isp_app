import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isp_onlinecer/features/survey/data/submit_survey_network.dart';
import 'package:isp_onlinecer/features/survey/data/submit_survey_repository.dart';
import 'package:isp_onlinecer/features/survey/presentation/connection_request_providers.dart';
import 'package:isp_onlinecer/features/survey/presentation/submit_survey_providers.dart';
import 'package:isp_onlinecer/models/connection_request.dart';

/// SubmitSurveyController feasibility mapping (D14).
///
/// The backend requires `survey_feasibility_status` on every complete-survey
/// (a normal submit without it 422s). The controller validates the pick
/// before any network call: no pick (or a not-feasible pick with no reason)
/// is blocked client-side with an error state and zero network calls.
/// The review case still forces `"feasible"` with no reason and no selector
/// involvement.
class _FakeSubmitSurveyNetwork implements SubmitSurveyNetwork {
  String? lastJsonFeasibility;
  String? lastJsonReason;
  String? lastMultipartFeasibility;
  String? lastMultipartReason;
  int jsonCalls = 0;
  int multipartCalls = 0;

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
    multipartCalls++;
    lastMultipartFeasibility = feasibilityStatus;
    lastMultipartReason = notFeasibleReason;
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

SubmitSurveyController _controllerWithNetwork(_FakeSubmitSurveyNetwork network) {
  final container = _containerWithNetwork(network);
  return container.read(submitSurveyControllerProvider.notifier);
}

/// Container with the fake submit repository AND a stubbed detail provider:
/// a successful submit invalidates the detail (Phase D refetch), and
/// without the override that refetch would hit the real network — the
/// binding-error noise that used to print from these tests.
ProviderContainer _containerWithNetwork(_FakeSubmitSurveyNetwork network) {
  final container = ProviderContainer(
    overrides: [
      submitSurveyRepositoryProvider.overrideWithValue(
        SubmitSurveyRepository(network: network),
      ),
      connectionRequestDetailProvider('101').overrideWith(
        (ref) async => ConnectionRequestDetail.fromJson(_detailJson()),
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

Map<String, Object?> _detailJson() => {
  'data': {
    'id': '101',
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

void main() {
  test('review submit forwards feasible and no reason', () async {
    final network = _FakeSubmitSurveyNetwork();
    final controller = _controllerWithNetwork(network);

    final review = await controller.submit(
      id: '101',
      notes: 'Reviewed after inventory approval. Items confirmed.',
      isReview: true,
    );
    expect(review, isNotNull);
    expect(network.lastJsonFeasibility, 'feasible');
    expect(network.lastJsonReason, isNull);
  });

  test('normal submit without a feasibility pick is blocked client-side',
      () async {
    final network = _FakeSubmitSurveyNetwork();
    final container = _containerWithNetwork(network);
    final controller = container.read(submitSurveyControllerProvider.notifier);

    final result = await controller.submit(id: '101', notes: 'All good');

    expect(result, isNull);
    expect(network.jsonCalls, 0);
    expect(network.multipartCalls, 0);
    expect(
      container.read(submitSurveyControllerProvider).errorMessage,
      'Select whether the site is feasible.',
    );
  });

  test('normal submit with a feasible pick forwards feasible, no reason',
      () async {
    final network = _FakeSubmitSurveyNetwork();
    final controller = _controllerWithNetwork(network);

    final result = await controller.submit(
      id: '101',
      notes: 'All good',
      feasibilityStatus: 'feasible',
    );
    expect(result, isNotNull);
    expect(network.lastJsonFeasibility, 'feasible');
    expect(network.lastJsonReason, isNull);
  });

  test('not-feasible pick without a reason is blocked client-side', () async {
    final network = _FakeSubmitSurveyNetwork();
    final container = _containerWithNetwork(network);
    final controller = container.read(submitSurveyControllerProvider.notifier);

    final result = await controller.submit(
      id: '101',
      notes: 'No FAT nearby',
      feasibilityStatus: 'not_feasible',
    );

    expect(result, isNull);
    expect(network.jsonCalls, 0);
    expect(
      container.read(submitSurveyControllerProvider).errorMessage,
      'Add a reason why the site is not feasible.',
    );
  });

  test('not-feasible pick with a reason forwards both fields', () async {
    final network = _FakeSubmitSurveyNetwork();
    final controller = _controllerWithNetwork(network);

    final result = await controller.submit(
      id: '101',
      notes: 'No FAT nearby',
      feasibilityStatus: 'not_feasible',
      notFeasibleReason: 'No FAT port is reachable from this address',
    );
    expect(result, isNotNull);
    expect(network.lastJsonFeasibility, 'not_feasible');
    expect(
      network.lastJsonReason,
      'No FAT port is reachable from this address',
    );
  });
}
