import 'dart:io';

import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_exceptions.dart';
import 'voice_note_network.dart';

/// Best-effort follow-up upload of a voice note captured for a stage
/// completion, via the standalone `POST .../voice-note` endpoint
/// (guide §20).
///
/// The guide warns "do not assume stage completion saves a voice note" and
/// the stage bodies do not list `voice_note` — so after a stage completion
/// succeeds, the recording is uploaded separately here. The stage itself is
/// already complete on the server before this runs: a failure here NEVER
/// fails or rolls back the stage, it only produces a user-facing warning.
///
/// Upload-once rule: each recording is attempted at most once per app
/// session (keyed `requestId|path`, marked BEFORE the upload starts), so
/// a retry can never double-send the same recording.
class VoiceNoteRepository {
  VoiceNoteRepository({required this.network});

  final VoiceNoteNetwork network;

  /// Recording paths already attempted this session.
  final Set<String> _attempted = {};

  /// Uploads [voiceNotePath] for [requestId] as a best-effort follow-up.
  ///
  /// Returns `null` when the note was uploaded, or when there was nothing
  /// to upload (no recording, or this recording was already attempted).
  /// Returns a user-facing warning when the upload failed or the file was
  /// invalid. NEVER throws.
  Future<String?> uploadBestEffort({
    required String requestId,
    required String? voiceNotePath,
    String? voiceNoteMimeType,
  }) async {
    if (voiceNotePath == null || voiceNotePath.isEmpty) return null;
    final key = '$requestId|$voiceNotePath';
    if (_attempted.contains(key)) return null;
    _attempted.add(key);
    try {
      final size = await File(voiceNotePath).length();
      if (size > maxVoiceNoteBytes) {
        return 'Stage saved, but the voice note was not uploaded (larger than 10 MB).';
      }
      final mime = voiceNoteMimeType ?? _mimeTypeForExtension(voiceNotePath);
      if (!allowedVoiceNoteMimeTypes.contains(mime)) {
        return 'Stage saved, but the voice note was not uploaded (unsupported audio type).';
      }
      await network.uploadVoiceNote(
        requestId,
        path: voiceNotePath,
        mimeType: mime,
      );
      return null;
    } on ApiException catch (e) {
      return 'Stage saved, but the voice note could not be uploaded: ${e.message}';
    } on Exception {
      return 'Stage saved, but the voice note could not be uploaded.';
    }
  }

  /// Maps a file extension to a backend-accepted MIME type, based on the
  /// formats the `record` package produces (same mapping as the stage
  /// repositories).
  static String _mimeTypeForExtension(String path) {
    final ext = path.toLowerCase().split('.').last;
    return switch (ext) {
      'm4a' || 'mp4' => 'audio/mp4',
      'webm' => 'audio/webm',
      'wav' => 'audio/x-wav',
      'ogg' || 'opus' => 'audio/ogg',
      'aac' => 'audio/mp4',
      _ => 'application/octet-stream',
    };
  }
}
