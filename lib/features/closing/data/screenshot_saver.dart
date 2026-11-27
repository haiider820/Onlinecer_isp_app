import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// Outcome of one screenshot save attempt.
class ScreenshotSaveResult {
  const ScreenshotSaveResult({required this.savedPath, required this.opened});

  /// Local temp path the PNG was saved to.
  final String savedPath;

  /// Whether a viewer app opened the file.
  final bool opened;
}

/// Saves PNG bytes to the app temp dir and opens them with the system viewer
/// — the same save/open pattern D19's document download already uses
/// (`path_provider` + `url_launcher`, both existing dependencies).
///
/// No `share_plus` was added for this: opening the image lets the technician
/// share it onward from the viewer/gallery app, which is the existing way
/// this app hands a file to another app. A file that saves but cannot be
/// opened still counts as saved and the caller shows the path instead of
/// failing.
class ScreenshotSaver {
  const ScreenshotSaver();

  Future<ScreenshotSaveResult> savePng(List<int> bytes, String fileName) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    final opened = await _open(file.path);
    return ScreenshotSaveResult(savedPath: file.path, opened: opened);
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
}
