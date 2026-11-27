import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isp_onlinecer/features/stage_shared/models/team_stage_detail.dart';
import 'package:isp_onlinecer/features/stage_shared/presentation/team_stage_detail_screen.dart';
import 'package:isp_onlinecer/features/stage_shared/presentation/team_stage_detail_sections.dart';
import 'package:isp_onlinecer/features/stage_shared/team_stage_config.dart';
import 'package:isp_onlinecer/features/verification/presentation/verification_providers.dart';
import 'package:isp_onlinecer/shared/widgets/ops_widgets.dart';
import 'package:isp_onlinecer/shared/widgets/stage_chips.dart';

// Same detail shape as test/stage_shared/verification_closing_flow_test.dart.
Map<String, dynamic> _detailJson(String action) => {
      'allowed_action': action,
      'data': {
        'id': 'request-1',
        'request_number': 'CRQ-101',
        'status': 'verification_assigned',
        'assigned_users': {
          'surveyor': {'id': 'survey-1', 'name': 'Surveyor'},
          'technician': {'id': 'tech-1', 'name': 'Technician'},
          'splicer': {'id': 'splice-1', 'name': 'Splicer'},
        },
        'locations': {
          'fat_node': {'id': 'fat-1', 'name': 'FAT North', 'latitude': 33.72, 'longitude': 73.07},
        },
        'charges': {'connection_charges_minor': 2500, 'subscription_charges_minor': 250000, 'inventory_cost_minor': 0},
        'timestamps': {'surveyed_at': '2026-01-01T00:00:00Z'},
        'notes': [
          {'type': 'splicing', 'note': 'Spliced.', 'voice_note_url': 'https://example.test/splice.m4a'},
        ],
        'items': [
          {'item_name': 'Drop cable', 'quantity': 1, 'total_minor': 0},
        ],
        'documents': {'id_card_front_url': 'https://example.test/id-front.jpg'},
        'stage_data': {'survey_notes': 'Survey complete', 'total_wire_used': 75},
      },
    };

final _testDetailProvider =
    FutureProvider.family<TeamStageDetail, String>((ref, id) async {
  return TeamStageDetail.fromJson(
    _detailJson(TeamStageConfig.verification.allowedAction),
  );
});

Future<void> _pumpSections(WidgetTester tester) async {
  GoogleFonts.config.allowRuntimeFetching = false;
  final detail = TeamStageDetail.fromJson(
    _detailJson(TeamStageConfig.verification.allowedAction),
  );
  // Device-tall viewport: the sections list (Customer + FAT + locations
  // + users) pushes the chips below the fold of the default 600px test
  // viewport, and a ListView only builds visible children — without this
  // the chips are not built at all and no finder can see them.
  tester.view.physicalSize = const Size(800, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          // The bubble only renders when a player is wired (D21): pass a
          // no-op callback so the test asserts on the real render path.
          body: TeamStageDetailSections(
            detail: detail,
            onPlayVoiceNote: (_) {},
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  // The verification screen creates shared voice controllers: mock the
  // record + audioplayers channels so they behave deterministically
  // (same mocks as test/shared/voice_recorder_controller_test.dart).
  // They stay registered for the whole file — the controller's dispose is
  // fire-and-forget, so clearing them early would let a late dispose hit
  // the unmocked channel.
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

  group('TeamStageDetailSections stage chips (D21)', () {
    testWidgets('previous-stage groups are collapsed behind chips by default',
        (tester) async {
      await _pumpSections(tester);

      // One chip per group that has data (no PPPoE/inventory in the
      // fixture, so that chip is absent).
      for (final label in [
        'Notes',
        'Items',
        'Documents',
        'Charges',
        'Timeline',
        'Stage data',
      ]) {
        expect(find.text(label), findsOneWidget);
      }
      expect(find.text('PPPoE & inventory'), findsNothing);

      // Nothing from the previous stages is on screen yet. The Customer
      // card stays visible — it is this request's context, not
      // previous-stage work.
      expect(find.text('Spliced.'), findsNothing);
      expect(find.text('Drop cable'), findsNothing);
      expect(find.text('Survey complete'), findsNothing);
      expect(find.text('Customer'), findsOneWidget);
    });

    testWidgets('tapping a chip reveals that group; tapping again hides it',
        (tester) async {
      await _pumpSections(tester);

      // Scope chip taps to the StageChips row: once a group is open its
      // section title repeats the chip label, so a bare find.text would
      // match two widgets.
      Finder chip(String label) => find.descendant(
            of: find.byType(StageChips),
            matching: find.text(label),
          );

      await tester.tap(chip('Notes'));
      await tester.pumpAndSettle();
      expect(find.text('Spliced.'), findsOneWidget);
      // The other groups stay hidden.
      expect(find.text('Drop cable'), findsNothing);

      await tester.tap(chip('Notes'));
      await tester.pumpAndSettle();
      expect(find.text('Spliced.'), findsNothing);

      await tester.tap(chip('Stage data'));
      await tester.pumpAndSettle();
      expect(find.text('Survey complete'), findsOneWidget);
    });

    testWidgets('Notes row shows the voice note as a bubble, not a button',
        (tester) async {
      await _pumpSections(tester);

      await tester.tap(find.text('Notes'));
      await tester.pumpAndSettle();

      // D21: the old plain "Play voice note" button is gone — the note
      // plays from the survey-style bubble (no duration: the server
      // provides none for remote notes).
      expect(find.byType(VoiceNoteBubble), findsOneWidget);
      expect(find.text('Play voice note'), findsNothing);
    });

    testWidgets('Documents chip reveals the document row', (tester) async {
      await _pumpSections(tester);

      expect(find.text('https://example.test/id-front.jpg'), findsNothing);

      await tester.tap(find.text('Documents'));
      await tester.pumpAndSettle();

      expect(find.text('https://example.test/id-front.jpg'), findsOneWidget);
    });
  });

  group('TeamStageDetailScreen completion form voice UI (D21)', () {
    testWidgets('survey pattern: recorder card, no re-record',
        (tester) async {
      GoogleFonts.config.allowRuntimeFetching = false;
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: TeamStageDetailScreen(
              requestId: 'request-1',
              config: TeamStageConfig.verification,
              title: 'Verification',
              detailProvider: _testDetailProvider,
              listRoute: '/verification',
              listPageProvider: verificationRequestsProvider,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The completion form sits at the bottom of the sections list.
      await tester.scrollUntilVisible(
        find.byType(VoiceRecorderCard),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.byType(VoiceRecorderCard), findsOneWidget);
      // The Re-record button is gone (D21): replace flow is delete, then
      // tap the mic again.
      expect(find.text('Re-record'), findsNothing);
    });
  });
}
