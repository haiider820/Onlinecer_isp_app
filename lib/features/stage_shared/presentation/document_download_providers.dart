import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/providers.dart';
import '../data/document_download.dart';

/// Authenticated document downloader (guide §21) for the detail screens.
final documentDownloaderProvider = Provider<DocumentDownloader>((ref) {
  return DocumentDownloader(ref.watch(apiClientProvider));
});
