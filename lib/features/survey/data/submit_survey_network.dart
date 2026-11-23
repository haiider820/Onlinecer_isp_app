import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';

/// Minimal seam over the HTTP layer that [SubmitSurveyRepository] depends on,
/// so the submission flow is unit-testable without a real server.
abstract interface class SubmitSurveyNetwork {
  /// Plain-JSON call: `POST .../complete-survey` with `{ survey_notes,
  /// survey_feasibility_status? }`.
  ///
  /// [feasibilityStatus] is sent only for the survey-review case
  /// (`survey_review` + `review_survey`): the backend requires
  /// `survey_feasibility_status: "feasible"` there. A normal survey submit
  /// omits it. `requested_items` is never sent by this client — a review
  /// must not re-request items (that would send the request back to
  /// `inventory_pending` for a second round).
  Future<Map<String, dynamic>> completeSurveyJson(
    String id, {
    String? notes,
    String? feasibilityStatus,
  });

  /// Multipart call with a voice note attached:
  /// `survey_notes` (string) + `survey_feasibility_status` (when given) +
  /// `voice_note` (audio file).
  Future<Map<String, dynamic>> completeSurveyMultipart(
    String id, {
    String? notes,
    String? feasibilityStatus,
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
  }) {
    return _client.postMap(
      Endpoints.completeSurvey(id),
      data: {
        if (notes != null && notes.isNotEmpty) 'survey_notes': notes,
        if (feasibilityStatus != null)
          'survey_feasibility_status': feasibilityStatus,
      },
    );
  }

  @override
  Future<Map<String, dynamic>> completeSurveyMultipart(
    String id, {
    String? notes,
    String? feasibilityStatus,
    required String voiceNotePath,
    required String voiceNoteMimeType,
  }) {
    final form = FormData.fromMap({
      if (notes != null && notes.isNotEmpty) 'survey_notes': notes,
      if (feasibilityStatus != null)
        'survey_feasibility_status': feasibilityStatus,
      'voice_note': MultipartFile.fromFileSync(
        voiceNotePath,
        contentType: MediaType.parse(voiceNoteMimeType),
      ),
    });
    return _client.postMultipart(Endpoints.completeSurvey(id), data: form);
  }
}