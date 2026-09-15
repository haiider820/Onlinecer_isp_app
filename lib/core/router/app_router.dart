import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/closing/presentation/closing_list_screen.dart';
import '../../features/closing/presentation/closing_request_detail_screen.dart';
import '../../features/dashboard/dashboard_shell.dart';
import '../../features/installation/presentation/installation_list_screen.dart';
import '../../features/installation/presentation/installation_request_detail_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/splicing/presentation/splicing_list_screen.dart';
import '../../features/splicing/presentation/splicing_request_detail_screen.dart';
import '../../features/survey/presentation/submit_survey_screen.dart';
import '../../features/survey/presentation/survey_list_screen.dart';
import '../../features/survey/presentation/survey_request_detail_screen.dart';
import '../../features/survey/presentation/survey_route_screen.dart';
import '../../features/tickets/presentation/ticket_list_screen.dart';
import '../../features/tickets/presentation/ticket_detail_screen.dart';
import '../../features/verification/presentation/verification_list_screen.dart';
import '../../features/verification/presentation/verification_request_detail_screen.dart';
import 'functional_team.dart';
import 'session_team_guard.dart';
import '../storage/secure_storage.dart';

/// Route names so navigation can reference stable identifiers.
abstract final class Routes {
  Routes._();

  /// Boot / readiness gate. Cold start and post-login both pass through it;
  /// it is the only route allowed to decide its own destination.
  static const boot = '/boot';
  static const login = '/login';
  static const dashboard = '/dashboard';
  static const surveyList = '/survey/requests';
  static const surveyDetail = '/survey/requests/:id';
  static const submitSurvey = '/survey/requests/:id/submit-survey';
  static const surveyRoute = '/survey/requests/:id/route';

  static const installationList = '/installation/requests';
  static const installationDetail = '/installation/requests/:id';
  static const splicingList = '/splicing/requests';
  static const splicingDetail = '/splicing/requests/:id';
  static const verificationList = '/verification/requests';
  static const verificationDetail = '/verification/requests/:id';
  static const closingList = '/closing/requests';
  static const closingDetail = '/closing/requests/:id';
  static const ticketsList = '/tickets';
  static const ticketDetail = '/tickets/:id';
  static const notifications = '/notifications';

  /// Concrete detail path for a given request id.
  static String surveyDetailFor(String id) => '/survey/requests/$id';

  /// Concrete installation detail path for a given request id.
  static String installationDetailFor(String id) => '/installation/requests/$id';
  static String splicingDetailFor(String id) => '/splicing/requests/$id';
  static String verificationDetailFor(String id) => '/verification/requests/$id';
  static String closingDetailFor(String id) => '/closing/requests/$id';
  static String ticketDetailFor(String id) => '/tickets/$id';

  /// Concrete submit-survey path for a given request id.
  static String submitSurveyFor(String id) => '/survey/requests/$id/submit-survey';

  /// Concrete route-planning path for a given request id.
  static String surveyRouteFor(String id) => '/survey/requests/$id/route';
}

/// Builds the app's [GoRouter].
///
/// `/boot` is the readiness gate: on cold start and after login it verifies
/// the session (storage read-back + real `GET /me`) and only then routes to
/// login or the dashboard. It is deliberately exempt from the auth redirect —
/// the boot sequence itself decides the destination.
///
/// After that, the router reads the employee's `functional_team_type` from
/// secure storage and routes to [`DashboardShell`], which itself dispatches to
/// the team's dashboard. Every team-scoped sub-route is gated by
/// [SessionTeamGuard] against that same session value, so a Verification or
/// Closing employee can never land on another team's list or detail screen.
GoRouter buildAppRouter({required SecureStorage storage}) {
  return GoRouter(
    initialLocation: Routes.boot,
    redirect: (context, state) async {
      // The boot gate owns its destination; never bounce it to login.
      if (state.matchedLocation == Routes.boot) {
        return null;
      }
      final loggedIn = await storage.isLoggedIn();
      final onLogin = state.matchedLocation == Routes.login;
      if (!loggedIn) {
        return onLogin ? null : Routes.login;
      }
      if (onLogin) {
        return Routes.dashboard;
      }
      return null;
    },
    routes: [
      GoRoute(path: Routes.boot, builder: (context, state) => const SplashScreen()),
      GoRoute(path: Routes.login, builder: (context, state) => const LoginScreen()),
      GoRoute(path: Routes.dashboard, builder: (context, state) => const DashboardShell()),
      GoRoute(path: Routes.ticketsList, builder: (context, state) => const TicketListScreen()),
      // Notifications — UI renders sample data until the backend endpoint
      // exists (see notifications_screen.dart).
      GoRoute(
        path: Routes.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: Routes.ticketDetail,
        builder: (context, state) => TicketDetailScreen(ticketId: state.pathParameters['id'] ?? ''),
      ),
      GoRoute(
        path: Routes.verificationList,
        builder: (context, state) => const SessionTeamGuard(
          expectedTeam: FunctionalTeamType.connectionVerification,
          child: VerificationListScreen(),
        ),
      ),
      GoRoute(
        path: Routes.verificationDetail,
        builder: (context, state) => SessionTeamGuard(
          expectedTeam: FunctionalTeamType.connectionVerification,
          child: VerificationRequestDetailScreen(
            requestId: state.pathParameters['id'] ?? '',
          ),
        ),
      ),
      GoRoute(
        path: Routes.closingList,
        builder: (context, state) => const SessionTeamGuard(
          expectedTeam: FunctionalTeamType.closing,
          child: ClosingListScreen(),
        ),
      ),
      GoRoute(
        path: Routes.closingDetail,
        builder: (context, state) => SessionTeamGuard(
          expectedTeam: FunctionalTeamType.closing,
          child: ClosingRequestDetailScreen(
            requestId: state.pathParameters['id'] ?? '',
          ),
        ),
      ),
      GoRoute(
        path: Routes.surveyList,
        builder: (context, state) => const SessionTeamGuard(
          expectedTeam: FunctionalTeamType.survey,
          child: SurveyListScreen(),
        ),
      ),
      GoRoute(
        path: Routes.surveyDetail,
        builder: (context, state) => SessionTeamGuard(
          expectedTeam: FunctionalTeamType.survey,
          child: SurveyRequestDetailScreen(
            requestId: state.pathParameters['id'] ?? '',
          ),
        ),
      ),
      GoRoute(
        path: Routes.submitSurvey,
        builder: (context, state) => SessionTeamGuard(
          expectedTeam: FunctionalTeamType.survey,
          child: SubmitSurveyScreen(
            requestId: state.pathParameters['id'] ?? '',
          ),
        ),
      ),
      GoRoute(
        path: Routes.surveyRoute,
        builder: (context, state) => SessionTeamGuard(
          expectedTeam: FunctionalTeamType.survey,
          child: SurveyRouteScreen(
            requestId: state.pathParameters['id'] ?? '',
          ),
        ),
      ),
      GoRoute(
        path: Routes.installationList,
        builder: (context, state) => const SessionTeamGuard(
          expectedTeam: FunctionalTeamType.installation,
          child: InstallationListScreen(),
        ),
      ),
      GoRoute(
        path: Routes.installationDetail,
        builder: (context, state) => SessionTeamGuard(
          expectedTeam: FunctionalTeamType.installation,
          child: InstallationRequestDetailScreen(
            requestId: state.pathParameters['id'] ?? '',
          ),
        ),
      ),
      GoRoute(
        path: Routes.splicingList,
        builder: (context, state) => const SessionTeamGuard(
          expectedTeam: FunctionalTeamType.fiberSplicing,
          child: SplicingListScreen(),
        ),
      ),
      GoRoute(
        path: Routes.splicingDetail,
        builder: (context, state) => SessionTeamGuard(
          expectedTeam: FunctionalTeamType.fiberSplicing,
          child: SplicingRequestDetailScreen(
            requestId: state.pathParameters['id'] ?? '',
          ),
        ),
      ),
    ],
  );
}