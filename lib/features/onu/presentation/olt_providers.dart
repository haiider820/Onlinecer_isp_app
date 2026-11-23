import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exceptions.dart';
import '../../../models/direct_olt.dart';
import '../../../models/waiting_onu.dart';
import '../../auth/presentation/providers.dart';
import '../../lookups/presentation/sub_branch_providers.dart';
import '../data/olt_network.dart';
import '../data/olt_repository.dart';

/// Real HTTP-backed OLT network.
final oltNetworkProvider = Provider<OltNetwork>((ref) {
  return DioOltNetwork(ref.watch(apiClientProvider));
});

/// OLT repository wiring the network layer.
final oltRepositoryProvider = Provider<OltRepository>((ref) {
  return OltRepository(network: ref.watch(oltNetworkProvider));
});

/// Fetches the direct OLTs for a sub-branch (`GET /lookups/direct-olts`),
/// keyed by the sub-branch id (`null` = no scope resolved yet).
final directOltsProvider =
    FutureProvider.family<DirectOltList, String?>((ref, subBranchId) {
  return ref
      .watch(oltRepositoryProvider)
      .fetchDirectOlts(subBranchId: subBranchId);
});

/// Fetches the CACHED waiting ONUs for one OLT
/// (`GET /lookups/direct-olts/{olt}/waiting-onus`), keyed by OLT id.
///
/// The sub-branch scope is read from [subBranchStateProvider] at read time
/// (its `effectiveId` when `canProceed`, otherwise `null`): the provider
/// re-reads when the scope changes, but the family key stays the OLT id so
/// a discovery refresh invalidates exactly this list.
final waitingOnusProvider =
    FutureProvider.family<WaitingOnuList, String>((ref, oltId) {
  final scope = ref.watch(subBranchStateProvider);
  return ref.watch(oltRepositoryProvider).fetchWaitingOnus(
        oltId,
        subBranchId: scope.canProceed ? scope.effectiveId : null,
      );
});

/// Outcome of one "Refresh from OLT" discovery run.
class DiscoveryState {
  const DiscoveryState({
    this.isDiscovering = false,
    this.errorMessage,
    this.source,
    this.seenCount,
    this.discoveredAt,
  });

  /// True while the POST discovery is in flight.
  final bool isDiscovering;

  /// The backend's message when discovery failed (e.g. a 422), else `null`.
  final String? errorMessage;

  /// `source` from the discovery response (live vs cached), when known.
  final String? source;

  /// `seen_count` from the discovery response, when known.
  final int? seenCount;

  /// When the last successful discovery ran.
  final DateTime? discoveredAt;

  bool get hasError => errorMessage != null;
}

/// Drives `POST /lookups/direct-olts/{olt}/discover-waiting-onus`
/// (ISPFINAL §6), one controller per OLT id.
///
/// On success the cached list is invalidated (so the screen re-reads the
/// fresh rows) and the response's `source` + `seen_count` are kept for the
/// "last updated" label. On failure the cached list is deliberately NOT
/// invalidated — the backend preserves previous rows, so the screen keeps
/// showing them under the error + Retry.
class DiscoveryController extends FamilyNotifier<DiscoveryState, String> {
  String get _oltId => arg;

  @override
  DiscoveryState build(String oltId) => const DiscoveryState();

  Future<void> discover() async {
    if (state.isDiscovering) return;
    state = const DiscoveryState(isDiscovering: true);
    try {
      final scope = ref.read(subBranchStateProvider);
      final result =
          await ref.read(oltRepositoryProvider).discoverWaitingOnus(
                _oltId,
                subBranchId: scope.canProceed ? scope.effectiveId : null,
              );
      state = DiscoveryState(
        source: result.source,
        seenCount: result.seenCount,
        discoveredAt: DateTime.now(),
      );
      ref.invalidate(waitingOnusProvider(_oltId));
    } on ApiException catch (e) {
      state = DiscoveryState(errorMessage: e.message);
    } catch (e) {
      state = DiscoveryState(errorMessage: e.toString());
    }
  }

  void clearError() {
    state = const DiscoveryState();
  }
}

final discoveryControllerProvider =
    NotifierProvider.family<DiscoveryController, DiscoveryState, String>(
  DiscoveryController.new,
);
