import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isp_onlinecer/features/voice_notes/data/voice_note_network.dart';
import 'package:isp_onlinecer/features/voice_notes/data/voice_note_repository.dart';

/// D19 (guide §20): after a stage completion succeeds, the captured voice
/// note is uploaded separately via `POST .../voice-note` as a best-effort
/// follow-up. It must never fail the stage, never throw, and never
/// double-send the same recording.
class _FakeVoiceNoteNetwork implements VoiceNoteNetwork {
  int calls = 0;
  String? lastRequestId;
  String? lastPath;
  String? lastMime;
  Exception? error;

  @override
  Future<Map<String, dynamic>> uploadVoiceNote(
    String requestId, {
    required String path,
    required String mimeType,
  }) async {
    calls++;
    lastRequestId = requestId;
    lastPath = path;
    lastMime = mimeType;
    if (error != null) throw error!;
    return const {'message': 'Voice note saved.'};
  }
}

Future<String> _recording(Directory dir, String name, {int bytes = 100}) async {
  final file = File('${dir.path}/$name');
  await file.writeAsBytes(List<int>.filled(bytes, 1));
  return file.path;
}

void main() {
  group('VoiceNoteRepository.uploadBestEffort', () {
    late Directory dir;
    setUp(() async {
      dir = await Directory.systemTemp.createTemp('voice_note');
    });
    tearDown(() => dir.delete(recursive: true));

    test('uploads once with the request id, path and mime', () async {
      final network = _FakeVoiceNoteNetwork();
      final repository = VoiceNoteRepository(network: network);
      final path = await _recording(dir, 'note.m4a');

      final warning = await repository.uploadBestEffort(
        requestId: 'req-1',
        voiceNotePath: path,
        voiceNoteMimeType: 'audio/mp4',
      );

      expect(warning, isNull);
      expect(network.calls, 1);
      expect(network.lastRequestId, 'req-1');
      expect(network.lastPath, path);
      expect(network.lastMime, 'audio/mp4');
    });

    test('no recording is a no-op (no network call)', () async {
      final network = _FakeVoiceNoteNetwork();
      final repository = VoiceNoteRepository(network: network);

      expect(
        await repository.uploadBestEffort(requestId: 'req-1', voiceNotePath: null),
        isNull,
      );
      expect(
        await repository.uploadBestEffort(requestId: 'req-1', voiceNotePath: ''),
        isNull,
      );
      expect(network.calls, 0);
    });

    test('the same recording is never sent twice (retry-safe)', () async {
      final network = _FakeVoiceNoteNetwork();
      final repository = VoiceNoteRepository(network: network);
      final path = await _recording(dir, 'note.m4a');

      expect(
        await repository.uploadBestEffort(requestId: 'req-1', voiceNotePath: path),
        isNull,
      );
      // Same recording, same request: second attempt is a no-op.
      expect(
        await repository.uploadBestEffort(requestId: 'req-1', voiceNotePath: path),
        isNull,
      );
      expect(network.calls, 1);

      // Same file for a different request is a different upload.
      expect(
        await repository.uploadBestEffort(requestId: 'req-2', voiceNotePath: path),
        isNull,
      );
      expect(network.calls, 2);
    });

    test('a failed first attempt is not re-sent either', () async {
      final network = _FakeVoiceNoteNetwork()..error = Exception('offline');
      final repository = VoiceNoteRepository(network: network);
      final path = await _recording(dir, 'note.m4a');

      final warning = await repository.uploadBestEffort(
        requestId: 'req-1',
        voiceNotePath: path,
      );
      expect(warning, isNotNull);
      expect(warning, contains('Stage saved'));
      expect(network.calls, 1);

      // The retry never double-sends, even though the first attempt failed.
      network.error = null;
      expect(
        await repository.uploadBestEffort(requestId: 'req-1', voiceNotePath: path),
        isNull,
      );
      expect(network.calls, 1);
    });

    test('network failure returns a warning, never throws', () async {
      final network = _FakeVoiceNoteNetwork()..error = Exception('server error');
      final repository = VoiceNoteRepository(network: network);
      final path = await _recording(dir, 'note.m4a');

      final warning = await repository.uploadBestEffort(
        requestId: 'req-1',
        voiceNotePath: path,
      );

      expect(warning, isNotNull);
      expect(warning, contains('Stage saved'));
      expect(warning, contains('could not be uploaded'));
    });

    test('oversize recording is rejected without a network call', () async {
      final network = _FakeVoiceNoteNetwork();
      final repository = VoiceNoteRepository(network: network);
      final path = await _recording(dir, 'big.m4a', bytes: 10 * 1024 * 1024 + 1);

      final warning = await repository.uploadBestEffort(
        requestId: 'req-1',
        voiceNotePath: path,
      );

      expect(warning, contains('larger than 10 MB'));
      expect(network.calls, 0);
    });

    test('unsupported MIME is rejected without a network call', () async {
      final network = _FakeVoiceNoteNetwork();
      final repository = VoiceNoteRepository(network: network);
      final path = await _recording(dir, 'note.xyz');

      final warning = await repository.uploadBestEffort(
        requestId: 'req-1',
        voiceNotePath: path,
        voiceNoteMimeType: 'audio/xyz',
      );

      expect(warning, contains('unsupported audio type'));
      expect(network.calls, 0);
    });

    test('missing file returns a warning, never throws', () async {
      final network = _FakeVoiceNoteNetwork();
      final repository = VoiceNoteRepository(network: network);

      final warning = await repository.uploadBestEffort(
        requestId: 'req-1',
        voiceNotePath: '${dir.path}/gone.m4a',
      );

      expect(warning, isNotNull);
      expect(warning, contains('Stage saved'));
      expect(network.calls, 0);
    });

    test('mime is derived from the extension when not given', () async {
      final network = _FakeVoiceNoteNetwork();
      final repository = VoiceNoteRepository(network: network);
      final path = await _recording(dir, 'note.m4a');

      expect(
        await repository.uploadBestEffort(requestId: 'req-1', voiceNotePath: path),
        isNull,
      );
      expect(network.lastMime, 'audio/mp4');
    });
  });
}
