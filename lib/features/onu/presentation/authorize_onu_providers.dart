import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exceptions.dart';
import '../../../models/authorization_job.dart';
import '../../auth/presentation/providers.dart';
import '../../survey/presentation/connection_request_providers.dart';
import '../data/authorize_onu_network.dart';
import '../data/authorize_onu_repository.dart';
import 'olt_providers.dart';

/// Real HTTP-backed authorize-ONU network.
final authorizeOnuNetworkProvider = Provider<AuthorizeOnuNetwork>((ref) {
  return DioAuthorizeOnuNetwork(ref.watch(apiClientProvider));
});

/// Authorize-ONU repository wiring the network layer.
final authorizeOnuRepositoryProvider = Provider<AuthorizeOnuRepository>((ref) {
  return AuthorizeOnuRepository(network: ref.watch(authorizeOnuNetworkProvider));
});

/// Where the authorize flow sits in its state machine.
enum AuthorizePhase {
  /// Form only; nothing sent yet.
  idle,

  /// The 201 POST is in flight.
  submitting,

  /// 201 received; the job is being polled every few seconds.
  polling,

  /// Job reached `succeeded`.
  succeeded,

  /// Job reached `failed` (backend `error_message` shown).
  failed,

  /// Still pending/running after the max screen wait — the server job may
  /// still finish; the screen offers a manual refresh.
  timedOut,

  /// The technician stopped waiting; the server job is NOT cancelled and
  /// polling can resume from the kept job id.
  cancelled,
}

/// Immutable authorize + poll state exposed to the authorize screen.
class AuthorizeOnuState {
  const AuthorizeOnuState({
    this.phase = AuthorizePhase.idle,
    this.requestId,
    this.oltId,
    this.jobId,
    this.message,
    this.job,
    this.errorMessage,
    this.pollErrorMessage,
    this.pollCount = 0,
  });

  final AuthorizePhase phase;
  final String? requestId;
  final String? oltId;

  /// The job id from the 201 — kept on screen through offline gaps and
  /// after cancel-wait, so polling can always resume without a re-POST.
  final String? jobId;

  /// The backend's 201 message, e.g. "ONU authorization queued".
  final String? message;

  /// Latest polled job snapshot.
  final AuthorizationJob? job;

  /// Terminal failure message (job `error_message`) or submit failure.
  final String? errorMessage;

  /// Last transient poll failure (e.g. offline mid-poll). The job id stays
  /// on screen and polling continues; this is never a re-POST trigger.
  final String? pollErrorMessage;

  /// How many polls have run (elapsed-time display + tests).
  final int pollCount;

  /// True while a job is being submitted or polled. The Authorize button
  /// is disabled while this is true and [AuthorizeOnuController] refuses a
  /// second POST — the backend is idempotent, but a double-tap must still
  /// be impossible client-side (guide §14).
  bool get isJobActive =>
      phase == AuthorizePhase.submitting || phase == AuthorizePhase.polling;

  bool get hasError => errorMessage != null;

  AuthorizeOnuState copyWith({
    AuthorizePhase? phase,
    String? requestId,
    String? oltId,
    String? jobId,
    String? message,
    AuthorizationJob? job,
    String? errorMessage,
    String? pollErrorMessage,
    int? pollCount,
  }) {
    return AuthorizeOnuState(
      phase: phase ?? this.phase,
      requestId: requestId ?? this.requestId,
      oltId: oltId ?? this.oltId,
      jobId: jobId ?? this.jobId,
      message: message ?? this.message,
      job: job ?? this.job,
      errorMessage: errorMessage,
      pollErrorMessage: pollErrorMessage,
      pollCount: pollCount ?? this.pollCount,
    );
  }
}

/// Drives `POST /connection-requests/{request}/authorize-onu` + the
/// `GET .../authorization-jobs/{job}` poll loop (ISPFINAL §9–§10).
///
/// Polling uses a [Timer.periodic] inside this controller, cancelled on
/// dispose, on a terminal status, on timeout, and on cancel-wait. The poll
/// interval is 3 s (guide: every 2–3 s) and the max screen wait is ~5 min,
/// after which polling stops with "Still running — check again later" and a
/// manual refresh. Both are settable fields so tests can shorten them.
class AuthorizeOnuController extends Notifier<AuthorizeOnuState> {
  /// How often the job endpoint is polled.
  Duration pollInterval = const Duration(seconds: 3);

  /// Max time the screen waits for a terminal status before timing out.
  Duration maxWait = const Duration(minutes: 5);

  Timer? _timer;

  /// Ticks of the poll timer since polling (re)started. The max-wait cap is
  /// derived from this count, not from the wall clock, so a device clock
  /// jump (or a fake clock in tests) can never stretch or shrink the wait.
  int _pollTicks = 0;
  bool _pollInFlight = false;

  @override
  AuthorizeOnuState build() {
    ref.onDispose(_stopTimer);
    return const AuthorizeOnuState();
  }

  /// Shape 1 — discovered ONU (guide §9).
  Future<AuthorizeOnuResult?> submitDiscovered({
    required String requestId,
    required String oltId,
    required String onuId,
    required String description,
  }) {
    return _submit(
      requestId: requestId,
      oltId: oltId,
      call: () => ref.read(authorizeOnuRepositoryProvider).authorizeDiscovered(
            requestId: requestId,
            directOltId: oltId,
            onuId: onuId,
            description: description,
          ),
    );
  }

  /// Shape 2 — serial fallback (guide §9). `lineProfile` /
  /// `serviceProfile` may be omitted only when the OLT preset is ready;
  /// `gemport` defaults to 1 inside the repository.
  Future<AuthorizeOnuResult?> submitBySerial({
    required String requestId,
    required String oltId,
    required String serialNumber,
    String? lineProfile,
    String? serviceProfile,
    int? vlan,
    int? userVlan,
    int? gemport,
    required String description,
  }) {
    return _submit(
      requestId: requestId,
      oltId: oltId,
      call: () => ref.read(authorizeOnuRepositoryProvider).authorizeBySerial(
            requestId: requestId,
            directOltId: oltId,
            serialNumber: serialNumber,
            lineProfile: lineProfile,
            serviceProfile: serviceProfile,
            vlan: vlan,
            userVlan: userVlan,
            gemport: gemport,
            description: description,
          ),
    );
  }

  Future<AuthorizeOnuResult?> _submit({
    required String requestId,
    required String oltId,
    required Future<AuthorizeOnuResult> Function() call,
  }) async {
    // Guide §14: never re-POST while a job is pending/running.
    if (state.isJobActive) return null;
    state = AuthorizeOnuState(
      phase: AuthorizePhase.submitting,
      requestId: requestId,
      oltId: oltId,
    );
    try {
      final result = await call();
      if (result.jobId == null) {
        // A 201 with no job id cannot be polled. If the embedded job is
        // already terminal-succeeded, honour it; otherwise surface the
        // backend message instead of guessing an id.
        if (result.job?.isTerminal == true &&
            result.job!.parsedStatus == AuthorizationJobStatus.succeeded) {
          state = AuthorizeOnuState(
            phase: AuthorizePhase.succeeded,
            requestId: requestId,
            oltId: oltId,
            message: result.message,
            job: result.job,
          );
          _refreshAfterSuccess(requestId, oltId);
          return result;
        }
        state = AuthorizeOnuState(
          phase: AuthorizePhase.failed,
          requestId: requestId,
          oltId: oltId,
          message: result.message,
          errorMessage: result.message ??
              'The server did not return an authorization job id.',
        );
        return result;
      }
      state = AuthorizeOnuState(
        phase: AuthorizePhase.polling,
        requestId: requestId,
        oltId: oltId,
        jobId: result.jobId,
        message: result.message ?? 'ONU authorization queued',
        job: result.job,
      );
      _startPolling();
      return result;
    } on ApiException catch (e) {
      state = AuthorizeOnuState(
        phase: AuthorizePhase.idle,
        requestId: requestId,
        oltId: oltId,
        errorMessage: e.message,
      );
      return null;
    } catch (e) {
      state = AuthorizeOnuState(
        phase: AuthorizePhase.idle,
        requestId: requestId,
        oltId: oltId,
        errorMessage: e.toString(),
      );
      return null;
    }
  }

  void _startPolling() {
    _stopTimer();
    _pollTicks = 0;
    _timer = Timer.periodic(pollInterval, (_) {
      _pollTicks++;
      unawaited(_poll());
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  /// One poll tick. Public so tests can drive terminal transitions without
  /// waiting on the timer; the timer path calls the same method.
  Future<void> pollOnce() => _poll();

  Future<void> _poll() async {
    final jobId = state.jobId;
    final requestId = state.requestId;
    if (jobId == null || requestId == null) return;
    if (state.phase != AuthorizePhase.polling) return;
    if (_pollInFlight) return;
    // Max-wait cap, from tick count (see _pollTicks): once the elapsed
    // polling time reaches maxWait, stop with a manual-refresh message.
    // The server job may still finish; nothing is cancelled.
    if (pollInterval * _pollTicks >= maxWait) {
      _stopTimer();
      state = state.copyWith(
        phase: AuthorizePhase.timedOut,
        errorMessage: 'Still running — check again later',
      );
      return;
    }
    _pollInFlight = true;
    try {
      final job = await ref
          .read(authorizeOnuRepositoryProvider)
          .fetchJob(requestId, jobId);
      if (state.phase != AuthorizePhase.polling) return;
      state = state.copyWith(
        job: job,
        pollCount: state.pollCount + 1,
        pollErrorMessage: null,
      );
      if (!job.isTerminal) return;
      _stopTimer();
      if (job.parsedStatus == AuthorizationJobStatus.succeeded) {
        state = state.copyWith(phase: AuthorizePhase.succeeded);
        _refreshAfterSuccess(requestId, state.oltId);
      } else {
        state = state.copyWith(
          phase: AuthorizePhase.failed,
          errorMessage: job.errorMessage ?? 'Authorization failed.',
        );
      }
    } on ApiException catch (e) {
      // Offline mid-poll: keep the job id on screen and keep polling
      // (the max-wait cap still applies). Never re-POST.
      if (state.phase == AuthorizePhase.polling) {
        state = state.copyWith(
          pollErrorMessage: e.message,
          pollCount: state.pollCount + 1,
        );
      }
    } catch (e) {
      if (state.phase == AuthorizePhase.polling) {
        state = state.copyWith(
          pollErrorMessage: e.toString(),
          pollCount: state.pollCount + 1,
        );
      }
    } finally {
      _pollInFlight = false;
    }
  }

  /// Stops waiting on screen. Does NOT cancel the server job — polling can
  /// resume from the kept job id via [resumePolling].
  void cancelWait() {
    if (!state.isJobActive) return;
    _stopTimer();
    state = state.copyWith(phase: AuthorizePhase.cancelled);
  }

  /// Resumes polling a kept job (after cancel-wait, a timeout, or an
  /// offline gap). Never re-POSTs.
  void resumePolling() {
    final jobId = state.jobId;
    final requestId = state.requestId;
    if (jobId == null || requestId == null) return;
    if (state.phase != AuthorizePhase.cancelled &&
        state.phase != AuthorizePhase.timedOut) {
      return;
    }
    state = state.copyWith(
      phase: AuthorizePhase.polling,
      errorMessage: null,
      pollErrorMessage: null,
    );
    _startPolling();
  }

  /// Clears a terminal failure back to the form so the technician can fix
  /// the inputs and authorize again. The form fields live in the screen
  /// and are untouched.
  void resetForRetry() {
    _stopTimer();
    state = AuthorizeOnuState(
      requestId: state.requestId,
      oltId: state.oltId,
    );
  }

  void _refreshAfterSuccess(String requestId, String? oltId) {
    if (oltId != null) ref.invalidate(waitingOnusProvider(oltId));
    refreshConnectionRequestDetail(ref, requestId);
  }
}

final authorizeOnuControllerProvider =
    NotifierProvider<AuthorizeOnuController, AuthorizeOnuState>(
  AuthorizeOnuController.new,
);
