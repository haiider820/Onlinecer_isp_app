import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isp_onlinecer/core/network/api_exceptions.dart';
import 'package:isp_onlinecer/features/lookups/data/sub_branch_network.dart';
import 'package:isp_onlinecer/features/lookups/data/sub_branch_repository.dart';
import 'package:isp_onlinecer/features/lookups/presentation/sub_branch_providers.dart';
import 'package:isp_onlinecer/features/lookups/presentation/sub_branch_selector.dart';

/// Fake network returning one queued result per fetch: a response map for
/// success, an [Exception] to throw for failure. Repeats the last result
/// when the queue is exhausted, so a retry replays the final behaviour.
class _FakeSubBranchNetwork implements SubBranchNetwork {
  _FakeSubBranchNetwork(this.results);

  final List<Object> results;
  int fetchCount = 0;

  @override
  Future<Map<String, dynamic>> fetchSubBranches({String? subBranchId}) async {
    final index = fetchCount++;
    final result = results[index.clamp(0, results.length - 1)];
    if (result is Exception) throw result;
    return result as Map<String, dynamic>;
  }
}

/// Network that never answers, so the sheet stays in its loading state.
class _HangingSubBranchNetwork implements SubBranchNetwork {
  @override
  Future<Map<String, dynamic>> fetchSubBranches({String? subBranchId}) {
    return Completer<Map<String, dynamic>>().future;
  }
}

const _centralizedMap = {
  'mode': 'centralized',
  'selected_sub_branch_id': null,
  'data': [
    {'id': 'sb_gulberg', 'name': 'Gulberg Sub-Branch', 'type': 'sub_branch'},
    {'id': 'sb_north', 'name': 'North Sub-Branch', 'type': 'sub_branch'},
  ],
};

const _scopedSingleMap = {
  'mode': 'scoped',
  'selected_sub_branch_id': null,
  'data': [
    {'id': 'sb_only', 'name': 'Only Sub-Branch'},
  ],
};

const _emptyMap = {
  'mode': 'scoped',
  'selected_sub_branch_id': null,
  'data': <Object?>[],
};

/// Bounded settle: pumps frames until nothing is scheduled, but gives up
/// after a bounded number of frames. Never `pumpAndSettle` — a hanging
/// fetch (or a future animation) must not hang the test run.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 30; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (!tester.binding.hasScheduledFrame) break;
  }
}

Future<ProviderContainer> _pumpSheet(
  WidgetTester tester,
  SubBranchRepository repository, {
  ValueChanged<String>? onSelected,
}) async {
  final container = ProviderContainer(
    overrides: [subBranchRepositoryProvider.overrideWithValue(repository)],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: Scaffold(body: SubBranchSelectorSheet(onSelected: onSelected)),
      ),
    ),
  );
  await _settle(tester);
  return container;
}

SubBranchRepository _repositoryWith(List<Object> results) {
  return SubBranchRepository(network: _FakeSubBranchNetwork(results));
}

void main() {
  group('SubBranchSelectorSheet', () {
    testWidgets('loading state shows a skeleton, not a bare spinner', (
      tester,
    ) async {
      final container = await _pumpSheet(
        tester,
        SubBranchRepository(network: _HangingSubBranchNetwork()),
      );

      expect(
        find.byKey(const ValueKey('sub-branch-loading-skeleton')),
        findsOneWidget,
      );
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(container.read(subBranchStateProvider).isLoading, isTrue);
    });

    testWidgets('centralized mode shows the radio list (name + type)', (
      tester,
    ) async {
      final container = await _pumpSheet(
        tester,
        _repositoryWith([_centralizedMap]),
      );

      expect(find.text('Choose sub-branch'), findsOneWidget);
      expect(find.text('Gulberg Sub-Branch'), findsOneWidget);
      expect(find.text('North Sub-Branch'), findsOneWidget);
      expect(find.text('sub_branch'), findsNWidgets(2));
      expect(find.byType(RadioListTile<String>), findsNWidgets(2));
      // No pick yet in centralized mode: the create gate stays closed.
      expect(container.read(subBranchStateProvider).canProceed, isFalse);
      expect(container.read(subBranchStateProvider).effectiveId, isNull);
    });

    testWidgets('tapping a row selects it and opens the create gate', (
      tester,
    ) async {
      String? picked;
      final container = await _pumpSheet(
        tester,
        _repositoryWith([_centralizedMap]),
        onSelected: (id) => picked = id,
      );

      await tester.tap(find.text('North Sub-Branch'));
      await _settle(tester);

      expect(picked, 'sb_north');
      expect(container.read(selectedSubBranchProvider), 'sb_north');
      expect(container.read(subBranchStateProvider).effectiveId, 'sb_north');
      expect(container.read(subBranchStateProvider).canProceed, isTrue);
    });

    testWidgets('single-row scoped list resolves silently (no pick needed)', (
      tester,
    ) async {
      final container = await _pumpSheet(
        tester,
        _repositoryWith([_scopedSingleMap]),
      );

      expect(find.text('Only Sub-Branch'), findsOneWidget);
      final state = container.read(subBranchStateProvider);
      expect(state.effectiveId, 'sb_only');
      expect(state.canProceed, isTrue);
      expect(container.read(selectedSubBranchProvider), isNull);
    });

    testWidgets('empty list shows the empty state with one retry', (
      tester,
    ) async {
      final container = await _pumpSheet(tester, _repositoryWith([_emptyMap]));

      expect(
        find.text('No sub-branch assigned — contact the office'),
        findsOneWidget,
      );
      expect(find.text('Retry'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      expect(container.read(subBranchStateProvider).canProceed, isFalse);
    });

    testWidgets(
      'fetch error shows the message with one retry; retry refetches',
      (tester) async {
        final network = _FakeSubBranchNetwork([
          const NetworkException(),
          _centralizedMap,
        ]);
        final container = await _pumpSheet(
          tester,
          SubBranchRepository(network: network),
        );

        expect(
          find.text('Network error. Check your connection.'),
          findsOneWidget,
        );
        expect(find.text('Retry'), findsOneWidget);
        expect(container.read(subBranchStateProvider).canProceed, isFalse);

        await tester.tap(find.text('Retry'));
        await _settle(tester);

        expect(network.fetchCount, 2);
        expect(find.text('Gulberg Sub-Branch'), findsOneWidget);
        expect(
          find.text('Network error. Check your connection.'),
          findsNothing,
        );
      },
    );

    testWidgets(
      'failed refresh keeps the last-known list, labelled stale, gate closed',
      (tester) async {
        final network = _FakeSubBranchNetwork([
          _centralizedMap,
          const NetworkException(),
        ]);
        final container = await _pumpSheet(
          tester,
          SubBranchRepository(network: network),
        );

        expect(find.text('Gulberg Sub-Branch'), findsOneWidget);

        container.read(subBranchStateProvider.notifier).refresh();
        await _settle(tester);

        final state = container.read(subBranchStateProvider);
        expect(state.isStale, isTrue);
        expect(state.lastKnownList, isNotNull);
        expect(state.canProceed, isFalse);
        // The previous list stays on screen, labelled with its fetch time.
        expect(find.text('Gulberg Sub-Branch'), findsOneWidget);
        expect(find.textContaining('Last updated'), findsWidgets);
        expect(find.textContaining('create is paused'), findsOneWidget);
      },
    );
  });

  group('showSubBranchSelector', () {
    testWidgets('opens the sheet and returns the picked id', (tester) async {
      final container = ProviderContainer(
        overrides: [
          subBranchRepositoryProvider.overrideWithValue(
            _repositoryWith([_centralizedMap]),
          ),
        ],
      );
      addTearDown(container.dispose);

      String? returned;
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => FilledButton(
                  onPressed: () async {
                    returned = await showSubBranchSelector(context);
                  },
                  child: const Text('Open picker'),
                ),
              ),
            ),
          ),
        ),
      );
      await _settle(tester);

      await tester.tap(find.text('Open picker'));
      await _settle(tester);

      expect(find.text('Choose sub-branch'), findsOneWidget);
      await tester.tap(find.text('Gulberg Sub-Branch'));
      await _settle(tester);

      expect(returned, 'sb_gulberg');
      expect(container.read(selectedSubBranchProvider), 'sb_gulberg');
      expect(find.text('Choose sub-branch'), findsNothing);
    });
  });

  group('subBranchLastUpdatedLabel', () {
    test('formats as Last updated HH:mm', () {
      expect(
        subBranchLastUpdatedLabel(DateTime(2026, 11, 23, 9, 5)),
        'Last updated 09:05',
      );
      expect(
        subBranchLastUpdatedLabel(DateTime(2026, 11, 23, 12, 10)),
        'Last updated 12:10',
      );
    });
  });
}
