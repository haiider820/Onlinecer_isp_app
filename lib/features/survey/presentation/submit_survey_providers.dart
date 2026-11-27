import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exceptions.dart';
import '../../../models/survey_submission.dart';
import '../../auth/presentation/providers.dart';
import '../../voice_notes/presentation/voice_note_providers.dart';
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
    this.voiceNoteWarning,
  });

  final bool isSubmitting;
  final String? errorMessage;
  final CompleteSurveyResponse? done;

  /// Best-effort voice-note follow-up failed after a successful submit
  /// (guide §20): the stage is complete, this is only a warning for the
  /// screen to show alongside the success message. `null` = uploaded (or
  /// no recording was captured).
  final String? voiceNoteWarning;

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
  /// never re-sends `requested_items`.
  ///
  /// A normal submit must carry the surveyor's pick: [feasibilityStatus]
  /// (`"feasible"` / `"not_feasible"`) is required, and [notFeasibleReason]
  /// is required when the pick is `"not_feasible"` — the backend 422s
  /// without them (D14). Both are validated here, before any network call,
  /// so a missing pick never leaves the phone as a failed POST.
  Future<CompleteSurveyResponse?> submit({
    required String id,
    String? notes,
    String? voiceNotePath,
    String? voiceNoteMimeType,
    bool isReview = false,
    String? feasibilityStatus,
    String? notFeasibleReason,
  }) async {
    // D23: a second submit while one is already in flight is a no-op.
    // The button disables on rebuild, but two taps in the same frame —
    // before that rebuild — used to fire two POST .../complete-survey
    // calls. The guard runs before validation so a concurrent call can
    // never reach the network (or a validation error) twice.
    if (state.isSubmitting) return null;
    if (!isReview) {
      if (feasibilityStatus == null || feasibilityStatus.isEmpty) {
        state = const SubmitSurveyState(
          errorMessage: 'Select whether the site is feasible.',
        );
        return null;
      }
      if (feasibilityStatus == 'not_feasible' &&
          (notFeasibleReason == null || notFeasibleReason.trim().isEmpty)) {
        state = const SubmitSurveyState(
          errorMessage: 'Add a reason why the site is not feasible.',
        );
        return null;
      }
    }
    state = const SubmitSurveyState(isSubmitting: true);
    try {
      final repo = ref.read(submitSurveyRepositoryProvider);
      final result = await repo.submit(
        id: id,
        notes: notes,
        feasibilityStatus: isReview ? 'feasible' : feasibilityStatus,
        notFeasibleReason: isReview ? null : notFeasibleReason,
        voiceNotePath: voiceNotePath,
        voiceNoteMimeType: voiceNoteMimeType,
      );
      // Guide §20: stage completion may not save the voice note, so the
      // recording is uploaded separately as a best-effort follow-up. The
      // stage is already complete — a failure here only warns, never
      // fails or rolls back the submit.
      final voiceNoteWarning = await ref
          .read(voiceNoteRepositoryProvider)
          .uploadBestEffort(
            requestId: id,
            voiceNotePath: voiceNotePath,
            voiceNoteMimeType: voiceNoteMimeType,
          );
      state = SubmitSurveyState(done: result, voiceNoteWarning: voiceNoteWarning);
      // D24: refresh detail + every list + dashboard, so the new stage
      // shows with no manual refresh (the old call only refetched the
      // detail, which is why the list kept showing the old phase).
      refreshAfterStageSubmit(ref.invalidate, id);
      return result;
    } on ApiException catch (e) {
      state = SubmitSurveyState(errorMessage: e.message);
      return null;
    } catch (e) {
      // D23: never show raw Dart text (e.g. a SocketException) to the
      // user — a generic failure gets the friendly fallback. ApiException
      // messages (above) are already user-facing and stay as-is.
      state = const SubmitSurveyState(
        errorMessage:
            "Couldn't reach the server. Check your connection and try again.",
      );
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