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
  });

  final String featureName;

  /// Optional override for the default body text.
  final String? message;

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
          ],
        ),
      ),
    );
  }
}