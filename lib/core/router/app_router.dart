import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/device_scan/presentation/scanner_home_screen.dart';
import '../../features/device_scan/presentation/scanner_login_screen.dart';
import '../../features/closing/presentation/closing_list_screen.dart';
import '../../features/closing/presentation/closing_request_detail_screen.dart';
import '../../features/closing/presentation/closing_success_screen.dart';
import '../../features/connection_requests/presentation/create_request_screen.dart';
import '../../features/installation/presentation/inventory_catalog_screen.dart';
import '../../features/installation/presentation/pending_authorization_list_screen.dart';
import '../../features/onu/presentation/authorize_onu_screen.dart';
import '../../features/onu/presentation/global_waiting_onus_screen.dart';
import '../../features/onu/presentation/olt_list_screen.dart';
import '../../features/onu/presentation/waiting_onu_list_screen.dart';
import '../../features/dashboard/dashboard_shell.dart';
import '../../features/installation/presentation/installation_list_screen.dart';
import '../../features/installation/presentation/installation_request_detail_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/splicing/presentation/splicing_list_screen.dart';
import '../../features/splicing/presentation/splicing_request_detail_screen.dart';
import '../../features/survey/presentation/all_requests_screen.dart';
import '../../features/survey/presentation/submit_survey_screen.dart';
import '../../features/survey/presentation/survey_list_screen.dart';
import '../../features/survey/presentation/survey_request_detail_screen.dart';
import '../../features/survey/presentation/survey_route_screen.dart';
import '../../features/tickets/presentation/ticket_list_screen.dart';
import '../../features/tickets/presentation/ticket_detail_screen.dart';
import '../../features/verification/presentation/verification_list_screen.dart';
import '../../features/verification/presentation/verification_request_detail_screen.dart';
import '../constants/app_constants.dart';
import '../storage/secure_storage.dart';
import '../../models/connection_request.dart';
import 'functional_team.dart';
import 'session_team_guard.dart';

/// Route names so navigation can reference stable identifiers.
abstract final class Routes {
  Routes._();

  /// Boot / readiness gate. Cold start and post-login both pass through it;
  /// it is the only route allowed to decide its own destination.
  static const boot = '/boot';
  static const login = '/login';
  static const scannerLogin = '/scanner-login';
  static const scannerHome = '/scanner/home';
  static const dashboard = '/dashboard';
  static const newRequest = '/requests/new';
  static const surveyList = '/survey/requests';
  static const surveyDetail = '/survey/requests/:id';
  static const submitSurvey = '/survey/requests/:id/submit-survey';
  // Survey review after Inventory approval (status `survey_review`,
  // `allowed_action` `review_survey`): same submit screen, review mode —
  // confirms with the same POST .../complete-survey.
  static const reviewSurvey = '/survey/requests/:id/review-survey';
  static const surveyRoute = '/survey/requests/:id/route';

  static const installationList = '/installation/requests';
  static const installationDetail = '/installation/requests/:id';
  // ONU authorization (ISPFINAL Phases E–F). Installation-team only; the
  // OLT list is scoped by the request's sub-branch, the waiting-ONU list by
  // OLT, and the authorize form by OLT + waiting ONU (or serial fallback
  // when the :onuId segment is absent).
  static const oltList = '/installation/requests/:id/olts';
  static const waitingOnus = '/installation/requests/:id/olts/:oltId/onus';
  static const authorizeOnu = '/installation/requests/:id/olts/:oltId/authorize/:onuId';
  static const authorizeOnuSerial = '/installation/requests/:id/olts/:oltId/authorize';
  static const splicingList = '/splicing/requests';
  static const splicingDetail = '/splicing/requests/:id';
  static const verificationList = '/verification/requests';
  static const verificationDetail = '/verification/requests/:id';
  static const closingList = '/closing/requests';
  static const closingDetail = '/closing/requests/:id';
  static const closingSuccess = '/closing/requests/:id/success';
  static const ticketsList = '/tickets';
  static const ticketDetail = '/tickets/:id';
  static const notifications = '/notifications';

  /// All connection requests across stages (D25 — Connection Flow tile).
  static const allRequests = '/requests';

  /// Inventory catalog (D25 — Inventory Items tile).
  static const inventory = '/inventory';

  /// Waiting ONUs across every OLT (D25 — Waiting ONUs tile).
  static const waitingOnusGlobal = '/waiting-onus';

  /// Requests awaiting ONU authorization (D25 — ONU Authorization tile
  /// fallback). Not the guarded installation list: see
  /// PendingAuthorizationListScreen for why this is a separate route.
  static const pendingAuthorization = '/requests/pending-authorization';

  /// Concrete detail path for a given request id.
  static String surveyDetailFor(String id) => '/survey/requests/$id';

  /// Concrete installation detail path for a given request id.
  static String installationDetailFor(String id) => '/installation/requests/$id';
  static String splicingDetailFor(String id) => '/splicing/requests/$id';
  static String verificationDetailFor(String id) => '/verification/requests/$id';
  static String closingDetailFor(String id) => '/closing/requests/$id';

  /// Concrete closing-success path for a given request id (D24).
  static String closingSuccessFor(String id) => '/closing/requests/$id/success';
  static String ticketDetailFor(String id) => '/tickets/$id';

  /// Concrete submit-survey path for a given request id.
  static String submitSurveyFor(String id) => '/survey/requests/$id/submit-survey';

  /// Concrete review-survey path for a given request id (Inventory review).
  static String reviewSurveyFor(String id) => '/survey/requests/$id/review-survey';

  /// Concrete OLT-list path for a given request id (ISPFINAL Phase E).
  static String oltListFor(String id) => '/installation/requests/$id/olts';

  /// Concrete waiting-ONU list path for a given request + OLT (Phase E).
  static String waitingOnusFor(String requestId, String oltId) =>
      '/installation/requests/$requestId/olts/$oltId/onus';

  /// Concrete authorize path for a discovered waiting ONU (Phase F).
  static String authorizeOnuFor(String requestId, String oltId, String onuId) =>
      '/installation/requests/$requestId/olts/$oltId/authorize/$onuId';

  /// Concrete authorize path for the serial fallback (Phase F, shape 2).
  static String authorizeOnuSerialFor(String requestId, String oltId) =>
      '/installation/requests/$requestId/olts/$oltId/authorize';

  /// Concrete route-planning path for a given request id.
  static String surveyRouteFor(String id) => '/survey/requests/$id/route';

  /// Chooses the detail route for a request from its backend `status`
  /// (D18) — not from the viewer's session team.
  ///
  /// A team can now own several stages at once, so a request's current stage
  /// may be ahead of the viewer's session team (e.g. a survey-session user
  /// tapping an `installation_assigned` request). The list payload carries
  /// `status` but no `allowed_actions`, so the status is the routing signal;
  /// it matches the backend's own status → allowed_action map
  /// (`survey_assigned → complete_survey`,
  /// `installation_assigned → complete_installation`, and so on for every
  /// stage). The detail screens themselves still gate their buttons on
  /// `allowed_actions` — this only picks which screen opens.
  ///
  /// An unknown or unmapped status falls back to [fallbackRouteFor] (the
  /// session team's detail route), so a tap can never go dead or crash on a
  /// status this build does not know yet.
  static String detailRouteForRequest(
    ConnectionRequest request,
    String Function(String requestId) fallbackRouteFor,
  ) {
    return switch (request.status) {
      ConnectionStatus.surveyAssigned => surveyDetailFor(request.id),
      ConnectionStatus.surveyReview => surveyDetailFor(request.id),
      // Guide §8 survey-lifecycle statuses: no action, read-only survey
      // detail (inventory approval is web-only). The survey detail screen
      // offers no action button when `allowed_actions` is empty (D19).
      ConnectionStatus.inventoryPending => surveyDetailFor(request.id),
      ConnectionStatus.surveyNotFeasible => surveyDetailFor(request.id),
      ConnectionStatus.surveyCompleted => surveyDetailFor(request.id),
      ConnectionStatus.installationAssigned =>
        installationDetailFor(request.id),
      ConnectionStatus.splicingAssigned => splicingDetailFor(request.id),
      ConnectionStatus.verificationAssigned =>
        verificationDetailFor(request.id),
      ConnectionStatus.closingAssigned => closingDetailFor(request.id),
      _ => fallbackRouteFor(request.id),
    };
  }
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
/// Closing employee can never land on another team's list screen. Detail
/// routes are stage-aware (D18): a user whose team owns several stages may
/// open a later stage's detail screen — the guard checks the team's
/// `functional_team_types` there instead of the single session team.
GoRouter buildAppRouter({required SecureStorage storage}) {
  return GoRouter(
    initialLocation: Routes.boot,
    redirect: (context, state) async {
      // The boot gate owns its destination; never bounce it to login.
      if (state.matchedLocation == Routes.boot) {
        return null;
      }
      final loggedIn = await storage.isLoggedIn();
      final scannerLoggedIn = await storage.isScannerLoggedIn();
      final onLogin = state.matchedLocation == Routes.login;
      final onScannerLogin = state.matchedLocation == Routes.scannerLogin;
      final onScannerHome = state.matchedLocation == Routes.scannerHome;

      // Neither session exists: only the two login screens are reachable.
      if (!loggedIn && !scannerLoggedIn) {
        return (onLogin || onScannerLogin) ? null : Routes.login;
      }
      // Staff login while a session already exists goes to that session's
      // home (employee → dashboard, scanner-only → scanner home).
      if (onLogin) {
        return loggedIn ? Routes.dashboard : Routes.scannerHome;
      }
      // Scanner login is ALWAYS reachable: never bounce away from it here.
      // The two logins are independent entry points for two independent
      // sessions, and the scanner form is only ever reached by an explicit
      // tap on the "Device scanner? Sign in here" link. Bouncing an
      // employee-signed-in user to the dashboard (the pre-2026-11-23
      // behaviour) made the scanner form unreachable whenever any employee
      // token existed. And the redirect must not bounce to the scanner
      // home on token presence alone either: a STALE scanner token (401
      // on GET /me) would send the user to the scanner home, which then
      // has no session to show. The screen itself is the verified gate —
      // ScannerLoginScreen._tryRestore proves the token with GET /me and
      // forwards to the scanner home only when it verifies, otherwise it
      // shows the form. So the redirect stays out of the way entirely.
      // NOTE: the mirrored `onLogin` branch is intentionally NOT relaxed
      // the same way — the boot gate lands scanner-only users on the
      // employee login and relies on that branch to forward them to the
      // scanner home on cold start.
      if (onScannerLogin) {
        return null;
      }
      // Scanner home needs a scanner session only — an employee-only
      // session goes to the dashboard instead of the scanner home.
      if (onScannerHome && !scannerLoggedIn) {
        return Routes.dashboard;
      }
      // Employee routes need the employee session: a scanner-only session
      // belongs on the scanner home, not the dashboard.
      if (!loggedIn) {
        return scannerLoggedIn ? Routes.scannerHome : Routes.login;
      }
      return null;
    },
    routes: [
      GoRoute(path: Routes.boot, builder: (context, state) => const SplashScreen()),
      GoRoute(path: Routes.login, builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: Routes.scannerLogin,
        builder: (context, state) => const ScannerLoginScreen(),
      ),
      GoRoute(
        path: Routes.scannerHome,
        builder: (context, state) => const ScannerHomeScreen(),
      ),
      GoRoute(path: Routes.dashboard, builder: (context, state) => const DashboardShell()),
      // New connection request (ISPFINAL Phase C). Protected route — the
      // redirect above bounces unauthenticated users to login as usual.
      // Survey-team only: a new request always starts at survey (§4).
      GoRoute(
        path: Routes.newRequest,
        builder: (context, state) => const SessionTeamGuard(
          expectedTeam: FunctionalTeamType.survey,
          child: CreateRequestScreen(),
        ),
      ),
      GoRoute(path: Routes.ticketsList, builder: (context, state) => const TicketListScreen()),
      // D25 shared screens — reached from every team's dashboard, so
      // unguarded like the tickets list (no single team owns them). The
      // data is backend-scoped by the employee token; the dashboard tiles
      // already read the same providers without a guard.
      GoRoute(
        path: Routes.allRequests,
        builder: (context, state) => const AllRequestsScreen(),
      ),
      GoRoute(
        path: Routes.inventory,
        builder: (context, state) => const InventoryCatalogScreen(),
      ),
      GoRoute(
        path: Routes.waitingOnusGlobal,
        builder: (context, state) => const GlobalWaitingOnusScreen(),
      ),
      GoRoute(
        path: Routes.pendingAuthorization,
        builder: (context, state) => const PendingAuthorizationListScreen(),
      ),
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
          stageAware: true,
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
          stageAware: true,
          child: ClosingRequestDetailScreen(
            requestId: state.pathParameters['id'] ?? '',
          ),
        ),
      ),
      GoRoute(
        path: Routes.closingSuccess,
        builder: (context, state) {
          // D24: the success screen is only ever pushed from the closing
          // form with the activation in `extra`. A deep link (or a
          // restored route) without it still renders a plain success with
          // a working Close button — never a crash.
          final args = state.extra is ClosingSuccessArgs
              ? state.extra as ClosingSuccessArgs
              : ClosingSuccessArgs(
                  message: null,
                  activation: null,
                  voiceNoteWarning: null,
                  listRoute: Routes.closingList,
                );
          return SessionTeamGuard(
            expectedTeam: FunctionalTeamType.closing,
            stageAware: true,
            child: ClosingSuccessScreen(args: args),
          );
        },
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
          stageAware: true,
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
        path: Routes.reviewSurvey,
        builder: (context, state) => SessionTeamGuard(
          expectedTeam: FunctionalTeamType.survey,
          child: SubmitSurveyScreen(
            requestId: state.pathParameters['id'] ?? '',
            isReview: true,
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
          stageAware: true,
          child: InstallationRequestDetailScreen(
            requestId: state.pathParameters['id'] ?? '',
          ),
        ),
      ),
      // ONU authorization (ISPFINAL Phases E–F). Stage-aware like the
      // installation detail guard above: these screens are reached from
      // the installation detail's "Authorize ONU" button, so a multi-stage
      // user admitted to that detail screen must also reach them.
      GoRoute(
        path: Routes.oltList,
        builder: (context, state) => SessionTeamGuard(
          expectedTeam: FunctionalTeamType.installation,
          stageAware: true,
          child: OltListScreen(
            requestId: state.pathParameters['id'] ?? '',
          ),
        ),
      ),
      GoRoute(
        path: Routes.waitingOnus,
        builder: (context, state) => SessionTeamGuard(
          expectedTeam: FunctionalTeamType.installation,
          stageAware: true,
          child: WaitingOnuListScreen(
            requestId: state.pathParameters['id'] ?? '',
            oltId: state.pathParameters['oltId'] ?? '',
          ),
        ),
      ),
      GoRoute(
        path: Routes.authorizeOnu,
        builder: (context, state) => SessionTeamGuard(
          expectedTeam: FunctionalTeamType.installation,
          stageAware: true,
          child: AuthorizeOnuScreen(
            requestId: state.pathParameters['id'] ?? '',
            oltId: state.pathParameters['oltId'] ?? '',
            onuId: state.pathParameters['onuId'],
          ),
        ),
      ),
      GoRoute(
        path: Routes.authorizeOnuSerial,
        builder: (context, state) => SessionTeamGuard(
          expectedTeam: FunctionalTeamType.installation,
          stageAware: true,
          child: AuthorizeOnuScreen(
            requestId: state.pathParameters['id'] ?? '',
            oltId: state.pathParameters['oltId'] ?? '',
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
          stageAware: true,
          child: SplicingRequestDetailScreen(
            requestId: state.pathParameters['id'] ?? '',
          ),
        ),
      ),
    ],
  );
}