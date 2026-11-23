import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exceptions.dart';
import '../../../core/router/app_router.dart';
import '../../../models/waiting_onu.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../lookups/presentation/sub_branch_providers.dart';
import 'olt_list_screen.dart';
import 'olt_providers.dart';

/// Cached waiting ONUs for one OLT (ISPFINAL §6–§7).
///
/// Opens with the CACHED GET list (fast, no OLT contact) + a "last updated"
/// label; "Refresh from OLT" fires the POST discovery. A failed discovery
/// (e.g. HTTP 422 with a message) shows the message + Retry and KEEPS the
/// previous cached list — the backend preserves previous rows, so the screen
/// is never blanked by a failed refresh.
class WaitingOnuListScreen extends ConsumerStatefulWidget {
  const WaitingOnuListScreen({
    super.key,
    required this.requestId,
    required this.oltId,
  });

  final String requestId;
  final String oltId;

  @override
  ConsumerState<WaitingOnuListScreen> createState() =>
      _WaitingOnuListScreenState();
}

class _WaitingOnuListScreenState extends ConsumerState<WaitingOnuListScreen> {
  DateTime? _lastUpdated;

  static String _timeLabel(DateTime at) {
    final h = at.hour.toString().padLeft(2, '0');
    final m = at.minute.toString().padLeft(2, '0');
    return 'Last updated $h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final scope = ref.watch(subBranchStateProvider);
    final cached = ref.watch(waitingOnusProvider(widget.oltId));
    final discovery = ref.watch(discoveryControllerProvider(widget.oltId));
    final olts = ref.watch(directOltsProvider(scope.effectiveId));

    // Stamp the cached list's arrival time (once per fresh load) for the
    // "last updated" label; a discovery success re-stamps it below.
    ref.listen(waitingOnusProvider(widget.oltId), (previous, next) {
      next.whenOrNull(
        data: (_) {
          if (mounted) setState(() => _lastUpdated ??= DateTime.now());
        },
      );
    });

    final olt = olts.valueOrNull?.data
        .where((o) => o.id == widget.oltId)
        .firstOrNull;
    final vendorSupported = olt == null
        ? true // Unknown OLT (list still loading): don't block the cached rows.
        : OltListScreen.supportsOnuFlow(olt.vendor);
    final lastUpdated = discovery.discoveredAt ?? _lastUpdated;

    return Scaffold(
      appBar: AppBar(title: Text(olt?.name ?? 'Waiting ONUs')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          if (!vendorSupported)
            _VendorUnsupportedNote(vendor: olt.vendor),
          if (lastUpdated != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                _timeLabel(lastUpdated),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
          if (discovery.seenCount != null || discovery.source != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                [
                  if (discovery.source != null) 'Source: ${discovery.source}',
                  if (discovery.seenCount != null)
                    'Seen: ${discovery.seenCount}',
                ].join(' · '),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
          if (vendorSupported)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: discovery.isDiscovering
                    ? null
                    : () => ref
                        .read(
                          discoveryControllerProvider(widget.oltId).notifier,
                        )
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
            const SizedBox(height: 12),
            _DiscoveryError(
              message: discovery.errorMessage!,
              onRetry: () => ref
                  .read(discoveryControllerProvider(widget.oltId).notifier)
                  .discover(),
            ),
          ],
          const SizedBox(height: 12),
          cached.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => _ErrorView(
              message: e is ApiException
                  ? e.message
                  : 'Could not load waiting ONUs.',
              onRetry: () =>
                  ref.invalidate(waitingOnusProvider(widget.oltId)),
            ),
            data: (list) => _OnuListBody(
              requestId: widget.requestId,
              oltId: widget.oltId,
              onus: list.data,
              vendorSupported: vendorSupported,
            ),
          ),
          if (vendorSupported) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () => context.push(
                  Routes.authorizeOnuSerialFor(widget.requestId, widget.oltId),
                ),
                icon: const Icon(Icons.add_outlined),
                label: const Text('Authorize by serial number'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _VendorUnsupportedNote extends StatelessWidget {
  const _VendorUnsupportedNote({required this.vendor});

  final String? vendor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        'Vendor ${vendor ?? 'unknown'} does not support ONU authorization '
        'in the app. Only Huawei and VSOL OLTs support this flow.',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _DiscoveryError extends StatelessWidget {
  const _DiscoveryError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onErrorContainer,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Showing the previous cached list.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onErrorContainer,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnuListBody extends StatelessWidget {
  const _OnuListBody({
    required this.requestId,
    required this.oltId,
    required this.onus,
    required this.vendorSupported,
  });

  final String requestId;
  final String oltId;
  final List<WaitingOnu> onus;
  final bool vendorSupported;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (onus.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
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
        for (final onu in onus)
          _OnuRow(
            requestId: requestId,
            oltId: oltId,
            onu: onu,
            vendorSupported: vendorSupported,
          ),
      ],
    );
  }
}

class _OnuRow extends StatelessWidget {
  const _OnuRow({
    required this.requestId,
    required this.oltId,
    required this.onu,
    required this.vendorSupported,
  });

  final String requestId;
  final String oltId;
  final WaitingOnu onu;
  final bool vendorSupported;

  /// Maps the backend's ONU authorization status onto the kit status
  /// colours (assigned blue / in progress amber / done green / urgent red)
  /// via [StatusBadge]'s existing palette.
  static String _badgeStatus(String? raw) => switch (raw) {
        'waiting_authorization' => 'assigned',
        'queued' => 'pending',
        'authorizing' => 'in_progress',
        'failed' => 'failed',
        'needs_attention' => 'urgent',
        _ => raw ?? 'pending',
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final failed = onu.authorizationStatus == 'failed' ||
        onu.authorizationStatus == 'needs_attention';
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SectionCard(
        title: onu.serialNumber ?? onu.id,
        icon: Icons.settings_input_component_outlined,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  onu.detectedOnuType ?? 'Unknown ONU type',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              StatusBadge(status: _badgeStatus(onu.authorizationStatus)),
            ],
          ),
          if (onu.ponPort != null)
            InfoRow(label: 'PON port', value: onu.ponPort!),
          if (onu.lastDiscoveredAt != null)
            InfoRow(label: 'Last discovered', value: onu.lastDiscoveredAt!),
          if (failed && onu.authorizationReason != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                onu.authorizationReason!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
          if (vendorSupported) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: () => context.push(
                  Routes.authorizeOnuFor(requestId, oltId, onu.id),
                ),
                child: const Text('Authorize this ONU'),
              ),
            ),
          ],
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
