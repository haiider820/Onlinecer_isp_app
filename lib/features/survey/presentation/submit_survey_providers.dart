import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exceptions.dart';
import '../../../models/survey_submission.dart';
import '../../auth/presentation/providers.dart';
import '../data/submit_survey_network.dart';
import '../data/submit_survey_repository.dart';
import 'connection_request_providers.dart';

/// Real HTTP-backed submit-survey network.
final submitSurveyNetworkProvider = Provider<SubmitSurveyNetwork>((ref) {
  return DioSubmitSurveyNetwork(ref.watch(apiClientProvider));
});

/// Submit-survey repository wiring the network layer.
final submitSurveyRepositoryProvider = Provider<SubmitSurveyRepository>((ref) {
  return SubmitSurveyRepository(network: ref.watch(submitSurveyNetworkProvider));
});

/// Immutable submission state exposed to the submit screen.
class SubmitSurveyState {
  const SubmitSurveyState({
    this.isSubmitting = false,
    this.errorMessage,
    this.done,
  });

  final bool isSubmitting;
  final String? errorMessage;
  final CompleteSurveyResponse? done;

  bool get hasError => errorMessage != null;
}

/// Drives the complete-survey submission. Populates [SubmitSurveyState.done]
/// on success so the screen can show the new status and navigate away.
class SubmitSurveyController extends Notifier<SubmitSurveyState> {
  @override
  SubmitSurveyState build() => const SubmitSurveyState();

  /// Submits the survey for [id]. [isReview] marks the survey-review case
  /// (request came back from Inventory, `survey_review` / `review_survey`):
  /// the confirm POST carries `survey_feasibility_status: "feasible"` and
  /// never re-sends `requested_items`. A normal submit passes nothing extra.
  Future<CompleteSurveyResponse?> submit({
    required String id,
    String? notes,
    String? voiceNotePath,
    String? voiceNoteMimeType,
    bool isReview = false,
  }) async {
    state = const SubmitSurveyState(isSubmitting: true);
    try {
      final repo = ref.read(submitSurveyRepositoryProvider);
      final result = await repo.submit(
        id: id,
        notes: notes,
        feasibilityStatus: isReview ? 'feasible' : null,
        voiceNotePath: voiceNotePath,
        voiceNoteMimeType: voiceNoteMimeType,
      );
      state = SubmitSurveyState(done: result);
      // Phase D: refetch detail so the next screen re-derives its stage
      // buttons from fresh `allowed_actions`, never the stale pre-submit one.
      refreshConnectionRequestDetail(ref, id);
      return result;
    } on ApiException catch (e) {
      state = SubmitSurveyState(errorMessage: e.message);
      return null;
    } catch (e) {
      state = SubmitSurveyState(errorMessage: e.toString());
      return null;
    }
  }

  void clearError() {
    state = SubmitSurveyState();
  }
}

final submitSurveyControllerProvider =
    NotifierProvider<SubmitSurveyController, SubmitSurveyState>(
  SubmitSurveyController.new,
);