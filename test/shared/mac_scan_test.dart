import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isp_onlinecer/features/installation/presentation/mac_scan_sheet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('classifyScannedBarcode', () {
    test('colon-separated MAC is a MAC', () {
      final result = classifyScannedBarcode('AA:BB:CC:DD:EE:FF');
      expect(result.kind, ScannedBarcodeKind.mac);
      expect(result.mac, 'AA:BB:CC:DD:EE:FF');
    });

    test('bare 12-hex barcode normalises to a MAC', () {
      final result = classifyScannedBarcode('aabbccddeeff');
      expect(result.kind, ScannedBarcodeKind.mac);
      expect(result.mac, 'AA:BB:CC:DD:EE:FF');
    });

    test('MAC: prefix and dashes normalise to a MAC', () {
      expect(
        classifyScannedBarcode('MAC: AABBCCDDEEFF').mac,
        'AA:BB:CC:DD:EE:FF',
      );
      expect(
        classifyScannedBarcode('AA-BB-CC-DD-EE-FF').mac,
        'AA:BB:CC:DD:EE:FF',
      );
    });

    test('serial barcode is a serial candidate, never a MAC', () {
      final result = classifyScannedBarcode('SN123456789');
      expect(result.kind, ScannedBarcodeKind.serialCandidate);
      expect(result.mac, isNull);
    });

    test('empty and too-short values are serial candidates', () {
      expect(
        classifyScannedBarcode('').kind,
        ScannedBarcodeKind.serialCandidate,
      );
      expect(
        classifyScannedBarcode('AABBCC').kind,
        ScannedBarcodeKind.serialCandidate,
      );
    });
  });

  group('MacScanSheet', () {
    // mobile_scanner talks to the native camera over this channel. In the
    // test env there is no platform implementation: an unmocked start
    // throws MissingPluginException (uncaught inside the plugin) and the
    // sheet never reaches its error UI. Mock the channel instead — the
    // permission state reports authorized, the camera start reports
    // permission denied — so the sheet's own fallback is what is tested.
    const scannerChannel =
        MethodChannel('dev.steenbakker.mobile_scanner/scanner/method');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

    setUp(() {
      messenger.setMockMethodCallHandler(scannerChannel, (call) async {
        switch (call.method) {
          case 'state':
            return 1; // MobileScannerAuthorizationState.authorized
          case 'start':
            throw PlatformException(
              code: 'MOBILE_SCANNER_CAMERA_PERMISSION_DENIED',
            );
          default:
            return null;
        }
      });
    });

    tearDown(() {
      messenger.setMockMethodCallHandler(scannerChannel, null);
    });

    testWidgets('camera failure falls back to manual entry', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              onPressed: () => showMacScanSheet(context),
              child: const Text('Open scanner'),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('Open scanner'));
      await tester.pumpAndSettle();

      expect(find.text('Scan device barcode'), findsOneWidget);
      // The mocked camera start reports permission denied: the sheet
      // explains and offers manual entry instead of a dead camera view.
      expect(find.text('Camera permission needed'), findsOneWidget);
      expect(find.text('Enter manually'), findsOneWidget);

      await tester.tap(find.text('Enter manually'));
      await tester.pumpAndSettle();
      expect(find.text('Scan device barcode'), findsNothing);
    });
  });
}
