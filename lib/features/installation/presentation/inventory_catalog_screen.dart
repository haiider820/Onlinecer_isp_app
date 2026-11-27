import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exceptions.dart';
import '../../../models/inventory_item.dart';
import '../../../shared/widgets/section_card.dart';
import 'installation_providers.dart';

/// Inventory catalog (D25).
///
/// The Inventory Items tile's target: the rows of
/// `GET /lookups/inventory-items` ([inventoryItemsProvider]) — name,
/// category, stock quantity + unit per row. No invented fields: every
/// value shown is a field of [InventoryItem]. Before D25 the tile opened
/// the team's request list because no catalog screen existed (D20 gap).
class InventoryCatalogScreen extends ConsumerWidget {
  const InventoryCatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(inventoryItemsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory Items')),
      body: items.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(
          message: e is ApiException
              ? e.message
              : 'Could not load inventory items.',
          onRetry: () => ref.invalidate(inventoryItemsProvider),
        ),
        data: (list) => list.data.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    'No inventory items.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                        ),
                  ),
                ),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  for (final item in list.data) _InventoryRow(item: item),
                ],
              ),
      ),
    );
  }
}

class _InventoryRow extends StatelessWidget {
  const _InventoryRow({required this.item});

  final InventoryItem item;

  static String _stockText(InventoryItem item) {
    final quantity = item.stockQuantity;
    if (quantity == null) return '—';
    final unit = item.unit;
    return unit == null || unit.isEmpty ? '$quantity' : '$quantity $unit';
  }

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: item.name,
      icon: Icons.layers_outlined,
      children: [
        if (item.category != null && item.category!.isNotEmpty)
          InfoRow(label: 'Category', value: item.category!),
        InfoRow(label: 'Stock', value: _stockText(item)),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
