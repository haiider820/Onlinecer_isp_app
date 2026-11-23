import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';

/// Minimal seam over the HTTP layer that [AuthorizeOnuRepository] depends
/// on, so the authorize + job-poll flows are unit-testable without a real
/// server.
abstract interface class AuthorizeOnuNetwork {
  /// `POST /connection-requests/{request}/authorize-onu` (expect 201).
  Future<Map<String, dynamic>> authorizeOnu(
    String requestId,
    Map<String, Object?> body,
  );

  /// `GET /connection-requests/{request}/authorization-jobs/{job}`.
  Future<Map<String, dynamic>> fetchAuthorizationJob(
    String requestId,
    String jobId,
  );
}

/// Real HTTP-backed implementation (ISPFINAL §9–§10).
class DioAuthorizeOnuNetwork implements AuthorizeOnuNetwork {
  DioAuthorizeOnuNetwork(this._client);

  final ApiClient _client;

  @override
  Future<Map<String, dynamic>> authorizeOnu(
    String requestId,
    Map<String, Object?> body,
  ) {
    return _client.postMap(Endpoints.authorizeOnu(requestId), data: body);
  }

  @override
  Future<Map<String, dynamic>> fetchAuthorizationJob(
    String requestId,
    String jobId,
  ) {
    return _client.getMap(Endpoints.authorizationJob(requestId, jobId));
  }
}
