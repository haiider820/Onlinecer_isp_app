import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../core/constants/app_constants.dart';

/// Pure decision for a stopped recording: which error (if any) to report.
///
/// - `null` / missing file → the generic record failure. A missing file is
///   NOT "too large" — the old splicing screen reported exactly that
///   (D21 bug d).
/// - Oversize file → the 10 MB message.
/// - Otherwise `null` (the recording is usable).
String? voiceStopError({
  required String? path,
  required bool exists,
  required int? sizeBytes,
}) {
  if (path == null || !exists) return AppStrings.snackbarRecordFailed;
  if (sizeBytes != null && sizeBytes > maxVoiceNoteBytes) {
    return 'Voice note is too large (max ${maxVoiceNoteBytes ~/ (1024 * 1024)} MB).';
  }
  return null;
}

/// The one voice-note engine for the whole app (D21): recording + playback,
/// replacing the four copy-pasted state machines (survey, installation,
/// splicing, verification/closing completion form).
///
/// Behaviour is the survey screen's, which is the reference pattern:
/// AAC-LC `.m4a` into the temp dir (`<prefix>_<epoch>.m4a`), 1-second
/// ticker, 10 MB cap ([maxVoiceNoteBytes]), no max duration, replace flow =
/// delete then tap the mic again (no re-record button anywhere).
///
/// Playback covers both local files (pre-submit, [playRecording]) and
/// remote URLs (detail Notes rows, [playUrl]). A natural finish resets the
/// play/pause icon via [AudioPlayer.onPlayerComplete] — the old code had
/// zero such subscriptions, so the pause icon stuck after every playback
/// (D21 bug c).
///
/// The owning screen creates the controller in `initState` (passing a
/// `filePrefix` and an [onMessage] that shows snackbars), calls [initMic],
/// rebuilds on [ChangeNotifier] updates (e.g. `addListener` +
/// `setState`), and disposes it in `dispose`. The controller never touches
/// `BuildContext`, so it stays unit-testable.
class VoiceRecorderController extends ChangeNotifier {
  VoiceRecorderController({required this.filePrefix, this.onMessage}) {
    _completionSubscription =
        _player.onPlayerComplete.listen((_) => handlePlaybackComplete());
  }

  /// Temp-file prefix (`survey`, `installation`, `splicing`, `stage`,
  /// `detail`). Only used when recording; playback-only owners pass
  /// anything (e.g. `'detail'`).
  final String filePrefix;

  /// Where user-facing messages go (snackbar text). The owner guards
  /// `mounted` inside its own callback.
  final void Function(String message)? onMessage;

  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  StreamSubscription<void>? _completionSubscription;
  Timer? _ticker;
  bool _disposed = false;

  /// Mic permission resolved (see [micChecked]); false until [initMic] runs.
  bool micPermission = false;

  /// True once the first permission check has resolved. The inline
  /// "permission needed" row renders only after this (never on first paint).
  bool micChecked = false;

  /// A record start/stop is in flight — the mic button ignores taps while set.
  bool busy = false;
  bool isRecording = false;
  Duration elapsed = Duration.zero;
  String? recordedPath;
  String? recordedMime;

  /// Local-file playback state (the recorded note's bubble).
  bool isPlaying = false;

  /// Remote-URL playback state (a detail Notes row's bubble): the URL
  /// currently playing, or null. Tapping the same URL stops it.
  String? playingUrl;

  String get recordingLabel {
    final m = elapsed.inMinutes;
    final s = elapsed.inSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> initMic() async {
    bool granted;
    try {
      granted = await _recorder.hasPermission();
    } catch (_) {
      // No platform implementation in tests / denied by the OS.
      granted = false;
    }
    micPermission = granted;
    micChecked = true;
    _notify();
  }

  /// Re-checks the mic permission (e.g. after the user enabled it in the
  /// system Settings) and, if still denied, points at Settings. No
  /// app_settings dependency — the button re-runs the permission check.
  Future<void> retryMicPermission() async {
    await initMic();
    if (!micPermission) {
      onMessage?.call('Enable microphone access in Settings');
    }
  }

  /// Single entry point for the mic button. The [busy] guard closes the
  /// splicing double-tap race (D21 bug f): a second tap while a start is
  /// in flight used to double-start the recorder.
  Future<void> toggleRecording() async {
    if (busy) return;
    if (isRecording) {
      await stopRecording();
    } else {
      await startRecording();
    }
  }

  Future<void> startRecording() async {
    if (!micPermission) {
      onMessage?.call(AppStrings.snackbarMicPermission);
      return;
    }
    busy = true;
    _notify();
    try {
      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/${filePrefix}_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: path,
      );
      final stopwatch = Stopwatch()..start();
      _ticker?.cancel();
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        elapsed = stopwatch.elapsed;
        _notify();
      });
      isRecording = true;
      elapsed = Duration.zero;
      recordedPath = null;
      recordedMime = null;
    } on Exception {
      onMessage?.call(AppStrings.snackbarRecordFailed);
    } finally {
      busy = false;
      _notify();
    }
  }

  Future<void> stopRecording() async {
    busy = true;
    _notify();
    _ticker?.cancel();
    try {
      final path = await _recorder.stop();
      isRecording = false;
      int? size;
      var exists = false;
      if (path != null) {
        exists = File(path).existsSync();
        if (exists) size = await File(path).length();
      }
      final error = voiceStopError(path: path, exists: exists, sizeBytes: size);
      if (error != null) {
        if (size != null && size > maxVoiceNoteBytes) {
          File(path!).deleteSync();
        }
        onMessage?.call(error);
        _notify();
        return;
      }
      recordedPath = path;
      recordedMime = 'audio/mp4';
    } on Exception {
      onMessage?.call(AppStrings.snackbarRecordFailed);
    } finally {
      busy = false;
      isRecording = false;
      _notify();
    }
  }

  /// Toggles playback of the recorded local file.
  Future<void> playRecording() async {
    if (recordedPath == null) return;
    try {
      if (isPlaying) {
        await _player.stop();
        isPlaying = false;
        _notify();
        return;
      }
      await _player.play(DeviceFileSource(recordedPath!));
      isPlaying = true;
      _notify();
    } catch (error) {
      onMessage?.call('Could not play voice note: $error');
    }
  }

  /// Toggles playback of a remote voice-note URL (detail Notes rows).
  /// Tapping the URL that is already playing stops it.
  Future<void> playUrl(String url) async {
    try {
      if (playingUrl == url) {
        await _player.stop();
        playingUrl = null;
        _notify();
        return;
      }
      await _player.play(UrlSource(url));
      playingUrl = url;
      _notify();
    } catch (_) {
      onMessage?.call('Could not play this voice note.');
    }
  }

  /// Natural playback finish: the play/pause icon flips back to play.
  /// Wired to [AudioPlayer.onPlayerComplete] in the constructor.
  @visibleForTesting
  void handlePlaybackComplete() {
    if (isPlaying || playingUrl != null) {
      isPlaying = false;
      playingUrl = null;
      _notify();
    }
  }

  /// Discards the recorded note (delete button). Replace flow = delete,
  /// then tap the mic again — exactly the survey flow.
  void clearRecording() {
    if (isPlaying) {
      // Fire-and-forget: the UI already moved on; the player must not
      // keep playing a note the user just discarded.
      _player.stop();
    }
    recordedPath = null;
    recordedMime = null;
    elapsed = Duration.zero;
    isPlaying = false;
    _notify();
  }

  @override
  void dispose() {
    _disposed = true;
    _ticker?.cancel();
    _completionSubscription?.cancel();
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }
}
