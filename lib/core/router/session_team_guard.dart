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
///
/// D18 — stage-aware detail routes: a team can now own several stages at once
/// (e.g. Centralized Tech owns all five), and one user does them all. A strict
/// single-team check would bounce such a user off a later stage's detail
/// screen even though the backend offers them that stage's action. Detail
/// routes therefore pass `stageAware: true`: the guard then admits the user
/// when the route's [expectedTeam] is in the employee team's persisted
/// `functional_team_types` list ([functionalTeamTypesProvider]). List and
/// dashboard routes stay strict — only detail (and the ONU sub-routes reached
/// from the installation detail screen) use the relaxed check. When no list
/// was ever stored (legacy sessions, or a backend that omits the field), the
/// guard falls back to the strict single-team comparison, so old sessions
/// behave exactly as before.
class SessionTeamGuard extends ConsumerWidget {
  const SessionTeamGuard({
    super.key,
    required this.expectedTeam,
    required this.child,
    this.stageAware = false,
  });

  final FunctionalTeamType expectedTeam;
  final Widget child;

  /// When `true`, admit the user when [expectedTeam] is one of the stages
  /// the employee's team owns (see [functionalTeamTypesProvider]).
  /// `false` (default) keeps the original strict single-team check.
  final bool stageAware;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamFuture = ref.watch(functionalTeamTypeProvider.future);
    final typesFuture = stageAware
        ? ref.watch(functionalTeamTypesProvider.future)
        : Future.value(const <FunctionalTeamType>[]);
    return FutureBuilder<(FunctionalTeamType?, List<FunctionalTeamType>)>(
      future: Future.wait([teamFuture, typesFuture]).then(
        (values) => (
          values[0] as FunctionalTeamType?,
          values[1] as List<FunctionalTeamType>,
        ),
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final team = snapshot.data?.$1;
        final ownedStages = snapshot.data?.$2 ?? const <FunctionalTeamType>[];
        // Stage-aware detail routes admit any stage the team owns; with no
        // stored list the check degrades to the strict single-team one.
        final admitted = ownedStages.isNotEmpty
            ? ownedStages.contains(expectedTeam)
            : team == expectedTeam;

        if (!admitted) {
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
