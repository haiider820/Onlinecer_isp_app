import 'dart:io';

import '../../../core/constants/app_constants.dart';
import '../../survey/data/submit_survey_repository.dart'
    show UnsupportedVoiceNoteException, VoiceNoteTooLargeException;
import '../team_stage_config.dart';
import 'team_stage_completion_network.dart';

/// Shared JSON/multipart branching used by both future stage screens.
class TeamStageCompletionRepository {
  TeamStageCompletionRepository({required this.network});
  final TeamStageCompletionNetwork network;

  Future<TeamStageCompletionResult> submit({
    required TeamStageConfig config,
    required String requestId,
    String? notes,
    String? voiceNotePath,
    String? voiceNoteMimeType,
  }) async {
    if (voiceNotePath == null) {
      return TeamStageCompletionResult.fromJson(await network.postJson(config, requestId, notes: notes));
    }

    final size = await File(voiceNotePath).length();
    if (size > maxVoiceNoteBytes) throw VoiceNoteTooLargeException(size);
    final mime = voiceNoteMimeType ?? _mimeForPath(voiceNotePath);
    if (!allowedVoiceNoteMimeTypes.contains(mime)) throw UnsupportedVoiceNoteException(mime);
    return TeamStageCompletionResult.fromJson(await network.postMultipart(
      config, requestId, notes: notes, voiceNotePath: voiceNotePath, voiceNoteMimeType: mime));
  }

  static String _mimeForPath(String path) => switch (path.toLowerCase().split('.').last) {
    'm4a' || 'mp4' || 'aac' => 'audio/mp4',
    'webm' => 'audio/webm',
    'wav' => 'audio/x-wav',
    'ogg' || 'opus' => 'audio/ogg',
    _ => 'application/octet-stream',
  };
}

/// Terminal Closing completion legitimately has a null [currentTeam].
class TeamStageCompletionResult {
  const TeamStageCompletionResult({this.message, this.id, this.status, this.currentTeam});
  final String? message;
  final String? id;
  final String? status;
  final Map<String, dynamic>? currentTeam;
  factory TeamStageCompletionResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map ? Map<String, dynamic>.from(json['data'] as Map) : const <String, dynamic>{};
    return TeamStageCompletionResult(
      message: json['message']?.toString(), id: data['id']?.toString(), status: data['status']?.toString(),
      currentTeam: data['current_team'] is Map ? Map<String, dynamic>.from(data['current_team'] as Map) : null);
  }
}
