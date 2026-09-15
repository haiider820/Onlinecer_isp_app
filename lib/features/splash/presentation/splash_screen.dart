import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/field_ops_design_tokens.dart';
import 'boot_providers.dart';

/// Boot / readiness gate screen (stitch `splash_screen` mockup).
///
/// The status rows are the REAL boot steps from [BootController] — session
/// read, server verification (`GET /me`), team context, dashboard module —
/// not decorative telemetry. Navigation happens only after the whole
/// sequence settles: `needsLogin` → login screen, `ready` → dashboard.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Start (or restart) the boot sequence once, after first frame. Every
    // arrival on /boot — cold start or post-login — runs a fresh sequence.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(bootControllerProvider.notifier).run();
    });
  }

  @override
  Widget build(BuildContext context) {
    final boot = ref.watch(bootControllerProvider);
    final theme = Theme.of(context);

    // Navigate only when the whole gate has settled — never mid-sequence.
    ref.listen<BootState>(bootControllerProvider, (previous, next) {
      final outcome = next.outcome;
      if (outcome == null || previous?.outcome == outcome) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        switch (outcome) {
          case BootOutcome.needsLogin:
            context.go(Routes.login);
          case BootOutcome.ready:
            context.go(Routes.dashboard);
        }
      });
    });

    return Scaffold(
      body: ColoredBox(
        color: FieldOpsDesignTokens.surface,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              FieldOpsDesignTokens.pageMargin,
              FieldOpsDesignTokens.spaceSm,
              FieldOpsDesignTokens.pageMargin,
              FieldOpsDesignTokens.spaceLg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Top hardware status strip ──
                Row(
                  children: [
                    _pulseDot(FieldOpsDesignTokens.completedForeground),
                    const SizedBox(width: 4),
                    _pulseDot(FieldOpsDesignTokens.completedForeground
                        .withValues(alpha: 0.45)),
                    const SizedBox(width: 8),
                    Text(
                      'FIELD OPS OS',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const Spacer(),
                    _pill(
                      context,
                      icon: Icons.bolt,
                      label: 'v1.0.0 (Build 1)',
                    ),
                  ],
                ),
                const SizedBox(height: FieldOpsDesignTokens.spaceMd),

                // ── Primary identity card ──
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: _cardDecoration(),
                  child: Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: FieldOpsDesignTokens.primaryContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.wifi_tethering,
                          size: 30,
                          color: FieldOpsDesignTokens.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'MALIK FIBER',
                        style: FieldOpsDesignTokens.headlineLg.copyWith(
                          color: FieldOpsDesignTokens.primary,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: FieldOpsDesignTokens.surfaceContainer,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.alt_route,
                                size: 14, color: FieldOpsDesignTokens.secondary),
                            const SizedBox(width: 5),
                            Text(
                              'FIELD OPS · ENTERPRISE UTILITY GATEWAY',
                              style: FieldOpsDesignTokens.labelSm.copyWith(
                                color: FieldOpsDesignTokens.onPrimaryFixedVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: FieldOpsDesignTokens.spaceMd),

                // ── Boot sequence card ──
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: _cardDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.sync,
                                      size: 18,
                                      color: FieldOpsDesignTokens.secondary,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      'BOOT SEQUENCE',
                                      style: FieldOpsDesignTokens.labelMd.copyWith(
                                        color: FieldOpsDesignTokens.secondary,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  _statusLine(boot),
                                  style: FieldOpsDesignTokens.bodySm.copyWith(
                                    color: FieldOpsDesignTokens.onSurfaceVariant,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${boot.progress}',
                            style: FieldOpsDesignTokens.displayLg.copyWith(
                              color: FieldOpsDesignTokens.primary,
                              height: 1.0,
                            ),
                          ),
                          Text(
                            ' %',
                            style: FieldOpsDesignTokens.labelMd.copyWith(
                              color: FieldOpsDesignTokens.onSurfaceVariant,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                          tween: Tween(begin: 0, end: boot.progress / 100),
                          builder: (context, value, _) => LinearProgressIndicator(
                            value: value,
                            minHeight: 10,
                            backgroundColor:
                                FieldOpsDesignTokens.surfaceContainerHigh,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                FieldOpsDesignTokens.secondary),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      // ── Real diagnostic rows (one per boot stage) ──
                      for (final stage in BootStage.values) ...[
                        _BootRow(stage: stage),
                        if (stage != BootStage.values.last)
                          const SizedBox(height: FieldOpsDesignTokens.spaceSm),
                      ],
                      // ── Retry on unexpected boot failure ──
                      if (boot.error != null) ...[
                        const SizedBox(height: FieldOpsDesignTokens.spaceMd),
                        SizedBox(
                          height: FieldOpsDesignTokens.minTouchTarget,
                          child: FilledButton.icon(
                            onPressed: () => ref
                                .read(bootControllerProvider.notifier)
                                .run(),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Try Again'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: FieldOpsDesignTokens.spaceMd),

                // ── Auth session badge ──
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: FieldOpsDesignTokens.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(FieldOpsDesignTokens.radiusLg),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: FieldOpsDesignTokens.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.enhanced_encryption_outlined,
                          size: 20,
                          color: FieldOpsDesignTokens.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'AUTH SESSION',
                                  style: FieldOpsDesignTokens.labelSm.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: boot.step(BootStage.verify).status ==
                                            BootStepStatus.done
                                        ? FieldOpsDesignTokens.tertiaryContainer
                                        : FieldOpsDesignTokens.outlineVariant,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  boot.step(BootStage.verify).status ==
                                          BootStepStatus.done
                                      ? 'VERIFIED'
                                      : 'PENDING',
                                  style: FieldOpsDesignTokens.labelSm.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: boot.step(BootStage.verify).status ==
                                            BootStepStatus.done
                                        ? FieldOpsDesignTokens.tertiaryContainer
                                        : FieldOpsDesignTokens.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              _sessionSubtitle(boot),
                              style: FieldOpsDesignTokens.bodySm.copyWith(
                                color: FieldOpsDesignTokens.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.shield_outlined,
                          size: 20, color: FieldOpsDesignTokens.primary),
                    ],
                  ),
                ),
                const SizedBox(height: FieldOpsDesignTokens.spaceMd),

                // ── Footer ──
                Text(
                  'OUTDOOR RUGGEDISED INTERFACE PROFILE',
                  textAlign: TextAlign.center,
                  style: FieldOpsDesignTokens.labelSm.copyWith(
                    color: FieldOpsDesignTokens.onSurfaceVariant,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Malik Telecom Infrastructure Group © 2025',
                  textAlign: TextAlign.center,
                  style: FieldOpsDesignTokens.bodySm.copyWith(
                    color: FieldOpsDesignTokens.outline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
        color: FieldOpsDesignTokens.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(FieldOpsDesignTokens.radiusLg),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: FieldOpsDesignTokens.shadowLevel1,
      );

  String _statusLine(BootState boot) {
    if (boot.error != null) return boot.error!;
    final running = boot.steps
        .where((s) => s.status == BootStepStatus.running)
        .toList(growable: false);
    if (running.isEmpty) {
      return boot.outcome == null ? 'Starting boot sequence…' : 'Boot complete.';
    }
    return switch (running.first.stage) {
      BootStage.session => 'Reading saved session…',
      BootStage.verify => 'Verifying session with the server…',
      BootStage.team => 'Loading team context…',
      BootStage.dashboard => 'Preparing dashboard…',
    };
  }

  String _sessionSubtitle(BootState boot) {
    final verify = boot.step(BootStage.verify);
    switch (verify.status) {
      case BootStepStatus.done:
        final name = verify.detail.isEmpty ? 'Session verified' : verify.detail;
        return 'Signed in as $name';
      case BootStepStatus.skipped:
        return verify.detail.isEmpty ? 'No active session' : verify.detail;
      case BootStepStatus.failed:
        return 'Token rejected — sign in again.';
      case BootStepStatus.running:
      case BootStepStatus.pending:
        return 'Checking stored credentials…';
    }
  }
}

class _BootRow extends ConsumerWidget {
  const _BootRow({required this.stage});

  final BootStage stage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boot = ref.watch(bootControllerProvider);
    final step = boot.step(stage);

    final (icon, title, subtitle) = switch (stage) {
      BootStage.session => (
          Icons.lock_outline,
          'Secure Session Store',
          'Reading saved credentials',
        ),
      BootStage.verify => (
          Icons.verified_user_outlined,
          'Session Verification',
          'Verifying token with the server',
        ),
      BootStage.team => (
          Icons.groups_outlined,
          'Team Context',
          'Resolving functional team',
        ),
      BootStage.dashboard => (
          Icons.space_dashboard_outlined,
          'Dashboard Module',
          'Preparing the workspace',
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: FieldOpsDesignTokens.surfaceContainerLow,
        borderRadius: BorderRadius.circular(FieldOpsDesignTokens.radiusMd),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: FieldOpsDesignTokens.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 18, color: FieldOpsDesignTokens.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: FieldOpsDesignTokens.labelMd,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  step.detail.isNotEmpty ? step.detail : subtitle,
                  style: FieldOpsDesignTokens.bodySm.copyWith(
                    color: FieldOpsDesignTokens.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _StepPill(status: step.status),
          if (step.status == BootStepStatus.running)
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 1.6,
                color: FieldOpsDesignTokens.secondary,
              ),
            ),
        ],
      ),
    );
  }
}

class _StepPill extends StatelessWidget {
  const _StepPill({required this.status});

  final BootStepStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, background, foreground) = switch (status) {
      BootStepStatus.done => ('DONE', FieldOpsDesignTokens.tertiaryFixed,
          FieldOpsDesignTokens.onTertiaryFixed),
      BootStepStatus.running => ('RUNNING', FieldOpsDesignTokens.secondaryFixed,
          FieldOpsDesignTokens.onSecondaryFixed),
      BootStepStatus.skipped => ('SKIPPED', FieldOpsDesignTokens.surfaceContainerHigh,
          FieldOpsDesignTokens.onSurfaceVariant),
      BootStepStatus.failed => ('FAILED', FieldOpsDesignTokens.urgentBackground,
          FieldOpsDesignTokens.urgentForeground),
      BootStepStatus.pending => ('WAITING', FieldOpsDesignTokens.surfaceContainerHigh,
          FieldOpsDesignTokens.outline),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (status == BootStepStatus.done) ...[
            Icon(Icons.check_circle, size: 12, color: foreground),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: FieldOpsDesignTokens.labelSm.copyWith(color: foreground),
          ),
        ],
      ),
    );
  }
}

Widget _pulseDot(Color color) => Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );

Widget _pill(BuildContext context, {required IconData icon, required String label}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: FieldOpsDesignTokens.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: FieldOpsDesignTokens.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: FieldOpsDesignTokens.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    ),
  );
}
