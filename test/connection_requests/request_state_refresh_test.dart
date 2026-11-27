import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isp_onlinecer/features/closing/presentation/closing_providers.dart';
import 'package:isp_onlinecer/features/installation/presentation/installation_providers.dart';
import 'package:isp_onlinecer/features/splicing/presentation/splicing_providers.dart';
import 'package:isp_onlinecer/features/stage_shared/models/team_stage_detail.dart';
import 'package:isp_onlinecer/features/survey/data/connection_request_network.dart';
import 'package:isp_onlinecer/features/survey/data/dashboard_network.dart';
import 'package:isp_onlinecer/features/survey/data/submit_survey_network.dart';
import 'package:isp_onlinecer/features/survey/data/submit_survey_repository.dart';
import 'package:isp_onlinecer/features/survey/presentation/connection_request_providers.dart';
import 'package:isp_onlinecer/features/survey/presentation/dashboard_providers.dart';
import 'package:isp_onlinecer/features/survey/presentation/submit_survey_providers.dart';
import 'package:isp_onlinecer/features/verification/presentation/verification_providers.dart';
import 'package:isp_onlinecer/models/splicing.dart';

/// D24 root cause: after a stage submit the app only invalidated the shared
/// detail provider, so the list screens — which accumulate rows in local
/// state from a NON-autoDispose page family — kept showing the OLD phase
/// until the user pulled to refresh. `refreshAfterStageSubmit` must
/// invalidate every list (all pages), every detail, and the dashboard, so a
/// fresh mount refetches from the server.

class _CountingConnectionRequestNetwork implements ConnectionRequestNetwork {
  int fetchPageCalls = 0;
  int fetchDetailCalls = 0;

  @override
  Future<Map<String, dynamic>> fetchPage({
    required int page,
    String? status,
  }) async {
    fetchPageCalls++;
    return {
      'data': [
        {
          'id': '101',
          'request_number': 'CRQ-20261001-ABCD',
          'status': 'survey_assigned',
          'customer_name': 'Test Customer',
          'customer_area': 'Blue Area',
        },
      ],
      'meta': {'current_page': 1, 'per_page': 15, 'total': 1, 'last_page': 1},
    };
  }

  @override
  Future<Map<String, dynamic>> fetchDetail(String id) async {
    fetchDetailCalls++;
    return {
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
  }
}

class _CountingDashboardNetwork implements DashboardNetwork {
  int calls = 0;

  @override
  Future<Map<String, dynamic>> fetchDashboard() async {
    calls++;
    return {
      'stats': {
        'connection_requests': {'total': 5, 'pending': 2, 'completed': 3},
      },
    };
  }
}

class _FakeSubmitSurveyNetwork implements SubmitSurveyNetwork {
  @override
  Future<Map<String, dynamic>> completeSurveyJson(
    String id, {
    String? notes,
    String? feasibilityStatus,
    String? notFeasibleReason,
  }) async {
    return {
      'message': 'Survey marked as completed.',
      'data': {
        'id': '101',
        'request_number': 'CRQ-20261001-ABCD',
        'status': 'installation_assigned',
      },
    };
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
    throw UnimplementedError();
  }
}

Map<String, dynamic> _stageDetailJson() => {
      'data': {
        'id': '101',
        'request_number': 'CRQ-20261001-ABCD',
        'status': 'splicing_assigned',
      },
    };

ProviderContainer _container(
  _CountingConnectionRequestNetwork network,
  _CountingDashboardNetwork dashboard,
  _FakeSubmitSurveyNetwork submit,
) {
  final container = ProviderContainer(
    overrides: [
      submitSurveyRepositoryProvider.overrideWithValue(
        SubmitSurveyRepository(network: submit),
      ),
      connectionRequestNetworkProvider.overrideWithValue(network),
      dashboardNetworkProvider.overrideWithValue(dashboard),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

/// Polls until [condition] holds (invalidation refetches asynchronously).
Future<void> _waitFor(bool Function() condition) async {
  for (var i = 0; i < 50 && !condition(); i++) {
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  expect(condition(), isTrue);
}

void main() {
  group('refreshAfterStageSubmit (D24)', () {
    test('a survey submit refetches the lists, the detail and the dashboard',
        () async {
      final network = _CountingConnectionRequestNetwork();
      final dashboard = _CountingDashboardNetwork();
      final submit = _FakeSubmitSurveyNetwork();
      final container = _container(network, dashboard, submit);

      // Keep the providers alive so invalidation triggers a refetch.
      container.listen(connectionRequestsProvider(1), (_, _) {});
      container.listen(connectionRequestDetailProvider('101'), (_, _) {});
      container.listen(installationRequestsProvider(1), (_, _) {});
      container.listen(dashboardSummaryProvider, (_, _) {});
      await container.read(connectionRequestsProvider(1).future);
      await container.read(connectionRequestDetailProvider('101').future);
      await container.read(installationRequestsProvider(1).future);
      await container.read(dashboardSummaryProvider.future);
      final pageCalls = network.fetchPageCalls;
      final detailCalls = network.fetchDetailCalls;
      final dashboardCalls = dashboard.calls;

      final controller =
          container.read(submitSurveyControllerProvider.notifier);
      final result = await controller.submit(
        id: '101',
        feasibilityStatus: 'feasible',
        notes: 'All good',
      );
      expect(result, isNotNull);

      // Every invalidated provider refetches on its own.
      await _waitFor(() => network.fetchPageCalls > pageCalls);
      await _waitFor(() => network.fetchDetailCalls > detailCalls);
      await _waitFor(() => dashboard.calls > dashboardCalls);
    });

    test('direct call refetches every queue and every detail', () async {
      final network = _CountingConnectionRequestNetwork();
      final dashboard = _CountingDashboardNetwork();
      final submit = _FakeSubmitSurveyNetwork();
      var splicingDetailBuilds = 0;
      var verificationDetailBuilds = 0;
      var closingDetailBuilds = 0;
      final container = ProviderContainer(
        overrides: [
          submitSurveyRepositoryProvider.overrideWithValue(
            SubmitSurveyRepository(network: submit),
          ),
          connectionRequestNetworkProvider.overrideWithValue(network),
          dashboardNetworkProvider.overrideWithValue(dashboard),
          splicingDetailProvider('101').overrideWith((ref) async {
            splicingDetailBuilds++;
            return SplicingDetail.fromJson(_stageDetailJson());
          }),
          verificationDetailProvider('101').overrideWith((ref) async {
            verificationDetailBuilds++;
            return TeamStageDetail.fromJson(_stageDetailJson());
          }),
          closingDetailProvider('101').overrideWith((ref) async {
            closingDetailBuilds++;
            return TeamStageDetail.fromJson(_stageDetailJson());
          }),
        ],
      );
      addTearDown(container.dispose);

      container.listen(connectionRequestsProvider(1), (_, _) {});
      container.listen(installationRequestsProvider(1), (_, _) {});
      container.listen(splicingRequestsProvider(1), (_, _) {});
      container.listen(verificationRequestsProvider(1), (_, _) {});
      container.listen(closingRequestsProvider(1), (_, _) {});
      container.listen(connectionRequestDetailProvider('101'), (_, _) {});
      container.listen(splicingDetailProvider('101'), (_, _) {});
      container.listen(verificationDetailProvider('101'), (_, _) {});
      container.listen(closingDetailProvider('101'), (_, _) {});
      container.listen(dashboardSummaryProvider, (_, _) {});
      await container.read(connectionRequestsProvider(1).future);
      await container.read(installationRequestsProvider(1).future);
      await container.read(splicingRequestsProvider(1).future);
      await container.read(verificationRequestsProvider(1).future);
      await container.read(closingRequestsProvider(1).future);
      await container.read(connectionRequestDetailProvider('101').future);
      await container.read(splicingDetailProvider('101').future);
      await container.read(verificationDetailProvider('101').future);
      await container.read(closingDetailProvider('101').future);
      await container.read(dashboardSummaryProvider.future);
      final pageCalls = network.fetchPageCalls;
      final detailCalls = network.fetchDetailCalls;
      final dashboardCalls = dashboard.calls;

      refreshAfterStageSubmit(container.invalidate, '101');

      // All five queues refetch exactly once each.
      await _waitFor(() => network.fetchPageCalls == pageCalls + 5);
      await _waitFor(() => network.fetchDetailCalls > detailCalls);
      await _waitFor(() => dashboard.calls > dashboardCalls);
      await _waitFor(() => splicingDetailBuilds > 1);
      await _waitFor(() => verificationDetailBuilds > 1);
      await _waitFor(() => closingDetailBuilds > 1);
    });
  });
}
