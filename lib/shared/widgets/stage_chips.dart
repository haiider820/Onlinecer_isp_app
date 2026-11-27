import 'package:flutter/material.dart';

/// Top row of stage chips that reveal previous-stage data on tap (D21).
///
/// Previous-stage blocks are collapsed by default on every detail screen:
/// the user sees only the current stage's work until they tap a chip. One
/// chip open at a time; tapping the open chip closes it again. Only stages
/// that actually have data get a chip — the caller builds [labels] from
/// non-empty blocks only.
class StageChips extends StatelessWidget {
  const StageChips({
    super.key,
    required this.labels,
    required this.selected,
    required this.onSelect,
  });

  /// One chip per stage/group that has data. An empty list renders nothing.
  final List<String> labels;

  /// Index of the open chip, or null when all are collapsed (the default).
  final int? selected;

  /// Fires with the tapped index; the parent toggles (same index closes).
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    if (labels.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            GestureDetector(
              onTap: () => onSelect(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: selected == i
                      ? theme.colorScheme.primary
                      : Colors.transparent,
                  border: Border.all(
                    color: selected == i
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outlineVariant,
                  ),
                ),
                child: Text(
                  labels[i],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: selected == i
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A single previous-stage block behind its own top chip: collapsed by
/// default, tap the chip to show the content, tap again to hide it.
/// For screens with one standalone block (e.g. the Inventory-approval card
/// on the survey detail); multi-block screens use [StageChips] instead.
class CollapsibleStageSection extends StatefulWidget {
  const CollapsibleStageSection({
    super.key,
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  State<CollapsibleStageSection> createState() =>
      _CollapsibleStageSectionState();
}

class _CollapsibleStageSectionState extends State<CollapsibleStageSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StageChips(
          labels: [widget.label],
          selected: _expanded ? 0 : null,
          onSelect: (_) => setState(() => _expanded = !_expanded),
        ),
        if (_expanded) ...[
          const SizedBox(height: 8),
          widget.child,
        ],
      ],
    );
  }
}
