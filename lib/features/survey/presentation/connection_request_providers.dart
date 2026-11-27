import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/connection_request.dart';
import '../../auth/presentation/providers.dart';
import '../../closing/presentation/closing_providers.dart';
import '../../dashboard/presentation/dashboard_tiles_providers.dart';
import '../../installation/presentation/installation_providers.dart';
import '../../splicing/presentation/splicing_providers.dart';
import '../../verification/presentation/verification_providers.dart';
import '../data/connection_request_network.dart';
import '../data/connection_request_repository.dart';
import 'dashboard_providers.dart';

/// Real HTTP-backed connection-request network.
final connectionRequestNetworkProvider = Provider<ConnectionRequestNetwork>((ref) {
  return DioConnectionRequestNetwork(ref.watch(apiClientProvider));
});

/// Connection-request repository wiring the network layer.
final connectionRequestRepositoryProvider = Provider<ConnectionRequestRepository>((ref) {
  return ConnectionRequestRepository(network: ref.watch(connectionRequestNetworkProvider));
});

/// Fetches one page of connection requests, `page` is 1-based.
///
/// The list screen watches the page it needs and accumulates results locally.
final connectionRequestsProvider =
    FutureProvider.family<ConnectionRequestPage, int>((ref, page) {
  return ref.watch(connectionRequestRepositoryProvider).fetchPage(page: page);
});

/// Fetches the full detail for one request, keyed by request id.
final connectionRequestDetailProvider =
    FutureProvider.family<ConnectionRequestDetail, String>((ref, id) {
  return ref.watch(connectionRequestRepositoryProvider).fetchDetail(id);
});

/// Refetches one request's detail after a stage transition (ISPFINAL §11).
///
/// Every stage controller calls this on a successful transition so the next
/// detail read re-derives its buttons from fresh `allowed_actions` — never
/// from the pre-transition payload. Invalidation only marks the provider
/// stale; the refetch itself happens when a watcher reads it again.
void refreshConnectionRequestDetail(Ref ref, String id) {
  ref.invalidate(connectionRequestDetailProvider(id));
}

/// D24: refresh EVERYTHING that can show this request after a stage submit
/// — the shared detail, every team's list (all pages), every stage detail
/// provider, and the dashboard — so the new stage/status appears with NO
/// manual refresh.
///
/// ROOT CAUSE (Haider, 2026-11-27): after a submit the app only invalidated
/// the shared detail provider (survey/installation/splicing) or the detail
/// + one list page (verification/closing). The list screens keep their rows
/// in local state (`PaginatedRequestListScreen._requests`, loaded once in
/// `initState` from `pageProvider(1)`), and the list providers are plain
/// `FutureProvider.family` — NOT autoDispose — so a fresh list mount reads
/// the CACHED page and the request still shows its OLD stage until the user
/// pulls to refresh. The dashboard's pending-authorization tile reads the
/// same cached installation page, so it went stale too.
///
/// The fix is one call, from every stage's submit success path (see the
/// callers): invalidating a family with no argument invalidates ALL its
/// pages, so every list remount refetches from the server and the request
/// leaves its old queue / appears in its new one on its own.
///
/// NOTE on imports: this file is imported by the stage providers it
/// invalidates (they call [refreshConnectionRequestDetail]), so these
/// imports are circular at the library level. That is legal Dart — every
/// provider here is a lazily-initialised top-level, nothing runs at import
/// time — and `flutter analyze` stays clean.
///
/// NOTE on the signature: the helper takes `ref.invalidate` as a tear-off
/// instead of the ref itself, because the call sites hold two different
/// ref types that share no common interface — `Ref` in the stage
/// controllers, `WidgetRef` in the completion form — while both expose an
/// identical `invalidate(ProviderOrFamily)` method.
void refreshAfterStageSubmit(
  void Function(ProviderOrFamily provider) invalidate,
  String id,
) {
  // The request itself, however it is read next.
  invalidate(connectionRequestDetailProvider(id));
  invalidate(splicingDetailProvider(id));
  invalidate(verificationDetailProvider(id));
  invalidate(closingDetailProvider(id));
  // Every team's queue, every loaded page — the list screens re-read page 1
  // from the server on their next mount instead of serving the cached page.
  invalidate(connectionRequestsProvider);
  invalidate(installationRequestsProvider);
  invalidate(splicingRequestsProvider);
  invalidate(verificationRequestsProvider);
  invalidate(closingRequestsProvider);
  // The dashboard: its summary and every tile count (the authorization tile
  // reads the installation queue, so it goes stale with the list).
  invalidate(dashboardSummaryProvider);
  invalidate(dashboardTeamFlowCountProvider);
  invalidate(dashboardOpenTicketCountProvider);
  invalidate(dashboardInventoryCountProvider);
  invalidate(dashboardWaitingOnuCountProvider);
  invalidate(dashboardPendingAuthorizationProvider);
}