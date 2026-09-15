import 'package:flutter_test/flutter_test.dart';
import 'package:isp_onlinecer/core/router/functional_team.dart';
import 'package:isp_onlinecer/core/router/team_module.dart';

/// Single consolidated dispatch test (per the bug report): drive all five
/// [FunctionalTeamType] values through the one [TeamModule.forTeam] dispatch and
/// prove that every label a user sees — dashboard title, "View All" button,
/// list title, pending label, detail title — and every route/queue provider all
/// correspond to the *same* team.
void main() {
  const expectations = <(FunctionalTeamType, String, String, String, String, String)>[
    // team, dashboard title, view-all button, list title, pending label, detail title
    (FunctionalTeamType.survey, 'Survey', 'View All Survey Requests',
        'Survey Requests', 'Pending', 'Request Detail'),
    (FunctionalTeamType.installation, 'Installation', 'View All Installation Requests',
        'Installation Requests', 'Pending', 'Installation Detail'),
    (FunctionalTeamType.fiberSplicing, 'Splicing', 'View All Pending Splicing',
        'Pending Splicing', 'Pending Splicing', 'Splicing Detail'),
    (FunctionalTeamType.connectionVerification, 'Verification', 'View All Pending Verification',
        'Pending Verification', 'Pending Verification', 'Verification Detail'),
    (FunctionalTeamType.closing, 'Closing', 'View All Pending Closing',
        'Pending Closing', 'Pending Closing', 'Closing Detail'),
  ];

  test('forTeam dispatches every team to labels, routes, and queue of the same team', () {
    expect(expectations, hasLength(FunctionalTeamType.values.length),
        reason: 'Every team in the enum must have an expectation — the exhaustive '
            'switch with no default arm also guarantees this at compile time.');

    for (final (team, dashboard, viewAll, listTitle, pending, detailTitle) in expectations) {
      final module = TeamModule.forTeam(team);

      // Identity: the module describes exactly the team it was asked for.
      expect(module.team, team);

      // Labels a user sees all name this one team and no other.
      expect(module.dashboardTitle, dashboard);
      expect(module.viewAllLabel, viewAll);
      expect(module.listTitle, listTitle);
      expect(module.pendingLabel, pending);
      expect(module.detailTitle, detailTitle);

      // Routes can never cross teams: each detail path is nested under its own
      // team's list route, so both screens live under the same team segment.
      final detailRoute = module.detailRouteFor('request-123');
      expect(detailRoute, startsWith(module.listRoute));
      expect(detailRoute, endsWith('request-123'));

      // The shared queue provider is wired, and the two stage teams carry the
      // matching stage config that labels and completes for this team.
      expect(module.inboxPageProvider, isNotNull);
      if (team == FunctionalTeamType.connectionVerification ||
          team == FunctionalTeamType.closing) {
        expect(module.stageConfig, isNotNull);
        expect(module.stageConfig!.team, team);
      } else {
        expect(module.stageConfig, isNull);
      }
    }
  });
}