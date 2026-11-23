import '../../../models/sub_branch.dart';
import 'sub_branch_network.dart';

/// Fetches the sub-branch list from `GET /lookups/sub-branches`
/// (ISPFINAL §2 + §12).
///
/// The returned [SubBranchList] carries the org's `mode` (`"centralized"` or
/// scoped) plus the rows. Callers must only ever submit IDs from this list —
/// sub-branch IDs are never invented client-side.
class SubBranchRepository {
  SubBranchRepository({required this.network});

  final SubBranchNetwork network;

  /// Fetches the list, optionally scoped to one known sub-branch id.
  ///
  /// Network failures propagate untouched as typed [ApiException]s from
  /// the network layer, so the UI can show the backend's message + retry.
  Future<SubBranchList> fetchSubBranches({String? subBranchId}) async {
    final map = await network.fetchSubBranches(subBranchId: subBranchId);
    return SubBranchList.fromJson(_unwrapEnvelope(map));
  }

  /// The envelope is `{mode, selected_sub_branch_id, data: [...]}` at the
  /// top level (see `test/models/sub_branch_test.dart`). Some Laravel
  /// resource responses nest the same envelope under a `data` key instead;
  /// unwrap that shape rather than failing the parse.
  static Map<String, dynamic> _unwrapEnvelope(Map<String, dynamic> map) {
    final nested = map['data'];
    if (nested is Map<String, dynamic> && !map.containsKey('mode')) {
      return nested;
    }
    return map;
  }
}
