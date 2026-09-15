import 'dart:io';

import '../../../core/constants/app_constants.dart';
import '../../../models/splicing.dart';
import '../../survey/data/submit_survey_repository.dart'
    show UnsupportedVoiceNoteException, VoiceNoteTooLargeException;
import 'splicing_network.dart';

class SplicingRepository {
  SplicingRepository({required this.network});
  final SplicingNetwork network;

  Future<SplicingDetail> fetchDetail(String id) async =>
      SplicingDetail.fromJson(await network.fetchDetail(id));

  Future<CompleteSplicingResponse> complete({
    required String id,
    String? voiceNotePath,
    String? voiceNoteMimeType,
  }) async {
    var mime = voiceNoteMimeType;
    if (voiceNotePath != null) {
      final size = await File(voiceNotePath).length();
      if (size > maxVoiceNoteBytes) throw VoiceNoteTooLargeException(size);
      mime ??= _mimeForPath(voiceNotePath);
      if (!allowedVoiceNoteMimeTypes.contains(mime)) {
        throw UnsupportedVoiceNoteException(mime);
      }
    }
    return CompleteSplicingResponse.fromJson(await network.completeSplicingMultipart(
      id,
      voiceNotePath: voiceNotePath,
      voiceNoteMimeType: mime,
    ));
  }

  static String _mimeForPath(String path) => switch (path.toLowerCase().split('.').last) {
        'm4a' || 'mp4' || 'aac' => 'audio/mp4',
        'webm' => 'audio/webm',
        'wav' => 'audio/x-wav',
        'ogg' || 'opus' => 'audio/ogg',
        _ => 'application/octet-stream',
      };
}
