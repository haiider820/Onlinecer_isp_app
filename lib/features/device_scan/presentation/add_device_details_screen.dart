import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exceptions.dart';
import '../../../core/theme/field_ops_colors.dart';
import '../../../core/theme/field_ops_design_tokens.dart';
import '../../../models/device_scan.dart';
import '../../../shared/widgets/branded_header.dart';
import '../../../shared/widgets/field_ops_card.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../installation/presentation/device_scan_screen.dart';
import 'scanner_providers.dart';

/// Add Details for one untracked device. Scan-only by product rule: no text
/// fields exist on this screen — serial/MAC arrive exclusively through the
/// Scan buttons (camera today, any string-returning scanner tomorrow via
/// [scanHandler], e.g. a Bluetooth scanner in tests).
///
/// Save semantics (workflow doc): enabled once ≥1 identifier is present;
/// the PUT carries ONLY changed fields (empty strings are never sent, so a
/// stored value can never be wiped); the row data travels in, never refetched.
class AddDeviceDetailsScreen extends ConsumerStatefulWidget {
  const AddDeviceDetailsScreen({
    super.key,
    required this.device,
    this.scanHandler,
  });

  /// The untracked row (route `extra`). `null` (deep link without extra) →
  /// explicit error view instead of a crash.
  final ScannedDevice? device;

  /// Test/hardware seam: resolves a scanned string for the field. Production
  /// passes nothing and gets the camera dialog.
  final Future<String?> Function(BuildContext context, {required bool mac})?
      scanHandler;

  @override
  ConsumerState<AddDeviceDetailsScreen> createState() =>
      _AddDeviceDetailsScreenState();
}

class _AddDeviceDetailsScreenState
    extends ConsumerState<AddDeviceDetailsScreen> {
  late String? _serial;
  late String? _mac;
  bool _sending = false;
  String? _fieldError;
  String? _duplicateCode;

  @override
  void initState() {
    super.initState();
    _serial = widget.device?.serialNumber?.trim();
    _mac = widget.device?.macAddress?.trim();
  }

  Future<void> _scan({required bool mac}) async {
    String? code;
    if (widget.scanHandler != null) {
      code = await widget.scanHandler!(context, mac: mac);
    } else {
      code = await showDialog<String>(
        context: context,
        builder: (_) => const DeviceScanDialog(),
      );
    }
    final scanned = code?.trim() ?? '';
    if (scanned.isEmpty || !mounted) return;
    setState(() {
      if (mac) {
        // Barcodes print the MAC bare (`E86E4424D818`); store the canonical
        // `AA:BB:CC:DD:EE:FF` form so display and the PUT both match the
        // API's documented format.
        _mac = normalizeMacAddress(scanned);
      } else {
        _serial = scanned;
      }
      _fieldError = null;
      _duplicateCode = null;
    });
  }

  /// One camera session for both identifiers (see [DeviceScanBothDialog]).
  /// Fills whichever slots came back non-empty; existing values are kept
  /// when a slot comes back empty. Under the test seam the handler resolves
  /// each kind in turn.
  Future<void> _scanBoth() async {
    String? serial;
    String? mac;
    if (widget.scanHandler != null) {
      serial = await widget.scanHandler!(context, mac: false);
      if (!mounted) return;
      mac = await widget.scanHandler!(context, mac: true);
    } else {
      final result = await showDialog<ScannedIdentifiers>(
        context: context,
        builder: (_) => const DeviceScanBothDialog(),
      );
      if (!mounted) return;
      serial = result?.serial;
      mac = result?.mac;
    }
    if (!mounted) return;
    final s = serial?.trim() ?? '';
    final m = mac?.trim() ?? '';
    if (s.isEmpty && m.isEmpty) return;
    setState(() {
      if (s.isNotEmpty) _serial = s;
      if (m.isNotEmpty) _mac = normalizeMacAddress(m);
      _fieldError = null;
      _duplicateCode = null;
    });
  }

  Future<void> _save() async {
    final device = widget.device;
    final id = device?.id;
    if (id == null || id.isEmpty) return;
    final body = changedDeviceFields(
      initialSerial: device?.serialNumber,
      initialMac: device?.macAddress,
      serial: _serial,
      mac: _mac,
    );
    if (body.isEmpty) {
      _snack('No changes to save.');
      return;
    }
    setState(() {
      _sending = true;
      _fieldError = null;
      _duplicateCode = null;
    });
    try {
      final result = await ref
          .read(scannerRepositoryProvider)
          .updateDevice(id, body);
      if (!mounted) return;
      _snack(result.message ?? 'Device details saved.');
      ref.invalidate(untrackedDevicesProvider);
      Navigator.of(context).maybePop();
    } on ApiException catch (e) {
      if (!mounted) return;
      // Stale row (tenant moved on / deleted meanwhile): drop it and
      // refresh rather than stranding the user on a dead form.
      if (e.statusCode == 403 || e.statusCode == 404) {
        _snack(e.message);
        ref.invalidate(untrackedDevicesProvider);
        Navigator.of(context).maybePop();
        return;
      }
      // Duplicate serial/MAC: the code exists on another device — inline
      // error plus a lookup-backed "show it" action (the errors map itself
      // is not exposed on ApiException, so the backend's exact duplicate
      // wording is matched narrowly here).
      final duplicateField = _duplicateField(e.message);
      if (e.statusCode == 422 && duplicateField != null) {
        setState(() {
          _fieldError = e.message;
          _duplicateCode = duplicateField == 'mac' ? _mac : _serial;
        });
      } else {
        _snack(e.message);
      }
    } catch (e) {
      if (mounted) _snack(e.toString());
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  /// Returns `'serial'`/`'mac'` when [message] is the backend's duplicate
  /// wording for that field, else `null`.
  static String? _duplicateField(String message) {
    if (!message.contains('already been taken')) return null;
    final lower = message.toLowerCase();
    if (lower.contains('mac')) return 'mac';
    if (lower.contains('serial')) return 'serial';
    return null;
  }

  Future<void> _showExisting() async {
    final code = _duplicateCode?.trim() ?? '';
    if (code.isEmpty) return;
    late LookupResult found;
    try {
      found = await ref.read(scannerRepositoryProvider).lookup(code);
    } on ApiException catch (e) {
      if (mounted) _snack(e.message);
      return;
    } catch (e) {
      if (mounted) _snack(e.toString());
      return;
    }
    if (!mounted) return;
    if (found.device == null) {
      // Globally unique but outside this tenant: visible nowhere, so say so
      // plainly instead of opening an empty screen.
      _snack(found.message ?? 'Already registered on another device.');
      return;
    }
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Existing device'),
        content: _ExistingDeviceCard(device: found.device!),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final device = widget.device;
    return Scaffold(
      appBar: BrandedHeader(
        title: 'Add Details',
        onBack: () => Navigator.of(context).maybePop(),
      ),
      body: device == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 12),
                    const Text(
                      'Open this screen from the untracked list.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      child: const Text('Back'),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                SectionCard(
                  title: 'Device',
                  icon: Icons.memory_outlined,
                  children: [
                    Text(
                      device.item?.name ?? '—',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    if ((device.status ?? '').isNotEmpty) ...[
                      const SizedBox(height: 8),
                      StatusBadge(status: device.status!),
                    ],
                  ],
                ),
                // One camera session captures BOTH identifiers: each label
                // is classified on the spot (MAC vs D-SN serial), so the
                // technician points once instead of scanning twice.
                SizedBox(
                  height: 52,
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _scanBoth,
                    icon: const Icon(Icons.qr_code_scanner, size: 20),
                    label: const Text('Scan serial + MAC'),
                  ),
                ),
                const SizedBox(height: 8),
                _IdentifierBlock(
                  label: 'Serial number',
                  value: _serial,
                  buttonLabel: 'Scan Serial',
                  icon: Icons.qr_code_scanner,
                  onScan: () => _scan(mac: false),
                ),                _IdentifierBlock(
                  label: 'MAC address',
                  value: _mac,
                  buttonLabel: 'Scan MAC',
                  icon: Icons.qr_code_scanner,
                  onScan: () => _scan(mac: true),
                ),
                if (_fieldError != null) ...[
                  Text(
                    _fieldError!,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.error),
                  ),
                  if (_duplicateCode != null) ...[
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _showExisting,
                      icon: const Icon(Icons.search, size: 18),
                      label: const Text('Show existing device'),
                    ),
                  ],
                  const SizedBox(height: 8),
                ],
                SizedBox(
                  height: 52,
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: (_sending ||
                            !hasIdentifier(_serial, _mac))
                        ? null
                        : _save,
                    icon: _sending
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).colorScheme.onSecondary,
                            ),
                          )
                        : const Icon(Icons.check_circle_outline, size: 20),
                    label: Text(_sending ? 'Saving…' : 'Save Details'),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}

/// One identifier: current value (or amber Missing) plus its scan button.
/// No text entry exists anywhere here by product rule — values arrive only
/// through [_AddDeviceDetailsScreenState._scan].
class _IdentifierBlock extends StatelessWidget {
  const _IdentifierBlock({
    required this.label,
    required this.value,
    required this.buttonLabel,
    required this.icon,
    required this.onScan,
  });

  final String label;
  final String? value;
  final String buttonLabel;
  final IconData icon;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final missing = value == null || value!.trim().isEmpty;
    return FieldOpsCard(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              label,
              style: FieldOpsDesignTokens.labelSm.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              missing ? 'Missing' : value!.trim(),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontFamily: FieldOpsDesignTokens.monoFamily,
                color: missing
                    ? context.fieldOpsColors.pendingFg
                    : theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onScan,
              icon: Icon(icon, size: 18),
              label: Text(buttonLabel),
            ),
          ],
        ),
      ),
    );
  }
}

/// Read-only card for the device a duplicate code belongs to.
class _ExistingDeviceCard extends StatelessWidget {
  const _ExistingDeviceCard({required this.device});

  final ScannedDevice device;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          device.item?.name ?? 'Device',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        InfoRow(label: 'Serial', value: device.serialNumber),
        InfoRow(label: 'MAC', value: device.macAddress),
        if ((device.status ?? '').isNotEmpty)
          InfoRow(label: 'Status', value: device.status?.replaceAll('_', ' ')),
        if (device.warehouse?.name != null)
          InfoRow(label: 'Warehouse', value: device.warehouse?.name),
      ],
    );
  }
}
