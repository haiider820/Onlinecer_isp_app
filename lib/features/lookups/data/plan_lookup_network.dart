import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';

abstract interface class PlanLookupNetwork {
  Future<Map<String, dynamic>> fetchPlans();
}

class DioPlanLookupNetwork implements PlanLookupNetwork {
  DioPlanLookupNetwork(this._client);

  final ApiClient _client;

  @override
  Future<Map<String, dynamic>> fetchPlans() => _client.getMap(Endpoints.plans);
}
