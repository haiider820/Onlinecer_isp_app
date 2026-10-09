import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Full-screen camera scanner used from the complete-installation form to
/// capture the ONU/ONT device MAC off its barcode/QR label. Returns the raw
/// scanned string to the opener via `Navigator.pop`; the opener normalizes it.
///
/// Manual entry remains the fallback: the dialog can be dismissed with the
/// close button and the MAC typed by hand into the form field.
class DeviceScanDialog extends StatefulWidget {
  const DeviceScanDialog({super.key});

  @override
  State<DeviceScanDialog> createState() => _DeviceScanDialogState();
}

class _DeviceScanDialogState extends State<DeviceScanDialog> {
  final MobileScannerController _controller = MobileScannerController(
    // MAC labels are usually printed as Code128/QR; auto-detect all formats.
    formats: const <BarcodeFormat>[],
  );

  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue;
      if (value == null || value.trim().isEmpty) continue;
      _handled = true;
      Navigator.of(context).pop(value.trim());
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog.fullscreen(
      backgroundColor: Colors.black,
      child: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error) => _ScanErrorView(error: error),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: IconButton(
                  tooltip: 'Cancel scan',
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ),
          // Scan-frame hint + instruction.
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Container(
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.zero,
                ),
                child: Text(
                  'Point the camera at the MAC/QR label on the ONU/ONT device.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanErrorView extends StatelessWidget {  const _ScanErrorView({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.no_photography_outlined, color: Colors.white70, size: 48),
            const SizedBox(height: 16),
            Text(
              'Camera unavailable.\nType the MAC address manually instead.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Serial + MAC captured in ONE camera session.
class ScannedIdentifiers {
  const ScannedIdentifiers({this.serial, this.mac});

  final String? serial;
  final String? mac;

  bool get hasAny =>
      (serial?.trim().isNotEmpty ?? false) ||
      (mac?.trim().isNotEmpty ?? false);
}

/// True for MAC labels: `E8-6E-44-24-D8-18`, the colon form, or a bare
/// 12-hex run. Checked BEFORE [isSerialNumber]: a bare 12-hex run is a MAC,
/// not a serial. Input is uppercased by callers; the regexes accept both.
bool isMacAddress(String raw) {
  final text = raw.trim().toUpperCase();
  if (RegExp(r'^([0-9A-F]{2}[:-]){5}[0-9A-F]{2}$').hasMatch(text)) return true;
  return RegExp(r'^[0-9A-F]{12}$').hasMatch(text);
}

/// Canonical `AA:BB:CC:DD:EE:FF` form for a MAC label — the format the API
/// documents and its MAC validation expects. Handles label prefixes
/// (`MAC:AABBCCDDEEFF`), colon/dash pairing, and the bare 12-hex run
/// barcodes print (`E86E4424D818`). Anything that is not 12 hex digits after
/// stripping is returned trimmed and unchanged (never mangled).
String normalizeMacAddress(String raw) {
  var text = raw.trim().toUpperCase();
  final macIdx = text.indexOf('MAC');
  if (macIdx >= 0) text = text.substring(macIdx + 3);
  text = text.replaceAll(RegExp(r'[^0-9A-F]'), '');
  if (text.length != 12) return raw.trim();
  return [
    for (var i = 0; i < 12; i += 2) text.substring(i, i + 2),
  ].join(':');
}

/// True for ZTE D-SN style serials (`ZTEOQJNN2T03485`): uppercase
/// alphanumerics, 6–32 chars, with at least one letter and one digit.
/// Anything carrying separators that is not a MAC is deliberately NOT a
/// serial — misrouting a tracking code into the serial slot is worse than
/// asking for a rescan.
bool isSerialNumber(String raw) {
  final text = raw.trim().toUpperCase();
  // A bare 12-hex run is a MAC, never a serial (see [isMacAddress]).
  if (RegExp(r'^[0-9A-F]{12}$').hasMatch(text)) return false;
  return RegExp(r'^(?=.*[A-Z])(?=.*[0-9])[A-Z0-9]{6,32}$').hasMatch(text);
}

/// Full-screen camera scanner that captures the serial (D-SN) AND the MAC in
/// one session: every detected code is classified on the spot — MAC-like
/// fills the MAC slot, serial-like fills the serial slot. Both filled closes
/// automatically with [ScannedIdentifiers]; otherwise Done returns whatever
/// was captured (≥1 required), each slot clearable for a rescan. Unrecognized
/// codes are ignored with a hint instead of landing in the wrong slot.
class DeviceScanBothDialog extends StatefulWidget {
  const DeviceScanBothDialog({super.key});

  @override
  State<DeviceScanBothDialog> createState() => _DeviceScanBothDialogState();
}

class _DeviceScanBothDialogState extends State<DeviceScanBothDialog> {
  final MobileScannerController _controller = MobileScannerController(
    formats: const <BarcodeFormat>[],
  );

  static const _defaultHint =
      'Point the camera at the serial (D-SN) and MAC labels.';
  static const _unrecognizedHint =
      'That code was not recognized — try the other label.';

  String? _serial;
  String? _mac;
  String _hint = _defaultHint;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    for (final barcode in capture.barcodes) {
      final normalized = barcode.rawValue?.trim().toUpperCase() ?? '';
      if (normalized.isEmpty) continue;
      final macLike = isMacAddress(normalized);
      final serialLike = !macLike && isSerialNumber(normalized);
      if (macLike && _mac == null) {
        if (_serial != null) {
          // Both captured — close with success, no extra tap needed.
          Navigator.of(context)
              .pop(ScannedIdentifiers(serial: _serial, mac: normalized));
          return;
        }
        setState(() => _mac = normalized);
        return;
      }
      if (serialLike && _serial == null) {
        if (_mac != null) {
          Navigator.of(context)
              .pop(ScannedIdentifiers(serial: normalized, mac: _mac));
          return;
        }
        setState(() => _serial = normalized);
        return;
      }
      // Already-captured kinds are ignored silently (the camera re-reads the
      // same label every frame); only a genuinely unrecognized code updates
      // the hint, and only once.
      if (!macLike && !serialLike && _hint != _unrecognizedHint) {
        setState(() => _hint = _unrecognizedHint);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasAny = (_serial ?? '').isNotEmpty || (_mac ?? '').isNotEmpty;
    return Dialog.fullscreen(
      backgroundColor: Colors.black,
      child: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error) => _ScanErrorView(error: error),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: IconButton(
                  tooltip: 'Cancel scan',
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.zero,
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.08),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SlotRow(
                      label: 'Serial (D-SN)',
                      value: _serial,
                      onClear: _serial == null
                          ? null
                          : () => setState(() => _serial = null),
                    ),
                    const SizedBox(height: 8),
                    _SlotRow(
                      label: 'MAC address',
                      value: _mac,
                      onClear: _mac == null
                          ? null
                          : () => setState(() => _mac = null),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed: hasAny
                            ? () => Navigator.of(context).pop(
                                  ScannedIdentifiers(
                                      serial: _serial, mac: _mac),
                                )
                            : null,
                        child: const Text('Done'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _hint,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One capture slot: label + captured mono value (or a waiting placeholder),
/// with a clear button to rescan that kind.
class _SlotRow extends StatelessWidget {
  const _SlotRow({required this.label, required this.value, required this.onClear});

  final String label;
  final String? value;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final captured = value != null && value!.isNotEmpty;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.black54,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                captured ? value! : 'Waiting…',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: captured ? Colors.black87 : Colors.black38,
                      fontWeight:
                          captured ? FontWeight.w700 : FontWeight.w400,
                      fontFamily: captured ? 'IBM Plex Mono' : null,
                    ),
              ),
            ],
          ),
        ),
        if (captured)
          IconButton(
            tooltip: 'Rescan $label',
            visualDensity: VisualDensity.compact,
            onPressed: onClear,
            icon: const Icon(Icons.close, size: 18, color: Colors.black54),
          ),
      ],
    );
  }
}
