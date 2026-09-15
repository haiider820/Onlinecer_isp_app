import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

import '../../../core/network/api_client.dart';
import '../team_stage_config.dart';

/// Transport seam for Verification and Closing's identical completion API.
abstract interface class TeamStageCompletionNetwork {
  Future<Map<String, dynamic>> postJson(
    TeamStageConfig config,
    String requestId, {
    String? notes,
  });

  Future<Map<String, dynamic>> postMultipart(
    TeamStageConfig config,
    String requestId, {
    String? notes,
    required String voiceNotePath,
    required String voiceNoteMimeType,
  });
}

class DioTeamStageCompletionNetwork implements TeamStageCompletionNetwork {
  DioTeamStageCompletionNetwork(this._client);
  final ApiClient _client;

  @override
  Future<Map<String, dynamic>> postJson(
    TeamStageConfig config,
    String requestId, {
    String? notes,
  }) => _client.postMap(
    config.completionPathFor(requestId),
    data: {if (notes != null && notes.trim().isNotEmpty) config.notesField: notes.trim()},
  );

  @override
  Future<Map<String, dynamic>> postMultipart(
    TeamStageConfig config,
    String requestId, {
    String? notes,
    required String voiceNotePath,
    required String voiceNoteMimeType,
  }) => _client.postMultipart(
    config.completionPathFor(requestId),
    data: FormData.fromMap({
      if (notes != null && notes.trim().isNotEmpty) config.notesField: notes.trim(),
      'voice_note': MultipartFile.fromFileSync(
        voiceNotePath,
        contentType: MediaType.parse(voiceNoteMimeType),
      ),
    }),
  );
}