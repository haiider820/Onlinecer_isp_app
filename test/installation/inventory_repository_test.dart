import 'package:flutter_test/flutter_test.dart';
import 'package:isp_onlinecer/features/installation/data/inventory_network.dart';
import 'package:isp_onlinecer/features/installation/data/inventory_repository.dart';

class _FakeInventoryNetwork implements InventoryNetwork {
  _FakeInventoryNetwork(this.result, {this.error});

  final Map<String, dynamic> result;
  final Exception? error;

  @override
  Future<Map<String, dynamic>> fetchInventory() async {
    if (error != null) throw error!;
    return result;
  }
}

void main() {
  group('InventoryRepository.fetch', () {
    test('parses the {data:[...]} envelope into an InventoryItemList', () async {
      final network = _FakeInventoryNetwork({
        'data': [
          {'id': 'item_1', 'name': 'Cat6 Cable', 'unit': 'meter'},
          {'id': 'item_2', 'name': 'Fiber Pigtail'}, // unit absent
        ],
      });

      final repository = InventoryRepository(network: network);
      final items = await repository.fetch();

      expect(items.data, hasLength(2));
      expect(items.data.first.id, 'item_1');
      expect(items.data.first.name, 'Cat6 Cable');
      expect(items.data.first.unit, 'meter');
      expect(items.data.last.unit, isNull);
    });

    test('parses an empty data array', () async {
      final network = _FakeInventoryNetwork({'data': []});

      final repository = InventoryRepository(network: network);
      final items = await repository.fetch();

      expect(items.data, isEmpty);
    });

    test('propagates network failures to the caller', () async {
      final network = _FakeInventoryNetwork(
        const {},
        error: Exception('server unreachable'),
      );

      final repository = InventoryRepository(network: network);

      expect(repository.fetch(), throwsException);
    });
  });
}