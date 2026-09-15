import 'package:flutter_test/flutter_test.dart';
import 'package:isp_onlinecer/features/splicing/data/splicing_network.dart';
import 'package:isp_onlinecer/features/splicing/data/splicing_repository.dart';

class _FakeSplicingNetwork implements SplicingNetwork {
  String? completedId;
  String? voicePath;

  @override
  Future<Map<String, dynamic>> fetchDetail(String id) async => {
        'allowed_action': 'complete_splicing',
        'data': {
          'id': id,
          'request_number': 'CR-101',
          'status': 'splicing_assigned',
          'connection_fat_node': {'id': 'fat-1', 'name': 'FAT North'},
          'splicer': {'id': 'emp-2', 'name': 'Bilal Khan'},
          'installation_latitude': 33.6844,
          'installation_longitude': 73.0479,
          'notes': [
            {'type': 'installation', 'note': 'ONT installed', 'voice_note_url': 'https://example.test/note.m4a'},
          ],
        },
      };

  @override
  Future<Map<String, dynamic>> completeSplicingMultipart(
    String id, {
    String? voiceNotePath,
    String? voiceNoteMimeType,
  }) async {
    completedId = id;
    voicePath = voiceNotePath;
    return {'message': 'Splicing completed.', 'data': {'status': 'verification_assigned', 'spliced_at': '2026-09-12T12:00:00Z'}};
  }
}

void main() {
  test('splicing detail gates completion and completes with an empty multipart payload', () async {
    final network = _FakeSplicingNetwork();
    final repository = SplicingRepository(network: network);

    final detail = await repository.fetchDetail('request-1');
    expect(detail.canComplete, isTrue);
    expect(detail.connectionFatNode?.name, 'FAT North');
    expect(detail.splicer?.name, 'Bilal Khan');
    expect(detail.installationLatitude, 33.6844);
    expect(detail.notes.single.voiceNoteUrl, 'https://example.test/note.m4a');

    final result = await repository.complete(id: detail.id);
    expect(network.completedId, 'request-1');
    expect(network.voicePath, isNull);
    expect(result.status, 'verification_assigned');
    expect(result.splicedAt, '2026-09-12T12:00:00Z');
  });
}
