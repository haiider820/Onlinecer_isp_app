import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';

/// Minimal seam over the HTTP layer that [SubmitSurveyRepository] depends on,
/// so the submission flow is unit-testable without a real server.
abstract interface class SubmitSurveyNetwork {
  /// Plain-JSON call: `POST .../complete-survey` with `{ survey_notes,
  /// survey_feasibility_status, survey_not_feasible_reason? }`.
  ///
  /// The backend requires `survey_feasibility_status` (`"feasible"` /
  /// `"not_feasible"`) on every complete-survey (D14 — a normal submit
  /// without it 422s with "The survey feasibility status field is
  /// required."). When the value is `"not_feasible"` a reason is required
  /// too (`survey_not_feasible_reason`); the reason is never sent when the
  /// site is feasible. `requested_items` is never sent by this client —
  /// the backend confirmed it is optional, and a review must not re-request
  /// items (that would send the request back to `inventory_pending` for a
  /// second round).
  Future<Map<String, dynamic>> completeSurveyJson(
    String id, {
    String? notes,
    String? feasibilityStatus,
    String? notFeasibleReason,
  });

  /// Multipart call with a voice note attached:
  /// `survey_notes` (string) + `survey_feasibility_status` (when given) +
  /// `survey_not_feasible_reason` (only when not feasible) + `voice_note`
  /// (audio file).
  Future<Map<String, dynamic>> completeSurveyMultipart(
    String id, {
    String? notes,
    String? feasibilityStatus,
    String? notFeasibleReason,
    required String voiceNotePath,
    required String voiceNoteMimeType,
  });
}

/// Real HTTP-backed implementation for the submit-survey flow.
class DioSubmitSurveyNetwork implements SubmitSurveyNetwork {
  DioSubmitSurveyNetwork(this._client);

  final ApiClient _client;

  @override
  Future<Map<String, dynamic>> completeSurveyJson(
    String id, {
    String? notes,
    String? feasibilityStatus,
    String? notFeasibleReason,
  }) {
    return _client.postMap(
      Endpoints.completeSurvey(id),
      data: {
        if (notes != null && notes.isNotEmpty) 'survey_notes': notes,
        if (feasibilityStatus != null)
          'survey_feasibility_status': feasibilityStatus,
        if (feasibilityStatus == 'not_feasible' &&
            notFeasibleReason != null &&
            notFeasibleReason.isNotEmpty)
          'survey_not_feasible_reason': notFeasibleReason,
      },
    );
  }

  @override
  Future<Map<String, dynamic>> completeSurveyMultipart(
    String id, {
    String? notes,
    String? feasibilityStatus,
    String? notFeasibleReason,
    required String voiceNotePath,
    required String voiceNoteMimeType,
  }) {
    final form = FormData.fromMap({
      if (notes != null && notes.isNotEmpty) 'survey_notes': notes,
      if (feasibilityStatus != null)
        'survey_feasibility_status': feasibilityStatus,
      if (feasibilityStatus == 'not_feasible' &&
          notFeasibleReason != null &&
          notFeasibleReason.isNotEmpty)
        'survey_not_feasible_reason': notFeasibleReason,
      'voice_note': MultipartFile.fromFileSync(
        voiceNotePath,
        contentType: MediaType.parse(voiceNoteMimeType),
      ),
    });
    return _client.postMultipart(Endpoints.completeSurvey(id), data: form);
  }
}