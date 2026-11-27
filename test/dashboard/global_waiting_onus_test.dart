import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isp_onlinecer/core/theme/app_theme.dart';
import 'package:isp_onlinecer/features/lookups/presentation/sub_branch_providers.dart';
import 'package:isp_onlinecer/features/onu/presentation/global_waiting_onus_screen.dart';
import 'package:isp_onlinecer/features/onu/presentation/olt_providers.dart';
import 'package:isp_onlinecer/models/direct_olt.dart';
import 'package:isp_onlinecer/models/sub_branch.dart';
import 'package:isp_onlinecer/models/waiting_onu.dart';

// Minimal SubBranchController stand-in (same shape as the one in
// adversarial_detail_olt_test.dart): a fresh scoped single-branch list so
// the OLT calls resolve a scope id. Only the state shape matters here.
class _FakeSubBranchController extends SubBranchController {
  @override
  SubBranchState build() {
    return SubBranchState(
      lastKnownList: const SubBranchList(
        mode: 'scoped',
        data: [SubBranch(id: 'sub-1', name: 'Sub 1')],
      ),
      lastUpdated: DateTime.now(),
      isLoading: false,
    );
  }
}

const _olts = DirectOltList(data: [
  DirectOlt(
    id: 'olt-1',
    name: 'Wah OLT',
    vendor: 'Huawei',
    model: 'MA5608T',
    connectionStatus: 'Connected',
  ),
  DirectOlt(
    id: 'olt-2',
    name: 'VSOL OLT',
    vendor: 'VSOL',
    connectionStatus: 'Connected',
  ),
]);

Future<void> _pumpGlobal(
  WidgetTester tester, {
  List<Override> extraOverrides = const [],
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        subBranchStateProvider.overrideWith(_FakeSubBranchController.new),
        directOltsProvider.overrideWith((ref, _) async => _olts),
        waitingOnusProvider.overrideWith((ref, oltId) async {
          if (oltId == 'olt-1') {
            return const WaitingOnuList(data: [
              WaitingOnu(
                id: 'onu-1',
                serialNumber: 'HWTC12345678',
                detectedOnuType: 'HG8245H',
                authorizationStatus: 'waiting_authorization',
                ponPort: 'PON 1',
                lastDiscoveredAt: '2026-11-27 10:00',
              ),
              WaitingOnu(
                id: 'onu-2',
                serialNumber: 'HWTC87654321',
                detectedOnuType: 'HG8245H',
                authorizationStatus: 'queued',
              ),
            ]);
          }
          return const WaitingOnuList(data: []);
        }),
        ...extraOverrides,
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        home: const GlobalWaitingOnusScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  // See dashboard_tiles_test.dart: google_fonts must not fetch at runtime.
  GoogleFonts.config.allowRuntimeFetching = false;

  testWidgets('OLTs render with their waiting counts (D25)', (tester) async {
    await _pumpGlobal(tester);

    expect(find.text('Waiting ONUs'), findsOneWidget);
    expect(find.text('Wah OLT'), findsOneWidget);
    expect(find.text('VSOL OLT'), findsOneWidget);
    expect(find.text('2 waiting'), findsOneWidget);
    expect(find.text('0 waiting'), findsOneWidget);
    // Rows stay collapsed until tapped.
    expect(find.text('HWTC12345678'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping an OLT shows its waiting rows, read-only (D25)', (
    tester,
  ) async {
    await _pumpGlobal(tester);

    await tester.tap(find.text('Wah OLT'));
    await tester.pumpAndSettle();

    expect(find.text('HWTC12345678'), findsOneWidget);
    expect(find.text('HWTC87654321'), findsOneWidget);
    expect(find.text('HG8245H'), findsNWidgets(2));
    expect(find.text('PON 1'), findsOneWidget);
    expect(find.text('Refresh from OLT'), findsOneWidget);
    // No request context on the global screen: no authorize buttons.
    expect(find.text('Authorize this ONU'), findsNothing);
    expect(find.text('Authorize by serial number'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('an OLT with no waiting ONUs says so when expanded (D25)', (
    tester,
  ) async {
    await _pumpGlobal(tester);

    await tester.tap(find.text('VSOL OLT'));
    await tester.pumpAndSettle();

    expect(find.text('No waiting ONUs on this OLT.'), findsOneWidget);
    expect(find.text('HWTC12345678'), findsNothing);
  });

  testWidgets('empty OLT list shows the empty state (D25)', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          subBranchStateProvider.overrideWith(_FakeSubBranchController.new),
          directOltsProvider.overrideWith(
            (ref, _) async => const DirectOltList(data: []),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const GlobalWaitingOnusScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('No direct OLTs found for this sub-branch.'),
      findsOneWidget,
    );
  });
}
