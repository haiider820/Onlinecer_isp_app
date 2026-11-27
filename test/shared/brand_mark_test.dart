import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isp_onlinecer/shared/widgets/branded_header.dart';

/// D24: the in-app brand mark is the techtis globe logo, not the old
/// Malik Fiber mark. The old file stays in the tree, unreferenced.
void main() {
  group('BrandedHeader brand mark (D24)', () {
    testWidgets('renders the techtis logo at the legacy 44dp box',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(appBar: BrandedHeader(title: 'Survey')),
        ),
      );

      final image = tester.widget<Image>(find.byType(Image).first);
      expect(image.image, isA<AssetImage>());
      expect(
        (image.image as AssetImage).assetName,
        'assets/images/techtis_logo.png',
      );
      expect(image.width, 44);
      expect(image.height, 44);
    });

    testWidgets('renders the techtis logo at 32dp for the dashboard header',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            appBar: BrandedHeader(title: 'Survey', brandMarkHeight: 32),
          ),
        ),
      );

      final image = tester.widget<Image>(find.byType(Image).first);
      expect(
        (image.image as AssetImage).assetName,
        'assets/images/techtis_logo.png',
      );
      expect(image.height, 32);
    });
  });
}
