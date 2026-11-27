import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isp_onlinecer/shared/widgets/stage_chips.dart';

void main() {
  group('StageChips (D21)', () {
    testWidgets('renders one chip per label and toggles on tap', (tester) async {
      int? selected;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => StageChips(
              labels: const ['Survey', 'Installation'],
              selected: selected,
              onSelect: (index) => setState(
                () => selected = selected == index ? null : index,
              ),
            ),
          ),
        ),
      ));

      expect(find.text('Survey'), findsOneWidget);
      expect(find.text('Installation'), findsOneWidget);

      await tester.tap(find.text('Survey'));
      await tester.pump();
      expect(selected, 0);

      // Tapping the open chip closes it again.
      await tester.tap(find.text('Survey'));
      await tester.pump();
      expect(selected, isNull);
    });

    testWidgets('empty labels render nothing', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: StageChips(
            labels: [],
            selected: null,
            onSelect: _noop,
          ),
        ),
      ));
      expect(find.byType(StageChips), findsOneWidget);
      expect(find.byType(GestureDetector), findsNothing);
    });
  });

  group('CollapsibleStageSection (D21)', () {
    testWidgets('collapsed by default, tap reveals, tap hides', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CollapsibleStageSection(
            label: 'Inventory approval',
            child: Text('Approved item: Drop cable'),
          ),
        ),
      ));

      expect(find.text('Inventory approval'), findsOneWidget);
      expect(find.text('Approved item: Drop cable'), findsNothing);

      await tester.tap(find.text('Inventory approval'));
      await tester.pump();
      expect(find.text('Approved item: Drop cable'), findsOneWidget);

      await tester.tap(find.text('Inventory approval'));
      await tester.pump();
      expect(find.text('Approved item: Drop cable'), findsNothing);
    });
  });
}

void _noop(int _) {}
