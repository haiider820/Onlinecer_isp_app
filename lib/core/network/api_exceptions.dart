/// Typed exceptions thrown by the API layer.
///
/// The UI layer converts these into snackbars/dialogs via [ApiErrorMapper]
/// so every screen shows consistent, API-specific messages instead of a
/// generic "something went wrong".
library;

class ApiException implements Exception {
  const ApiException({required this.message, this.statusCode});

  /// Human-readable message safe to show to the user.
  final String message;

  /// HTTP status code when the error originated from a server response,
  /// otherwise `null` (network/parse errors).
  final int? statusCode;

  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Thrown when the request could not reach the server
/// (offline, DNS, connection refused).
class NetworkException extends ApiException {
  const NetworkException({super.message = 'Network error. Check your connection.'});
}

/// Thrown when a successful HTTP response could not be parsed into a model.
class ServerFromException extends ApiException {
  const ServerFromException({super.message = 'Unexpected response from server.'});
}

/// Thrown when the API returns `message: "The provided credentials are incorrect."`
class InvalidCredentialsException extends ApiException {
  const InvalidCredentialsException({super.message = 'The provided credentials are incorrect.'});
}

/// Thrown when the API returns `message: "This employee account is inactive."`
class InactiveAccountException extends ApiException {
  const InactiveAccountException({super.message = 'This employee account is inactive.'});
}

/// Thrown when the request is not assigned to the employee's team queue.
class NotAssignedToQueueException extends ApiException {
  const NotAssignedToQueueException({
    super.message = 'This connection request is not assigned to your queue.',
  });
}

/// Thrown when the team cannot complete the current stage.
class TeamCannotCompleteStageException extends ApiException {
  const TeamCannotCompleteStageException({
    super.message = 'Your team cannot complete this stage.',
  });
}

/// Thrown when the request is not in the right status for this stage.
class StageNotReadyException extends ApiException {
  const StageNotReadyException({
    super.message = 'This connection request is not ready for this stage.',
  });
}

/// Thrown when a stage action belongs to another employee/team.
class NotAuthorizedForActionException extends ApiException {
  const NotAuthorizedForActionException({
    super.message = 'You are not authorized to perform this action.',
  });
}

/// Thrown when the session token could not be read back from secure storage
/// after login. Login must NOT be treated as successful (and must not
/// navigate anywhere) until the token is confirmed persisted, otherwise the
/// first authorized request would fire without a bearer token and 401.
class SessionPersistenceException extends ApiException {
  const SessionPersistenceException({
    super.message = 'Could not save your session securely. Please try signing in again.',
  });
}

/// Thrown when a ticket action is attempted by someone other than its assignee.
class TicketNotAssignedException extends ApiException {
  const TicketNotAssignedException({
    super.message = "This ticket isn't assigned to you.",
  });
}

/// Thrown when a stale ticket detail tries to advance a closed ticket.
class TicketAtFinalStageException extends ApiException {
  const TicketAtFinalStageException({
    super.message = 'This ticket is already at the final stage.',
  });
}

// Installation-stage message mappings. The exact backend strings for the
// complete-installation endpoint are NOT yet confirmed (they live in the
// external API checklist); the constants below are our best-guess wording.
// Match the real response strings against these once the backend checklist
// is available — the mapping only fires on an exact text match.
//
// Because that wording can't be relied on for the documented device
// MAC/serial-mismatch 422, [ApiErrorMapper] additionally classifies a 422
// whose `errors` object is keyed by `installed_device_mac` /
// `installed_device_serial`, or whose message carries explicit
// mismatch/assignment wording, into [DeviceMismatchException] /
// [DeviceNotAvailableException]. A bare mention of "mac"/"serial" is NOT
// enough: the scanner portal's duplicate ("already been taken") and
// format-validation 422s name those identifiers too, and masking them as
// "device mismatch" hides the real cause (and breaks Add Details' inline
// duplicate handling).
//
// TODO(contract): confirm these three strings against the backend API.

/// Thrown when the installation was already completed (duplicate submit).
class InstallationAlreadyCompletedException extends ApiException {
  const InstallationAlreadyCompletedException({
    super.message = 'This installation has already been completed.',
  });
}

/// Thrown when the selected FAT node does not belong to the connection request.
class InvalidInstallationFatNodeException extends ApiException {
  const InvalidInstallationFatNodeException({
    super.message = 'The selected FAT node is not valid for this connection request.',
  });
}

/// Thrown when the submitted total wire usage is not a non-negative number.
class InvalidTotalWireUsedException extends ApiException {
  const InvalidTotalWireUsedException({
    super.message = 'Total wire used must be a number greater than or equal to zero.',
  });
}

/// Thrown when the scanned ONU/ONT MAC/serial does not match the company
/// device assigned during inventory approval (complete-installation 422).
class DeviceMismatchException extends ApiException {
  const DeviceMismatchException({
    super.message =
        'The scanned device does not match the device assigned to this request.',
    super.statusCode,
  });
}

/// Thrown when the scanned device is not registered in inventory, belongs to
/// another organization, or is already assigned to another customer/request.
class DeviceNotAvailableException extends ApiException {
  const DeviceNotAvailableException({
    super.message =
        'This device is not available: it is unregistered, belongs to another organization, or is already assigned.',
    super.statusCode,
  });
}

/// Maps the backend's human-readable `message` strings to typed exceptions so
/// the UI can branch on them (e.g. show a warning vs. navigate away).
abstract final class ApiErrorMapper {
  ApiErrorMapper._();

  static final Map<String, ApiException> _messageToException = <String, ApiException>{
    invalidCredentialsMessage: const InvalidCredentialsException(),
    inactiveAccountMessage: const InactiveAccountException(),
    notAssignedMessage: const NotAssignedToQueueException(),
    cannotCompleteMessage: const TeamCannotCompleteStageException(),
    notReadyMessage: const StageNotReadyException(),
    notAuthorizedForActionMessage: const NotAuthorizedForActionException(),
    ticketForbiddenMessage: const TicketNotAssignedException(),
    ticketFinalStageMessage: const TicketAtFinalStageException(),
    installationAlreadyCompletedMessage: const InstallationAlreadyCompletedException(),
    invalidInstallationFatNodeMessage: const InvalidInstallationFatNodeException(),
    invalidTotalWireUsedMessage: const InvalidTotalWireUsedException(),
    deviceMismatchMessage: const DeviceMismatchException(),
    deviceNotAvailableMessage: const DeviceNotAvailableException(),
  };

  static const String invalidCredentialsMessage = 'The provided credentials are incorrect.';
  static const String inactiveAccountMessage = 'This employee account is inactive.';
  static const String notAssignedMessage = 'This connection request is not assigned to your queue.';
  static const String cannotCompleteMessage = 'Your team cannot complete this stage.';
  static const String notReadyMessage = 'This connection request is not ready for this stage.';
  static const String notAuthorizedForActionMessage =
      'You are not authorized to perform this action.';
  static const String ticketForbiddenMessage = 'Forbidden.';
  static const String ticketFinalStageMessage =
      'This ticket is already at the final stage.';
  static const String installationAlreadyCompletedMessage =
      'This installation has already been completed.';
  static const String invalidInstallationFatNodeMessage =
      'The selected FAT node is not valid for this connection request.';
  static const String invalidTotalWireUsedMessage =
      'Total wire used must be a number greater than or equal to zero.';
  // Best-guess wordings for the device-validation 422s (see the TODO note
  // above): the scanner MAC/serial can mismatch the assigned company device,
  // or the scanned device can be unregistered/foreign/already-assigned.
  static const String deviceMismatchMessage =
      'The scanned device does not match the device assigned to this request.';
  static const String deviceNotAvailableMessage =
      'This device is not available: it is unregistered, belongs to another organization, or is already assigned.';

  /// Returns a typed exception when [serverMessage] matches a known backend
  /// message, otherwise a generic [ApiException] carrying the original text.
  static ApiException fromMessage(String serverMessage, {int? statusCode}) {
    final known = _messageToException[serverMessage];
    if (known != null) {
      return ApiException(message: known.message, statusCode: statusCode);
    }
    return ApiException(message: serverMessage, statusCode: statusCode);
  }

  /// Field names the complete-installation endpoint validates against the
  /// physical device assigned during inventory approval.
  static const Set<String> _deviceFieldNames = <String>{
    'installed_device_mac',
    'installed_device_serial',
  };

  /// Phrases where the backend itself states a mismatch/assignment problem
  /// (`does not match`, `must match`, `assigned to this request`, …). Free
  /// text only classifies with wording like this — never on the strength of
  /// an identifier alone (see the note at the top of this file).
  static final RegExp _deviceMismatchPattern = RegExp(
    r"does\s+not\s+match|doesn'?t\s+match|must\s+match|"
    r'match(?:es)?\s+(?:the|this)|mismatch|'
    r'assigned\s+to\s+(?:this|another|your|a\s+different)',
    caseSensitive: false,
  );

  /// Phrases meaning the scanned device exists but cannot be used on this
  /// request (unregistered / foreign / already assigned to someone else).
  static final RegExp _deviceUnavailablePattern = RegExp(
    r'unregistered|not registered|already\s+(?:been\s+|be\s+)?assigned|'
    r'not available|belongs to another|'
    r'another (?:organization|customer|connection request|request)',
    caseSensitive: false,
  );

  /// Classifies a device-validation `422`.
  ///
  /// Returns [DeviceMismatchException] when the scanned MAC/serial does not
  /// match the company device assigned during inventory approval, or
  /// [DeviceNotAvailableException] when the device itself cannot be used
  /// (unregistered / foreign / already assigned) — the two device-validation
  /// 422s documented for the complete-installation endpoint. `null` means
  /// "not device-related; keep the normal message mapping".
  ///
  /// Accepts both Laravel response shapes: a top-level `message` with
  /// explicit mismatch/unavailability wording, and a validation dump whose
  /// `errors` object is keyed by the device fields (the common "The given
  /// data was invalid." case, where the top-level message alone would
  /// surface a generic dump).
  static ApiException? _deviceIssue422({
    required int? statusCode,
    required String? serverMessage,
    required Map<String, dynamic>? errorFields,
  }) {
    if (statusCode != 422) return null;
    final message = serverMessage ?? '';
    final keyedByDeviceField =
        errorFields?.keys.any(_deviceFieldNames.contains) ?? false;
    final deviceWording = keyedByDeviceField ||
        _deviceMismatchPattern.hasMatch(message) ||
        _deviceUnavailablePattern.hasMatch(message);
    if (!deviceWording) return null;
    if (_deviceUnavailablePattern.hasMatch(message)) {
      return DeviceNotAvailableException(statusCode: statusCode);
    }
    return DeviceMismatchException(statusCode: statusCode);
  }

  /// Maps raw error parts to a typed [ApiException].
  /// Callers (the ApiClient) unwrap dio's exception first and pass the
  /// server `message`, status code, and whether it was a network failure.
  ///
  /// [errorFields] is the response's Laravel `errors` object (field name ->
  /// messages) when present; it lets a field-level device MAC/serial mismatch
  /// map to [DeviceMismatchException] instead of the generic top-level
  /// validation message.
  static ApiException surfacing({
    required String? serverMessage,
    required int? statusCode,
    required bool isNetworkError,
    Map<String, dynamic>? errorFields,
  }) {
    if (isNetworkError) {
      return const NetworkException();
    }
    if (serverMessage != null && serverMessage.isNotEmpty) {
      final known = _messageToException[serverMessage];
      if (known != null) {
        return ApiException(message: known.message, statusCode: statusCode);
      }
    }
    // Runs after the exact-text map so confirmed wordings still win, but
    // before the raw fallback so the device-mismatch 422 never shows a dump.
    final deviceIssue = _deviceIssue422(
      statusCode: statusCode,
      serverMessage: serverMessage,
      errorFields: errorFields,
    );
    if (deviceIssue != null) return deviceIssue;
    if (serverMessage != null && serverMessage.isNotEmpty) {
      return ApiException(message: serverMessage, statusCode: statusCode);
    }
    return ApiException(message: 'Something went wrong. Please try again.', statusCode: statusCode);
  }
}
