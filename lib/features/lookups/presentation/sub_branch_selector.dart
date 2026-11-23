import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/field_ops_design_tokens.dart';
import 'sub_branch_providers.dart';

/// "Last updated HH:mm" label for the stale-data rule (APP_BRIEF rule 7):
/// reference data always carries its fetch time, and a stale list says so.
String subBranchLastUpdatedLabel(DateTime updatedAt) {
  final hour = updatedAt.hour.toString().padLeft(2, '0');
  final minute = updatedAt.minute.toString().padLeft(2, '0');
  return 'Last updated $hour:$minute';
}

/// Opens the sub-branch picker as a modal bottom sheet and returns the id
/// the user picked, or `null` when the sheet is dismissed without a pick.
///
/// Phase C calls this from the create-request entry point. Only IDs returned
/// by `GET /lookups/sub-branches` can ever be returned — the sheet has no
/// free-text field and [SubBranchController.select] rejects unknown ids.
Future<String?> showSubBranchSelector(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => const SubBranchSelectorSheet(),
  );
}

/// Trigger row for the picker: shows the currently effective sub-branch
/// name, or "Choose sub-branch" when nothing is resolved yet, and opens
/// [showSubBranchSelector] on tap. Phase C places this on the
/// create-request entry point; it does not navigate anywhere on its own.
class SubBranchSelectorButton extends ConsumerWidget {
  const SubBranchSelectorButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(subBranchStateProvider);
    final scheme = Theme.of(context).colorScheme;
    final effective = state.lastKnownList?.data
        .where((branch) => branch.id == state.effectiveId)
        .firstOrNull;
    final label = effective?.name ?? 'Choose sub-branch';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: FieldOpsDesignTokens.pageMargin,
      ),
      title: Text(label, style: Theme.of(context).textTheme.titleMedium),
      subtitle: state.isStale && state.lastUpdated != null
          ? Text(
              '${subBranchLastUpdatedLabel(state.lastUpdated!)} — showing previous list',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            )
          : null,
      trailing: Icon(Icons.arrow_drop_down, color: scheme.primary),
      onTap: () => showSubBranchSelector(context),
    );
  }
}

/// Bottom-sheet content for picking a sub-branch (ISPFINAL §2 + §12).
///
/// States (APP_BRIEF rule 6 — loading is a skeleton, error has one clear
/// retry, empty is a moment not a blank page):
/// * loading with no list yet → skeleton rows in the shape of the list.
/// * fetch failed with no list → error message + one Retry button.
/// * fetch failed with a previous list → the previous list, labelled stale
///   with its "last updated …" time, plus Retry. Creating against this
///   stale list is blocked ([SubBranchState.canProceed] is `false`).
/// * fresh empty list → "No sub-branch assigned — contact the office" +
///   Retry. Never a free-text field.
/// * fresh list → radio list (name + type per row).
///
/// Tapping a row stores the id in [selectedSubBranchProvider] (via
/// [SubBranchController.select]) and — when the sheet was opened with
/// [showSubBranchSelector] — pops with the id. Tests (or an embedded use)
/// can pass [onSelected] instead to receive the pick without popping.
class SubBranchSelectorSheet extends ConsumerWidget {
  const SubBranchSelectorSheet({super.key, this.onSelected});

  final ValueChanged<String>? onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(subBranchStateProvider);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final list = state.lastKnownList;

    void pick(String id) {
      ref.read(subBranchStateProvider.notifier).select(id);
      if (onSelected != null) {
        onSelected!(id);
      } else {
        Navigator.of(context).pop(id);
      }
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          FieldOpsDesignTokens.pageMargin,
          FieldOpsDesignTokens.spaceSmMd,
          FieldOpsDesignTokens.pageMargin,
          FieldOpsDesignTokens.spaceMd,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(
                    FieldOpsDesignTokens.radiusFull,
                  ),
                ),
              ),
            ),
            const SizedBox(height: FieldOpsDesignTokens.spaceSmMd),
            Text(
              'Choose sub-branch',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (state.lastUpdated != null) ...[
              const SizedBox(height: FieldOpsDesignTokens.spaceXs),
              Text(
                state.isStale
                    ? '${subBranchLastUpdatedLabel(state.lastUpdated!)} — showing previous list'
                    : subBranchLastUpdatedLabel(state.lastUpdated!),
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: FieldOpsDesignTokens.spaceSmMd),
            if (state.isStale)
              _StaleBanner(
                onRetry: () =>
                    ref.read(subBranchStateProvider.notifier).refresh(),
              ),
            if (state.isLoading && list == null)
              const _LoadingSkeleton(
                key: ValueKey('sub-branch-loading-skeleton'),
              )
            else if (state.errorMessage != null && list == null)
              _ErrorState(
                message: state.errorMessage!,
                onRetry: () =>
                    ref.read(subBranchStateProvider.notifier).refresh(),
              )
            else if (list != null && list.data.isEmpty)
              _EmptyState(
                onRetry: () =>
                    ref.read(subBranchStateProvider.notifier).refresh(),
              )
            else if (list != null)
              Flexible(
                child: RadioGroup<String>(
                  groupValue: state.effectiveId,
                  onChanged: (id) {
                    if (id != null) pick(id);
                  },
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (final branch in list.data)
                        RadioListTile<String>(
                          value: branch.id,
                          title: Text(branch.name),
                          subtitle: Text(branch.type ?? 'Sub-branch'),
                          activeColor: scheme.primary,
                          contentPadding: EdgeInsets.zero,
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton rows in the shape of the radio list (APP_BRIEF rule 6).
class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        for (var i = 0; i < 3; i++) ...[
          Container(
            height: 56,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(
                FieldOpsDesignTokens.radiusMd,
              ),
            ),
          ),
          const SizedBox(height: FieldOpsDesignTokens.spaceSm),
        ],
      ],
    );
  }
}

/// Error state: the backend/network message + exactly one Retry button.
class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(FieldOpsDesignTokens.cardPadding),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(FieldOpsDesignTokens.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            message,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: scheme.onErrorContainer),
          ),
          const SizedBox(height: FieldOpsDesignTokens.spaceSmMd),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

/// Empty state: no sub-branch is assigned to this employee. Retry only —
/// never a free-text field, and never an invented id.
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'No sub-branch assigned — contact the office',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: FieldOpsDesignTokens.spaceSmMd),
        FilledButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    );
  }
}

/// Amber banner shown above a stale list: the data is on screen, labelled,
/// and must not be used for a create until Retry succeeds.
class _StaleBanner extends StatelessWidget {
  const _StaleBanner({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: FieldOpsDesignTokens.spaceSmMd),
      padding: const EdgeInsets.all(FieldOpsDesignTokens.spaceSmMd),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(FieldOpsDesignTokens.radiusMd),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_outlined,
            color: scheme.onSecondaryContainer,
          ),
          const SizedBox(width: FieldOpsDesignTokens.spaceSm),
          Expanded(
            child: Text(
              'Couldn’t refresh — create is paused until the list loads.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: scheme.onSecondaryContainer,
              ),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
