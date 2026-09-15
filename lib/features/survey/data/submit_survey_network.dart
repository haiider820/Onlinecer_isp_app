import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';

/// Minimal seam over the HTTP layer that [SubmitSurveyRepository] depends on,
/// so the submission flow is unit-testable without a real server.
abstract interface class SubmitSurveyNetwork {
  /// Plain-JSON call: `POST .../complete-survey` with `{ survey_notes }`.
  Future<Map<String, dynamic>> completeSurveyJson(String id, {String? notes});

  /// Multipart call with a voice note attached:
  /// `survey_notes` (string) + `voice_note` (audio file).
  Future<Map<String, dynamic>> completeSurveyMultipart(
    String id, {
    String? notes,
    required String voiceNotePath,
    required String voiceNoteMimeType,
  });
}

/// Real HTTP-backed implementation for the submit-survey flow.
class DioSubmitSurveyNetwork implements SubmitSurveyNetwork {
  DioSubmitSurveyNetwork(this._client);

  final ApiClient _client;

  @override
  Future<Map<String, dynamic>> completeSurveyJson(String id, {String? notes}) {
    return _client.postMap(
      Endpoints.completeSurvey(id),
      data: {if (notes != null && notes.isNotEmpty) 'survey_notes': notes},
    );
  }

  @override
  Future<Map<String, dynamic>> completeSurveyMultipart(
    String id, {
    String? notes,
    required String voiceNotePath,
    required String voiceNoteMimeType,
  }) {
    final form = FormData.fromMap({
      if (notes != null && notes.isNotEmpty) 'survey_notes': notes,
      'voice_note': MultipartFile.fromFileSync(
        voiceNotePath,
        contentType: MediaType.parse(voiceNoteMimeType),
      ),
    });
    return _client.postMultipart(Endpoints.completeSurvey(id), data: form);
  }
}