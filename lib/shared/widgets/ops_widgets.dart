import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/field_ops_design_tokens.dart';

/// "Midnight Ops" component kit — the building blocks of the redesigned
/// screens. Every widget is theme-aware (reads [Theme.of]) so light and dark
/// mode both render correctly. No hardcoded hex anywhere.
///
/// Contents: [OpsCard], [OpsSectionLabel], [OpsAvatar], [StatTile],
/// [MissionStepper], [MissionHeader], [ActionDock], [OptionTile],
/// [FatPickerCard], [WireStepper], [InventoryStepperRow], [CheckTile],
/// [VoiceRecorderCard], [OpsBadge], [PriorityFlag], [FilterChips],
/// [ChatBubble], [SystemPill], [InternalNoteCard], [VoiceNoteBubble],
/// [OpsComposer], [OpsTimeline].

// ─── OpsCard ──────────────────────────────────────────────────────────────

/// Signature ops card: 18px radius, hairline border, soft shadow, optional
/// glowing status edge on the left.
class OpsCard extends StatelessWidget {
  const OpsCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.edgeColor,
    this.onTap,
    this.margin = EdgeInsets.zero,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  /// When set, paints a glowing 3px edge on the card's left side.
  final Color? edgeColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius:
            BorderRadius.circular(FieldOpsDesignTokens.cardRadius),
        border: Border.all(color: theme.colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(FieldOpsDesignTokens.cardRadius),
        child: Stack(
          children: [
            Padding(padding: padding, child: child),
            if (edgeColor != null)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 3,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: edgeColor,
                    boxShadow: [
                      BoxShadow(
                        color: edgeColor!.withValues(alpha: 0.8),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
    if (onTap == null) return card;
    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(FieldOpsDesignTokens.cardRadius),
      child: card,
    );
  }
}

// ─── OpsSectionLabel ──────────────────────────────────────────────────────

/// Uppercase eyebrow label used above card groups.
class OpsSectionLabel extends StatelessWidget {
  const OpsSectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 18, 2, 10),
      child: Text(
        text.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}

// ─── OpsAvatar ────────────────────────────────────────────────────────────

/// Gradient initials avatar (cyan → violet) with a soft glow.
class OpsAvatar extends StatelessWidget {
  const OpsAvatar({super.key, required this.initials, this.size = 48});

  final String initials;
  final double size;

  static String initialsOf(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.32),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: opsGlow(context),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: theme.colorScheme.onPrimary,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.34,
        ),
      ),
    );
  }
}

// ─── StatTile ─────────────────────────────────────────────────────────────

/// Mono instrument readout tile for dashboards.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.value,
    required this.label,
    this.accent = false,
  });

  final String value;
  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: OpsCard(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Text(
              value,
              style: FieldOpsDesignTokens.dataLg.copyWith(
                color: accent
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 9.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── MissionStepper ───────────────────────────────────────────────────────

/// Horizontal 5-stage mission stepper: done → glowing current → todo.
class MissionStepper extends StatelessWidget {
  const MissionStepper({
    super.key,
    required this.steps,
    required this.currentIndex,
  }) : assert(steps.length >= 2);

  final List<String> steps;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Row(
      children: [
        for (var i = 0; i < steps.length; i++)
          Expanded(
            child: _Step(
              label: steps[i],
              state: i < currentIndex
                  ? _StepState.done
                  : i == currentIndex
                      ? _StepState.now
                      : _StepState.todo,
              showLine: i > 0,
              primary: primary,
              onSurfaceVariant: theme.colorScheme.onSurfaceVariant,
              onSurface: theme.colorScheme.onSurface,
              onPrimary: theme.colorScheme.onPrimary,
              cardColor: theme.colorScheme.surfaceContainerLow,
            ),
          ),
      ],
    );
  }
}

enum _StepState { done, now, todo }

class _Step extends StatelessWidget {
  const _Step({
    required this.label,
    required this.state,
    required this.showLine,
    required this.primary,
    required this.onSurfaceVariant,
    required this.onSurface,
    required this.onPrimary,
    required this.cardColor,
  });

  final String label;
  final _StepState state;
  final bool showLine;
  final Color primary;
  final Color onSurfaceVariant;
  final Color onSurface;
  final Color onPrimary;
  final Color cardColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 22,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (showLine)
                Positioned(
                  left: -20,
                  right: 20,
                  top: 10,
                  child: Container(
                    height: 2,
                    color: state == _StepState.done
                        ? primary
                        : onSurfaceVariant.withValues(alpha: 0.25),
                  ),
                ),
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: state == _StepState.done
                      ? primary
                      : state == _StepState.now
                          ? cardColor
                          : Colors.transparent,
                  border: Border.all(
                    color: state == _StepState.todo
                        ? onSurfaceVariant.withValues(alpha: 0.4)
                        : primary,
                    width: 2,
                  ),
                  boxShadow: state == _StepState.now ? opsGlow(context) : null,
                ),
                alignment: Alignment.center,
                child: state == _StepState.done
                    ? Icon(Icons.check, size: 12, color: onPrimary)
                    : state == _StepState.now
                        ? Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: primary,
                            ),
                          )
                        : null,
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 8.5,
            fontWeight: FontWeight.w600,
            color: state == _StepState.now
                ? primary
                : state == _StepState.done
                    ? onSurface
                    : onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// ─── MissionHeader ────────────────────────────────────────────────────────

/// Sticky mission header: back button, mono request id, live status pill,
/// and the mission stepper underneath.
class MissionHeader extends StatelessWidget {
  const MissionHeader({
    super.key,
    required this.requestId,
    required this.statusLabel,
    required this.steps,
    required this.currentStep,
    this.onBack,
  });

  final String requestId;
  final String statusLabel;
  final List<String> steps;
  final int currentStep;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (onBack != null)
                InkWell(
                  onTap: onBack,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: theme.colorScheme.outlineVariant),
                      color: theme.colorScheme.surfaceContainerLowest,
                    ),
                    alignment: Alignment.center,
                    child: Icon(Icons.chevron_left,
                        color: theme.colorScheme.onSurface),
                  ),
                ),
              if (onBack != null) const SizedBox(width: 10),
              Text(
                requestId,
                style: FieldOpsDesignTokens.dataMd.copyWith(color: primary),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: primary.withValues(alpha: 0.12),
                  border: Border.all(
                      color: primary.withValues(alpha: 0.35)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PulseDot(color: primary),
                    const SizedBox(width: 6),
                    Text(
                      statusLabel.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          MissionStepper(steps: steps, currentIndex: currentStep),
        ],
      ),
    );
  }
}

class PulseDot extends StatefulWidget {
  const PulseDot({super.key, required this.color});
  final Color color;

  @override
  State<PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1600))
      ..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.color,
          boxShadow: [
            BoxShadow(
              color: widget.color.withValues(alpha: 0.6 * (1 - _c.value)),
              blurRadius: 6,
              spreadRadius: 3 * _c.value,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── ActionDock ───────────────────────────────────────────────────────────

/// Grouped quick actions (Call / Navigate / WhatsApp): one primary + rest.
class ActionDock extends StatelessWidget {
  const ActionDock({super.key, required this.actions});

  final List<DockAction> actions;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < actions.length; i++) ...[
          Expanded(child: _DockButton(action: actions[i])),
          if (i < actions.length - 1) const SizedBox(width: 10),
        ],
      ],
    );
  }
}

class DockAction {
  const DockAction({
    required this.label,
    required this.icon,
    this.onTap,
    this.primary = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool primary;
}

class _DockButton extends StatelessWidget {
  const _DockButton({required this.action});

  final DockAction action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Material(
      color: action.primary
          ? primary
          : theme.colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(15),
      elevation: 0,
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: action.primary
                  ? primary
                  : theme.colorScheme.outlineVariant,
            ),
            boxShadow: action.primary ? opsGlow(context) : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                action.icon,
                size: 19,
                color: action.primary
                    ? theme.colorScheme.onPrimary
                    : primary,
              ),
              const SizedBox(height: 6),
              Text(
                action.label,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: action.primary
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── OptionTile ───────────────────────────────────────────────────────────

/// Big tappable option tile (e.g. OLT ownership: User / Company).
class OptionTile extends StatelessWidget {
  const OptionTile({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: selected
                ? primary.withValues(alpha: 0.1)
                : theme.colorScheme.surfaceContainerLow,
            border: Border.all(
              color: selected
                  ? primary
                  : theme.colorScheme.outlineVariant,
              width: selected ? 1.5 : 1,
            ),
            boxShadow: selected ? opsGlow(context) : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 22,
                color: selected
                    ? primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 7),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: selected
                      ? primary
                      : theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── FatPickerCard ────────────────────────────────────────────────────────

/// "Signal source" picker card: mono node id + meta + chevron.
class FatPickerCard extends StatelessWidget {
  const FatPickerCard({
    super.key,
    required this.nodeId,
    required this.meta,
    required this.onTap,
  });

  final String nodeId;
  final String meta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: primary.withValues(alpha: 0.07),
          border: Border.all(color: primary.withValues(alpha: 0.45)),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: primary.withValues(alpha: 0.14),
              ),
              child: Icon(Icons.cell_tower, size: 19, color: primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nodeId,
                    style: FieldOpsDesignTokens.dataMd
                        .copyWith(color: primary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    meta,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

// ─── WireStepper ──────────────────────────────────────────────────────────

/// Glove-friendly stepper input: − [ mono value + unit ] +
class WireStepper extends StatelessWidget {
  const WireStepper({
    super.key,
    required this.value,
    required this.unit,
    required this.onDecrement,
    required this.onIncrement,
  });

  final String value;
  final String unit;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget stepBtn(IconData icon, VoidCallback onTap) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border:
                Border.all(color: theme.colorScheme.outlineVariant),
            color: theme.colorScheme.surfaceContainerLow,
          ),
          child: Icon(icon, color: theme.colorScheme.primary, size: 20),
        ),
      );
    }

    return Row(
      children: [
        stepBtn(Icons.remove, onDecrement),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: theme.colorScheme.outlineVariant),
              color: theme.colorScheme.surfaceContainerLow,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: FieldOpsDesignTokens.dataLg.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  unit.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 9.5,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        stepBtn(Icons.add, onIncrement),
      ],
    );
  }
}

// ─── InventoryStepperRow ──────────────────────────────────────────────────

/// Inventory line with a quantity stepper.
class InventoryStepperRow extends StatelessWidget {
  const InventoryStepperRow({
    super.key,
    required this.name,
    this.subtitle,
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  final String name;
  final String? subtitle;
  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: theme.colorScheme.outlineVariant),
        color: theme.colorScheme.surfaceContainerLow,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: FieldOpsDesignTokens.dataSm.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          _QtyBtn(icon: Icons.remove, onTap: onDecrement),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '$quantity',
              style: FieldOpsDesignTokens.dataMd.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          _QtyBtn(icon: Icons.add, onTap: onIncrement),
        ],
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  const _QtyBtn({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: theme.colorScheme.outlineVariant),
          color: theme.colorScheme.surfaceContainerLowest,
        ),
        child: Icon(icon, size: 15, color: theme.colorScheme.primary),
      ),
    );
  }
}

// ─── CheckTile ────────────────────────────────────────────────────────────

/// Tappable checklist tile (e.g. site checklist on the survey screen).
class CheckTile extends StatelessWidget {
  const CheckTile({
    super.key,
    required this.label,
    required this.checked,
    required this.onTap,
  });

  final String label;
  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ok = theme.colorScheme.tertiary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: checked ? ok : theme.colorScheme.outlineVariant,
            width: checked ? 1.5 : 1,
          ),
          color: checked
              ? ok.withValues(alpha: 0.08)
              : theme.colorScheme.surfaceContainerLowest,
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(9),
                color: checked
                    ? ok
                    : Colors.transparent,
                border: Border.all(
                  color: checked
                      ? ok
                      : theme.colorScheme.outlineVariant,
                  width: 1.5,
                ),
              ),
              child: checked
                  ? Icon(Icons.check,
                      size: 15, color: theme.colorScheme.onTertiary)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── VoiceRecorderCard ────────────────────────────────────────────────────

/// Voice-first input card: big glowing mic, timer, waveform, typed fallback.
class VoiceRecorderCard extends StatelessWidget {
  const VoiceRecorderCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.elapsedLabel,
    required this.isRecording,
    required this.onMicTap,
    this.waveformBars = const [8, 16, 24, 12, 20, 9, 18, 26, 14, 10, 22, 15],
    this.onTypeTap,
  });

  final String title;
  final String subtitle;
  final String elapsedLabel;
  final bool isRecording;
  final VoidCallback onMicTap;
  final List<double> waveformBars;
  final VoidCallback? onTypeTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final violet = theme.colorScheme.secondary;
    final primary = theme.colorScheme.primary;
    return OpsCard(
      child: Column(
        children: [
          Text(title,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: onMicTap,
            customBorder: const CircleBorder(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [violet, primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: opsGlow(context),
                border: isRecording
                    ? Border.all(
                        color: theme.colorScheme.error, width: 3)
                    : null,
              ),
              child: Icon(
                isRecording ? Icons.stop : Icons.mic,
                size: 30,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            elapsedLabel,
            style: FieldOpsDesignTokens.dataMd.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final h in waveformBars)
                Container(
                  width: 4,
                  height: isRecording ? h : h * 0.45,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    gradient: LinearGradient(
                      colors: [primary, violet],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
            ],
          ),
          if (onTypeTap != null) ...[
            const SizedBox(height: 12),
            InkWell(
              onTap: onTypeTap,
              borderRadius: BorderRadius.circular(13),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant,
                    style: BorderStyle.solid,
                  ),
                  color: theme.colorScheme.surfaceContainerLow,
                ),
                child: Text(
                  '…or tap here to type instead',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
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

// ─── OpsBadge / PriorityFlag / FilterChips ─────────────────────────────────

/// Glowing status pill.
class OpsBadge extends StatelessWidget {
  const OpsBadge({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: background,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration:
                BoxDecoration(shape: BoxShape.circle, color: foreground),
          ),
          const SizedBox(width: 6),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}

/// HIGH priority flag.
class PriorityFlag extends StatelessWidget {
  const PriorityFlag({super.key, this.label = 'HIGH'});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final red = theme.colorScheme.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: red.withValues(alpha: 0.12),
        border: Border.all(color: red),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
          color: red,
        ),
      ),
    );
  }
}

/// Horizontally scrollable filter chips with counts.
class FilterChips extends StatelessWidget {
  const FilterChips({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<FilterOption> options;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final o in options)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(o.label),
                    if (o.count != null) ...[
                      const SizedBox(width: 5),
                      Text(
                        '${o.count}',
                        style: TextStyle(
                          fontFamily:
                              FieldOpsDesignTokens.monoFamily,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
                selected: selected == o.value,
                onSelected: (_) => onSelected(o.value),
                selectedColor: primary.withValues(alpha: 0.14),
                side: BorderSide(
                  color: selected == o.value
                      ? primary
                      : theme.colorScheme.outlineVariant,
                ),
                labelStyle: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: selected == o.value
                      ? primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                showCheckmark: false,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class FilterOption {
  const FilterOption(this.value, this.label, [this.count]);
  final String value;
  final String label;
  final int? count;
}

// ─── Discussion thread ────────────────────────────────────────────────────

/// Chat-style message bubble (left = others, right = you).
class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
    required this.author,
    required this.timeLabel,
    this.isMine = false,
    this.avatarInitials,
    this.tickLabel,
  });

  final String message;
  final String author;
  final String timeLabel;
  final bool isMine;
  final String? avatarInitials;
  final String? tickLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final bubble = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isMine ? 16 : 4),
          topRight: Radius.circular(isMine ? 4 : 16),
          bottomLeft: const Radius.circular(16),
          bottomRight: const Radius.circular(16),
        ),
        color: isMine
            ? primary.withValues(alpha: 0.13)
            : theme.colorScheme.surfaceContainerLowest,
        border: Border.all(
          color: isMine
              ? primary.withValues(alpha: 0.35)
              : theme.colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(height: 1.5)),
          const SizedBox(height: 6),
          Text(
            '$author · $timeLabel${tickLabel != null ? '  $tickLabel' : ''}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isMine) ...[
          OpsAvatar(
              initials: avatarInitials ?? OpsAvatar.initialsOf(author),
              size: 32),
          const SizedBox(width: 9),
        ],
        Flexible(child: bubble),
      ],
    );
  }
}

/// Centered system pill for status changes inside the thread.
class SystemPill extends StatelessWidget {
  const SystemPill({super.key, required this.text, required this.timeLabel});

  final String text;
  final String timeLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Center(
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: primary.withValues(alpha: 0.09),
          border: Border.all(color: primary.withValues(alpha: 0.28)),
        ),
        child: Text(
          '$text · $timeLabel',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: primary,
          ),
        ),
      ),
    );
  }
}

/// Internal note card — visibly distinct, violet dashed, locked to staff.
class InternalNoteCard extends StatelessWidget {
  const InternalNoteCard({
    super.key,
    required this.message,
    required this.author,
    required this.timeLabel,
  });

  final String message;
  final String author;
  final String timeLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final violet = theme.colorScheme.secondary;
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: violet.withValues(alpha: 0.08),
        border: Border.all(
          color: violet.withValues(alpha: 0.5),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lock_outline, size: 12, color: violet),
              const SizedBox(width: 6),
              Text(
                'INTERNAL ONLY · CUSTOMER CAN\u2019T SEE',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                  color: violet,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(message,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(height: 1.5)),
          const SizedBox(height: 6),
          Text(
            '$author · $timeLabel',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

/// Inline voice-note bubble with play button + waveform + duration.
class VoiceNoteBubble extends StatelessWidget {
  const VoiceNoteBubble({
    super.key,
    required this.durationLabel,
    required this.onPlay,
    this.isPlaying = false,
  });

  final String durationLabel;
  final VoidCallback onPlay;
  final bool isPlaying;

  static const _bars = [8.0, 16.0, 11.0, 20.0, 14.0, 18.0, 9.0, 22.0, 13.0, 17.0, 10.0, 15.0];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return InkWell(
      onTap: onPlay,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: primary.withValues(alpha: 0.08),
          border: Border.all(color: primary.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primary,
                boxShadow: opsGlow(context),
              ),
              child: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                size: 17,
                color: theme.colorScheme.onPrimary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Row(
                children: [
                  for (final h in _bars)
                    Container(
                      width: 3,
                      height: h,
                      margin:
                          const EdgeInsets.symmetric(horizontal: 1.5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: primary.withValues(alpha: 0.75),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              durationLabel,
              style: FieldOpsDesignTokens.dataSm.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sticky bottom composer: attach + input + mic + send.
class OpsComposer extends StatelessWidget {
  const OpsComposer({
    super.key,
    required this.controller,
    this.hintText = 'Message…',
    this.onAttach,
    this.onMic,
    required this.onSend,
  });

  final TextEditingController controller;
  final String hintText;
  final VoidCallback? onAttach;
  final VoidCallback? onMic;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
            top: BorderSide(color: theme.colorScheme.outlineVariant)),
      ),
      child: Row(
        children: [
          _RoundIcon(
              icon: Icons.add,
              color: theme.colorScheme.onSurfaceVariant,
              onTap: onAttach),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 4,
              style: theme.textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: hintText,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 11),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: BorderSide(
                      color: theme.colorScheme.outlineVariant),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: BorderSide(
                      color: theme.colorScheme.outlineVariant),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: BorderSide(color: primary, width: 1.5),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _RoundIcon(
              icon: Icons.mic_outlined,
              color: theme.colorScheme.secondary,
              onTap: onMic),
          const SizedBox(width: 8),
          InkWell(
            onTap: onSend,
            customBorder: const CircleBorder(),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primary,
                boxShadow: opsGlow(context),
              ),
              child: Icon(Icons.send,
                  size: 18, color: theme.colorScheme.onPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon(
      {required this.icon, required this.color, required this.onTap});

  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border:
              Border.all(color: theme.colorScheme.outlineVariant),
          color: theme.colorScheme.surfaceContainerLowest,
        ),
        child: Icon(icon, size: 19, color: color),
      ),
    );
  }
}

// ─── OpsTimeline ──────────────────────────────────────────────────────────

/// Vertical event timeline (used on the ticket screen).
class OpsTimeline extends StatelessWidget {
  const OpsTimeline({super.key, required this.events});

  final List<TimelineEvent> events;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        for (var i = 0; i < events.length; i++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  children: [
                    _TlDot(event: events[i]),
                    if (i < events.length - 1)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: events[i].done
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outlineVariant,
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          events[i].title,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: events[i].done
                                ? theme.colorScheme.onSurface
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          events[i].subtitle,
                          style: FieldOpsDesignTokens.dataSm.copyWith(
                            color:
                                theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _TlDot extends StatelessWidget {
  const _TlDot({required this.event});

  final TimelineEvent event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final current = event.current && !event.done;
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: event.done ? primary : Colors.transparent,
        border: Border.all(
          color: current
              ? primary
              : event.done
                  ? primary
                  : theme.colorScheme.outlineVariant,
          width: 2,
        ),
        boxShadow: current ? opsGlow(context) : null,
      ),
      alignment: Alignment.center,
      child: event.done
          ? Icon(Icons.check,
              size: 12, color: theme.colorScheme.onPrimary)
          : current
              ? Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: primary),
                )
              : Text(
                  '${event.index}',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
    );
  }
}

class TimelineEvent {
  const TimelineEvent({
    required this.title,
    required this.subtitle,
    required this.index,
    this.done = false,
    this.current = false,
  });

  final String title;
  final String subtitle;
  final int index;
  final bool done;
  final bool current;
}
