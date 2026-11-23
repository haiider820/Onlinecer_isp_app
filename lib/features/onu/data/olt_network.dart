import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';

/// Minimal seam over the HTTP layer that [OltRepository] depends on, so the
/// OLT / waiting-ONU flows are unit-testable without a real server.
///
/// Mirrors [SubBranchNetwork]: the network returns the raw decoded envelope
/// and the repository parses it.
abstract interface class OltNetwork {
  /// `GET /lookups/direct-olts` (+ `?sub_branch_id=` when given).
  Future<Map<String, dynamic>> fetchDirectOlts({String? subBranchId});

  /// `POST /lookups/direct-olts/{olt}/discover-waiting-onus`
  /// (+ `?sub_branch_id=` when given). Live OLT contact; a 422 carries the
  /// backend's message and the previous cached rows stay valid.
  Future<Map<String, dynamic>> discoverWaitingOnus(
    String oltId, {
    String? subBranchId,
  });

  /// `GET /lookups/direct-olts/{olt}/waiting-onus`
  /// (+ `?sub_branch_id=` when given). Cached rows, no OLT contact.
  Future<Map<String, dynamic>> fetchWaitingOnus(
    String oltId, {
    String? subBranchId,
  });
}

/// Real HTTP-backed implementation (ISPFINAL §5–§7).
///
/// `sub_branch_id` is sent as a query parameter — the endpoint paths in
/// [Endpoints] carry no sub-branch segment, and the id always comes from
/// `subBranchStateProvider.effectiveId`, never invented client-side.
class DioOltNetwork implements OltNetwork {
  DioOltNetwork(this._client);

  final ApiClient _client;

  @override
  Future<Map<String, dynamic>> fetchDirectOlts({String? subBranchId}) {
    return _client.getMap(
      Endpoints.directOlts(subBranchId: subBranchId),
    );
  }

  @override
  Future<Map<String, dynamic>> discoverWaitingOnus(
    String oltId, {
    String? subBranchId,
  }) {
    return _client.postMap(
      Endpoints.discoverWaitingOnus(oltId),
      query: {
        if (subBranchId != null) 'sub_branch_id': subBranchId,
      },
    );
  }

  @override
  Future<Map<String, dynamic>> fetchWaitingOnus(
    String oltId, {
    String? subBranchId,
  }) {
    return _client.getMap(
      Endpoints.waitingOnus(oltId),
      query: {
        if (subBranchId != null) 'sub_branch_id': subBranchId,
      },
    );
  }
}
