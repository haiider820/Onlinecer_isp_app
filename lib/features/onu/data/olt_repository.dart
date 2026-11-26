import '../../../models/direct_olt.dart';
import '../../../models/olt_profiles.dart';
import '../../../models/waiting_onu.dart';
import 'olt_network.dart';

/// Fetches direct OLTs and their waiting ONUs (ISPFINAL §5–§7).
///
/// Network failures propagate untouched as typed [ApiException]s from the
/// network layer, so the UI can show the backend's message + retry — and, on
/// a failed discovery, keep showing the previous cached list (the backend
/// preserves previous rows; the app never blanks the screen).
class OltRepository {
  OltRepository({required this.network});

  final OltNetwork network;

  /// `GET /lookups/direct-olts` (+ `?sub_branch_id=` when given).
  Future<DirectOltList> fetchDirectOlts({String? subBranchId}) async {
    final map = await network.fetchDirectOlts(subBranchId: subBranchId);
    return DirectOltList.fromJson(_unwrapEnvelope(map));
  }

  /// `POST /lookups/direct-olts/{olt}/discover-waiting-onus`.
  ///
  /// Returns the discovery envelope (`message`, `source`, `seen_count`,
  /// `data`). A 422 throws with the backend's message; callers keep the
  /// cached list in that case.
  Future<DiscoverWaitingOnusResponse> discoverWaitingOnus(
    String oltId, {
    String? subBranchId,
  }) async {
    final map = await network.discoverWaitingOnus(
      oltId,
      subBranchId: subBranchId,
    );
    return DiscoverWaitingOnusResponse.fromJson(map);
  }

  /// `GET /lookups/direct-olts/{olt}/waiting-onus` (cached rows).
  Future<WaitingOnuList> fetchWaitingOnus(
    String oltId, {
    String? subBranchId,
  }) async {
    final map = await network.fetchWaitingOnus(
      oltId,
      subBranchId: subBranchId,
    );
    return WaitingOnuList.fromJson(_unwrapEnvelope(map));
  }

  /// `GET /lookups/direct-olts/{olt}/profiles` (guide §15): line/service
  /// profiles + VLANs for the authorize form. The response is flat (no
  /// `data` envelope); [OltProfiles.fromJson] unwraps defensively anyway.
  Future<OltProfiles> fetchProfiles(
    String oltId, {
    String? subBranchId,
  }) async {
    final map = await network.fetchProfiles(
      oltId,
      subBranchId: subBranchId,
    );
    return OltProfiles.fromJson(map);
  }

  /// Some Laravel resource responses nest the envelope under a `data` key
  /// instead of returning it flat; unwrap that shape rather than failing
  /// the parse. Only unwraps when the nested map actually holds the list.
  static Map<String, dynamic> _unwrapEnvelope(Map<String, dynamic> map) {
    final nested = map['data'];
    if (nested is Map<String, dynamic> && nested['data'] is List) {
      return nested;
    }
    return map;
  }
}
