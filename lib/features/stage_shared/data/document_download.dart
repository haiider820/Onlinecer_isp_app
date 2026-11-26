import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exceptions.dart';
import '../models/team_stage_detail.dart';

/// Outcome of one document download attempt.
class DocumentDownloadResult {
  const DocumentDownloadResult({
    required this.savedPath,
    required this.opened,
  });

  /// Local temp path the file was saved to.
  final String savedPath;

  /// Whether a viewer app opened the file.
  final bool opened;
}

class DocumentDownloadException implements Exception {
  const DocumentDownloadException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Authenticated document download (guide §21).
///
/// The URL comes from the detail payload's `data.documents` (the exact URL,
/// never constructed client-side). The bytes are fetched through the
/// authenticated [ApiClient] — the bearer token rides the interceptor, so
/// the file is never fetched without auth — saved to the app temp dir
/// (never a public cache), then opened with the system viewer via
/// url_launcher. When no viewer can open the file the download still counts
/// as saved and the caller shows the path instead of failing.
class DocumentDownloader {
  DocumentDownloader(this._client);

  final ApiClient _client;

  /// Fetches the raw bytes for [url] through the authenticated client.
  /// Kept separate so tests can assert the auth header without touching
  /// the filesystem.
  Future<List<int>> fetchBytes(String url) => _client.downloadBytes(url);

  /// Downloads [document] and opens it with the system viewer.
  ///
  /// Throws [DocumentDownloadException] when the URL is missing or the
  /// download fails. A file that downloads but cannot be opened returns
  /// `opened: false` with the saved path — never an exception.
  Future<DocumentDownloadResult> download(TeamStageDocument document) async {
    final url = document.url;
    if (url == null || url.isEmpty) {
      throw const DocumentDownloadException('Document is unavailable.');
    }
    late final List<int> bytes;
    try {
      bytes = await fetchBytes(url);
    } on ApiException catch (e) {
      throw DocumentDownloadException(e.message);
    }
    final dir = await getTemporaryDirectory();
    final name = _fileName(document, url);
    final file = File('${dir.path}/$name');
    await file.writeAsBytes(bytes, flush: true);
    final opened = await _open(file.path);
    return DocumentDownloadResult(savedPath: file.path, opened: opened);
  }

  Future<bool> _open(String path) async {
    try {
      return await launchUrl(
        Uri.file(path),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      return false;
    }
  }

  static String _fileName(TeamStageDocument document, String url) {
    final raw = (document.name ?? document.type ?? 'document')
        .replaceAll(RegExp(r'[^A-Za-z0-9._-]+'), '_');
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final ext = _extension(url);
    final base = raw.isEmpty ? 'document' : raw;
    return '${stamp}_$base$ext';
  }

  static String _extension(String url) {
    final clean = url.split('?').first;
    final dot = clean.lastIndexOf('.');
    final slash = clean.lastIndexOf('/');
    if (dot <= slash || dot == clean.length - 1) return '';
    final ext = clean.substring(dot);
    return RegExp(r'^\.[A-Za-z0-9]{1,5}$').hasMatch(ext) ? ext : '';
  }
}
