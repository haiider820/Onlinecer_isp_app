import 'package:flutter/foundation.dart';

/// Application-wide constants and environment configuration.
///
/// Base URL selection:
/// - Pass `--dart-define=API_BASE_URL=http://127.0.0.1:8000/api/mobile` for local dev
/// - Defaults to the production server when the define is absent.
abstract final class AppConstants {
  AppConstants._();

  /// Whether the app is running as a debug/flutter run build.
  static bool get isDebug => kDebugMode;

  static const String _defaultBaseUrl = 'https://ttsn.onlinecer.com/api/mobile';

  /// Production API base URL.
  static const String prodBaseUrl = _defaultBaseUrl;

  /// Local development API base URL.
  static const String localBaseUrl = 'http://127.0.0.1:8000/api/mobile';

  /// The active API base URL. Override via `--dart-define=API_BASE_URL=...`.
  ///
  /// Read once at startup so hot restarts pick up the value consistently.
  static String get baseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;
    return _defaultBaseUrl;
  }
}

/// Endpoint paths, resolved against [AppConstants.baseUrl].
abstract final class Endpoints {
  Endpoints._();

  // Auth
  static String get login => '/login';
  static String get me => '/me';
  static String get logout => '/logout';

  // Dashboard
  static String get dashboard => '/dashboard';
  static String get tickets => '/tickets';
  static String ticketDetail(String id) => '/tickets/$id';
  static String advanceTicket(String id) => '/tickets/$id/advance';

  // Connection requests
  static String connectionRequests() => '/connection-requests';
  static String connectionRequestDetail(String id) => '/connection-requests/$id';
  static String completeSurvey(String id) => '/connection-requests/$id/complete-survey';
  static String calculateRoute(String id) => '/connection-requests/$id/route';
  static String completeInstallation(String id) =>
      '/connection-requests/$id/complete-installation';
  static String completeSplicing(String id) =>
      '/connection-requests/$id/complete-splicing';
  static String completeVerification(String id) =>
      '/connection-requests/$id/complete-verification';
  static String completeClosing(String id) =>
      '/connection-requests/$id/complete-closing';
  static String requestVoiceNote(String id) => '/connection-requests/$id/voice-note';

  // Lookups
  static String fatNodes(String connectionRequestId) =>
      '/lookups/fat-nodes?connection_request_id=$connectionRequestId';
  static String get inventoryItems => '/lookups/inventory-items';
  static String get plans => '/lookups/plans';
  static String subBranches({String? subBranchId}) => subBranchId == null
      ? '/lookups/sub-branches'
      : '/lookups/sub-branches?sub_branch_id=$subBranchId';
  static String directOlts({String? subBranchId}) => subBranchId == null
      ? '/lookups/direct-olts'
      : '/lookups/direct-olts?sub_branch_id=$subBranchId';
  static String discoverWaitingOnus(String oltId) =>
      '/lookups/direct-olts/$oltId/discover-waiting-onus';
  static String waitingOnus(String oltId) =>
      '/lookups/direct-olts/$oltId/waiting-onus';
  static String oltProfiles(String oltId, {String? subBranchId}) =>
      subBranchId == null
          ? '/lookups/direct-olts/$oltId/profiles'
          : '/lookups/direct-olts/$oltId/profiles?sub_branch_id=$subBranchId';

  // Connection request creation (ISPFINAL §3–§4)
  static String createData({String? subBranchId}) => subBranchId == null
      ? '/connection-requests/create-data'
      : '/connection-requests/create-data?sub_branch_id=$subBranchId';
  static String createConnectionRequest() => '/connection-requests';
  static String authorizeOnu(String requestId) =>
      '/connection-requests/$requestId/authorize-onu';
  static String authorizationJob(String requestId, String jobId) =>
      '/connection-requests/$requestId/authorization-jobs/$jobId';

  // Notifications
  static String get notifications => '/notifications';
  static String get notificationUnreadCount => '/notifications/unread-count';
  static String get notificationRecent => '/notifications/recent';
  static String notificationRead(String id) => '/notifications/$id/read';
  static String get notificationReadAll => '/notifications/read-all';
  static String notificationOpen(String id) => '/notifications/$id/open';
}

/// Backend status strings that drive per-team request queues. Each team's list
/// endpoint filters the connection-request queue to the statuses it owns.
/// The status → allowed_action map (backend reply, API report §13) is:
/// `survey_assigned → complete_survey`, `survey_review → review_survey`,
/// `installation_assigned → complete_installation`,
/// `splicing_assigned → complete_splicing`,
/// `verification_assigned → complete_verification`,
/// `closing_assigned → complete_closing`, anything else → no action.
///
/// The survey-lifecycle statuses (guide §8) carry no action: a feasible
/// survey with items lands in `inventory_pending` (web-only approval, then
/// `installation_assigned` or `survey_review`); a not-feasible survey lands
/// in `survey_not_feasible`; a feasible survey with no items lands in
/// `survey_completed`. All three route to the survey detail, read-only —
/// the detail screen offers no action button when `allowed_actions` is
/// empty (D19).
abstract final class ConnectionStatus {
  ConnectionStatus._();

  static const String surveyAssigned = 'survey_assigned';
  static const String surveyReview = 'survey_review';
  static const String installationAssigned = 'installation_assigned';
  static const String splicingAssigned = 'splicing_assigned';
  static const String verificationAssigned = 'verification_assigned';
  static const String closingAssigned = 'closing_assigned';
  static const String inventoryPending = 'inventory_pending';
  static const String surveyNotFeasible = 'survey_not_feasible';
  static const String surveyCompleted = 'survey_completed';
}

/// Backend wire values for `olt_device_ownership` on complete-installation.
abstract final class OltOwnership {
  OltOwnership._();

  static const String user = 'user';
  static const String company = 'company';
}

/// Allowed MIME types the backend accepts for survey voice notes.
/// Any file whose reported MIME type is not in this set is rejected before upload.
const Set<String> allowedVoiceNoteMimeTypes = <String>{
  'audio/webm',
  'video/webm',
  'audio/mp4',
  'video/mp4',
  'audio/mpeg',
  'audio/ogg',
  'audio/wav',
  'audio/x-wav',
  'application/octet-stream',
};

/// Maximum voice note size the backend accepts (10 MB).
const int maxVoiceNoteBytes = 10 * 1024 * 1024;

/// MIME types the backend accepts for installation photos.
/// Any file whose reported type is not in this set is rejected before upload.
const Set<String> allowedInstallationPhotoMimeTypes = <String>{
  'image/jpeg',
  'image/png',
  'image/webp',
};

/// Maximum size a single installation photo may have (2 MB).
const int maxInstallationPhotoBytes = 2 * 1024 * 1024;

/// MIME types the backend accepts for ID card images on connection-request
/// creation (ISPFINAL §4). Images only — no PDF (Haider's call, 2026-11-23).
/// Any file whose reported type is not in this set is rejected before upload.
const Set<String> allowedIdCardMimeTypes = <String>{
  'image/jpeg',
  'image/png',
  'image/webp',
};

/// Maximum ID card image size the backend accepts (10 MB each).
const int maxIdCardBytes = 10 * 1024 * 1024;

/// Application-wide text used in multiple screens.
abstract final class AppStrings {
  AppStrings._();

  static const String appName = 'ISP OnlineCER';
  static const String unknownError = 'Something went wrong. Please try again.';
  static const String networkError = 'Network error. Check your connection.';
  static const String snackbarMicPermission =
      'Microphone permission is required to record a voice note.';
  static const String snackbarRecordFailed = 'Could not record voice note. Please try again.';

  // Pricing card.
  /// Placeholder for the connection charge until the backend exposes it on
  /// `GET /connection-requests/{id}` (see the module's contract note).
  static const String connectionChargePending = 'To be quoted';
  static const String connectionChargeNote =
      'The one-time connection charge is quoted by the office.';

  // Route map.
  static const String mapUseMyLocation = 'Use my location';
  static const String mapCaptureDpLocation = 'Capture DP Location';
  static const String mapRouteCalculating = 'Calculating route…';
  static const String mapNoLocationYet = 'No location captured yet.';
  static const String mapRouteUnavailable = 'Route unavailable right now.';
  static const String mapRouteStraightLine =
      'Route geometry unavailable — showing straight line between the points.';
  static const String snackbarLocationFailed =
      'Could not read the device location. Please try again.';
  /// Shown as a tooltip/caption on the disabled Navigate action so the greyed
  /// out control reads as "waiting on data" rather than broken.
  static const String navigateUnavailable =
      'Navigate is off until a location is captured.';
}
