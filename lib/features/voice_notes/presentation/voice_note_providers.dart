import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/providers.dart';
import '../data/voice_note_network.dart';
import '../data/voice_note_repository.dart';

/// Real HTTP-backed voice-note network.
final voiceNoteNetworkProvider = Provider<VoiceNoteNetwork>((ref) {
  return DioVoiceNoteNetwork(ref.watch(apiClientProvider));
});

/// Voice-note follow-up repository wiring the network layer.
///
/// One instance per container, so the upload-once set in
/// [VoiceNoteRepository] lives for the app session — a recording attempted
/// from any stage is never re-sent from another.
final voiceNoteRepositoryProvider = Provider<VoiceNoteRepository>((ref) {
  return VoiceNoteRepository(network: ref.watch(voiceNoteNetworkProvider));
});
