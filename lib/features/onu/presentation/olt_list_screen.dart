import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exceptions.dart';
import '../../../core/router/app_router.dart';
import '../../../models/direct_olt.dart';
import '../../../shared/widgets/section_card.dart';
import '../../lookups/presentation/sub_branch_providers.dart';
import '../../lookups/presentation/sub_branch_selector.dart';
import 'olt_providers.dart';

/// OLT picker for one connection request (ISPFINAL §5).
///
/// The list is scoped by the request's sub-branch
/// ([subBranchStateProvider.effectiveId]) — the OLT list screen is only
/// reachable from the installation detail's Authorize-ONU entry, and the
/// scope is never invented client-side. Only Huawei + VSOL OLTs support the
/// waiting-ONU flow; any other vendor is labelled plainly on its row
/// instead of offering a dead button.
class OltListScreen extends ConsumerWidget {
  const OltListScreen({super.key, required this.requestId});

  final String requestId;

  /// True for the two vendors the backend's waiting-ONU flow supports.
  static bool supportsOnuFlow(String? vendor) {
    final v = vendor?.toLowerCase() ?? '';
    return v.contains('huawei') || v.contains('vsol');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scope = ref.watch(subBranchStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Choose OLT')),
      body: _scopeBody(context, ref, scope),
    );
  }

  Widget _scopeBody(
    BuildContext context,
    WidgetRef ref,
    SubBranchState scope,
  ) {
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
      data: (list) => _OltListBody(requestId: requestId, olts: list.data),
    );
  }
}

/// Shown when no sub-branch scope is resolved yet: the selector (centralized
/// mode) or the load error, never an invented id.
///
/// Public so the D25 global waiting screen reuses the same gate instead of
/// duplicating it.
class SubBranchScopeGate extends ConsumerWidget {
  const SubBranchScopeGate({super.key, required this.scope});

  final SubBranchState scope;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        if (scope.errorMessage != null) ...[
          Text(
            scope.errorMessage!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () =>
                ref.read(subBranchStateProvider.notifier).refresh(),
            child: const Text('Retry'),
          ),
          const SizedBox(height: 12),
        ],
        if (scope.lastKnownList != null) const SubBranchSelectorButton(),
        if (scope.lastKnownList == null && scope.errorMessage == null)
          Text(
            'No sub-branch assigned — contact the office.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}

class _OltListBody extends StatelessWidget {
  const _OltListBody({required this.requestId, required this.olts});

  final String requestId;
  final List<DirectOlt> olts;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (olts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'No direct OLTs found for this sub-branch.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        for (final olt in olts) _OltRow(requestId: requestId, olt: olt),
      ],
    );
  }
}

class _OltRow extends StatelessWidget {
  const _OltRow({required this.requestId, required this.olt});

  final String requestId;
  final DirectOlt olt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final supported = OltListScreen.supportsOnuFlow(olt.vendor);
    final preset = olt.authorizationPreset;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SectionCard(
        title: olt.name ?? olt.id,
        icon: Icons.router_outlined,
        children: [
          if (olt.vendor != null || olt.model != null)
            InfoRow(
              label: 'Vendor',
              value: [olt.vendor, olt.model]
                  .whereType<String>()
                  .join(' · '),
            ),
          if (olt.managementIp != null)
            InfoRow(label: 'Management IP', value: olt.managementIp!),
          if (olt.connectionStatus != null)
            InfoRow(label: 'Status', value: olt.connectionStatus!),
          if (olt.runningAuthorizationsCount != null)
            InfoRow(
              label: 'Authorizations running',
              value: '${olt.runningAuthorizationsCount}',
            ),
          InfoRow(
            label: 'Authorization preset',
            value: preset?.ready == true ? 'Ready' : 'Not ready — enter profiles manually',
          ),
          const SizedBox(height: 12),
          if (supported)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: () => context.push(
                  Routes.waitingOnusFor(requestId, olt.id),
                ),
                child: const Text('View waiting ONUs'),
              ),
            )
          else
            Text(
              'Vendor ${olt.vendor ?? 'unknown'} does not support ONU '
              'authorization in the app.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
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
