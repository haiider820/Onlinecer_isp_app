import 'package:flutter/material.dart';

/// Placeholder screen for teams or features not yet implemented.
///
/// [message] replaces the default "This feature is coming soon." body text when
/// provided, for the case of an unrecognised / unassigned team that should
/// explain itself rather than implying the feature is still being built.
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({
    super.key,
    required this.featureName,
    this.message,
    this.onSignOut,
  });

  final String featureName;

  /// Optional override for the default body text.
  final String? message;

  /// When provided, a "Log out" escape is shown: a signed-in user whose
  /// account has no usable team must always be able to sign out instead
  /// of being stranded (D10). Screens that have no session to escape from
  /// leave this null and render exactly as before.
  final VoidCallback? onSignOut;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(featureName)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction, size: 48),
            const SizedBox(height: 12),
            Text(message ?? 'This feature is coming soon.'),
            if (onSignOut != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onSignOut,
                icon: const Icon(Icons.logout),
                label: const Text('Log out'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}