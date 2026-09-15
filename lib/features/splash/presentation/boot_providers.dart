import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exceptions.dart';
import '../../../core/router/functional_team.dart';
import '../../../core/router/team_module.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/presentation/providers.dart';

/// The real work the boot screen performs, in order. Each stage maps to one
/// status row in the splash UI; nothing here is decorative — a stage only
/// reports "done" after the actual future it represents completed.
enum BootStage { session, verify, team, dashboard }

enum BootStepStatus { pending, running, done, skipped, failed }

enum BootOutcome { needsLogin, ready }

/// One boot step's live state for the splash row list.
class BootStep {
  const BootStep({
    required this.stage,
    this.status = BootStepStatus.pending,
    this.detail = '',
  });  final BootStage stage;
  final BootStepStatus status;

  /// Short honest detail for the pill/subtitle, e.g. the employee name that
  /// `GET /me` returned or "No saved session".
  final String detail;

  BootStep copyWith({BootStepStatus? status, String? detail}) => BootStep(
        stage: stage,
        status: status ?? this.status,
        detail: detail ?? this.detail,
      );
}

const _initialSteps = <BootStep>[
  BootStep(stage: BootStage.session),
  BootStep(stage: BootStage.verify),
  BootStep(stage: BootStage.team),
  BootStep(stage: BootStage.dashboard),
];

/// Immutable snapshot of the boot sequence the splash screen renders.
class BootState {
  const BootState({this.steps = _initialSteps, this.outcome, this.error});

  final List<BootStep> steps;
  final BootOutcome? outcome;

  /// Unexpected failure message; when set the splash offers a retry button.
  final String? error;

  /// 0–100 based on settled (done/skipped/failed) steps.
  int get progress {
    final settled = steps.where((s) => s.status != BootStepStatus.pending).length;
    return (settled * 100 / steps.length).round();
  }

  BootStep step(BootStage stage) =>
      steps.firstWhere((s) => s.stage == stage, orElse: () => BootStep(stage: stage));

  BootState copyWith({List<BootStep>? steps, BootOutcome? outcome, String? error}) => BootState(
        steps: steps ?? this.steps,
        outcome: outcome ?? this.outcome,
        error: error ?? this.error,
      );
}

/// Readiness gate between "a token exists somewhere" and "protected screens
/// may fire requests".
///
/// Cold start: reads the persisted session, drops expired tokens, then
/// verifies the token with a real `GET /me` (which also refreshes the stored
/// employee/team context) before declaring the app ready for the dashboard.
/// Post-login: the same sequence re-runs — the token was already
/// write-verified by [AuthRepository], and `/me` proves the interceptor can
/// attach it end-to-end before `GET /dashboard` fires.
///
/// Every step awaits the actual future it gates on; no delays, no timers.
class BootController extends StateNotifier<BootState> {
  BootController(this._ref) : super(const BootState());

  final Ref _ref;

  /// Guards against overlapping runs when the splash remounts (cold start →
  /// login → post-login boot). Only the newest run may publish state.
  int _generation = 0;

  Future<void> run() async {
    final generation = ++_generation;
    state = const BootState();

    final storage = _ref.read(secureStorageProvider);
    final repository = _ref.read(authRepositoryProvider);

    try {
      // ── Stage 1: read the persisted session ──
      _setStage(BootStage.session, BootStepStatus.running);
      final token = await storage.getToken();
      if (generation != _generation) return;

      if (token == null || token.isEmpty) {
        _finishWithoutSession(generation);
        return;
      }
      _setStage(BootStage.session, BootStepStatus.done, detail: 'Token found');

      if (await storage.hasExpiredToken()) {
        if (generation != _generation) return;
        await storage.clearSession();
        if (generation != _generation) return;
        _finishWithoutSession(generation, sessionDetail: 'Token expired');
        return;
      }

      // ── Stage 2: verify the token with a real GET /me ──
      // This is the honest readiness proof: the request goes through the same
      // ApiClient + AuthInterceptor the dashboard will use, so a token the
      // interceptor cannot attach fails here (on the splash) instead of on
      // the dashboard as a surprise 401.
      _setStage(BootStage.verify, BootStepStatus.running);
      String? employeeName;
      String? teamLabel;
      var verified = false;
      try {
        final employee = await repository.fetchMeAndRefreshSession();
        if (generation != _generation) return;
        employeeName = employee?.name;
        teamLabel = employee?.team?.name;
        verified = true;
        _setStage(BootStage.verify, BootStepStatus.done,
            detail: employeeName?.isNotEmpty == true ? employeeName! : 'Verified');
      } on ApiException catch (e) {
        if (generation != _generation) return;
        if (e.isUnauthorized) {
          // Token rejected by the server — it cannot ever be "ready".
          await storage.clearSession();
          if (generation != _generation) return;
          _finishWithoutSession(generation,
              sessionDetail: 'Token found',
              verifyDetail: 'Rejected',
              verifyStatus: BootStepStatus.failed);
          return;
        }
        // Network/other failure with a plausibly valid stored token: the
        // field app continues into the dashboard, whose screens own retry
        // states. The token itself was read back from storage, so requests
        // will still carry it.
        _setStage(BootStage.verify, BootStepStatus.skipped, detail: 'Offline — using saved session');
      }

      // ── Stage 3: resolve the team context the dashboard dispatches on ──
      _setStage(BootStage.team, BootStepStatus.running);
      final rawTeam = await storage.getFunctionalTeamType();
      if (generation != _generation) return;
      final team = FunctionalTeamType.fromWire(rawTeam);
      if (team != null) {
        teamLabel ??= TeamModule.forTeam(team).dashboardTitle;
        _setStage(BootStage.team, BootStepStatus.done, detail: teamLabel);
      } else {
        _setStage(BootStage.team, BootStepStatus.skipped, detail: 'No team assigned');
      }

      // ── Stage 4: dashboard module ready ──
      _setStage(BootStage.dashboard, BootStepStatus.done,
          detail: verified ? 'Ready' : 'Ready (offline)');

      state = state.copyWith(outcome: BootOutcome.ready);
    } catch (e) {
      if (generation != _generation) return;
      state = state.copyWith(
        error: e is ApiException ? e.message : 'Boot failed. Please try again.',
      );
    }
  }

  void _finishWithoutSession(
    int generation, {
    String? sessionDetail,
    String? verifyDetail,
    BootStepStatus verifyStatus = BootStepStatus.skipped,
  }) {
    if (generation != _generation) return;
    _setStage(BootStage.session, BootStepStatus.skipped, detail: sessionDetail ?? 'No saved session');
    _setStage(BootStage.verify, verifyStatus, detail: verifyDetail ?? 'Not signed in');
    _setStage(BootStage.team, BootStepStatus.skipped);
    _setStage(BootStage.dashboard, BootStepStatus.done, detail: 'Login required');
    state = state.copyWith(outcome: BootOutcome.needsLogin);
  }

  void _setStage(BootStage stage, BootStepStatus status, {String? detail}) {
    state = state.copyWith(
      steps: state.steps
          .map((s) => s.stage == stage ? s.copyWith(status: status, detail: detail) : s)
          .toList(growable: false),
    );
  }
}

final bootControllerProvider =
    StateNotifierProvider<BootController, BootState>(BootController.new);
