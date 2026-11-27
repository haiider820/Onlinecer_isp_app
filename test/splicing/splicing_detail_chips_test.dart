import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isp_onlinecer/features/splicing/presentation/complete_splicing_screen.dart';
import 'package:isp_onlinecer/features/splicing/presentation/splicing_providers.dart';
import 'package:isp_onlinecer/features/splicing/presentation/splicing_request_detail_screen.dart';
import 'package:isp_onlinecer/models/splicing.dart';
import 'package:isp_onlinecer/shared/widgets/ops_widgets.dart';

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

Future<void> _pumpDetail(WidgetTester tester) async {
  GoogleFonts.config.allowRuntimeFetching = false;
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        splicingDetailProvider('req-1').overrideWith((ref) async => _fixture),
      ],
      child: const MaterialApp(
        home: SplicingRequestDetailScreen(requestId: 'req-1'),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  // record + audioplayers have no platform implementation in tests: mock
  // their channels for the WHOLE file (same mocks as
  // test/shared/voice_recorder_controller_test.dart). They must be
  // registered in setUp, not per-test: the shared voice controller is
  // created in every test here, and an unmocked earlier test leaves the
  // audioplayers global-init state behind in a way that makes a later
  // test's playback hang instead of failing. They stay registered for the
  // whole file — the controller's dispose is fire-and-forget, so clearing
  // them early would let a late dispose hit the unmocked channel.
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

  group('Splicing detail stage chips (D21)', () {
    testWidgets('previous-stage data is collapsed behind chips by default',
        (tester) async {
      await _pumpDetail(tester);

      // One chip per previous-stage block that has data.
      expect(find.text('Survey'), findsOneWidget);
      expect(find.text('Installation'), findsOneWidget);
      expect(find.text('Notes'), findsOneWidget);

      // Nothing from the previous stages is on screen yet.
      expect(find.text('Roof access confirmed, FAT port 3 free.'),
          findsNothing);
      expect(find.text('ONT installed, wire 12m.'), findsNothing);
      expect(find.text('Customer home all day.'), findsNothing);
    });

    testWidgets('tapping a chip reveals that stage; tapping again hides it',
        (tester) async {
      await _pumpDetail(tester);

      await tester.tap(find.text('Survey'));
      await tester.pumpAndSettle();
      expect(find.text('Roof access confirmed, FAT port 3 free.'),
          findsOneWidget);
      // The other stages stay hidden.
      expect(find.text('ONT installed, wire 12m.'), findsNothing);

      await tester.tap(find.text('Survey'));
      await tester.pumpAndSettle();
      expect(find.text('Roof access confirmed, FAT port 3 free.'),
          findsNothing);

      await tester.tap(find.text('Installation'));
      await tester.pumpAndSettle();
      expect(find.text('ONT installed, wire 12m.'), findsOneWidget);
    });

  });

  group('CompleteSplicingForm voice UI (D21)', () {
    testWidgets('survey pattern: recorder card + bubble, no re-record',
        (tester) async {
      GoogleFonts.config.allowRuntimeFetching = false;
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CompleteSplicingForm(requestId: 'req-1'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(VoiceRecorderCard), findsOneWidget);
      // The Re-record button (and the old dead "Play Memo") are gone.
      expect(find.text('Re-record'), findsNothing);
      expect(find.text('Play Memo'), findsNothing);
    });
  });
}
