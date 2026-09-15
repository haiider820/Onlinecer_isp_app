import 'dart:io';

import '../../../core/constants/app_constants.dart';
import '../../../models/survey_submission.dart';
import 'submit_survey_network.dart';

/// Thrown when the recorded voice note exceeds the backend's 10 MB limit.
class VoiceNoteTooLargeException implements Exception {
  const VoiceNoteTooLargeException(this.sizeBytes);

  final int sizeBytes;

  @override
  String toString() => 'Voice note exceeds 10 MB limit ($sizeBytes bytes).';
}

/// Thrown when a voice note is provided whose MIME type the backend does not
/// accept (see [allowedVoiceNoteMimeTypes]).
class UnsupportedVoiceNoteException implements Exception {
  const UnsupportedVoiceNoteException(this.mimeType);

  final String mimeType;

  @override
  String toString() => 'Unsupported voice note type: $mimeType';
}

/// Submits completed survey work to `POST .../complete-survey`.
///
/// The endpoint takes two shapes (plain JSON vs multipart) depending on
/// whether a voice note is attached; the branch lives here so the UI only
/// calls a single [submit] method.
class SubmitSurveyRepository {
  SubmitSurveyRepository({required this.network});

  final SubmitSurveyNetwork network;

  /// Completes the survey for [id].
  ///
  /// When [voiceNotePath] is non-null the payload is sent as
  /// `multipart/form-data` (and [voiceNoteMimeType] must be one of
  /// [allowedVoiceNoteMimeTypes]); otherwise plain JSON. Both paths are
  /// covered by dedicated tests.
  Future<CompleteSurveyResponse> submit({
    required String id,
    String? notes,
    String? voiceNotePath,
    String? voiceNoteMimeType,
  }) async {
    if (voiceNotePath != null) {
      final size = await File(voiceNotePath).length();
      if (size > maxVoiceNoteBytes) {
        throw VoiceNoteTooLargeException(size);
      }
      final mime = voiceNoteMimeType ?? _mimeTypeForExtension(voiceNotePath);
      if (!allowedVoiceNoteMimeTypes.contains(mime)) {
        throw UnsupportedVoiceNoteException(mime);
      }
      final map = await network.completeSurveyMultipart(
        id,
        notes: notes,
        voiceNotePath: voiceNotePath,
        voiceNoteMimeType: mime,
      );
      return CompleteSurveyResponse.fromJson(map);
    }

    final map = await network.completeSurveyJson(id, notes: notes);
    return CompleteSurveyResponse.fromJson(map);
  }

  /// Maps a file extension to a backend-accepted MIME type, based on the
  /// formats the `record` package produces.
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