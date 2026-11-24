import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exceptions.dart';
import '../../../models/sub_branch.dart';
import '../../auth/presentation/providers.dart';
import '../data/sub_branch_network.dart';
import '../data/sub_branch_repository.dart';

/// Real HTTP-backed sub-branch network.
final subBranchNetworkProvider = Provider<SubBranchNetwork>((ref) {
  return DioSubBranchNetwork(ref.watch(apiClientProvider));
});

/// Sub-branch repository wiring the network layer.
final subBranchRepositoryProvider = Provider<SubBranchRepository>((ref) {
  return SubBranchRepository(network: ref.watch(subBranchNetworkProvider));
});

/// Fetches the sub-branch list from `GET /lookups/sub-branches`
/// (ISPFINAL §2 + §12). Invalidated on logout via
/// [invalidateSubBranchState] and on manual retry via
/// [SubBranchController.refresh].
final subBranchListProvider = FutureProvider<SubBranchList>((ref) {
  return ref.watch(subBranchRepositoryProvider).fetchSubBranches();
});

/// The logged-in employee's own sub-branch id, as stored at login and
/// refreshed by the boot `GET /me` (see `AuthRepository`): the id from
/// `employee.sub_branch` in the session payload. `null` when the session
/// carries no sub-branch (or no session is stored).
///
/// Read by [SubBranchController] so the create-request gate can pre-select
/// the employee's own sub-branch — the auto-default. The value is only
/// ever used when it matches one of the rows `GET /lookups/sub-branches`
/// returned (see [effectiveSubBranchId]); it is never submitted on its
/// own. Invalidated with the rest of the sub-branch scope on logout /
/// session clear (D5), so a stale id can never leak into the next login.
final employeeSubBranchIdProvider = FutureProvider<String?>((ref) async {
  return ref.watch(secureStorageProvider).getSubBranchId();
});

/// The selected sub-branch id for this session.
///
/// IN-MEMORY ONLY — deliberately NOT secure storage: scope is a per-session
/// choice, re-fetched on boot. Only IDs returned by the endpoint may be
/// stored here (enforced by [SubBranchController.select]).
///
/// The selection drops itself when the employee session is cleared (D5):
/// the notifier subscribes to [SecureStorage]'s session-cleared
/// notification, so the central 401 path — which only calls
/// `storage.clearSession()` and can never touch a Riverpod provider
/// directly — drops the scope exactly like the manual dashboard logout
/// does, instead of letting it survive into the next employee's session.
/// Scanner clears never notify, so a scanner logout cannot drop the
/// employee scope. The cached list is invalidated alongside the selection
/// so the next session fetches fresh scope data.
class SelectedSubBranchNotifier extends Notifier<String?> {
  @override
  String? build() {
    final storage = ref.watch(secureStorageProvider);
    void onSessionCleared() {
      state = null;
      ref.invalidate(subBranchListProvider);
      ref.invalidate(employeeSubBranchIdProvider);
    }

    storage.addSessionClearedListener(onSessionCleared);
    ref.onDispose(() => storage.removeSessionClearedListener(onSessionCleared));
    return null;
  }
}

final selectedSubBranchProvider =
    NotifierProvider<SelectedSubBranchNotifier, String?>(SelectedSubBranchNotifier.new);

/// Resolves the sub-branch id a caller should submit, from endpoint data
/// only — never invents an id.
///
/// Order: an explicit selection (if it is one of the returned rows), then
/// the backend's own `selected_sub_branch_id` (when it is one of the rows),
/// then the logged-in employee's own sub-branch ([employeeSubBranchId],
/// from the session payload — when it is one of the rows), then — scoped
/// mode only, with exactly one row — that row, silently. Centralized mode
/// with several rows and no pick (and no employee sub-branch in the list)
/// returns `null`: the caller must show the selector first. An id that is
/// not in [list] (a stale selection from a previous login) is ignored,
/// never submitted.
String? effectiveSubBranchId(
  SubBranchList list,
  String? selected, {
  String? employeeSubBranchId,
}) {
  if (selected != null && list.data.any((branch) => branch.id == selected)) {
    return selected;
  }
  final backendSelected = list.selectedSubBranchId;
  if (backendSelected != null &&
      list.data.any((branch) => branch.id == backendSelected)) {
    return backendSelected;
  }
  if (employeeSubBranchId != null &&
      list.data.any((branch) => branch.id == employeeSubBranchId)) {
    return employeeSubBranchId;
  }
  if (!list.isCentralized && list.data.length == 1) {
    return list.data.first.id;
  }
  return null;
}

/// Snapshot of the sub-branch scope for the create-data / OLT callers
/// (Phase C/E/F) and the selector sheet.
///
/// The last-known list is kept across a failed refetch so the UI can show
/// stale data labelled as stale (APP_BRIEF rule 7) instead of blanking —
/// but [canProceed] stays `false` until a FRESH list arrives, so a create
/// can never go out against a stale scope.
class SubBranchState {
  const SubBranchState({
    this.lastKnownList,
    this.lastUpdated,
    this.errorMessage,
    this.isLoading = true,
    this.selectedId,
    this.employeeSubBranchId,
  });

  /// Last successfully fetched list, or `null` if none ever arrived.
  final SubBranchList? lastKnownList;

  /// When [lastKnownList] was fetched. `null` when nothing was fetched.
  final DateTime? lastUpdated;

  /// The fetch error message when the latest fetch failed, else `null`.
  final String? errorMessage;

  /// True while the first (or a retry) fetch is in flight.
  final bool isLoading;

  /// The explicit in-memory selection, if any.
  final String? selectedId;

  /// The logged-in employee's own sub-branch id (from the session), if
  /// any. The auto-default: used by [effectiveId] when no explicit pick
  /// and no backend pre-selection resolve, and only when it is one of the
  /// returned rows.
  final String? employeeSubBranchId;

  /// True when [lastKnownList] came from a successful fetch and no fetch
  /// is currently in flight or failed.
  bool get hasFreshList =>
      lastKnownList != null && errorMessage == null && !isLoading;

  /// True when a previous list is on screen but the latest fetch failed —
  /// the data is shown labelled stale, never trusted for a create.
  bool get isStale => lastKnownList != null && errorMessage != null;

  /// The id a caller should submit, or `null` when no id is resolved yet.
  String? get effectiveId => lastKnownList == null
      ? null
      : effectiveSubBranchId(
          lastKnownList!,
          selectedId,
          employeeSubBranchId: employeeSubBranchId,
        );

  /// The create gate. True ONLY when a fresh list is in hand AND an id is
  /// resolved. False while loading, on any fetch error (stale list or
  /// not), on an empty list, and in centralized mode until the user picks
  /// or their own sub-branch (from the session) resolves as the default.
  /// Callers must show a clear "couldn't load sub-branches" message when
  /// this is `false` because of an error — never a silent default.
  bool get canProceed => hasFreshList && effectiveId != null;
}

/// Tracks the sub-branch scope: keeps the last-known list + fetch time
/// across failures and exposes the create gate ([SubBranchState.canProceed]).
class SubBranchController extends Notifier<SubBranchState> {
  SubBranchList? _lastList;
  DateTime? _lastFetchedAt;

  @override
  SubBranchState build() {
    final selected = ref.watch(selectedSubBranchProvider);
    final listAsync = ref.watch(subBranchListProvider);
    // The employee's own sub-branch (session) — the auto-default. Read
    // leniently: while it is still loading (or the read fails) there is
    // simply no default yet, and the list fetch proceeds on its own.
    final employeeSubBranchId =
        ref.watch(employeeSubBranchIdProvider).valueOrNull;

    // Stamp the fetch time only when a NEW fresh list arrives, so a
    // selection change (which rebuilds this controller) does not re-label
    // old data as fresh.
    if (listAsync case AsyncData(:final value)) {
      if (!identical(value, _lastList)) {
        _lastList = value;
        _lastFetchedAt = DateTime.now();
      }
    }

    return listAsync.when(
      data: (list) => SubBranchState(
        lastKnownList: list,
        lastUpdated: _lastFetchedAt,
        isLoading: false,
        selectedId: selected,
        employeeSubBranchId: employeeSubBranchId,
      ),
      loading: () => SubBranchState(
        lastKnownList: listAsync.valueOrNull,
        lastUpdated: _lastFetchedAt,
        isLoading: true,
        selectedId: selected,
        employeeSubBranchId: employeeSubBranchId,
      ),
      error: (error, _) => SubBranchState(
        lastKnownList: listAsync.valueOrNull,
        lastUpdated: _lastFetchedAt,
        isLoading: false,
        errorMessage: error is ApiException
            ? error.message
            : 'Something went wrong. Please try again.',
        selectedId: selected,
        employeeSubBranchId: employeeSubBranchId,
      ),
    );
  }

  /// Stores a selection — only if [id] is one of the rows the endpoint
  /// returned. Any other id is ignored, never submitted.
  void select(String id) {
    final list = state.lastKnownList;
    if (list == null || !list.data.any((branch) => branch.id == id)) return;
    ref.read(selectedSubBranchProvider.notifier).state = id;
  }

  /// Clears the in-memory selection (e.g. when the scope must be re-picked).
  void clearSelection() {
    ref.read(selectedSubBranchProvider.notifier).state = null;
  }

  /// Re-fetches the list (the selector sheet's Retry button).
  void refresh() => ref.invalidate(subBranchListProvider);
}

final subBranchStateProvider =
    NotifierProvider<SubBranchController, SubBranchState>(
      SubBranchController.new,
    );

/// Clears the per-session sub-branch scope on logout.
///
/// Call this from the manual logout path — one line, next to `clearSession()`
/// in `team_dashboard_screen.dart` `_logout`:
/// ```dart
/// invalidateSubBranchState(ref);
/// ```
/// The central 401 path needs no call site: [SelectedSubBranchNotifier]
/// subscribes to the session-cleared notification and drops the selection
/// (plus the cached list) whenever `clearSession()` runs, so an automatic
/// logout drops the scope exactly like a manual one.
void invalidateSubBranchState(WidgetRef ref) {
  ref.invalidate(subBranchListProvider);
  ref.invalidate(selectedSubBranchProvider);
  ref.invalidate(employeeSubBranchIdProvider);
  ref.invalidate(subBranchStateProvider);
}
