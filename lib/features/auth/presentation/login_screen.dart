import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/device_info.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/field_ops_design_tokens.dart';
import '../../../shared/widgets/ops_widgets.dart';
import 'providers.dart';

/// Technician sign-in — "Midnight Ops" edition.
///
/// A full-bleed night-gradient hero (brand mark, mono tagline, display
/// headline) with the sign-in card overlapping it. The primary action is the
/// one glowing cyan fill on the screen. Follows the device theme (light/dark).
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

  /// Local-only "remember this handheld" preference (never sent to the API).
  bool _rememberDevice = true;

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
    final dark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _LoginHero(dark: dark),
            // Form card overlapping the hero.
            Transform.translate(
              offset: const Offset(0, -56),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: FieldOpsDesignTokens.pageMargin),
                child: OpsCard(
                  padding: const EdgeInsets.all(22),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Technician sign-in',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(
                            height: FieldOpsDesignTokens.spaceMd),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          style: theme.textTheme.bodyLarge,
                          cursorColor: theme.colorScheme.primary,
                          decoration: const InputDecoration(
                            labelText: 'Work email',
                            prefixIcon: Icon(Icons.badge_outlined),
                          ),
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
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_passwordVisible,
                          style: theme.textTheme.bodyLarge,
                          cursorColor: theme.colorScheme.primary,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon:
                                const Icon(Icons.lock_outline),
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
                            height: FieldOpsDesignTokens.spaceSm),
                        // Remember-this-handheld toggle (UI-only).
                        InkWell(
                          onTap: () => setState(
                              () => _rememberDevice = !_rememberDevice),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12),
                            child: Row(
                              children: [
                                _RememberCheck(
                                    value: _rememberDevice),
                                const SizedBox(
                                    width: FieldOpsDesignTokens
                                        .spaceSm),
                                Expanded(
                                  child: Text(
                                    'Remember this handheld unit',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                            height: FieldOpsDesignTokens.spaceMd),
                        // Primary action: the one glowing fill on screen.
                        SizedBox(
                          height:
                              FieldOpsDesignTokens.inputHeight,
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
                                      color: theme
                                          .colorScheme.onPrimary,
                                    ),
                                  )
                                : const Text('Log in'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Compliance + version, pulled up under the overlap.
            Transform.translate(
              offset: const Offset(0, -32),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: FieldOpsDesignTokens.spaceLg),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.shield_outlined,
                          size: 16,
                          color:
                              theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(
                            width: FieldOpsDesignTokens.spaceXs),
                        Expanded(
                          child: Text(
                            'AES-256 encrypted. Authorized operators only.',
                            style: theme.textTheme.bodySmall
                                ?.copyWith(
                              color: theme
                                  .colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                        height: FieldOpsDesignTokens.spaceXs),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding:
                            const EdgeInsets.only(left: 22),
                        child: Text(
                          'Version ${AppConstants.isDebug ? 'dev' : '1.0'}',
                          style: FieldOpsDesignTokens.dataSm
                              .copyWith(
                            color: theme
                                .colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
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

/// Full-bleed hero: night gradient, glow orbs, brand mark + wordmark,
/// mono tagline, display headline.
class _LoginHero extends StatelessWidget {
  const _LoginHero({required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 64, 24, 88),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: dark
              ? const [Color(0xFF0A1230), Color(0xFF05080F)]
              : const [Color(0xFF0E3A52), Color(0xFF0B1220)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Glow orbs.
          Positioned(
            top: -70,
            right: -50,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primary.withValues(alpha: 0.28),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -40,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.secondary
                    .withValues(alpha: 0.25),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white.withValues(alpha: 0.12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    padding: const EdgeInsets.all(7),
                    child: Image.asset(
                      'assets/images/malik_fiber_logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.bolt,
                        color: primary,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'MALIK FIBER',
                    style: FieldOpsDesignTokens.headlineMd.copyWith(
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              Text(
                'FIELD OPERATIONS · v2.4',
                style: FieldOpsDesignTokens.dataSm.copyWith(
                  color: Colors.white.withValues(alpha: 0.65),
                  letterSpacing: 2.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Start your\nshift.',
                style: FieldOpsDesignTokens.displayLg.copyWith(
                  color: Colors.white,
                  fontSize: 38,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Rounded checkbox tile with a glow when checked.
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
        color: value
            ? theme.colorScheme.primary
            : Colors.transparent,
        border: Border.all(
          color: value
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant,
          width: 1.5,
        ),
        boxShadow: value ? opsGlow(context) : null,
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
