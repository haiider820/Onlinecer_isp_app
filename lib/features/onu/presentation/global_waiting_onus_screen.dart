import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exceptions.dart';
import '../../../core/theme/field_ops_design_tokens.dart';
import '../../../models/direct_olt.dart';
import '../../../shared/widgets/section_card.dart';
import '../../lookups/presentation/sub_branch_providers.dart';
import 'olt_list_screen.dart';
import 'olt_providers.dart';
import 'waiting_onu_list_screen.dart';

/// All waiting ONUs, across every direct OLT (D25 — global screen).
///
/// The Waiting ONUs tile's target: one row per direct OLT of the resolved
/// sub-branch ([directOltsProvider]) with that OLT's waiting-ONU count
/// ([waitingOnusProvider] per OLT). Tapping an OLT expands its waiting
/// rows inline — serial, type, status badge, PON port, last discovered —
/// with a "Refresh from OLT" discovery button per OLT.
///
/// There is deliberately NO authorize button here: authorization belongs
/// to a request (the request-scoped waiting screen), and this screen has
/// no request context — the rows render read-only
/// ([WaitingOnuRow] with `requestId: null`). Before D25 the tile fell back
/// to the team's request list because no global screen existed (D20 gap).
///
/// The per-OLT failure rule matches the tile count provider: one OLT's
/// list failing contributes 0 to its count and shows a Retry in its
/// expanded section — it never blanks the whole screen.
class GlobalWaitingOnusScreen extends ConsumerStatefulWidget {
  const GlobalWaitingOnusScreen({super.key});

  @override
  ConsumerState<GlobalWaitingOnusScreen> createState() =>
      _GlobalWaitingOnusScreenState();
}

class _GlobalWaitingOnusScreenState
    extends ConsumerState<GlobalWaitingOnusScreen> {
  final _expanded = <String>{};

  void _toggle(String oltId) {
    setState(() {
      if (_expanded.contains(oltId)) {
        _expanded.remove(oltId);
      } else {
        _expanded.add(oltId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scope = ref.watch(subBranchStateProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Waiting ONUs')),
      body: _scopeBody(scope),
    );
  }

  Widget _scopeBody(SubBranchState scope) {
    if (scope.isLoading && scope.lastKnownList == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!scope.canProceed) {
      return SubBranchScopeGate(scope: scope);
    }
    final olts = ref.watch(directOltsProvider(scope.effectiveId));
    return olts.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _ErrorView(
        message: e is ApiException ? e.message : 'Could not load OLTs.',
        onRetry: () => ref.invalidate(directOltsProvider(scope.effectiveId)),
      ),
      data: (list) => _OltListBody(
        olts: list.data,
        expanded: _expanded,
        onToggle: _toggle,
      ),
    );
  }
}

class _OltListBody extends StatelessWidget {
  const _OltListBody({
    required this.olts,
    required this.expanded,
    required this.onToggle,
  });

  final List<DirectOlt> olts;
  final Set<String> expanded;
  final void Function(String oltId) onToggle;

  @override
  Widget build(BuildContext context) {
    if (olts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'No direct OLTs found for this sub-branch.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        for (final olt in olts)
          _GlobalOltCard(
            olt: olt,
            expanded: expanded.contains(olt.id),
            onToggle: () => onToggle(olt.id),
          ),
      ],
    );
  }
}

class _GlobalOltCard extends ConsumerWidget {
  const _GlobalOltCard({
    required this.olt,
    required this.expanded,
    required this.onToggle,
  });

  final DirectOlt olt;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final waiting = ref.watch(waitingOnusProvider(olt.id));
    // A failed fetch contributes 0 — same rule as the tile count.
    final count = waiting.whenOrNull(data: (list) => list.data.length) ?? 0;
    final supported = OltListScreen.supportsOnuFlow(olt.vendor);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onToggle,
        borderRadius:
            BorderRadius.circular(FieldOpsDesignTokens.cardRadius),
        child: SectionCard(
          title: olt.name ?? olt.id,
          icon: Icons.router_outlined,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                waiting.isLoading ? '…' : '$count waiting',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              Icon(expanded ? Icons.expand_less : Icons.expand_more),
            ],
          ),
          children: [
            if (olt.vendor != null || olt.model != null)
              InfoRow(
                label: 'Vendor',
                value: [olt.vendor, olt.model]
                    .whereType<String>()
                    .join(' · '),
              ),
            if (olt.connectionStatus != null)
              InfoRow(label: 'Status', value: olt.connectionStatus!),
            if (expanded) ...[
              const SizedBox(height: 12),
              if (!supported)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Vendor ${olt.vendor ?? 'unknown'} does not support ONU '
                    'authorization in the app. Only Huawei and VSOL OLTs '
                    'support this flow.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              _ExpandedWaiting(olt: olt, supported: supported),
            ],
          ],
        ),
      ),
    );
  }
}

/// The expanded section of one OLT card: discovery refresh + its waiting
/// rows (read-only — no request context, so no authorize buttons).
class _ExpandedWaiting extends ConsumerWidget {
  const _ExpandedWaiting({required this.olt, required this.supported});

  final DirectOlt olt;
  final bool supported;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cached = ref.watch(waitingOnusProvider(olt.id));
    final discovery = ref.watch(discoveryControllerProvider(olt.id));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton.icon(
            onPressed: discovery.isDiscovering
                ? null
                : () => ref
                    .read(discoveryControllerProvider(olt.id).notifier)
                    .discover(),
            icon: discovery.isDiscovering
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_outlined),
            label: Text(
              discovery.isDiscovering
                  ? 'Contacting OLT…'
                  : 'Refresh from OLT',
            ),
          ),
        ),
        if (discovery.hasError) ...[
          const SizedBox(height: 8),
          Text(
            discovery.errorMessage!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
        const SizedBox(height: 12),
        cached.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _ErrorView(
            message: e is ApiException
                ? e.message
                : 'Could not load waiting ONUs.',
            onRetry: () => ref.invalidate(waitingOnusProvider(olt.id)),
          ),
          data: (list) {
            if (list.data.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'No waiting ONUs on this OLT.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            }
            return Column(
              children: [
                for (final onu in list.data)
                  WaitingOnuRow(
                    // No request context on the global screen.
                    requestId: null,
                    oltId: olt.id,
                    onu: onu,
                    vendorSupported: supported,
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
