import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isp_onlinecer/shared/widgets/success_moment.dart';

/// Widget tests for the native success moment (D23, kit Rule 8).
///
/// The moment plays once (~1.4s: check pop + Signal ring + words) and
/// then calls `onComplete`. It replaces the survey-submit Lottie — pure
/// Flutter, no asset, no new dependency.
Future<void> _pumpMoment(
  WidgetTester tester, {
  required VoidCallback onComplete,
  String headline = 'Survey submitted',
  String? subtitle = 'CRQ-20261001-ABCD  •  Installation assigned',
  Duration? duration,
  bool disableAnimations = false,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        child: Scaffold(
          body: Center(
            child: SuccessMoment(
              headline: headline,
              subtitle: subtitle,
              onComplete: onComplete,
              duration: duration ?? const Duration(milliseconds: 1400),
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('renders the check, the headline and the subtitle', (
    tester,
  ) async {
    var completed = false;
    await _pumpMoment(tester, onComplete: () => completed = true);

    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(find.text('Survey submitted'), findsOneWidget);
    expect(
      find.text('CRQ-20261001-ABCD  •  Installation assigned'),
      findsOneWidget,
    );
    expect(completed, isFalse);
  });

  testWidgets('calls onComplete once the moment has played', (
    tester,
  ) async {
    var calls = 0;
    await _pumpMoment(tester, onComplete: () => calls++);

    // Halfway through: still playing, not complete.
    await tester.pump(const Duration(milliseconds: 700));
    expect(calls, 0);

    // Past the 1.4s duration: complete, exactly once.
    await tester.pump(const Duration(milliseconds: 800));
    expect(calls, 1);

    await tester.pump(const Duration(milliseconds: 500));
    expect(calls, 1);
  });

  testWidgets('no subtitle means no subtitle row', (tester) async {
    await _pumpMoment(
      tester,
      subtitle: null,
      onComplete: () {},
    );

    expect(find.text('Survey submitted'), findsOneWidget);
    // Only the headline text is rendered — no empty second line.
    expect(find.byType(Text), findsOneWidget);
  });

  testWidgets('reduced motion completes right away (Rule 5)', (
    tester,
  ) async {
    var completed = false;
    await _pumpMoment(
      tester,
      disableAnimations: true,
      onComplete: () => completed = true,
    );

    // The final state is rendered and the moment completes without
    // waiting out the 1.4s animation.
    await tester.pump();
    expect(completed, isTrue);
    expect(find.text('Survey submitted'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
  });
}
