import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isp_onlinecer/core/network/api_client.dart';
import 'package:isp_onlinecer/features/stage_shared/data/document_download.dart';
import 'package:isp_onlinecer/features/stage_shared/models/team_stage_detail.dart';
import 'package:isp_onlinecer/features/stage_shared/presentation/document_download_providers.dart';
import 'package:isp_onlinecer/features/stage_shared/presentation/team_stage_detail_sections.dart';

import '../ispfinal_adversarial/helpers.dart';

/// D19 (guide §21): document rows on the detail screen download through
/// the AUTHENTICATED client (bearer <redacted> on the request) and open with
/// the system viewer. No unauthenticated fetch path exists — `downloadBytes`
/// on the ApiClient is the only fetch.
Future<ApiClient> _authenticatedClient({
  required String token,
  required void Function(RequestOptions options) onRequest,
}) async {
  final backing = InMemoryFlutterSecureStorage();
  final storage = freshStorage(backing);
  await storage.saveSession(
    token: token,
    tokenType: 'Bearer',
    expiresAt: null,
    employeeId: 'emp-1',
    employeeName: 'Test Employee',
    employeeEmail: null,
    functionalTeamType: 'survey',
    teamName: 'Survey Team',
  );
  final client = ApiClient(storage: storage);
  client.dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        onRequest(options);
        handler.resolve(
          Response<List<int>>(
            requestOptions: options,
            statusCode: 200,
            data: [1, 2, 3],
          ),
        );
      },
    ),
  );
  return client;
}

class _RecordingDownloader extends DocumentDownloader {
  _RecordingDownloader(super.client);

  final List<TeamStageDocument> downloads = [];

  @override
  Future<DocumentDownloadResult> download(TeamStageDocument document) async {
    downloads.add(document);
    return const DocumentDownloadResult(savedPath: '/tmp/id-card.pdf', opened: true);
  }
}

TeamStageDetail _detailWithDocument() => TeamStageDetail.fromJson({
      'data': {
        'id': 'req-1',
        'request_number': 'CRQ-20261125-TEST',
        'status': 'verification_assigned',
        'documents': {
          'id_card_front_url': 'https://ttsn.onlinecer.com/api/mobile/documents/1',
        },
      },
      'allowed_action': 'complete_verification',
    });

void main() {
  group('ApiClient.downloadBytes (authenticated document fetch)', () {
    test('sends the bearer token and returns the bytes', () async {
      RequestOptions? captured;
      final client = await _authenticatedClient(
        token: 'test-token-1',
        onRequest: (options) => captured = options,
      );

      final bytes = await client.downloadBytes(
        'https://ttsn.onlinecer.com/api/mobile/documents/1',
      );

      expect(bytes, [1, 2, 3]);
      expect(captured, isNotNull);
      expect(captured!.headers['Authorization'], 'Bearer test-token-1');
      // The document URL is used exactly as the detail payload returned it.
      expect(captured!.uri.toString(),
          'https://ttsn.onlinecer.com/api/mobile/documents/1');
    });

    test('no token means no Authorization header (never a fake one)', () async {
      RequestOptions? captured;
      final backing = InMemoryFlutterSecureStorage();
      final client = ApiClient(storage: freshStorage(backing));
      client.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            captured = options;
            handler.resolve(
              Response<List<int>>(
                requestOptions: options,
                statusCode: 200,
                data: [9],
              ),
            );
          },
        ),
      );

      await client.downloadBytes('https://example.invalid/doc.pdf');
      expect(captured!.headers.containsKey('Authorization'), isFalse);
    });
  });

  group('DocumentDownloader.fetchBytes', () {
    test('goes through the authenticated client', () async {
      RequestOptions? captured;
      final client = await _authenticatedClient(
        token: 'test-token-1',
        onRequest: (options) => captured = options,
      );
      final downloader = DocumentDownloader(client);

      final bytes = await downloader.fetchBytes(
        'https://ttsn.onlinecer.com/api/mobile/documents/1',
      );

      expect(bytes, [1, 2, 3]);
      expect(captured!.headers['Authorization'], 'Bearer test-token-1');
    });
  });

  group('TeamStageDetailSections document row tap', () {
    testWidgets('tapping a document row downloads it via the provider',
        (tester) async {
      final backing = InMemoryFlutterSecureStorage();
      final client = ApiClient(storage: freshStorage(backing));
      final downloader = _RecordingDownloader(client);
      final detail = _detailWithDocument();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            documentDownloaderProvider.overrideWithValue(downloader),
          ],
          child: MaterialApp(
            home: Scaffold(body: TeamStageDetailSections(detail: detail)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Documents'), findsOneWidget);
      expect(find.text('id card front'), findsOneWidget);

      await tester.tap(find.text('id card front'));
      await tester.pumpAndSettle();

      expect(downloader.downloads, hasLength(1));
      expect(downloader.downloads.single.url,
          'https://ttsn.onlinecer.com/api/mobile/documents/1');
      expect(find.text('Document downloaded.'), findsOneWidget);
    });
  });
}
