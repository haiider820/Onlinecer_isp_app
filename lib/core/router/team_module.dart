import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/closing/presentation/closing_providers.dart';
import '../../features/installation/presentation/installation_providers.dart';
import '../../features/splicing/presentation/splicing_providers.dart';
import '../../features/stage_shared/team_stage_config.dart';
import '../../features/verification/presentation/verification_providers.dart';
import '../../features/survey/presentation/connection_request_providers.dart';
import '../../models/connection_request.dart';
import '../../shared/widgets/team_dashboard_screen.dart';
import 'app_router.dart';
import 'functional_team.dart';

/// One place — the single source of truth — that turns the current session's
/// [FunctionalTeamType] into everything the app needs to render for that team.
///
/// Every label, route, widget, and queue provider a team ever shows is defined
/// here and only here. No other file may hardcode a team label or a team route;
/// any component that needs one must go through [TeamModule.forTeam].
class TeamModule {
  const TeamModule({
    required this.team,
    required this.dashboardTitle,
    required this.detailTitle,
    required this.viewAllLabel,
    required this.pendingLabel,
    required this.defaultEmployeeLabel,
    required this.defaultTeamLabel,
    required this.listTitle,
    required this.listRoute,
    required this.detailRouteFor,
    required this.inboxPageProvider,
    this.stageConfig,
  });

  /// The team this module describes.
  final FunctionalTeamType team;

  /// AppBar title on the dashboard. Kept deliberately short (no "Dashboard"
  /// suffix) so it never ellipsises on a 360dp-wide phone alongside the logo,
  /// notification bell, and logout icon.
  final String dashboardTitle;

  /// AppBar title of this team's request-detail screen.
  final String detailTitle;

  /// Bottom "View All …" button on the dashboard.
  final String viewAllLabel;

  /// Pending-count tile label on the dashboard.
  final String pendingLabel;

  /// Placeholder employee label when the backend omits the name.
  final String defaultEmployeeLabel;

  /// Placeholder team label when the backend omits the team name.
  final String defaultTeamLabel;

  /// AppBar title of this team's request list screen.
  final String listTitle;

  /// Route path for the full request list.
  final String listRoute;

  /// Concrete detail path for a given request id.
  final String Function(String requestId) detailRouteFor;

  /// Fetches one page of this team's queue (status-filtered server-side for
  /// installation/splicing/verification/closing; unfiltered for survey).
  final FutureProviderFamily<ConnectionRequestPage, int> inboxPageProvider;

  /// Stage-specific completion config — only Verification and Closing have one.
  final TeamStageConfig? stageConfig;

  /// The mounted dashboard for this team, built entirely from [TeamModule]
  /// values so the AppBar title, pending label, "View All" button, and routes
  /// can never disagree with the team that was dispatched.
  Widget get dashboardScreen => TeamDashboardScreen(
        featureName: dashboardTitle,
        defaultEmployeeLabel: defaultEmployeeLabel,
        defaultTeamLabel: defaultTeamLabel,
        pendingLabel: pendingLabel,
        viewAllLabel: viewAllLabel,
        listRoute: listRoute,
        detailRouteFor: detailRouteFor,
      );

  /// The canonical dispatch. Exhaustive `switch` with NO default arm: if a team
  /// is ever added, or a team's spec forgotten, this fails to compile instead
  /// of silently returning the wrong dashboard/label/route.
  static TeamModule forTeam(FunctionalTeamType team) {
    return switch (team) {
      FunctionalTeamType.survey => TeamModule(
          team: FunctionalTeamType.survey,
          dashboardTitle: 'Survey',
          detailTitle: 'Request Detail',
          viewAllLabel: 'View All Survey Requests',
          pendingLabel: 'Pending',
          defaultEmployeeLabel: 'Survey Employee',
          defaultTeamLabel: 'Survey Team',
          listTitle: 'Survey Requests',
          listRoute: Routes.surveyList,
          detailRouteFor: Routes.surveyDetailFor,
          inboxPageProvider: connectionRequestsProvider,
        ),
      FunctionalTeamType.installation => TeamModule(
          team: FunctionalTeamType.installation,
          dashboardTitle: 'Installation',
          detailTitle: 'Installation Detail',
          viewAllLabel: 'View All Installation Requests',
          pendingLabel: 'Pending',
          defaultEmployeeLabel: 'Installation Technician',
          defaultTeamLabel: 'Installation Team',
          listTitle: 'Installation Requests',
          listRoute: Routes.installationList,
          detailRouteFor: Routes.installationDetailFor,
          inboxPageProvider: installationRequestsProvider,
        ),
      FunctionalTeamType.fiberSplicing => TeamModule(
          team: FunctionalTeamType.fiberSplicing,
          dashboardTitle: 'Splicing',
          detailTitle: 'Splicing Detail',
          viewAllLabel: 'View All Pending Splicing',
          pendingLabel: 'Pending Splicing',
          defaultEmployeeLabel: 'Fiber Splicer',
          defaultTeamLabel: 'Fiber Splicing Team',
          listTitle: 'Pending Splicing',
          listRoute: Routes.splicingList,
          detailRouteFor: Routes.splicingDetailFor,
          inboxPageProvider: splicingRequestsProvider,
        ),
      FunctionalTeamType.connectionVerification => TeamModule(
          team: FunctionalTeamType.connectionVerification,
          dashboardTitle: 'Verification',
          detailTitle: 'Verification Detail',
          viewAllLabel: 'View All Pending Verification',
          pendingLabel: 'Pending Verification',
          defaultEmployeeLabel: 'Verification Officer',
          defaultTeamLabel: 'Connection Verification Team',
          listTitle: 'Pending Verification',
          listRoute: Routes.verificationList,
          detailRouteFor: Routes.verificationDetailFor,
          inboxPageProvider: verificationRequestsProvider,
          stageConfig: TeamStageConfig.verification,
        ),
      FunctionalTeamType.closing => TeamModule(
          team: FunctionalTeamType.closing,
          dashboardTitle: 'Closing',
          detailTitle: 'Closing Detail',
          viewAllLabel: 'View All Pending Closing',
          pendingLabel: 'Pending Closing',
          defaultEmployeeLabel: 'Closing Officer',
          defaultTeamLabel: 'Closing Team',
          listTitle: 'Pending Closing',
          listRoute: Routes.closingList,
          detailRouteFor: Routes.closingDetailFor,
          inboxPageProvider: closingRequestsProvider,
          stageConfig: TeamStageConfig.closing,
        ),
    };
  }
}