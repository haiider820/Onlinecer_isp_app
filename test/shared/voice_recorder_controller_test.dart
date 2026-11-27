import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isp_onlinecer/core/constants/app_constants.dart';
import 'package:isp_onlinecer/shared/voice/voice_recorder_controller.dart';

void main() {
  // AudioRecorder's constructor touches ServicesBinding — plain unit tests
  // have no binding; initialise the test binding first.
  TestWidgetsFlutterBinding.ensureInitialized();

  // record + audioplayers talk to native code over method channels. With no
  // platform implementation the calls throw MissingPluginException from
  // fire-and-forget futures (the recorder constructor's create, the
  // player's global init) — unhandled async errors that fail the test, and
  // the record package's global semaphore can stall a later acquire
  // behind a never-completing create. Mock the channels so the controller
  // is tested deterministically: permission denied, everything else a
  // no-op success. The mocks stay registered for the whole file: the
  // controller's dispose is fire-and-forget, so clearing them in a
  // tearDown would let a late dispose call hit the unmocked channel.
  const recordChannel = MethodChannel('com.llfbandit.record/messages');
  const playerChannel = MethodChannel('xyz.luan/audioplayers');
  const globalPlayerChannel = MethodChannel('xyz.luan/audioplayers.global');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  setUp(() {
    messenger.setMockMethodCallHandler(recordChannel, (call) async {
      if (call.method == 'hasPermission') return false;
      return null;
    });
    messenger.setMockMethodCallHandler(playerChannel, (_) async => null);
    messenger.setMockMethodCallHandler(globalPlayerChannel, (_) async => null);
  });

  group('voiceStopError (D21 bug d)', () {
    test('missing file reports the generic failure, not "too large"', () {
      expect(
        voiceStopError(path: null, exists: false, sizeBytes: null),
        AppStrings.snackbarRecordFailed,
      );
      expect(
        voiceStopError(path: '/tmp/x.m4a', exists: false, sizeBytes: null),
        AppStrings.snackbarRecordFailed,
      );
    });

    test('oversize file reports the 10 MB message', () {
      expect(
        voiceStopError(
          path: '/tmp/x.m4a',
          exists: true,
          sizeBytes: maxVoiceNoteBytes + 1,
        ),
        'Voice note is too large (max 10 MB).',
      );
    });

    test('usable recording reports no error', () {
      expect(
        voiceStopError(path: '/tmp/x.m4a', exists: true, sizeBytes: 1234),
        isNull,
      );
    });
  });

  group('VoiceRecorderController', () {
    testWidgets('recording label is mm:ss', (tester) async {
      final controller =
          VoiceRecorderController(filePrefix: 'test', onMessage: (_) {});
      addTearDown(controller.dispose);
      expect(controller.recordingLabel, '00:00');
      controller.elapsed = const Duration(seconds: 65);
      expect(controller.recordingLabel, '01:05');
      controller.elapsed = const Duration(minutes: 9, seconds: 3);
      expect(controller.recordingLabel, '09:03');
    });

    testWidgets('toggle without mic permission reports the permission message', (tester) async {
      final messages = <String>[];
      final controller = VoiceRecorderController(
        filePrefix: 'test',
        onMessage: messages.add,
      );
      addTearDown(controller.dispose);
      await controller.initMic();
      // No mic platform implementation in tests → permission resolves false.
      expect(controller.micPermission, isFalse);
      expect(controller.micChecked, isTrue);

      await controller.toggleRecording();

      expect(messages, contains(AppStrings.snackbarMicPermission));
      expect(controller.isRecording, isFalse);
    });

    testWidgets('handlePlaybackComplete resets the play/pause icon and the URL',
        (tester) async {
      final controller =
          VoiceRecorderController(filePrefix: 'test', onMessage: (_) {});
      addTearDown(controller.dispose);
      controller.isPlaying = true;
      controller.playingUrl = 'https://example.test/note.m4a';

      controller.handlePlaybackComplete();

      expect(controller.isPlaying, isFalse);
      expect(controller.playingUrl, isNull);
    });

    testWidgets('clearRecording drops the path and the playing state', (tester) async {
      final controller =
          VoiceRecorderController(filePrefix: 'test', onMessage: (_) {});
      addTearDown(controller.dispose);
      controller.recordedPath = '/tmp/test_1.m4a';
      controller.recordedMime = 'audio/mp4';
      controller.elapsed = const Duration(seconds: 7);
      controller.isPlaying = true;

      controller.clearRecording();

      expect(controller.recordedPath, isNull);
      expect(controller.recordedMime, isNull);
      expect(controller.elapsed, Duration.zero);
      expect(controller.isPlaying, isFalse);
    });
  });
}
