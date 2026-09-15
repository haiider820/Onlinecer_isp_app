import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';

abstract interface class TeamStageDetailNetwork {
  Future<Map<String, dynamic>> fetchDetail(String requestId);
}

class DioTeamStageDetailNetwork implements TeamStageDetailNetwork {
  DioTeamStageDetailNetwork(this._client);
  final ApiClient _client;

  @override
  Future<Map<String, dynamic>> fetchDetail(String requestId) =>
      _client.getMap(Endpoints.connectionRequestDetail(requestId));
}
