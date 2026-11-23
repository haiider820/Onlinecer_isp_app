import 'package:dio/dio.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';

/// Minimal seam over the HTTP layer that [CreateRequestRepository] depends
/// on, so the create-request flow is unit-testable without a real server.
///
/// Mirrors [SubBranchNetwork] (`sub_branch_network.dart`): the network
/// returns the raw decoded envelope and the repository parses it.
abstract interface class CreateRequestNetwork {
  /// `GET /connection-requests/create-data` (+ `?sub_branch_id=` when given).
  Future<Map<String, dynamic>> fetchCreateData({String? subBranchId});

  /// `POST /connection-requests` as `multipart/form-data` (ISPFINAL §4).
  /// The backend answers 201 with the created request.
  Future<Map<String, dynamic>> createConnectionRequest(FormData form);
}

/// Real HTTP-backed implementation for the create-request flow.
class DioCreateRequestNetwork implements CreateRequestNetwork {
  DioCreateRequestNetwork(this._client);

  final ApiClient _client;

  @override
  Future<Map<String, dynamic>> fetchCreateData({String? subBranchId}) {
    return _client.getMap(Endpoints.createData(subBranchId: subBranchId));
  }

  @override
  Future<Map<String, dynamic>> createConnectionRequest(FormData form) {
    return _client.postMultipart(
      Endpoints.createConnectionRequest(),
      data: form,
    );
  }
}
