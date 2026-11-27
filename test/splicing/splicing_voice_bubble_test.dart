import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isp_onlinecer/features/splicing/presentation/splicing_providers.dart';
import 'package:isp_onlinecer/features/splicing/presentation/splicing_request_detail_screen.dart';
import 'package:isp_onlinecer/models/splicing.dart';
import 'package:isp_onlinecer/shared/widgets/ops_widgets.dart';

// D21: the splicing detail's voice-note bubble — Play must actually play.
//
// This test lives in its own file on purpose: audioplayers keeps shared
// static state in the isolate (AudioPlayer.global's GlobalAudioScope and
// its _initCompleter, plus the platform's per-player event-stream map), so
// a test that depends on the player's async init behaves differently
// after other tests in the same file have created players. In its own
// file (own isolate) the behaviour is deterministic: with the channels
// mocked, play() waits for the "prepared" event that never comes in
// tests, audioplayers gives up after its 30s preparation timeout, and
// the failure surfaces as a snackbar.

const _fixture = SplicingDetail(
  id: 'req-1',
  requestNumber: 'CRQ-20261125-N2ON1HQK',
  status: 'splicing_assigned',
  customerName: 'Test Customer',
  surveyNotes: 'Roof access confirmed, FAT port 3 free.',
  installationNotes: 'ONT installed, wire 12m.',
  notes: [
    SplicingNote(
      type: 'Survey',
      note: 'Customer home all day.',
      voiceNoteUrl: 'https://example.test/notes/survey.m4a',
    ),
  ],
  allowedActions: ['complete_splicing'],
);

void main() {
  // record + audioplayers have no platform implementation in tests: mock
  // their channels so the shared voice controller behaves
  // deterministically (same mocks as
  // test/shared/voice_recorder_controller_test.dart). They stay registered
  // for the whole file — the controller's dispose is fire-and-forget, so
  // clearing them early would let a late dispose hit the unmocked channel.
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  setUp(() {
    messenger.setMockMethodCallHandler(
      const MethodChannel('com.llfbandit.record/messages'),
      (call) async => call.method == 'hasPermission' ? false : null,
    );
    messenger.setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers'),
      (_) async => null,
    );
    messenger.setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers.global'),
      (_) async => null,
    );
  });

  testWidgets('Notes chip shows the voice note as a playable bubble',
      (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          splicingDetailProvider('req-1')
              .overrideWith((ref) async => _fixture),
        ],
        child: const MaterialApp(
          home: SplicingRequestDetailScreen(requestId: 'req-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Notes'));
    await tester.pumpAndSettle();

    expect(find.text('Customer home all day.'), findsOneWidget);
    // D21 bug (b): the voice note used to render as raw URL text with
    // no way to play it. It is now the survey-style bubble.
    expect(find.byType(VoiceNoteBubble), findsOneWidget);
    expect(
      find.text('Voice note: https://example.test/notes/survey.m4a'),
      findsNothing,
    );

    // D21 bug (a): the old splicing Play was a dead no-op. The bubble's
    // Play button is wired to real playback — that snackbar proves the
    // button actually attempted to play (a no-op would show nothing).
    await tester.ensureVisible(find.byIcon(Icons.play_arrow));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pump(const Duration(seconds: 31));
    expect(find.text('Could not play this voice note.'), findsOneWidget);
  });
}
