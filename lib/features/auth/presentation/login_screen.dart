import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/device_info.dart';
import '../../../core/notifications/fcm_providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/field_ops_design_tokens.dart';
import 'providers.dart';

/// Technician sign-in: a clean, left-aligned single column on the light page
/// surface — the app name alone up top, then one bordered card holding the
/// form (the primary action is the only cobalt fill on the screen).
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
      //
      // Now that the user is signed in, ask for notification permission
      // (Android 13+ runtime POST_NOTIFICATIONS, iOS always) so push can
      // arrive. Fire-and-forget: the dialog is non-blocking and dismissal
      // must not delay the redirect. Registration itself already happened in
      // AuthRepository.login.
      unawaited(ref.read(fcmServiceProvider).requestPushPermission());
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

  /// Inputs: well fill, 1px hairline border, 2px cobalt focus ring.
  /// Applied locally via a [Theme] wrapper so the rest of the app keeps its
  /// global input theme.
  InputDecorationTheme _inputTheme(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: color, width: width),
        );

    return InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerLow,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: FieldOpsDesignTokens.bodyMd.copyWith(
        color: scheme.onSurfaceVariant,
      ),
      floatingLabelStyle: FieldOpsDesignTokens.bodySm.copyWith(
        color: scheme.primary,
        fontWeight: FontWeight.w600,
      ),
      hintStyle: FieldOpsDesignTokens.bodyMd.copyWith(
        color: scheme.onSurfaceVariant,
      ),
      prefixIconColor: scheme.onSurfaceVariant,
      suffixIconColor: scheme.onSurfaceVariant,
      enabledBorder: border(scheme.outline, 1),
      focusedBorder: border(scheme.primary, 2),
      errorBorder: border(scheme.error, 1),
      focusedErrorBorder: border(scheme.error, 2),
      errorStyle: FieldOpsDesignTokens.bodySm.copyWith(
        color: scheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final theme = Theme.of(context);

    final inputStyle = FieldOpsDesignTokens.bodyLg.copyWith(
      color: theme.colorScheme.onSurface,
    );

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Theme(
          data: theme.copyWith(inputDecorationTheme: _inputTheme(context)),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              FieldOpsDesignTokens.spaceLg,
              FieldOpsDesignTokens.spaceLg,
              FieldOpsDesignTokens.spaceLg,
              FieldOpsDesignTokens.spaceLg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Brand: the app name alone — no logo plate.
                Text(
                  AppStrings.appName,
                  style: FieldOpsDesignTokens.headlineLg.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: FieldOpsDesignTokens.spaceLg),

                // Form card.
                Container(
                  padding: const EdgeInsets.all(FieldOpsDesignTokens.spaceLg),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLowest,
                    borderRadius:
                        BorderRadius.circular(FieldOpsDesignTokens.cardRadius),
                    border: Border.all(color: theme.colorScheme.outline),
                    boxShadow: FieldOpsDesignTokens.shadowLevel1,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Technician sign-in',
                          style: FieldOpsDesignTokens.headlineSm.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: FieldOpsDesignTokens.spaceLg),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          style: inputStyle,
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
                        const SizedBox(height: FieldOpsDesignTokens.spaceMd),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_passwordVisible,
                          style: inputStyle,
                          cursorColor: theme.colorScheme.primary,
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
                        const SizedBox(height: FieldOpsDesignTokens.spaceSm),
                        Row(
                          children: [
                            _CheckboxTile(
                              value: _rememberDevice,
                              onChanged: (v) =>
                                  setState(() => _rememberDevice = v),
                            ),
                            const SizedBox(width: FieldOpsDesignTokens.spaceSm),
                            Expanded(
                              child: Text(
                                'Remember this handheld unit',
                                style: FieldOpsDesignTokens.bodyMd.copyWith(
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: FieldOpsDesignTokens.spaceMd),
                        // Primary action: the one cobalt fill on the screen.
                        SizedBox(
                          height: FieldOpsDesignTokens.inputHeight,
                          child: FilledButton(
                            onPressed:
                                authState.isSubmitting ? null : _submit,
                            // Keep the cobalt fill while submitting so the white
                            // spinner stays readable (Material would otherwise
                            // switch to its grey disabled fill).
                            style: FilledButton.styleFrom(
                              backgroundColor:
                                  theme.colorScheme.primary,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                                  theme.colorScheme.primary,
                              disabledForegroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    FieldOpsDesignTokens.controlRadius),
                              ),
                              textStyle: FieldOpsDesignTokens.bodyLg.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            child: authState.isSubmitting
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.4,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Log in'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: FieldOpsDesignTokens.spaceLg),

                // Standalone device-scanning portal (scanner accounts are not
                // employees): navigation only, the staff login flow above is
                // untouched.
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () => context.push(Routes.scannerLogin),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                      minimumSize: const Size(
                        FieldOpsDesignTokens.minTouchTarget,
                        FieldOpsDesignTokens.minTouchTarget,
                      ),
                    ),
                    child: const Text('Device scanner? Sign in here'),
                  ),
                ),
                const SizedBox(height: FieldOpsDesignTokens.spaceMd),

                // Compliance and version.
                Row(
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: FieldOpsDesignTokens.spaceXs),
                    Expanded(
                      child: Text(
                        'AES-256 encrypted. Authorized operators only.',
                        style: FieldOpsDesignTokens.bodySm.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: FieldOpsDesignTokens.spaceXs),
                Padding(
                  padding: const EdgeInsets.only(left: 22),
                  child: Text(
                    'Version ${AppConstants.isDebug ? 'dev' : '1.0'}',
                    style: FieldOpsDesignTokens.bodySm.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 24dp rounded check box with a 6px radius inside a 48dp touch target.
/// Checked = cobalt fill with a white check; unchecked = hairline border.
class _CheckboxTile extends StatelessWidget {
  const _CheckboxTile({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(FieldOpsDesignTokens.controlRadius),
      child: SizedBox(
        width: FieldOpsDesignTokens.minTouchTarget,
        height: FieldOpsDesignTokens.minTouchTarget,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: value
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.zero,
              border: Border.all(
                color: value
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outlineVariant,
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
      ),
    );
  }
}
