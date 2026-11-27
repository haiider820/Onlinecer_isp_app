import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/connection_request.dart';
import '../../connection_requests/presentation/create_request_providers.dart';
import '../../installation/presentation/installation_providers.dart';
import '../../lookups/presentation/sub_branch_providers.dart';
import '../../onu/presentation/olt_providers.dart';
import '../../survey/presentation/connection_request_providers.dart';
import '../../tickets/presentation/ticket_providers.dart';

/// Dashboard tile counts (D20).
///
/// Each tile reads its own endpoint through the existing providers — no new
/// endpoints, no invented data. A failed fetch surfaces as an error on the
/// tile's [AsyncValue] and the tile renders `0`; a tile never crashes the
/// dashboard or blocks the other tiles.
///
/// Import-cycle note (D25, same legal-Dart rationale as the D24 note in
/// `connection_request_providers.dart`): this file is imported by
/// `connection_request_providers.dart`, which it now also imports (for
/// [connectionRequestsProvider]). The imports are circular at library
/// level; every provider here is a lazily-initialised top-level, nothing
/// runs at import time, and `flutter analyze` stays clean.

/// "Connection Flow" tile: `team_flows.length` from
/// `GET /connection-requests/create-data`, scoped by the resolved
/// sub-branch (same scope the create form uses). A scope with no flow
/// configured returns `team_flows: []` — the tile shows 0, never an error.
///
/// D25: NO TILE watches this any more — the Connection Flow tile counts
/// requests now ([dashboardAllRequestsCountProvider]). Kept: six test
/// harnesses override it defensively when they mount the dashboard, and
/// the create form still reads `team_flows` through `createDataProvider`
/// directly. Delete it together with those overrides in a later cleanup,
/// not in this batch.
final dashboardTeamFlowCountProvider = FutureProvider.autoDispose<int>((
  ref,
) async {
  final scope = ref.watch(subBranchStateProvider);
  final createData = await ref.watch(
    createDataProvider(scope.canProceed ? scope.effectiveId : null).future,
  );
  return createData.data?.teamFlows?.length ?? 0;
});

/// "Connection Flow" tile (D25): TOTAL of all connection requests visible
/// to the user across ALL stages — page 1 of the unfiltered queue
/// (`GET /connection-requests` with no status filter, via
/// [connectionRequestsProvider]), the same provider the tile's target
/// screen ([AllRequestsScreen] at [Routes.allRequests]) reads. The count
/// is the server `meta.total`, so the number on the tile and the rows on
/// the screen can never disagree the way the D20/D23 tile did (2 flows
/// counted, a stage-scoped list opened).
final dashboardAllRequestsCountProvider = FutureProvider.autoDispose<int>((
  ref,
) async {
  final page = await ref.watch(connectionRequestsProvider(1).future);
  return page.meta.total ?? page.data.length;
});

/// "My Tickets" tile: open tickets from `GET /tickets`, page 1 filtered to
/// status `OPEN`; the count is the server `meta.total`.
///
/// NOTE on the definition of "open": there is no backend "open" aggregate
/// on `GET /tickets`, so this counts exactly the app's own ticket-filter
/// vocabulary — status `OPEN` only. `IN_PROGRESS` and `WAITING_CUSTOMER`
/// tickets are NOT included. If the backend later adds an open-aggregate,
/// switch this tile to it.
final dashboardOpenTicketCountProvider = FutureProvider.autoDispose<int>((
  ref,
) async {
  final page = await ref.watch(
    ticketPageProvider((
      query: const TicketQuery(status: 'OPEN'),
      page: 1,
    )).future,
  );
  return page.meta.total ?? page.data.length;
});

/// "Inventory Items" tile: `GET /lookups/inventory-items` row count.
final dashboardInventoryCountProvider = FutureProvider.autoDispose<int>((
  ref,
) async {
  final list = await ref.watch(inventoryItemsProvider.future);
  return list.data.length;
});

/// "Waiting ONUs" tile: cached waiting ONUs summed across every direct OLT
/// of the resolved sub-branch (`GET /lookups/direct-olts`, then
/// `GET /lookups/direct-olts/{olt}/waiting-onus` per OLT).
///
/// One OLT's list failing must not kill the whole count — that OLT
/// contributes 0. A failure of the OLT list itself surfaces as an error
/// and the tile shows 0.
final dashboardWaitingOnuCountProvider = FutureProvider.autoDispose<int>((
  ref,
) async {
  final scope = ref.watch(subBranchStateProvider);
  final olts = await ref.watch(
    directOltsProvider(scope.canProceed ? scope.effectiveId : null).future,
  );
  var total = 0;
  for (final olt in olts.data) {
    try {
      final waiting = await ref.watch(waitingOnusProvider(olt.id).future);
      total += waiting.data.length;
    } catch (_) {
      // One OLT's list failing must not blank the whole tile.
    }
  }
  return total;
});

/// "ONU Authorization" tile: requests awaiting ONU authorization.
///
/// DERIVED, not a backend count: there is NO endpoint for pending
/// authorization jobs, so this is page 1 of the installation-assigned
/// queue (`GET /connection-requests?status=installation_assigned`, via
/// [installationRequestsProvider]) and the count is its server
/// `meta.total` — every `installation_assigned` request is one whose
/// detail offers Authorize ONU.
///
/// The page is also the tile's navigation source: the first row is the
/// request whose (stage-aware) detail the tile opens, so the tile never
/// needs a request id from anywhere else.
final dashboardPendingAuthorizationProvider =
    FutureProvider.autoDispose<ConnectionRequestPage>((ref) {
      return ref.watch(installationRequestsProvider(1).future);
    });
