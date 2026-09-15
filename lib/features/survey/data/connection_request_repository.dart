import '../../../models/connection_request.dart';
import 'connection_request_network.dart';

/// Fetches paginated connection-request lists from `GET /connection-requests`.
///
/// Each call returns exactly one page. The screen accumulates pages locally.
class ConnectionRequestRepository {
  ConnectionRequestRepository({required this.network});

  final ConnectionRequestNetwork network;

  /// `page` is 1-based. [status] optionally narrows the queue server-side.
  Future<ConnectionRequestPage> fetchPage({required int page, String? status}) async {
    final map = await network.fetchPage(page: page, status: status);
    return ConnectionRequestPage.fromJson(map);
  }

  /// Full detail for one request, including its `allowed_action`.
  Future<ConnectionRequestDetail> fetchDetail(String id) async {
    final map = await network.fetchDetail(id);
    return ConnectionRequestDetail.fromJson(map);
  }
}
