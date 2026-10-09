import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/api_exceptions.dart';
import '../../core/router/team_module.dart';
import '../../shared/widgets/coming_soon_screen.dart';
import 'dashboard_shell.dart';

/// Queue tab anchor.
///
/// Resolves the session's `functional_team_type` and forwards to that team's
/// real list path (the same branch), so the tab lands on exactly the route the
/// rest of the app already uses — [SessionTeamGuard] wrapping, "View All"
/// buttons, and notification deep links all stay pointed at the canonical
/// paths instead of a parallel `/queue` copy of the screens.
class TeamQueueScreen extends ConsumerWidget {
  const TeamQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamAsync = ref.watch(functionalTeamTypeProvider);
    return teamAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        body: Center(
          child: Text(
            error is ApiException ? error.message : 'Failed to load queue',
          ),
        ),
      ),
      data: (team) {
        if (team == null) {
          return const ComingSoonScreen(
            featureName: 'Your team',
            message:
                'No team is assigned to this account yet. Contact your administrator.',
          );
        }
        final target = TeamModule.forTeam(team).listRoute;
        // One-shot forward after this frame; the list route lives in the same
        // shell branch, so the bottom tabs persist across the swap.
        //
        // pushReplacement, not go: `go` would rewrite the whole page stack
        // and drop whatever pushed this anchor (the dashboard's Working Queue
        // tile), so system back would leave the app instead of returning to
        // the screen the technician came from.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          context.pushReplacement(target);
        });
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
