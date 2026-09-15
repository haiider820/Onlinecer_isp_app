import '../../../models/inventory_item.dart';
import 'inventory_network.dart';

/// Fetches the catalog of inventory items available to an installation team.
///
/// Failures surface as typed [ApiException]s (see `api_exceptions.dart`),
/// consistent with the rest of the app.
class InventoryRepository {
  InventoryRepository({required this.network});

  final InventoryNetwork network;

  Future<InventoryItemList> fetch() async {
    final map = await network.fetchInventory();
    return InventoryItemList.fromJson(map);
  }
}