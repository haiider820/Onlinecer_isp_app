import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isp_onlinecer/features/survey/data/submit_survey_network.dart';
import 'package:isp_onlinecer/features/survey/data/submit_survey_repository.dart';
import 'package:isp_onlinecer/features/survey/presentation/submit_survey_providers.dart';

/// SubmitSurveyController review mapping: `isReview: true` must forward
/// `survey_feasibility_status: "feasible"` to the repository (and the
/// normal path must forward nothing), on the same complete-survey endpoint.
class _FakeSubmitSurveyNetwork implements SubmitSurveyNetwork {
  String? lastJsonFeasibility;
  String? lastMultipartFeasibility;

  @override
  Future<Map<String, dynamic>> completeSurveyJson(
    String id, {
    String? notes,
    String? feasibilityStatus,
  }) async {
    lastJsonFeasibility = feasibilityStatus;
    return _successMap;
  }

  @override
  Future<Map<String, dynamic>> completeSurveyMultipart(
    String id, {
    String? notes,
    String? feasibilityStatus,
    required String voiceNotePath,
    required String voiceNoteMimeType,
  }) async {
    lastMultipartFeasibility = feasibilityStatus;
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

void main() {
  test('controller review submit forwards feasible; normal submit forwards nothing',
      () async {
    final network = _FakeSubmitSurveyNetwork();
    final container = ProviderContainer(
      overrides: [
        submitSurveyRepositoryProvider.overrideWithValue(
          SubmitSurveyRepository(network: network),
        ),
      ],
    );
    addTearDown(container.dispose);
    final controller = container.read(submitSurveyControllerProvider.notifier);

    final review = await controller.submit(
      id: '101',
      notes: 'Reviewed after inventory approval. Items confirmed.',
      isReview: true,
    );
    expect(review, isNotNull);
    expect(network.lastJsonFeasibility, 'feasible');

    final normal = await controller.submit(id: '101', notes: 'All good');
    expect(normal, isNotNull);
    expect(network.lastJsonFeasibility, isNull);
  });
}
