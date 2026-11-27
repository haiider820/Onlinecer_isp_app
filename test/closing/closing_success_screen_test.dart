import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:isp_onlinecer/features/closing/data/screenshot_saver.dart';
import 'package:isp_onlinecer/features/closing/models/closing_activation.dart';
import 'package:isp_onlinecer/features/closing/presentation/closing_success_screen.dart';

class _FakeScreenshotSaver extends ScreenshotSaver {
  List<int>? savedBytes;
  String? savedName;
  int calls = 0;

  @override
  Future<ScreenshotSaveResult> savePng(List<int> bytes, String fileName) async {
    calls++;
    savedBytes = bytes;
    savedName = fileName;
    return const ScreenshotSaveResult(
      savedPath: '/tmp/closing-activation-test.png',
      opened: false,
    );
  }
}

const _fullActivation = ClosingActivation(
  pppoeUsername: 'user123',
  pppoePassword: 'secret-pass',
  portalEmail: 'customer@example.com',
  portalPassword: 'portal-pass',
  radiusSynced: true,
);

GoRouter _routerFor(ClosingSuccessArgs args, {ScreenshotSaver? saver}) {
  return GoRouter(
    initialLocation: '/closing/requests/req-1/success',
    routes: [
      GoRoute(
        path: '/closing/requests/:id/success',
        builder: (context, state) => ClosingSuccessScreen(
          args: args,
          screenshotSaver: saver ?? _FakeScreenshotSaver(),
        ),
      ),
      GoRoute(
        path: '/closing/requests',
        builder: (context, state) =>
            const Scaffold(body: Text('Closing list')),
      ),
    ],
  );
}

Future<void> _pumpScreen(
  WidgetTester tester,
  ClosingSuccessArgs args, {
  ScreenshotSaver? saver,
}) async {
  final router = _routerFor(args, saver: saver);
  await tester.pumpWidget(MaterialApp.router(routerConfig: router));
  await tester.pumpAndSettle();
}

void main() {
  group('ClosingSuccessScreen (D24)', () {
    testWidgets('shows the message and all four credentials',
        (tester) async {
      await _pumpScreen(
        tester,
        const ClosingSuccessArgs(
          message: 'Connection closed successfully.',
          activation: _fullActivation,
          voiceNoteWarning: null,
          listRoute: '/closing/requests',
        ),
      );

      expect(find.text('Connection closed successfully.'), findsOneWidget);
      expect(find.text('Activation details'), findsOneWidget);
      expect(find.text('user123'), findsOneWidget);
      expect(find.text('customer@example.com'), findsOneWidget);
      // Passwords are masked until revealed.
      expect(find.text('secret-pass'), findsNothing);
      expect(find.text('portal-pass'), findsNothing);
      expect(find.text('Take Screenshot'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);
    });

    testWidgets('password reveal shows the real value', (tester) async {
      await _pumpScreen(
        tester,
        const ClosingSuccessArgs(
          message: 'Connection closed successfully.',
          activation: _fullActivation,
          voiceNoteWarning: null,
          listRoute: '/closing/requests',
        ),
      );

      await tester.ensureVisible(find.byTooltip('Show password').first);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Show password').first);
      await tester.pump();

      expect(find.text('secret-pass'), findsOneWidget);
    });

    testWidgets('copy button copies the value', (tester) async {
      // Widget tests do not mock the clipboard channel — answer the
      // Clipboard.setData call so the success path is exercised.
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform,
              (MethodCall call) async {
        if (call.method == 'Clipboard.setData') return null;
        return null;
      });
      addTearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, null);
      });

      await _pumpScreen(
        tester,
        const ClosingSuccessArgs(
          message: 'Connection closed successfully.',
          activation: _fullActivation,
          voiceNoteWarning: null,
          listRoute: '/closing/requests',
        ),
      );

      await tester.ensureVisible(find.byTooltip('Copy PPPoE username'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Copy PPPoE username'));
      await tester.pump();

      expect(find.text('PPPoE username copied'), findsOneWidget);
    });

    testWidgets('radius_synced false shows the RADIUS warning',
        (tester) async {
      await _pumpScreen(
        tester,
        const ClosingSuccessArgs(
          message: 'Connection closed successfully.',
          activation: ClosingActivation(
            pppoeUsername: 'user123',
            pppoePassword: 'secret-pass',
            portalEmail: 'customer@example.com',
            portalPassword: 'portal-pass',
            radiusSynced: false,
          ),
          voiceNoteWarning: null,
          listRoute: '/closing/requests',
        ),
      );

      expect(find.text('RADIUS synchronization failed'), findsOneWidget);
      // The credentials stay visible alongside the warning.
      expect(find.text('user123'), findsOneWidget);
    });

    testWidgets('radius_synced true or absent shows no warning',
        (tester) async {
      await _pumpScreen(
        tester,
        const ClosingSuccessArgs(
          message: 'Connection closed successfully.',
          activation: _fullActivation,
          voiceNoteWarning: null,
          listRoute: '/closing/requests',
        ),
      );
      expect(find.text('RADIUS synchronization failed'), findsNothing);

      await _pumpScreen(
        tester,
        const ClosingSuccessArgs(
          message: 'Connection closed successfully.',
          activation: ClosingActivation(pppoeUsername: 'user123'),
          voiceNoteWarning: null,
          listRoute: '/closing/requests',
        ),
      );
      expect(find.text('RADIUS synchronization failed'), findsNothing);
    });

    testWidgets('absent activation shows the plain success, no card',
        (tester) async {
      await _pumpScreen(
        tester,
        const ClosingSuccessArgs(
          message: 'Job closed.',
          activation: null,
          voiceNoteWarning: null,
          listRoute: '/closing/requests',
        ),
      );

      expect(find.text('Job closed.'), findsOneWidget);
      expect(find.text('Activation details'), findsNothing);
      expect(find.text('Take Screenshot'), findsNothing);
      expect(find.text('Close'), findsOneWidget);
    });

    testWidgets('back press does not dismiss the screen', (tester) async {
      await _pumpScreen(
        tester,
        const ClosingSuccessArgs(
          message: 'Connection closed successfully.',
          activation: _fullActivation,
          voiceNoteWarning: null,
          listRoute: '/closing/requests',
        ),
      );

      // No back button exists by design — simulate the SYSTEM back press
      // (the engine's pop-route channel), which PopScope must veto.
      await tester.binding.handlePopRoute();
      await tester.pump();

      expect(find.byType(ClosingSuccessScreen), findsOneWidget);
    });

    testWidgets('Close goes to the list', (tester) async {
      await _pumpScreen(
        tester,
        const ClosingSuccessArgs(
          message: 'Connection closed successfully.',
          activation: _fullActivation,
          voiceNoteWarning: null,
          listRoute: '/closing/requests',
        ),
      );

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      expect(find.text('Closing list'), findsOneWidget);
      expect(find.byType(ClosingSuccessScreen), findsNothing);
    });

    testWidgets('Take Screenshot captures the card as a PNG',
        (tester) async {
      final saver = _FakeScreenshotSaver();
      await _pumpScreen(
        tester,
        const ClosingSuccessArgs(
          message: 'Connection closed successfully.',
          activation: _fullActivation,
          voiceNoteWarning: null,
          listRoute: '/closing/requests',
        ),
        saver: saver,
      );

      // The credentials card sits below the fold in the test viewport —
      // scroll it into view first, so the RepaintBoundary is actually
      // painted before the capture (an unpainted boundary never yields an
      // image). toImage() is real engine work: it only completes outside
      // the fake async zone (tester.runAsync) — the same rule as dart:io
      // file writes in this VM's tests.
      await tester.ensureVisible(find.text('Activation details'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Take Screenshot'));
      await tester.pump();
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(seconds: 2));
      });
      await tester.pump();

      expect(saver.calls, 1);
      expect(saver.savedBytes, isNotNull);
      // PNG magic bytes — the capture is a real PNG, not empty data.
      expect(saver.savedBytes!.take(4).toList(), [0x89, 0x50, 0x4E, 0x47]);
      expect(saver.savedName, endsWith('.png'));
      expect(
        find.text('Screenshot saved to /tmp/closing-activation-test.png'),
        findsOneWidget,
      );
    });
  });
}
