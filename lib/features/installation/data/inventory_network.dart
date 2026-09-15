import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';

/// Minimal seam over the HTTP layer for inventory lookups, so the completion
/// form flow is unit-testable without a real server.
abstract interface class InventoryNetwork {
  /// `GET /lookups/inventory-items` → `{ "data": [...] }`.
  Future<Map<String, dynamic>> fetchInventory();
}

/// Real HTTP-backed implementation calling the inventory lookup endpoint.
class DioInventoryNetwork implements InventoryNetwork {
  DioInventoryNetwork(this._client);

  final ApiClient _client;

  @override
  Future<Map<String, dynamic>> fetchInventory() {
    return _client.getMap(Endpoints.inventoryItems);
  }
}