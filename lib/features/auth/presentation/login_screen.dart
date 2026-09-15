import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/device_info.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/field_ops_design_tokens.dart';
import 'providers.dart';

/// Technician sign-in matching the stitch login mockup:
/// flat `#F7F9FD` backdrop, branding header, elevated white login card with
/// "Technician Authentication", icon-prefixed 52dp inputs, a full-width
/// Log In CTA, and a support/compliance footer.
///
/// Only real fields remain: email, password (with show/hide), and the submit
/// action. The remember-device checkbox is a local UI-only toggle — it carries
/// no device data to the backend by design (no invented persistence).
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

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      // Flat anti-glare surface canvas (DESIGN.md §Neutral Canvas).
      body: ColoredBox(
        color: FieldOpsDesignTokens.surface,
        child: SafeArea(
          child: Column(
            children: [
              // Top status strip: "Field Net Active" with a live dot.
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: FieldOpsDesignTokens.pageMargin,
                  vertical: FieldOpsDesignTokens.spaceXs,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: FieldOpsDesignTokens.completedForeground,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Field Net Active',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: FieldOpsDesignTokens.completedForeground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'v${AppConstants.isDebug ? 'dev' : '1.0'}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  child: Column(
                    children: [
                      // Branding header: logo in rounded rect + name + subtitle.
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: FieldOpsDesignTokens.shadowLevel1,
                        ),
                        child: Icon(
                          Icons.wifi_tethering,
                          size: 34,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        AppStrings.appName,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: FieldOpsDesignTokens.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Secure Fiber Field-Operations Portal',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Login card.
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(FieldOpsDesignTokens.cardRadius),
                          border:
                              Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: FieldOpsDesignTokens.shadowLevel2,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // "Technician Authentication" badge.
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: FieldOpsDesignTokens.secondaryFixed,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: FieldOpsDesignTokens.secondary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'TECHNICIAN AUTHENTICATION',
                                        style: theme.textTheme.labelSmall?.copyWith(
                                          color: FieldOpsDesignTokens.onSecondaryFixed,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.05,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                autocorrect: false,
                                decoration: const InputDecoration(
                                  labelText: 'Work Email',
                                  prefixIcon: Icon(Icons.badge_outlined),
                                ),
                                validator: (value) {
                                  final v = value?.trim() ?? '';
                                  if (v.isEmpty) return 'Email is required';
                                  if (!v.contains('@')) return 'Enter a valid email';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: !_passwordVisible,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: const Icon(Icons.lock_outline),
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
                                      () => _passwordVisible = !_passwordVisible,
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
                              // Remember-this-handheld toggle (UI-only).
                              Row(
                                children: [
                                  _CheckboxTile(
                                    value: _rememberDevice,
                                    onChanged: (v) =>
                                        setState(() => _rememberDevice = v),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Remember this handheld unit',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.colorScheme.onSurface,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Log In CTA.
                              SizedBox(
                                height: 52,
                                child: FilledButton(
                                  onPressed:
                                      authState.isSubmitting ? null : _submit,
                                  // Keep the enabled blue fill while submitting.
                                  // `onPressed: null` alone would switch Material
                                  // to its pale-grey disabled fill, which would
                                  // wash out the white spinner on top of it.
                                  style: authState.isSubmitting
                                      ? FilledButton.styleFrom(
                                          backgroundColor:
                                              FieldOpsDesignTokens.secondary,
                                          disabledBackgroundColor:
                                              FieldOpsDesignTokens.secondary,
                                        )
                                      : null,
                                  child: authState.isSubmitting
                                      ? SizedBox(
                                          height: 26,
                                          width: 26,
                                          child: Lottie.asset(
                                            'assets/lottie/login_loading.json',
                                            package: null,
                                            repeat: true,
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Text('Log In'),
                                            const SizedBox(width: 8),
                                            Icon(
                                              Icons.arrow_forward,
                                              size: 20,
                                              color: theme.colorScheme.onSecondary,
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                              ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Support footer.
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.headset_mic_outlined,
                      size: 18,
                      color: FieldOpsDesignTokens.secondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '24/7 Field Support',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 6),
                    TextButton(
                      onPressed: () =>
                          _snack('No field-support line is configured yet.'),
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                      ),
                      child: const Text('Call'),
                    ),
                  ],
                ),
              ),
              // Compliance footer.
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 2, 24, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      size: 13,
                      color: theme.colorScheme.outline,
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        'AES-256 encrypted · Authorized operators only',
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.outline,
                          letterSpacing: 0.02,
                        ),
                      ),
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

/// Large (24dp) rounded check box with a 6px radius, per DESIGN.md checklists.
class _CheckboxTile extends StatelessWidget {
  const _CheckboxTile({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(FieldOpsDesignTokens.radiusMd),
      child: Container(
        width: 48,
        height: 48,
        alignment: Alignment.center,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: value
                ? FieldOpsDesignTokens.completedForeground
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: value
                  ? FieldOpsDesignTokens.completedForeground
                  : theme.colorScheme.outline,
              width: 1.6,
            ),
          ),
          child: value
              ? const Icon(
                  Icons.check,
                  size: 16,
                  color: Colors.white,
                )
              : null,
        ),
      ),
    );
  }
}

