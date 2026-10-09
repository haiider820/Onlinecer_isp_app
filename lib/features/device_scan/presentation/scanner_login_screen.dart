import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/field_ops_colors.dart';
import '../../../core/theme/field_ops_design_tokens.dart';
import 'scanner_providers.dart';

/// Standalone sign-in for device-scanning accounts (warehouse handhelds).
/// These accounts are not employees, so this screen never touches the staff
/// login flow: a stored scanner token restores silently via `GET /me`, and a
/// fresh sign-in posts to the scanner-only endpoint.
///
/// Chassis-dark terminal styling matches the staff login (same visual
/// family): deep brand canvas, white input wells, cobalt accents.
class ScannerLoginScreen extends ConsumerStatefulWidget {
  const ScannerLoginScreen({super.key});

  @override
  ConsumerState<ScannerLoginScreen> createState() =>
      _ScannerLoginScreenState();
}

class _ScannerLoginScreenState extends ConsumerState<ScannerLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _passwordVisible = false;
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

  /// A stored token restores the portal without typing credentials.
  /// Anything short of a parsed session (no token, 401, network) falls
  /// through to the form — restore must never strand the user.
  Future<void> _tryRestore() async {
    try {
      final login =
          await ref.read(scannerRepositoryProvider).restoreSession();
      if (!mounted) return;
      if (login != null) {
        ref.invalidate(scannerSessionProvider);
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
    final ok =
        await ref.read(scannerLoginControllerProvider.notifier).submit(
              email: _emailController.text,
              password: _passwordController.text,
            );
    if (!mounted) return;
    if (ok) {
      context.go(Routes.scannerHome);
    } else {
      final error = ref.read(scannerLoginControllerProvider).errorMessage;
      if (error != null) _snack(error);
    }
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.fieldOpsColors;
    final theme = Theme.of(context);
    final state = ref.watch(scannerLoginControllerProvider);

    return Scaffold(
      backgroundColor: colors.chassis,
      appBar: AppBar(
        backgroundColor: colors.chassis,
        foregroundColor: colors.onChassis,
        elevation: 0,
        // Standalone entry: after a portal logout (`go`) there is no history
        // to pop, so Back falls through to the staff login instead of
        // stranding the scanner on this screen.
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(Routes.login);
            }
          },
        ),
        title: const Text('Device Scanning'),
      ),
      body: SafeArea(
        child: _restoring
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.qr_code_scanner,
                        size: 56,
                        color: colors.onChassis,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Scanner sign-in',
                        textAlign: TextAlign.center,
                        style: FieldOpsDesignTokens.displayLg.copyWith(
                          color: colors.onChassis,
                          fontSize: 26,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Use the scanning account from your administrator.\nStaff accounts sign in on the previous screen.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onChassis.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Mode-aware wells + ink (same recipe as the staff
                      // login): dark blue fill in dark mode, light fill in
                      // light mode, so typed text stays readable either way.
                      Theme(
                        data: theme.copyWith(
                          inputDecorationTheme: InputDecorationTheme(
                            filled: true,
                            fillColor: theme.colorScheme.surfaceContainerLow,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            labelStyle: FieldOpsDesignTokens.bodyMd.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            hintStyle: FieldOpsDesignTokens.bodyMd.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            prefixIconColor:
                                theme.colorScheme.onSurfaceVariant,
                            suffixIconColor:
                                theme.colorScheme.onSurfaceVariant,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.zero,
                              borderSide: BorderSide(
                                  color: theme.colorScheme.outline),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.zero,
                              borderSide: BorderSide(
                                color: theme.colorScheme.primary,
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.zero,
                              borderSide: BorderSide(
                                  color: theme.colorScheme.error),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.zero,
                              borderSide: BorderSide(
                                color: theme.colorScheme.error,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: false,
                              style: FieldOpsDesignTokens.bodyLg.copyWith(
                                color: theme.colorScheme.onSurface,
                              ),
                              cursorColor: theme.colorScheme.primary,
                              decoration: const InputDecoration(
                                labelText: 'Scanner Email',
                                prefixIcon: Icon(Icons.badge_outlined),
                              ),
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: !_passwordVisible,
                              style: FieldOpsDesignTokens.bodyLg.copyWith(
                                color: theme.colorScheme.onSurface,
                              ),
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
                              onFieldSubmitted: (_) {
                                if (!state.isSubmitting) _submit();
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 52,
                        child: FilledButton.icon(
                          // The scaffold is chassis cobalt in light mode, so
                          // the default secondary fill would vanish into it —
                          // invert instead: an on-chassis plate with chassis
                          // ink reads on either canvas.
                          style: FilledButton.styleFrom(
                            backgroundColor: colors.onChassis,
                            foregroundColor: colors.chassis,
                            disabledBackgroundColor: colors.onChassis,
                            disabledForegroundColor: colors.chassis,
                          ),
                          onPressed: state.isSubmitting ? null : _submit,
                          icon: state.isSubmitting
                              ? SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: colors.chassis,
                                  ),
                                )
                              : const Icon(Icons.login, size: 20),
                          label: Text(
                              state.isSubmitting ? 'Signing in…' : 'Sign In'),
                        ),
                      ),
                      if (state.hasError) ...[
                        const SizedBox(height: 12),
                        Text(
                          state.errorMessage!,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFFFF9E96),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
