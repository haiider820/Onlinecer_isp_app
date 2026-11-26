import 'package:flutter/material.dart';

import 'section_card.dart';

/// Read-only PPPoE credentials card (guide §6, Rev 1.0).
///
/// Returns nothing when [credentials] is null. The password is shown only
/// when `password_visible` is true — otherwise it is masked, and it is
/// never logged. Display-only: nothing here is ever sent back to the server.
class PppoeCredentialsCard extends StatelessWidget {
  const PppoeCredentialsCard({super.key, required this.credentials});

  final Map<String, dynamic>? credentials;

  @override
  Widget build(BuildContext context) {
    final creds = credentials;
    if (creds == null) return const SizedBox.shrink();
    final available = creds['available'];
    final username = creds['username']?.toString();
    final password = creds['password']?.toString();
    final visible = creds['password_visible'] == true;
    return SectionCard(
      title: 'PPPoE Credentials',
      icon: Icons.key_outlined,
      children: [
        if (available == false)
          const Text('Credentials not generated yet.'),
        if (available != false) ...[
          if (username != null && username.isNotEmpty)
            InfoRow(label: 'Username', value: username),
          if (password != null && password.isNotEmpty)
            InfoRow(
              label: 'Password',
              value: visible ? password : '••••••••',
            ),
          if ((username == null || username.isEmpty) &&
              (password == null || password.isEmpty))
            const Text('No credentials returned.'),
        ],
      ],
    );
  }
}

/// Read-only inventory approval state card (guide §6, Rev 1.0).
///
/// Shows the web inventory decision (`request_status`, `can_request`) and
/// the warehouse / item counts. Inventory approval itself is web-only —
/// this card never offers an action and never calls the server. The
/// `request_endpoint` URL is deliberately not rendered: it is a web action,
/// not something the app performs.
class InstallationInventoryCard extends StatelessWidget {
  const InstallationInventoryCard({super.key, required this.inventory});

  final Map<String, dynamic>? inventory;

  @override
  Widget build(BuildContext context) {
    final inv = inventory;
    if (inv == null) return const SizedBox.shrink();
    final rows = <Widget>[];
    final requestStatus = inv['request_status']?.toString();
    if (requestStatus != null && requestStatus.isNotEmpty) {
      rows.add(InfoRow(
        label: 'Request status',
        value: requestStatus.replaceAll('_', ' '),
      ));
    }
    final canRequest = inv['can_request'];
    if (canRequest is bool) {
      rows.add(InfoRow(
        label: 'Can request',
        value: canRequest ? 'Yes' : 'No',
      ));
    }
    final warehouse = inv['warehouse'];
    final warehouseName = warehouse is Map
        ? warehouse['name']?.toString()
        : warehouse?.toString();
    if (warehouseName != null && warehouseName.isNotEmpty) {
      rows.add(InfoRow(label: 'Warehouse', value: warehouseName));
    }
    final assigned = inv['assigned_items'];
    if (assigned is List) {
      rows.add(InfoRow(label: 'Assigned items', value: '${assigned.length}'));
    }
    final availableItems = inv['available_items'];
    if (availableItems is List) {
      rows.add(
        InfoRow(label: 'Available items', value: '${availableItems.length}'),
      );
    }
    if (rows.isEmpty) return const SizedBox.shrink();
    return SectionCard(
      title: 'Inventory',
      icon: Icons.inventory_2_outlined,
      children: rows,
    );
  }
}
