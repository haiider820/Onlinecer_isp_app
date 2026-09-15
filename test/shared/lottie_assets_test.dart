// Regression guard for the Lottie assets (login-loading indicator, empty-state
// illustration, success checkmark).
//
// History: an earlier revision shipped no `assets:` declaration in pubspec.yaml,
// so every `Lottie.asset(...)` call threw "Unable to load asset" at runtime
// while `flutter analyze` stayed green. These assertions fail loudly in that
// case, because they exercise the same `rootBundle` path `Lottie.asset` uses.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';

const _animations = <String>[
  'assets/lottie/login_loading.json',
  'assets/lottie/empty_list.json',
  'assets/lottie/success_checkmark.json',
];

void main() {
  group('Lottie assets ship and parse', () {
    for (final path in _animations) {
      testWidgets('$path resolves from the asset bundle', (tester) async {
        final data = await rootBundle.load(path);
        expect(data.lengthInBytes, greaterThan(0), reason: '$path is empty');

        // `Lottie.asset` -> `AssetLottie.load` -> the same rootBundle lookup.
        late final LottieComposition composition;
        await tester.runAsync(() async {
          composition = await AssetLottie(path).load();
        });

        expect(composition.layers, isNotEmpty, reason: 'no layers parsed');
        expect(composition.duration.inMilliseconds, greaterThan(0));

        // The animations are pure vector: nothing can silently fail to load
        // at runtime on-device because of an unbundled bitmap.
        expect(composition.images, isEmpty);
      });

      testWidgets('$path builds a Lottie widget without throwing',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(width: 200, height: 200, child: Lottie.asset(path)),
            ),
          ),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
      });
    }
  });
}
