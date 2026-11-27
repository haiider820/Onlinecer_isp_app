import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/ops_widgets.dart';
import '../../../shared/widgets/success_moment.dart';
import '../data/screenshot_saver.dart';
import '../models/closing_activation.dart';

/// Arguments for the closing success screen, carried on the route's `extra`.
///
/// The screen is only ever reached from the closing completion form right
/// after a successful `POST .../complete-closing`, so the activation is
/// in-memory by design — it is never fetched again and never persisted.
class ClosingSuccessArgs {
  const ClosingSuccessArgs({
    required this.message,
    required this.activation,
    required this.voiceNoteWarning,
    required this.listRoute,
  });

  /// `response.data.message` from the closing response.
  final String? message;

  /// `response.data.data.activation` — `null` on older responses.
  final ClosingActivation? activation;

  /// Best-effort voice-note follow-up failure (guide §20): a warning only,
  /// the stage is already complete.
  final String? voiceNoteWarning;

  /// Route the Close button goes to (the closing list, already refreshed).
  final String listRoute;
}

/// Success screen shown after a closing completes (D24, mobile-dev spec).
///
/// Top: the D23 `SuccessMoment` (the screen's one living element, Rule 1).
/// Then the server message, then — when the backend returned it — the
/// activation card with the four credentials the technician hands to the
/// customer (each with a copy button; passwords masked until revealed).
/// When `activation.radius_synced` is `false`, a warning that RADIUS
/// synchronization failed sits above the card.
///
/// LOCKED (D24 addition, same as the D23 overlay): system back and the
/// app-bar back can never dismiss this screen — the credentials must not
/// disappear by accident. There is no back button at all; the ONLY way out
/// is the Close button below, which goes to the (already refreshed) list.
///
/// The Take Screenshot button captures the credentials card as a PNG
/// (`RepaintBoundary`) and saves/opens it with the existing save pattern,
/// so the technician can send it to the customer.
class ClosingSuccessScreen extends StatefulWidget {
  const ClosingSuccessScreen({
    super.key,
    required this.args,
    this.screenshotSaver = const ScreenshotSaver(),
  });

  final ClosingSuccessArgs args;

  /// Save layer, injectable so tests can assert the capture + save call
  /// without touching the real filesystem or viewer.
  final ScreenshotSaver screenshotSaver;

  @override
  State<ClosingSuccessScreen> createState() => _ClosingSuccessScreenState();
}

class _ClosingSuccessScreenState extends State<ClosingSuccessScreen> {
  final _credentialsKey = GlobalKey();
  bool _savingScreenshot = false;

  ClosingActivation? get _activation => widget.args.activation;
  bool get _hasActivation => _activation?.hasAnyValue ?? false;

  Future<void> _takeScreenshot() async {
    if (_savingScreenshot) return;
    final boundary = _credentialsKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null) return;
    setState(() => _savingScreenshot = true);
    try {
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData?.buffer.asUint8List();
      if (bytes == null || bytes.isEmpty) {
        throw StateError('empty capture');
      }
      final name =
          'closing-activation-${DateTime.now().millisecondsSinceEpoch}.png';
      final result = await widget.screenshotSaver.savePng(bytes, name);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.opened
                ? 'Screenshot saved — opening…'
                : 'Screenshot saved to ${result.savedPath}',
          ),
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save the screenshot. Try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _savingScreenshot = false);
    }
  }

  void _close() => context.go(widget.args.listRoute);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radiusFailed = _activation?.radiusSynced == false;
    return PopScope(
      // D24: back must never dismiss this screen — credentials first.
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Closing complete'),
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SuccessMoment(
                        headline: 'Closing complete',
                        subtitle: widget.args.message ??
                            'Status: Connected',
                        // The moment plays once and stays — there is no
                        // auto-advance here: the technician must read and
                        // copy the credentials first.
                        onComplete: () {},
                      ),
                      const SizedBox(height: 24),
                      if (widget.args.voiceNoteWarning != null) ...[
                        Text(
                          widget.args.voiceNoteWarning!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (radiusFailed) ...[
                        _RadiusWarning(),
                        const SizedBox(height: 16),
                      ],
                      if (_hasActivation)
                        RepaintBoundary(
                          key: _credentialsKey,
                          child: _ActivationCard(
                            activation: _activation!,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_hasActivation)
                      OutlinedButton.icon(
                        onPressed:
                            _savingScreenshot ? null : _takeScreenshot,
                        icon: _savingScreenshot
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.camera_alt_outlined),
                        label: Text(
                          _savingScreenshot
                              ? 'Saving…'
                              : 'Take Screenshot',
                        ),
                      ),
                    if (_hasActivation) const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _close,
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// RADIUS warning (D24): icon + words, never colour alone (kit Rule 4).
class _RadiusWarning extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.error),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: theme.colorScheme.error,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RADIUS synchronization failed',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'The connection is closed, but the RADIUS sync did not '
                  'complete.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The four activation credentials, each with a copy button. Passwords are
/// masked until the eye toggle reveals them — these are handed to the
/// customer, so they must be readable on demand but never exposed by
/// default on a shared screen.
class _ActivationCard extends StatelessWidget {
  const _ActivationCard({required this.activation});

  final ClosingActivation activation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return OpsCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Activation details',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Share these with the customer.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          _CredentialRow(
            label: 'PPPoE username',
            value: activation.pppoeUsername,
          ),
          const SizedBox(height: 12),
          _CredentialRow(
            label: 'PPPoE password',
            value: activation.pppoePassword,
            isPassword: true,
          ),
          const SizedBox(height: 12),
          _CredentialRow(
            label: 'Portal email',
            value: activation.portalEmail,
          ),
          const SizedBox(height: 12),
          _CredentialRow(
            label: 'Portal password',
            value: activation.portalPassword,
            isPassword: true,
          ),
        ],
      ),
    );
  }
}

class _CredentialRow extends StatefulWidget {
  const _CredentialRow({
    required this.label,
    required this.value,
    this.isPassword = false,
  });

  final String label;
  final String? value;
  final bool isPassword;

  @override
  State<_CredentialRow> createState() => _CredentialRowState();
}

class _CredentialRowState extends State<_CredentialRow> {
  bool _revealed = false;

  Future<void> _copy() async {
    final value = widget.value;
    if (value == null) return;
    try {
      await Clipboard.setData(ClipboardData(text: value));
    } catch (_) {
      // Clipboard can genuinely fail on a device — say so instead of
      // claiming the copy worked (and in widget tests the platform
      // channel is unmocked by default).
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not copy. Try again.')),
        );
      }
      return;
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.label} copied')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final value = widget.value;
    final display = value == null
        ? '—'
        : widget.isPassword && !_revealed
            ? '•' * value.length
            : value;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              SelectableText(
                display,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (widget.isPassword && value != null)
          IconButton(
            tooltip: _revealed ? 'Hide password' : 'Show password',
            onPressed: () => setState(() => _revealed = !_revealed),
            icon: Icon(
              _revealed ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            ),
          ),
        IconButton(
          tooltip: 'Copy ${widget.label}',
          onPressed: value == null ? null : _copy,
          icon: const Icon(Icons.copy_outlined),
        ),
      ],
    );
  }
}
