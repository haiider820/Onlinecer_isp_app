import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/api_exceptions.dart';
import '../../core/router/app_router.dart';
import '../../core/router/functional_team.dart';
import '../../core/router/team_module.dart';
import '../../shared/widgets/coming_soon_screen.dart';
import '../auth/presentation/providers.dart';
import '../lookups/presentation/sub_branch_providers.dart';
import '../survey/presentation/dashboard_providers.dart';

/// Exposes the employee's `functional_team_type` from secure storage as a
/// parseable [FunctionalTeamType]. `null` means an unknown/absent team.
final functionalTeamTypeProvider = FutureProvider.autoDispose<FunctionalTeamType?>((ref) async {
  final raw = await ref.watch(secureStorageProvider).getFunctionalTeamType();
  return FunctionalTeamType.fromWire(raw);
});

/// Exposes the employee's `functional_team_types` list from secure storage
/// (D18): every stage the employee's team owns, parsed into typed values.
/// Unknown wire values are dropped. An empty list means nothing was stored
/// (legacy sessions, or a backend that omits the field) — callers must
/// treat it as "unknown", never as "no stages", and fall back to the single
/// [functionalTeamTypeProvider] value.
final functionalTeamTypesProvider =
    FutureProvider.autoDispose<List<FunctionalTeamType>>((ref) async {
  final raw = await ref.watch(secureStorageProvider).getFunctionalTeamTypes();
  if (raw == null) return const <FunctionalTeamType>[];
  return raw
      .map(FunctionalTeamType.fromWire)
      .whereType<FunctionalTeamType>()
      .toList();
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
          return ComingSoonScreen(
            featureName: 'Your team',
            message: 'No team is assigned to this account yet. Contact your administrator.',
            onSignOut: () => _signOut(context, ref),
          );
        }

        return TeamModule.forTeam(team).dashboardScreen;
      },
    );
  }

  /// Same logout path as the dashboard header: drops the employee session
  /// (scanner keys and the theme choice are untouched) and its sub-branch
  /// scope, then lands on the employee login.
  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    await ref.read(secureStorageProvider).clearSession();
    invalidateSubBranchState(ref);
    ref.invalidate(dashboardSummaryProvider);
    if (context.mounted) context.go(Routes.login);
  }
}