import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';

/// Minimal seam over the HTTP layer that [VoiceNoteRepository] depends on,
/// so the follow-up upload is unit-testable without a real server.
abstract interface class VoiceNoteNetwork {
  /// `POST /connection-requests/{request}/voice-note` (guide §20):
  /// multipart, single `voice_note` field (required, max 10 MB).
  Future<Map<String, dynamic>> uploadVoiceNote(
    String requestId, {
    required String path,
    required String mimeType,
  });
}

/// Real HTTP-backed implementation (guide §20).
///
/// The request rides the authenticated [ApiClient], so the bearer token is
/// attached by the interceptor — never fetched or sent without auth.
class DioVoiceNoteNetwork implements VoiceNoteNetwork {
  DioVoiceNoteNetwork(this._client);

  final ApiClient _client;

  @override
  Future<Map<String, dynamic>> uploadVoiceNote(
    String requestId, {
    required String path,
    required String mimeType,
  }) {
    return _client.postMultipart(
      Endpoints.requestVoiceNote(requestId),
      data: FormData.fromMap({
        'voice_note': MultipartFile.fromFileSync(
          path,
          contentType: MediaType.parse(mimeType),
        ),
      }),
    );
  }
}
