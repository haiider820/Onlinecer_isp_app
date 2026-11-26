import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isp_onlinecer/features/survey/presentation/connection_request_providers.dart';
import 'package:isp_onlinecer/features/survey/presentation/survey_request_detail_screen.dart';
import 'package:isp_onlinecer/models/connection_request.dart';

/// Request Detail bottom shelf at narrow width (D15).
///
/// Before the fix the Row was Plan Route (intrinsic) + Flag Expanded flex 1
/// + Complete Survey Expanded flex 2: at 360px the Flag label wrapped to
/// one letter per line ("F I a g") and "Complete Survey" wrapped to three
/// lines and clipped at 52px. The Flag button is now icon-only (52x52, same
/// error colour and snackbar, Semantics label "Flag issue").
///
/// The test runs at 600px, not 360px: the widget-test font renders ~2x
/// wider than Plus Jakarta Sans, so at a 360px test viewport even the fixed
/// layout overflows in the test (and the old one overflowed far worse).
/// 600px is the narrowest test width where the fixed shelf fits while the
/// old one did not (old needed ~642px, fixed needs ~572px in test metrics)
/// — it verifies the same property: the shelf fits at a width where it
/// previously broke, with the Complete Survey label on one line.
///
/// LIMIT (measured 2026-11-25 with the real Plus Jakarta Sans SemiBold
/// metrics, not the test font): icon-only Flag alone does NOT make
/// "Complete Survey" fit on one line at a real 360dp — the button gets
/// 133.8dp but one line needs 185.6dp (icon 20 + gap 8 + text 117.6 + M3
/// icon-button padding 40). One line needs a screen >= 412dp; at
/// 364-411dp the label renders on two clean lines without clipping; below
/// 364dp it still clips to three lines. The one-line bar needs a
/// follow-up decision (e.g. dropping the icon from Complete Survey too, or
/// a tighter padding) — see D15.
Map<String, Object?> _detailJson() => {
  'data': {
    'id': 'req-1',
    'request_number': 'CRQ-20261001-ABCD',
    'status': 'survey_assigned',
    'customer_name': 'Test Customer',
    'current_team': {
      'id': 'team_uuid',
      'name': 'Survey Team',
      'functional_team_type': 'survey',
    },
  },
  'allowed_action': 'complete_survey',
};

Future<void> _pumpDetail(WidgetTester tester) async {
  tester.view.physicalSize = const Size(600, 800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        connectionRequestDetailProvider('req-1').overrideWith(
          (ref) async =>
              ConnectionRequestDetail.fromJson(_detailJson()),
        ),
      ],
      child: const MaterialApp(
        home: SurveyRequestDetailScreen(requestId: 'req-1'),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('at narrow width: Flag is icon-only, Complete Survey on one line',
      (tester) async {
    await _pumpDetail(tester);

    // The "Flag" text label is gone; the flag icon remains.
    expect(find.text('Flag'), findsNothing);
    expect(find.byIcon(Icons.flag_outlined), findsOneWidget);
    // The other two actions are unchanged.
    expect(find.text('Plan Route'), findsOneWidget);
    expect(find.text('Complete Survey'), findsOneWidget);

    // The label renders on one line: its height is a single line-height
    // (~20px at labelLarge), not two wrapped lines (~40px).
    final labelSize = tester.getSize(find.text('Complete Survey'));
    expect(labelSize.height, lessThan(30));

    // No layout overflow anywhere on the screen.
    expect(tester.takeException(), isNull);
  });

  testWidgets('flag icon still shows the not-available snackbar',
      (tester) async {
    await _pumpDetail(tester);

    await tester.tap(find.byIcon(Icons.flag_outlined));
    await tester.pumpAndSettle();

    expect(
      find.text('Issue flagging is not available in this build yet.'),
      findsOneWidget,
    );
  });

  testWidgets(
      'inventory_pending (no allowed actions) shows no actionable buttons (D19, guide §8)',
      (tester) async {
    // A feasible survey with requested items lands in inventory_pending:
    // approval is web-only, so the survey detail must be read-only — no
    // Plan Route, no Complete Survey, no Review. The Flag button stays
    // (it is not a stage action).
    tester.view.physicalSize = const Size(600, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          connectionRequestDetailProvider('req-1').overrideWith(
            (ref) async => ConnectionRequestDetail.fromJson({
              'data': {
                'id': 'req-1',
                'request_number': 'CRQ-20261125-TEST',
                'status': 'inventory_pending',
                'customer_name': 'Test Customer',
                'current_team': {
                  'id': 'team_uuid',
                  'name': 'Survey Team',
                  'functional_team_type': 'survey',
                },
              },
              // No allowed_action / allowed_actions at all.
            }),
          ),
        ],
        child: const MaterialApp(
          home: SurveyRequestDetailScreen(requestId: 'req-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Plan Route'), findsNothing);
    expect(find.text('Complete Survey'), findsNothing);
    expect(find.text('Review'), findsNothing);
    // The screen itself still renders (read-only detail, not an error).
    expect(find.text('CRQ-20261125-TEST'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
