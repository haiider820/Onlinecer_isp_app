import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';

/// Minimal seam over the HTTP layer that [SubBranchRepository] depends on,
/// so the sub-branch lookup is unit-testable without a real server.
///
/// Mirrors [PlanLookupNetwork] (`plan_lookup_network.dart`): the network
/// returns the raw decoded envelope and the repository parses it.
abstract interface class SubBranchNetwork {
  /// `GET /lookups/sub-branches` (+ `?sub_branch_id=` when given).
  Future<Map<String, dynamic>> fetchSubBranches({String? subBranchId});
}

/// Real HTTP-backed implementation calling `GET /lookups/sub-branches`.
///
/// Network failures surface as typed [ApiException]s via [ApiClient]
/// (see `api_exceptions.dart`) — the repository does not re-wrap them.
class DioSubBranchNetwork implements SubBranchNetwork {
  DioSubBranchNetwork(this._client);

  final ApiClient _client;

  @override
  Future<Map<String, dynamic>> fetchSubBranches({String? subBranchId}) {
    return _client.getMap(Endpoints.subBranches(subBranchId: subBranchId));
  }
}
