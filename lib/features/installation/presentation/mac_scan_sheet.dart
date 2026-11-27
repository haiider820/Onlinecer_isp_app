import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../shared/validation/mac_address.dart';

/// What a scanned barcode value means.
enum ScannedBarcodeKind {
  /// The value normalises to a 12-hex MAC address.
  mac,

  /// Not a MAC — offered as the device serial instead (ONT labels usually
  /// barcode the serial, not the MAC).
  serialCandidate,
}

/// Pure decision for a scanned barcode value (unit-tested): a value that
/// normalises to a 12-hex MAC ([normalizeMacAddress] accepts colon/dash/
/// dot/bare forms plus an optional `MAC:` prefix) is a MAC; anything else
/// is a serial candidate. A barcode scan must never force a non-MAC value
/// into the required MAC field.
({ScannedBarcodeKind kind, String? mac}) classifyScannedBarcode(
  String rawValue,
) {
  final mac = normalizeMacAddress(rawValue);
  if (mac != null) return (kind: ScannedBarcodeKind.mac, mac: mac);
  return (kind: ScannedBarcodeKind.serialCandidate, mac: null);
}

/// Result of a MAC scan sheet session.
enum MacScanOutcome {
  /// The scanned barcode is a MAC address — fill the MAC field.
  mac,

  /// The scanned barcode is not a MAC — fill the serial field instead.
  serial,
}

class MacScanResult {
  const MacScanResult.mac(this.value) : outcome = MacScanOutcome.mac;
  const MacScanResult.serial(this.value) : outcome = MacScanOutcome.serial;

  final MacScanOutcome outcome;

  /// Normalised `AA:BB:CC:DD:EE:FF` for [MacScanOutcome.mac], the raw
  /// scanned value for [MacScanOutcome.serial].
  final String value;
}

/// Opens the barcode scan sheet for the installed-device MAC (D21).
///
/// Returns the scan result, or `null` when the sheet is closed without a
/// choice (manual entry stays available — the MAC field is never blocked
/// on the scanner).
Future<MacScanResult?> showMacScanSheet(BuildContext context) {
  return showModalBottomSheet<MacScanResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => const _MacScanSheet(),
  );
}

class _MacScanSheet extends StatefulWidget {
  const _MacScanSheet();

  @override
  State<_MacScanSheet> createState() => _MacScanSheetState();
}

class _MacScanSheetState extends State<_MacScanSheet> {
  late final MobileScannerController _controller;

  /// A scanned value that is not a MAC, awaiting the serial/again choice.
  String? _scannedValue;

  /// Camera/start failure reported by the scanner (e.g. permission denied).
  MobileScannerException? _error;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_scannedValue != null || _error != null) return;
    final raw = capture.barcodes
        .map((barcode) => barcode.rawValue?.trim())
        .firstWhere((value) => value != null && value.isNotEmpty,
            orElse: () => null);
    if (raw == null) return;
    final classified = classifyScannedBarcode(raw);
    if (classified.kind == ScannedBarcodeKind.mac) {
      if (mounted) {
        Navigator.of(context).pop(MacScanResult.mac(classified.mac!));
      }
      return;
    }
    // Not a MAC: pause the camera and let the user choose what to do
    // with the value instead of scanning it again and again.
    _controller.stop();
    if (mounted) setState(() => _scannedValue = raw);
  }

  void _scanAgain() {
    setState(() => _scannedValue = null);
    _controller.start();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.85,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Scan device barcode',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Expanded(
            child: _error != null
                ? _ErrorBody(error: _error!)
                : _scannedValue != null
                    ? _NonMacBody(
                        scannedValue: _scannedValue!,
                        onUseAsSerial: () => Navigator.of(context).pop(
                          MacScanResult.serial(_scannedValue!),
                        ),
                        onScanAgain: _scanAgain,
                      )
                    : _ScannerView(
                        controller: _controller,
                        onDetect: _onDetect,
                        onError: (error) {
                          if (mounted && _error == null) {
                            setState(() => _error = error);
                          }
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

/// Camera preview + scan-window overlay + hint. The scanner reports
/// start failures (e.g. camera permission denied) through [onError];
/// [errorBuilder] must not call `setState` during build, so the error is
/// delivered via a post-frame callback in the owner instead.
class _ScannerView extends StatelessWidget {
  const _ScannerView({
    required this.controller,
    required this.onDetect,
    required this.onError,
  });

  final MobileScannerController controller;
  final void Function(BarcodeCapture capture) onDetect;
  final void Function(MobileScannerException error) onError;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        MobileScanner(
          controller: controller,
          onDetect: onDetect,
          errorBuilder: (context, error) {
            WidgetsBinding.instance.addPostFrameCallback((_) => onError(error));
            return const ColoredBox(color: Colors.black);
          },
        ),
        // Scan window: a wide rounded frame for label barcodes.
        Center(
          child: Container(
            width: 280,
            height: 160,
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.colorScheme.primary,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Text(
              'Point the camera at the barcode on the device label.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// A scanned barcode that is not a MAC address: show the value and let the
/// technician use it as the device serial (the usual case — ONT labels
/// barcode the serial) or scan again.
class _NonMacBody extends StatelessWidget {
  const _NonMacBody({
    required this.scannedValue,
    required this.onUseAsSerial,
    required this.onScanAgain,
  });

  final String scannedValue;
  final VoidCallback onUseAsSerial;
  final VoidCallback onScanAgain;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.qr_code_2_outlined, size: 48),
          const SizedBox(height: 12),
          Text(
            'This barcode is not a MAC address.',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Scanned: $scannedValue',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'ONT labels usually barcode the serial number, not the MAC.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          FilledButton(
            onPressed: onUseAsSerial,
            child: const Text('Use as serial'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: onScanAgain,
            child: const Text('Scan again'),
          ),
        ],
      ),
    );
  }
}

/// Camera/start failure: explain briefly and send the user back to manual
/// entry — the MAC field is never blocked on the scanner.
class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.error});

  final MobileScannerException error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final denied =
        error.errorCode == MobileScannerErrorCode.permissionDenied;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.no_photography_outlined, size: 48),
          const SizedBox(height: 12),
          Text(
            denied ? 'Camera permission needed' : 'Could not start the camera',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            denied
                ? 'Allow camera access in Settings to scan barcodes. You can still type the MAC address manually.'
                : 'The camera could not be started. You can still type the MAC address manually.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Enter manually'),
          ),
        ],
      ),
    );
  }
}
