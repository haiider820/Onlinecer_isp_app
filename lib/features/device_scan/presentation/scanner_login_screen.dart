import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/device_info.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/field_ops_design_tokens.dart';
import '../../../shared/widgets/ops_widgets.dart';
import 'scanner_providers.dart';

/// Scanner sign-in — same login visual family as the staff login (Rule 14):
/// deep-navy scene, one title, frosted/liquid-glass card, Email + Password
/// only, one "Sign in" CTA. No theme toggle here — keep it simple.
///
/// Authenticates through the SAME `POST /login` as employees (ISPFINAL §1 —
/// there is no scanner-only endpoint); the response's `account_type` decides
/// which session this is, and the token is stored under the `scanner.*`
/// keys only, so it can never overwrite — or be wiped by — the employee
/// session. On open, a stored scanner token restores silently via `GET /me`:
/// success goes straight to the scanner home; 401/network falls through to
/// the form, never stranding the user.
class ScannerLoginScreen extends ConsumerStatefulWidget {
  const ScannerLoginScreen({super.key});

  @override
  ConsumerState<ScannerLoginScreen> createState() => _ScannerLoginScreenState();
}

class _ScannerLoginScreenState extends ConsumerState<ScannerLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  /// Whether the password is currently revealed by the show/hide toggle.
  bool _passwordVisible = false;

  /// True while the silent restore attempt is running.
  bool _restoring = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _tryRestore();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// A stored scanner token restores the session without typing credentials.
  /// Anything short of a verified session (no token, 401, network) falls
  /// through to the form — restore must never strand the user.
  Future<void> _tryRestore() async {
    try {
      final session = await ref.read(scannerSessionProvider.future);
      if (!mounted) return;
      if (session != null) {
        context.go(Routes.scannerHome);
        return;
      }
    } catch (_) {
      // Fall through to the form.
    }
    if (mounted) setState(() => _restoring = false);
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final response = await ref.read(scannerAuthControllerProvider.notifier).login(
          email: _emailController.text,
          password: _passwordController.text,
          deviceName: DeviceInfo.defaultDeviceName(),
        );

    if (!mounted) return;

    if (response != null) {
      // Scanner token persisted AND write-verified (ScannerRepository gates
      // on a storage read-back). No success animation — straight to the
      // scanner home (Rule 14 §6).
      context.go(Routes.scannerHome);
    }
    // On failure the error banner below the button shows the backend message;
    // no snackbar — the message stays visible on the form.
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(scannerAuthControllerProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final light = theme.brightness == Brightness.light;

    return Scaffold(
      // Same dark scene canvas as the staff login in both modes.
      backgroundColor: const Color(0xFF0B132B),
      body: Stack(
        children: [
          const _FiberScene(),
          if (light) const _GlassGlow(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 16, 8),
                  child: Row(
                    children: [
                      const _BobbingLogo(),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Back to staff login',
                        onPressed: () => context.go(Routes.login),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) => SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: FieldOpsDesignTokens.pageMargin),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: constraints.maxHeight),
                        child: Center(
                          child: _restoring
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      'Scanner sign-in',
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Use the scanning account from your administrator.\nStaff accounts sign in on the previous screen.',
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: Colors.white.withValues(alpha: 0.7),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Container(
                                      decoration: light
                                          ? FieldOpsDesignTokens.glassShadowDecoration
                                          : null,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(32),
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(
                                              sigmaX: light ? 20 : 16,
                                              sigmaY: light ? 20 : 16),
                                          child: Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: light
                                                ? FieldOpsDesignTokens.glassCardDecoration
                                                : BoxDecoration(
                                                    color: scheme.surface.withValues(alpha: 0.80),
                                                    borderRadius: BorderRadius.circular(32),
                                                    border: Border.all(
                                                      color: scheme.outlineVariant
                                                          .withValues(alpha: 0.6),
                                                    ),
                                                  ),
                                            child: Form(
                                              key: _formKey,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.stretch,
                                                children: [
                                                  OpsTextField(
                                                    controller: _emailController,
                                                    label: 'Scanner email',
                                                    hint: 'scanner@isp360.com',
                                                    keyboardType: TextInputType.emailAddress,
                                                    textInputAction: TextInputAction.next,
                                                    prefixIcon: Icons.badge_outlined,
                                                    validator: (value) {
                                                      final v = value?.trim() ?? '';
                                                      if (v.isEmpty) return 'Email is required';
                                                      if (!v.contains('@')) {
                                                        return 'Enter a valid email';
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                  const SizedBox(
                                                      height: FieldOpsDesignTokens.spaceMd),
                                                  OpsTextField(
                                                    controller: _passwordController,
                                                    label: 'Password',
                                                    hint: '••••••••',
                                                    obscureText: !_passwordVisible,
                                                    textInputAction: TextInputAction.done,
                                                    prefixIcon: Icons.lock_outline,
                                                    suffixIcon: IconButton(
                                                      tooltip: _passwordVisible
                                                          ? 'Hide password'
                                                          : 'Show password',
                                                      icon: Icon(
                                                        _passwordVisible
                                                            ? Icons.visibility_off
                                                            : Icons.visibility,
                                                      ),
                                                      onPressed: () => setState(() =>
                                                          _passwordVisible = !_passwordVisible),
                                                    ),
                                                    validator: (value) {
                                                      if (value == null || value.isEmpty) {
                                                        return 'Password is required';
                                                      }
                                                      return null;
                                                    },
                                                    onFieldSubmitted: (_) => _submit(),
                                                  ),
                                                  const SizedBox(
                                                      height: FieldOpsDesignTokens.spaceMd),
                                                  PressScale(
                                                    child: SizedBox(
                                                      height: FieldOpsDesignTokens.inputHeight,
                                                      child: FilledButton(
                                                        onPressed: authState.isSubmitting
                                                            ? null
                                                            : _submit,
                                                        child: authState.isSubmitting
                                                            ? SizedBox(
                                                                height: 22,
                                                                width: 22,
                                                                child: CircularProgressIndicator(
                                                                  strokeWidth: 2.4,
                                                                  color: scheme.onPrimary,
                                                                ),
                                                              )
                                                            : const Text('Sign in'),
                                                      ),
                                                    ),
                                                  ),
                                                  if (authState.hasError) ...[
                                                    const SizedBox(
                                                        height: FieldOpsDesignTokens.spaceMd),
                                                    Text(
                                                      authState.errorMessage!,
                                                      textAlign: TextAlign.center,
                                                      style: theme.textTheme.bodyMedium?.copyWith(
                                                        color: scheme.error,
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    TextButton(
                                      onPressed: () => context.go(Routes.login),
                                      child: const Text('Staff login? Sign in here'),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
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

/// Fiber/network scene behind the card — same recipe as the staff login.
class _FiberScene extends StatelessWidget {
  const _FiberScene();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Stack(
      children: [
        Positioned(
          top: 120,
          left: 24,
          right: 24,
          height: 40,
          child: SignalPulse(),
        ),
        Positioned(
          top: 208,
          left: 0,
          right: 0,
          height: 1,
          child: ColoredBox(color: primary.withValues(alpha: 0.14)),
        ),
        Positioned(
          top: 264,
          left: 0,
          right: 0,
          height: 1,
          child: ColoredBox(color: primary.withValues(alpha: 0.08)),
        ),
        Positioned(
          top: 336,
          left: 0,
          right: 0,
          height: 1,
          child: ColoredBox(color: primary.withValues(alpha: 0.05)),
        ),
      ],
    );
  }
}

/// Light-mode only sky glow behind the card — same recipe as the staff login.
class _GlassGlow extends StatelessWidget {
  const _GlassGlow();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0, 0.18),
      child: Container(
        width: 460,
        height: 460,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              FieldOpsDesignTokens.inversePrimary.withValues(alpha: 0.45),
              FieldOpsDesignTokens.primary.withValues(alpha: 0.22),
              Colors.transparent,
            ],
            stops: const [0.0, 0.55, 1.0],
          ),
        ),
      ),
    );
  }
}

/// Living logo, top-left — same recipe as the staff login.
class _BobbingLogo extends StatefulWidget {
  const _BobbingLogo();

  @override
  State<_BobbingLogo> createState() => _BobbingLogoState();
}

class _BobbingLogoState extends State<_BobbingLogo> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, -3 + 6 * _controller.value),
        child: child,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 64,
            height: 42,
            child: SignalPulse(),
          ),
          const SizedBox(width: 12),
          Text(
            'ISP 360',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
