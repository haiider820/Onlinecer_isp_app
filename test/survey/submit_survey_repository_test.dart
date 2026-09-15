import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isp_onlinecer/features/survey/data/submit_survey_network.dart';
import 'package:isp_onlinecer/features/survey/data/submit_survey_repository.dart';

class _FakeSubmitSurveyNetwork implements SubmitSurveyNetwork {
  _FakeSubmitSurveyNetwork(this.result, {this.error});

  final Map<String, dynamic> result;
  final Exception? error;

  String? lastJsonId;
  String? lastJsonNotes;
  String? lastMultipartId;
  String? lastMultipartNotes;
  String? lastMultipartPath;
  String? lastMultipartMime;

  @override
  Future<Map<String, dynamic>> completeSurveyJson(String id, {String? notes}) async {
    lastJsonId = id;
    lastJsonNotes = notes;
    if (error != null) throw error!;
    return result;
  }

  @override
  Future<Map<String, dynamic>> completeSurveyMultipart(
    String id, {
    String? notes,
    required String voiceNotePath,
    required String voiceNoteMimeType,
  }) async {
    lastMultipartId = id;
    lastMultipartNotes = notes;
    lastMultipartPath = voiceNotePath;
    lastMultipartMime = voiceNoteMimeType;
    if (error != null) throw error!;
    return result;
  }
}

const _successMap = {
  'message': 'Survey marked as completed.',
  'data': {
    'id': '101',
    'request_number': 'CRQ-20260910-ABCD',
    'status': 'installation_assigned',
    'current_team': {'id': 'team_uuid', 'name': 'Installation Team', 'functional_team_type': 'installation'},
    'timestamps': {'surveyed_at': '2026-09-10T11:00:00.000000Z'},
  },
};

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('submit_survey_test');
  });

  tearDown(() => tempDir.deleteSync(recursive: true));

  test('plain JSON branch when no voice note: sends notes, parses new status', () async {
    final network = _FakeSubmitSurveyNetwork(_successMap);
    final repository = SubmitSurveyRepository(network: network);

    final response = await repository.submit(id: '101', notes: 'All good');

    expect(network.lastJsonId, '101');
    expect(network.lastJsonNotes, 'All good');
    expect(network.lastMultipartId, isNull);
    expect(response.message, 'Survey marked as completed.');
    expect(response.data?.status, 'installation_assigned');
    expect(response.data?.currentTeam?.functionalTeamType, 'installation');
  });

  test('multipart branch when a voice note is attached', () async {
    final voice = File('${tempDir.path}/voice.m4a')..writeAsBytesSync(List.filled(1024, 0));
    final network = _FakeSubmitSurveyNetwork(_successMap);
    final repository = SubmitSurveyRepository(network: network);

    await repository.submit(
      id: '101',
      notes: 'With voice',
      voiceNotePath: voice.path,
      voiceNoteMimeType: 'audio/mp4',
    );

    expect(network.lastJsonId, isNull);
    expect(network.lastMultipartId, '101');
    expect(network.lastMultipartPath, voice.path);
    expect(network.lastMultipartMime, 'audio/mp4');
    expect(network.lastMultipartNotes, 'With voice');
  });

  test('infers a whitelisted MIME from the file extension when only path is given', () async {
    final voice = File('${tempDir.path}/voice.m4a')..writeAsBytesSync(List.filled(1024, 0));
    final network = _FakeSubmitSurveyNetwork(_successMap);
    final repository = SubmitSurveyRepository(network: network);

    await repository.submit(id: '101', voiceNotePath: voice.path);

    expect(network.lastMultipartMime, 'audio/mp4');
  });

  test('rejects a voice note whose MIME type is not whitelisted', () async {
    final voice = File('${tempDir.path}/voice.m4a')..writeAsBytesSync(List.filled(1024, 0));
    final network = _FakeSubmitSurveyNetwork(_successMap);
    final repository = SubmitSurveyRepository(network: network);

    expect(
      () => repository.submit(
        id: '101',
        voiceNotePath: voice.path,
        voiceNoteMimeType: 'text/plain',
      ),
      throwsA(isA<UnsupportedVoiceNoteException>()),
    );
    expect(network.lastMultipartId, isNull); // rejected before any network call
  });

  test('rejects a voice note larger than the 10 MB limit', () async {
    // 11 MB of zeros.
    final voice = File('${tempDir.path}/big.m4a')
      ..createSync();
    final csv = String.fromCharCodes(List<int>.filled(1024 * 1024, 0));
    final raf = voice.openSync(mode: FileMode.append);
    for (var i = 0; i < 11; i++) {
      raf.writeStringSync(csv);
      raf.flushSync();
    }
    raf.closeSync();

    final network = _FakeSubmitSurveyNetwork(_successMap);
    final repository = SubmitSurveyRepository(network: network);

    expect(
      () => repository.submit(id: '101', voiceNotePath: voice.path, voiceNoteMimeType: 'audio/mp4'),
      throwsA(isA<VoiceNoteTooLargeException>()),
    );
    expect(network.lastMultipartId, isNull);
  });

  test('propagates network failures to the caller', () async {
    final network = _FakeSubmitSurveyNetwork(
      const {},
      error: Exception('server unreachable'),
    );
    final repository = SubmitSurveyRepository(network: network);

    expect(repository.submit(id: '101'), throwsException);
  });
}