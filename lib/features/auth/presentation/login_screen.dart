import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/device_info.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/field_ops_design_tokens.dart';
import '../../../core/theme/theme_mode_provider.dart';
import '../../../shared/widgets/ops_widgets.dart';
import 'providers.dart';

/// Technician sign-in — Rule 14 login standard.
///
/// One title + one CTA, Email + Password only, over a full fiber/network
/// scene (deep-navy canvas in both modes, thin fiber lines + a travelling
/// SignalPulse). LIGHT mode: the card is Apple-style liquid glass
/// (translucent white gradient with a diagonal sheen band, bright top/left
/// rim, soft shadow, blur 20) over a soft sky glow pooled behind the card
/// so the glass has something to refract. DARK mode: the v2 frosted card
/// (blur 16, surface at alpha 0.80) — unchanged. The form is vertically
/// centred with no bottom strip. The living logo (SignalPulse mark +
/// "ISP 360" wordmark) sits top-left with a transform-only bob — no
/// opacity fade anywhere. On success there is no fade/grow animation:
/// the dashboard opens straight away.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  /// Whether the password is currently revealed by the show/hide toggle.
  /// Defaults to `false`, so the field starts obscured (`obscureText: true`).
  bool _passwordVisible = false;

  /// "Remember this handheld" preference (never sent to the API).
  /// Persisted in secure storage (`ui.remember_device`) and restored in
  /// [initState]; defaults to ON when never chosen (D12).
  bool _rememberDevice = true;

  @override
  void initState() {
    super.initState();
    _restoreRememberDevice();
  }

  Future<void> _restoreRememberDevice() async {
    final stored = await ref.read(secureStorageProvider).getRememberDevice();
    if (!mounted || stored == null) return;
    setState(() => _rememberDevice = stored);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final response = await ref.read(authControllerProvider.notifier).login(
          email: _emailController.text,
          password: _passwordController.text,
          // No UI field anymore — send a stable label automatically so the
          // backend can still tell sessions apart.
          deviceName: DeviceInfo.defaultDeviceName(),
        );

    if (!mounted) return;

    if (response != null) {
      // Token persisted AND write-verified (AuthRepository gates on a storage
      // read-back). The boot screen then proves the token end-to-end with a
      // real GET /me before any dashboard request fires.
      // No success animation — straight to the dashboard (Rule 14 §6).
      context.go(Routes.boot);
    } else {
      final state = ref.read(authControllerProvider);
      if (state.hasError) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    // Liquid glass applies to LIGHT mode only; dark keeps the v2 frost.
    final light = theme.brightness == Brightness.light;

    return Scaffold(
      // Login scene canvas: deep navy in BOTH modes (Rule 14 pattern —
      // the scene stays dark so the frosted card and white scene text
      // read the same in light and dark mode).
      backgroundColor: const Color(0xFF0B132B),
      body: Stack(
        children: [
          // ── Fiber/network scene (theme colours only, no glow) ──
          const _FiberScene(),
          // Light only: a soft sky glow pooled behind the card so the
          // liquid-glass card has something bright to refract. Sits low
          // and centred — clear of the white title/logo at the top.
          if (light) const _GlassGlow(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header: living logo top-left, theme toggle top-right.
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 16, 8),
                  child: Row(
                    children: [
                      const _BobbingLogo(),
                      const Spacer(),
                      const _ThemeToggleAction(),
                    ],
                  ),
                ),
                // Vertically centred form group: one title + frosted card.
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) =>
                        SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal:
                              FieldOpsDesignTokens.pageMargin),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                            minHeight: constraints.maxHeight),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment:
                                CrossAxisAlignment.stretch,
                            children: [
                              // One title only (Rule 14 §1). White because
                              // it sits on the dark scene in both modes —
                              // theme onSurface would be unreadable here
                              // in light mode.
                              Text(
                                'Log in to ISP 360',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.headlineSmall
                                    ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Card on top of the scene: liquid glass in
                              // light mode, the v2 frosted card in dark.
                              // The soft glass shadow lives on this outer
                              // container: a shadow on the clipped card
                              // itself would be cut off by the ClipRRect.
                              Container(
                                decoration: light
                                    ? FieldOpsDesignTokens
                                        .glassShadowDecoration
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
                                        ? FieldOpsDesignTokens
                                            .glassCardDecoration
                                        : BoxDecoration(
                                            color: scheme.surface
                                                .withValues(alpha: 0.80),
                                            borderRadius:
                                                BorderRadius.circular(32),
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
                                            label: 'Work email',
                                            hint: 'name@isp360.com',
                                            keyboardType: TextInputType
                                                .emailAddress,
                                            textInputAction:
                                                TextInputAction.next,
                                            prefixIcon:
                                                Icons.mail_outline,
                                            validator: (value) {
                                              final v =
                                                  value?.trim() ?? '';
                                              if (v.isEmpty) {
                                                return 'Email is required';
                                              }
                                              if (!v.contains('@')) {
                                                return 'Enter a valid email';
                                              }
                                              return null;
                                            },
                                          ),
                                          const SizedBox(
                                              height:
                                                  FieldOpsDesignTokens
                                                      .spaceMd),
                                          OpsTextField(
                                            controller: _passwordController,
                                            label: 'Password',
                                            hint: '••••••••',
                                            obscureText: !_passwordVisible,
                                            textInputAction:
                                                TextInputAction.done,
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
                                              onPressed: () => setState(
                                                () => _passwordVisible =
                                                    !_passwordVisible,
                                              ),
                                            ),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Password is required';
                                              }
                                              return null;
                                            },
                                            onFieldSubmitted: (_) =>
                                                _submit(),
                                          ),
                                          const SizedBox(
                                              height:
                                                  FieldOpsDesignTokens
                                                      .spaceSm),
                                          // Remember-this-handheld toggle:
                                          // persisted, restored on init (D12).
                                          InkWell(
                                            onTap: () async {
                                              final next = !_rememberDevice;
                                              setState(() =>
                                                  _rememberDevice = next);
                                              await ref
                                                  .read(secureStorageProvider)
                                                  .setRememberDevice(next);
                                            },
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 12),
                                              child: Row(
                                                children: [
                                                  _RememberCheck(
                                                      value: _rememberDevice),
                                                  const SizedBox(
                                                      width:
                                                          FieldOpsDesignTokens
                                                              .spaceSm),
                                                  Expanded(
                                                    child: Text(
                                                      'Remember this handheld unit',
                                                      style: theme.textTheme
                                                          .bodyMedium,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                              height:
                                                  FieldOpsDesignTokens
                                                      .spaceMd),
                                          // Primary action: the one CTA.
                                          PressScale(
                                            child: SizedBox(
                                              height: FieldOpsDesignTokens
                                                  .inputHeight,
                                              child: FilledButton(
                                                onPressed:
                                                    authState.isSubmitting
                                                        ? null
                                                        : _submit,
                                                child: authState.isSubmitting
                                                    ? SizedBox(
                                                        height: 22,
                                                        width: 22,
                                                        child:
                                                            CircularProgressIndicator(
                                                          strokeWidth: 2.4,
                                                          color: scheme
                                                              .onPrimary,
                                                        ),
                                                      )
                                                    : const Text('Log in'),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              ),
                              // Scanner entry (ISPFINAL §1): a plain text link
                              // BELOW the card — not a second primary CTA
                              // (Rule 14: one title + one Log in button
                              // stays). It only navigates; it never submits
                              // the employee login or touches its token.
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: () => context.go(Routes.scannerLogin),
                                child: const Text('Device scanner? Sign in here'),
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

/// Fiber/network scene behind the login card: a subtle SignalPulse fiber
/// line near the top plus a few thin 1px fiber lines at low alpha.
/// Theme colours only, no glow, no emoji.
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
          child: ColoredBox(
              color: primary.withValues(alpha: 0.14)),
        ),
        Positioned(
          top: 264,
          left: 0,
          right: 0,
          height: 1,
          child: ColoredBox(
              color: primary.withValues(alpha: 0.08)),
        ),
        Positioned(
          top: 336,
          left: 0,
          right: 0,
          height: 1,
          child: ColoredBox(
              color: primary.withValues(alpha: 0.05)),
        ),
      ],
    );
  }
}

/// Light-mode only: a soft sky glow pooled behind the login card so the
/// liquid-glass card has something bright to refract. A centred radial
/// wash (sky → cobalt → transparent), low enough to sit behind the card
/// and clear of the white title/logo at the top. No glow in dark mode.
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
              FieldOpsDesignTokens.inversePrimary
                  .withValues(alpha: 0.45),
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

/// Living logo, top-left: small SignalPulse mark + "ISP 360" wordmark.
/// Transform-only float/bob — no opacity fade anywhere (Rule 14 §3).
class _BobbingLogo extends StatefulWidget {
  const _BobbingLogo();

  @override
  State<_BobbingLogo> createState() => _BobbingLogoState();
}

class _BobbingLogoState extends State<_BobbingLogo>
    with SingleTickerProviderStateMixin {
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
          // Wordmark sits on the dark scene in both modes.
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

/// Theme toggle — same provider, same SecureStorage key (`ui.theme_mode`)
/// and same system → light → dark cycle as the dashboard toggle.
class _ThemeToggleAction extends ConsumerWidget {
  const _ThemeToggleAction();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final icon = switch (mode) {
      ThemeMode.light => Icons.light_mode_outlined,
      ThemeMode.dark => Icons.dark_mode_outlined,
      ThemeMode.system => Icons.brightness_auto_outlined,
    };
    final label = switch (mode) {
      ThemeMode.light => 'Theme: light (tap for dark)',
      ThemeMode.dark => 'Theme: dark (tap for system)',
      ThemeMode.system => 'Theme: system (tap for light)',
    };
    return IconButton(
      tooltip: label,
      onPressed: () => ref.read(themeModeProvider.notifier).cycle(),
      // White icon: the toggle sits on the dark login scene in both modes.
      icon: Icon(icon, color: Colors.white),
    );
  }
}

/// Rounded checkbox tile (no glow).
class _RememberCheck extends StatelessWidget {
  const _RememberCheck({required this.value});

  final bool value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9),
        color: value ? theme.colorScheme.primary : Colors.transparent,
        border: Border.all(
          color: value
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant,
          width: 1.5,
        ),
      ),
      child: value
          ? Icon(
              Icons.check,
              size: 16,
              color: theme.colorScheme.onPrimary,
            )
          : null,
    );
  }
}
