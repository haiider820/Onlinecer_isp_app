import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isp_onlinecer/core/theme/app_theme.dart';
import 'package:isp_onlinecer/features/installation/presentation/installation_providers.dart';
import 'package:isp_onlinecer/features/installation/presentation/inventory_catalog_screen.dart';
import 'package:isp_onlinecer/models/inventory_item.dart';

const _items = InventoryItemList(data: [
  InventoryItem(
    id: 'i1',
    name: 'Fiber Cable',
    category: 'Cable',
    unit: 'm',
    stockQuantity: 120,
  ),
  InventoryItem(
    id: 'i2',
    name: 'SC Connector',
    category: 'Connector',
    unit: 'pcs',
    stockQuantity: 45,
  ),
  InventoryItem(id: 'i3', name: 'ONT Box', category: 'Device'),
]);

Future<void> _pumpCatalog(
  WidgetTester tester, {
  List<Override> extraOverrides = const [],
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        inventoryItemsProvider.overrideWith((ref) async => _items),
        ...extraOverrides,
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        home: const InventoryCatalogScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  // See dashboard_tiles_test.dart: google_fonts must not fetch at runtime.
  GoogleFonts.config.allowRuntimeFetching = false;

  testWidgets('catalog rows render name, category and stock (D25)', (
    tester,
  ) async {
    await _pumpCatalog(tester);

    expect(find.text('Inventory Items'), findsOneWidget);
    expect(find.text('Fiber Cable'), findsOneWidget);
    expect(find.text('SC Connector'), findsOneWidget);
    expect(find.text('ONT Box'), findsOneWidget);
    expect(find.text('Cable'), findsOneWidget);
    expect(find.text('Connector'), findsOneWidget);
    expect(find.text('120 m'), findsOneWidget);
    expect(find.text('45 pcs'), findsOneWidget);
    // No stock on record renders as an em dash, never a crash or a 0.
    expect(find.text('—'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty catalog shows the empty state (D25)', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          inventoryItemsProvider.overrideWith(
            (ref) async => const InventoryItemList(data: []),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const InventoryCatalogScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No inventory items.'), findsOneWidget);
    expect(find.text('Fiber Cable'), findsNothing);
  });

  testWidgets('failed catalog shows the error and a retry (D25)', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          inventoryItemsProvider.overrideWith(
            (ref) async => throw Exception('boom'),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const InventoryCatalogScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Could not load inventory items.'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
