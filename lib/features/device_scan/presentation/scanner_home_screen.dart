import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/field_ops_design_tokens.dart';
import 'scanner_providers.dart';

/// Scanner home — a plain session/account screen for now.
///
/// It shows the signed-in scanner account (name, id, organisation when the
/// server provided one) and a Sign out button that clears ONLY the scanner
/// session. It deliberately does NOT fake scanning capability: no
/// device-scan endpoints are documented in the ISPFINAL guide, so there is
/// no scan UI here until the backend documents one. Real scan UI is out of
/// scope for Phase A.
class ScannerHomeScreen extends ConsumerWidget {
  const ScannerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(scannerSessionProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Scanner'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(FieldOpsDesignTokens.pageMargin),
          child: sessionAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => _Message(
              title: 'Could not load the scanner session.',
              body: 'Check your connection and try again.',
              onRetry: () => ref.invalidate(scannerSessionProvider),
            ),
            data: (session) {
              if (session == null) {
                return _Message(
                  title: 'No scanner session found.',
                  body: 'Sign in with the scanning account to continue.',
                  actionLabel: 'Go to Scanner sign-in',
                  onAction: () => context.go(Routes.scannerLogin),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Signed in as scanner',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _Row(
                            label: 'Account',
                            value: session.accountName ?? 'Not provided',
                          ),
                          const SizedBox(height: 8),
                          _Row(
                            label: 'Account ID',
                            value: session.accountId ?? 'Not provided',
                          ),
                          const SizedBox(height: 8),
                          _Row(
                            label: 'Organisation',
                            value: session.organizationName ?? 'Not provided',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Device scanning is not available in this build yet — '
                    'this screen only shows the signed-in scanner account. '
                    'Scanning arrives once the backend documents the '
                    'device-scan endpoints.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: FieldOpsDesignTokens.inputHeight,
                    child: FilledButton(
                      onPressed: () async {
                        final ok = await ref
                            .read(scannerAuthControllerProvider.notifier)
                            .logout();
                        if (!context.mounted) return;
                        if (ok) {
                          context.go(Routes.scannerLogin);
                        } else {
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              const SnackBar(
                                content: Text('Could not sign out. Please try again.'),
                              ),
                            );
                        }
                      },
                      child: const Text('Sign out'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context.go(Routes.login),
                    child: const Text('Staff login? Sign in here'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(value, style: theme.textTheme.bodyMedium),
        ),
      ],
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
    this.onRetry,
  });

  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            body,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 16),
            FilledButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}
