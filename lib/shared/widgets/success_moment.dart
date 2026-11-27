import 'package:flutter/material.dart';

/// Native success moment (kit DESIGN.md Rule 8: "Success ek real moment
/// hai: `HaiderCelebration`, har tap par nahi").
///
/// Pure Flutter, no Lottie, no Rive: a check badge pops in with an elastic
/// overshoot, one expanding ring in the app's sky primary fades out — the
/// "Signal" pulse, Onlinecer's living thing (APP_BRIEF) — and the success
/// WORDS appear underneath (headline + optional subtitle), because a
/// success shown with icon alone says nothing on a screenshot.
///
/// One living element only (Rule 1): the ring IS the pulse — there is no
/// second animation stacked on top of it. The whole moment plays once
/// (~1.4s) and then calls [onComplete]; it never loops.
///
/// Reduced motion (Rule 5): when `MediaQuery.disableAnimations` is true
/// the final state renders statically and [onComplete] fires right away.
class SuccessMoment extends StatefulWidget {
  const SuccessMoment({
    super.key,
    required this.headline,
    this.subtitle,
    required this.onComplete,
    this.duration = const Duration(milliseconds: 1400),
  });

  /// The success words, e.g. `'Survey submitted'`.
  final String headline;

  /// Second line, e.g. `'CRQ-20261001-ABCD  •  Installation assigned'`.
  final String? subtitle;

  /// Called once when the moment has played (or immediately, under
  /// reduced motion).
  final VoidCallback onComplete;

  /// Total play time. Kept short on purpose (Rule 5): an animation that
  /// makes a task slower is wrong.
  final Duration duration;

  @override
  State<SuccessMoment> createState() => _SuccessMomentState();
}

class _SuccessMomentState extends State<SuccessMoment>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _checkScale;
  late final Animation<double> _ringScale;
  late final Animation<double> _ringOpacity;
  late final Animation<double> _wordsOpacity;
  late final Animation<Offset> _wordsSlide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) widget.onComplete();
      });
    // Check badge: elastic pop-in over the first ~350ms.
    _checkScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.25, curve: Curves.elasticOut),
      ),
    );
    // Signal pulse: one ring expanding + fading, 20–65% of the timeline.
    final ringCurve = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.65, curve: Curves.easeOut),
    );
    _ringScale = Tween<double>(begin: 0.6, end: 1.7).animate(ringCurve);
    _ringOpacity = Tween<double>(begin: 0.7, end: 0.0).animate(ringCurve);
    // Words: fade + rise, 15–40% of the timeline.
    final wordsCurve = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.15, 0.4, curve: Curves.easeOut),
    );
    _wordsOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(wordsCurve);
    _wordsSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(wordsCurve);
    // The reduced-motion branch lives in didChangeDependencies, not
    // initState: MediaQuery is an inherited widget and cannot be read
    // before initState completes.
  }

  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      // Reduced motion: render the final state, complete right away.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onComplete();
      });
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Kit status success (DESIGN.md Rule 4): #4ADE80, always icon + word,
    // never colour alone. Dark-navy ink on the green keeps the check
    // readable in both themes.
    const success = Color(0xFF4ADE80);
    const successInk = Color(0xFF0B132B);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 168,
          height: 168,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) => Opacity(
                  opacity: _ringOpacity.value,
                  child: Transform.scale(
                    scale: _ringScale.value,
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.colorScheme.primary,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              ScaleTransition(
                scale: _checkScale,
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: success,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 48,
                    color: successInk,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        FadeTransition(
          opacity: _wordsOpacity,
          child: SlideTransition(
            position: _wordsSlide,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.headline,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    widget.subtitle!,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
