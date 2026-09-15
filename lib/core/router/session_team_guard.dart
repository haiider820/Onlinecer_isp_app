import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/dashboard/dashboard_shell.dart';
import 'app_router.dart';
import 'functional_team.dart';

/// Prevents stale or direct team routes from rendering for the wrong employee.
///
/// The persisted session's current team is the source of truth, read through
/// [functionalTeamTypeProvider] — the same value the dashboard shell dispatches
/// on. If a route and session disagree, the app returns to the dashboard shell,
/// which dispatches from the current session value again. The mismatch check is
/// a typed [FunctionalTeamType] comparison, so an unknown wire value can never
/// be misread as a valid team.
class SessionTeamGuard extends ConsumerWidget {
  const SessionTeamGuard({
    super.key,
    required this.expectedTeam,
    required this.child,
  });

  final FunctionalTeamType expectedTeam;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<FunctionalTeamType?>(
      future: ref.watch(functionalTeamTypeProvider.future),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.data != expectedTeam) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) context.go(Routes.dashboard);
          });
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        return child;
      },
    );
  }
}