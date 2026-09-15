import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_exceptions.dart';
import '../../core/router/functional_team.dart';
import '../../core/router/team_module.dart';
import '../../shared/widgets/coming_soon_screen.dart';
import '../auth/presentation/providers.dart';

/// Exposes the employee's `functional_team_type` from secure storage as a
/// parseable [FunctionalTeamType]. `null` means an unknown/absent team.
final functionalTeamTypeProvider = FutureProvider.autoDispose<FunctionalTeamType?>((ref) async {
  final raw = await ref.watch(secureStorageProvider).getFunctionalTeamType();
  return FunctionalTeamType.fromWire(raw);
});

/// Route-level dispatcher: after login, shows the dashboard for the employee's
/// team. The dispatch is a single exhaustive switch over [FunctionalTeamType]
/// through [TeamModule] — there is no fallback arm, so every known team maps to
/// its own dashboard and an unknown/empty team is surfaced explicitly instead
/// of silently rendering the wrong team or a generic placeholder.
class DashboardShell extends ConsumerWidget {
  const DashboardShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamFuture = ref.watch(functionalTeamTypeProvider.future);
    return FutureBuilder<FunctionalTeamType?>(
      future: teamFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasError) {
          final error = snapshot.error;
          return Scaffold(
            body: Center(
              child: Text(error is ApiException ? error.message : 'Failed to load dashboard'),
            ),
          );
        }

        final team = snapshot.data;
        if (team == null) {
          return const ComingSoonScreen(
            featureName: 'Your team',
            message: 'No team is assigned to this account yet. Contact your administrator.',
          );
        }

        return TeamModule.forTeam(team).dashboardScreen;
      },
    );
  }
}