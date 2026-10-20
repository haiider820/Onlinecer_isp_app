import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/field_ops_design_tokens.dart';
import '../../../models/fat_node.dart';
import '../../../models/inventory_item.dart';
import '../../../shared/widgets/ops_widgets.dart';
import '../../survey/presentation/route_providers.dart';
import '../data/complete_installation_network.dart';
import 'installation_map_providers.dart';
import 'installation_providers.dart';

/// Collects the installation fields — OLT device ownership (tappable tiles),
/// the FAT node used (picker card backed by the FAT-node lookup the survey
/// flow already uses), wire usage (stepper), installation notes (voice-first),
/// and repeatable inventory item rows — then submits them via
/// `POST .../complete-installation`.
///
/// Since the module's Phase 1 merge, this is **not a whole screen**: it is the
/// editable tail of the merged installation detail screen (information →
/// pricing → map → form). It renders a [Form] column that the parent drops
/// into its scrollable; [scrollController] (the parent's list) is used to pull
/// the form top back into view when validation fails.
///
/// The DP location is the selected FAT node by default — its coordinates ride
/// along with the submission as `dp_latitude`/`dp_longitude`. The DP marker can
/// alternatively come from a manual GPS override on the parent's map card; the
/// live point lives in [InstallationMapController], so the map above updates
/// instantly (Phase 4) and the submit reads from there.
///
/// The parent drives the sticky bottom CTA: [progress] is updated (0..1) as
/// the submit-blocking requirements complete, and [CompleteInstallationFormState.submit]
/// is the public entry point the CTA calls.
///
/// On success: confirms the new request status, then returns to the request
/// list (fresh instance → refetch, moving the completed request out of the
/// installation queue per the API checklist).
class CompleteInstallationForm extends ConsumerStatefulWidget {
  const CompleteInstallationForm({
    super.key,
    required this.requestId,
    this.scrollController,
    this.progress,
  });

  final String requestId;

  /// The parent (merged detail screen) list controller, used to reveal the
  /// top of this form when validation fails.
  final ScrollController? scrollController;

  /// Updated (0..1) as the submit-blocking requirements complete:
  /// OLT ownership chosen, FAT node chosen, DP location known.
  final ValueNotifier<double>? progress;

  @override
  ConsumerState<CompleteInstallationForm> createState() =>
      CompleteInstallationFormState();
}

/// One editable inventory row: the catalog item (id) plus its quantity.
class _InventoryRow {
  _InventoryRow({required this.id}) : quantityController = TextEditingController();

  final int id;
  final TextEditingController quantityController;

  /// Selected catalog item id; `null` until the user picks one.
  String? itemId;
}

class CompleteInstallationFormState
    extends ConsumerState<CompleteInstallationForm> {
  final _formKey = GlobalKey<FormState>();
  final _wireController = TextEditingController();
  final _notesController = TextEditingController();
  final _notesFocusNode = FocusNode();

  /// Owned by the customer (user) or the company; `null` until chosen.
  String? _ownership;
  String? _ownershipError;

  /// Selected FAT node id; sent as `connection_fat_node_id`.
  String? _fatNodeId;

  /// Inline error under the wire stepper (the stepper only writes valid
  /// values; this is defensive for programmatic/legacy controller content).
  String? _wireError;

  /// Inline error under the inventory section when a row has an item picked
  /// but no quantity.
  String? _inventoryError;

  final List<_InventoryRow> _inventoryRows = [];
  int _nextRowId = 0;

  final ImagePicker _imagePicker = ImagePicker();
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  /// Attached installation photos (local path + MIME), validated on pick.
  final List<InstallationPhoto> _photoPaths = [];

  /// Search query that filters the inventory catalog dropdown items.
  final _inventorySearch = TextEditingController();
  Timer? _inventorySearchDebounce;
  String _inventorySearchQuery = '';

  // Voice-note recording state machine (mirrors the survey submit screen).
  bool _micPermission = false;
  bool _micBusy = false;
  bool _isRecording = false;
  Duration _recordingTime = Duration.zero;
  Timer? _recordingTicker;
  String? _recordedPath;
  String? _recordedMime;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initMic();
  }

  @override
  void dispose() {
    _recordingTicker?.cancel();
    _wireController.dispose();
    _notesController.dispose();
    _notesFocusNode.dispose();
    _inventorySearch.dispose();
    _inventorySearchDebounce?.cancel();
    for (final row in _inventoryRows) {
      row.quantityController.dispose();
    }
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }

  /// Fraction (0..1) of the submit-blocking requirements currently met.
  double _computeProgress(bool dpKnown) {
    var done = 0;
    if (_ownership != null) done++;
    if (_fatNodeId != null) done++;
    if (dpKnown) done++;
    return done / 3;
  }

  void _syncProgress(double value) {
    final notifier = widget.progress;
    if (notifier != null && notifier.value != value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifier.value = value;
      });
    }
  }

  void _addInventoryRow() {
    setState(() => _inventoryRows.add(_InventoryRow(id: _nextRowId++)));
  }

  void _removeInventoryRow(_InventoryRow row) {
    row.quantityController.dispose();
    setState(() => _inventoryRows.remove(row));
  }

  Future<void> _initMic() async {
    bool granted;
    try {
      granted = await _recorder.hasPermission();
    } catch (_) {
      // No platform implementation in tests / denied by the OS.
      granted = false;
    }
    if (mounted) setState(() => _micPermission = granted);
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    if (!_micPermission) {
      _snack(AppStrings.snackbarMicPermission);
      return;
    }
    setState(() => _micBusy = true);
    try {
      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/installation_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _recorder.start(const RecordConfig(encoder: AudioEncoder.aacLc), path: path);
      final stopwatch = Stopwatch()..start();
      _recordingTicker?.cancel();
      _recordingTicker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _recordingTime = stopwatch.elapsed);
      });
      if (mounted) {
        setState(() {
          _isRecording = true;
          _recordingTime = Duration.zero;
          _recordedPath = null;
          _recordedMime = null;
        });
      }
    } on Exception {
      _snack(AppStrings.snackbarRecordFailed);
    } finally {
      if (mounted) setState(() => _micBusy = false);
    }
  }

  Future<void> _stopRecording() async {
    setState(() => _micBusy = true);
    _recordingTicker?.cancel();
    try {
      final path = await _recorder.stop();
      if (!mounted) return;
      setState(() => _isRecording = false);

      if (path == null || !File(path).existsSync()) {
        _snack(AppStrings.snackbarRecordFailed);
        return;
      }

      final size = await File(path).length();
      if (size > maxVoiceNoteBytes) {
        _snack('Voice note is too large (max ${maxVoiceNoteBytes ~/ (1024 * 1024)} MB).');
        File(path).deleteSync();
        return;
      }
      setState(() {
        _recordedPath = path;
        _recordedMime = 'audio/mp4';
      });
    } on Exception {
      _snack(AppStrings.snackbarRecordFailed);
    } finally {
      if (mounted) setState(() => _micBusy = false);
    }
  }

  Future<void> _playRecording() async {
    if (_recordedPath == null || !mounted) return;
    try {
      if (_isPlaying) {
        await _player.stop();
        if (mounted) setState(() => _isPlaying = false);
        return;
      }
      await _player.play(DeviceFileSource(_recordedPath!));
      if (mounted) setState(() => _isPlaying = true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not play voice note: $error')),
        );
      }
    }
  }

  String get _recordingLabel {
    final m = _recordingTime.inMinutes;
    final s = _recordingTime.inSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _pickPhotos() async {
    try {
      final files = await _imagePicker.pickMultiImage(imageQuality: 85);
      if (files.isEmpty) return;

      final photos = <InstallationPhoto>[];
      for (final file in files) {
        final mime = _mimeTypeForName(file.name);
        if (!allowedInstallationPhotoMimeTypes.contains(mime)) {
          _snack('Unsupported photo type: $mime');
          continue;
        }
        final size = await file.length();
        if (size > maxInstallationPhotoBytes) {
          _snack('Photo is too large (max ${maxInstallationPhotoBytes ~/ (1024 * 1024)} MB).');
          continue;
        }
        photos.add((path: file.path, mime: mime));
      }
      if (photos.isEmpty) return;
      if (mounted) setState(() => _photoPaths.addAll(photos));
    } on Exception {
      // No platform implementation (tests) or the picker was cancelled/failed.
      _snack('Could not add photo.');
    }
  }

  void _removePhoto(InstallationPhoto photo) {
    setState(() => _photoPaths.remove(photo));
  }

  static String _mimeTypeForName(String name) {
    final ext = name.toLowerCase().split('.').last;
    return switch (ext) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => 'application/octet-stream',
    };
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  // ─── Wire stepper ─────────────────────────────────────────────────────

  num _wireValue() {
    final text = _wireController.text.trim();
    if (text.isEmpty) return 0;
    return num.tryParse(text) ?? 0;
  }

  static String _trimNum(num value) {
    final raw = value.toString();
    if (!raw.contains('.')) return raw;
    return raw
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  void _stepWire(num delta) {
    final next = _wireValue() + delta;
    setState(() {
      _wireController.text = next <= 0 ? '' : _trimNum(next);
      _wireError = null;
    });
  }

  // ─── FAT node picker ──────────────────────────────────────────────────

  static String _fatMeta(FatNode node, LatLng? userLoc) {
    if (userLoc != null) {
      final meters =
          Distance()(userLoc, LatLng(node.latitude, node.longitude));
      final dist = meters >= 1000
          ? '${(meters / 1000).toStringAsFixed(1)} km'
          : '${meters.toStringAsFixed(0)} m';
      return '$dist away';
    }
    return 'Lat ${node.latitude.toStringAsFixed(5)}, '
        'lng ${node.longitude.toStringAsFixed(5)}';
  }

  Future<void> _pickFatNode(
    BuildContext context,
    List<FatNode> nodes,
    FormFieldState<String> field,
  ) async {
    final userLoc =
        ref.read(installationMapControllerProvider(widget.requestId)).userLocation;
    final selected = await showModalBottomSheet<FatNode>(
      context: context,
      builder: (sheetContext) {
        final sheetTheme = Theme.of(sheetContext);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Text(
                  'Choose FAT node',
                  style: sheetTheme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final node in nodes)
                      ListTile(
                        leading: Icon(
                          Icons.cell_tower,
                          color: sheetTheme.colorScheme.primary,
                        ),
                        title: Text(node.name),
                        subtitle: Text(_fatMeta(node, userLoc)),
                        trailing: node.id == _fatNodeId
                            ? Icon(
                                Icons.check_circle,
                                color: sheetTheme.colorScheme.primary,
                              )
                            : null,
                        onTap: () => Navigator.of(sheetContext).pop(node),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
    if (selected == null) return;
    field.didChange(selected.id);
    setState(() => _fatNodeId = selected.id);
    // DP auto-fills from the FAT node; the map card above reacts instantly
    // through the shared map controller.
    ref
        .read(installationMapControllerProvider(widget.requestId).notifier)
        .setDpFromFat(LatLng(selected.latitude, selected.longitude));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = ref.watch(completeInstallationControllerProvider);
    final fatNodes = ref.watch(fatNodesProvider(widget.requestId));
    final inventory = ref.watch(inventoryItemsProvider);
    final dpKnown = ref
        .watch(installationMapControllerProvider(widget.requestId))
        .dpLocation !=
        null;
    _syncProgress(_computeProgress(dpKnown));

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _FieldTitle('OLT device ownership'),
          const SizedBox(height: 8),
          // The ownership tiles and their inline error share ONE cell so the
          // parent list's child set keeps a constant shape; a
          // conditionally-inserted sibling above the FAT picker would shift
          // every later child's slot and remount it, wiping its validator
          // error on submit.
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  OptionTile(
                    label: 'User',
                    icon: Icons.person_outline,
                    selected: _ownership == OltOwnership.user,
                    onTap: () => setState(() {
                      _ownership = OltOwnership.user;
                      _ownershipError = null;
                    }),
                  ),
                  const SizedBox(width: 10),
                  OptionTile(
                    label: 'Company',
                    icon: Icons.domain_outlined,
                    selected: _ownership == OltOwnership.company,
                    onTap: () => setState(() {
                      _ownership = OltOwnership.company;
                      _ownershipError = null;
                    }),
                  ),
                ],
              ),
              if (_ownershipError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    _ownershipError!,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.error),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          _FieldTitle('FAT node'),
          const SizedBox(height: 8),
          fatNodes.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e is ApiException
                      ? e.message
                      : 'Could not load FAT nodes.',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.error),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => ref.invalidate(
                    fatNodesProvider(widget.requestId),
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
            data: (list) {
              FatNode? selected;
              for (final node in list.data) {
                if (node.id == _fatNodeId) selected = node;
              }
              final userLoc = ref
                  .watch(installationMapControllerProvider(widget.requestId))
                  .userLocation;
              return FormField<String>(
                initialValue: _fatNodeId,
                validator: (value) =>
                    value == null ? 'Select a FAT node' : null,
                builder: (field) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FatPickerCard(
                      nodeId: selected?.name ?? 'Select the FAT node used',
                      meta: selected == null
                          ? '${list.data.length} node${list.data.length == 1 ? '' : 's'} nearby — tap to choose'
                          : _fatMeta(selected, userLoc),
                      onTap: () => _pickFatNode(context, list.data, field),
                    ),
                    if (field.hasError)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          field.errorText!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          _FieldTitle('Total wire used (m)'),
          const SizedBox(height: 8),
          WireStepper(
            value: _wireController.text.trim().isEmpty
                ? '0'
                : _wireController.text.trim(),
            unit: 'meters',
            onDecrement: () => _stepWire(-1),
            onIncrement: () => _stepWire(1),
          ),
          if (_wireError != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                _wireError!,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.error),
              ),
            ),
          const SizedBox(height: 20),

          VoiceRecorderCard(
            title: 'Installation notes',
            subtitle: 'Tap the mic to record a voice note — or type below.',
            elapsedLabel: _isRecording
                ? _recordingLabel
                : (_recordedPath != null ? 'Voice note ready' : '00:00'),
            isRecording: _isRecording,
            onMicTap: _micBusy ? () {} : _toggleRecording,
            onTypeTap: () => _notesFocusNode.requestFocus(),
          ),
          if (_recordedPath != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  tooltip:
                      _isPlaying ? 'Pause voice note' : 'Play voice note',
                  onPressed: _playRecording,
                  icon: Icon(
                    _isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_fill,
                  ),
                  color: theme.colorScheme.primary,
                ),
                Expanded(
                  child: Text(
                    'Voice note attached',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() {
                    _recordedPath = null;
                    _recordedMime = null;
                    _recordingTime = Duration.zero;
                  }),
                  child: const Text('Remove'),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          TextFormField(
            controller: _notesController,
            focusNode: _notesFocusNode,
            maxLines: 4,
            maxLength: 1000,
            decoration: const InputDecoration(
              labelText: 'Typed notes',
              hintText: 'Optional',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 20),

          _FieldTitle('Inventory used (optional)'),
          const SizedBox(height: 8),
          // Search filter for the inventory catalog dropdown items.
          TextField(
            controller: _inventorySearch,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search, size: 20),
              hintText: 'Search items…',
              isDense: true,
            ),
            onChanged: (value) {
              _inventorySearchDebounce?.cancel();
              _inventorySearchDebounce = Timer(
                const Duration(milliseconds: 250),
                () => setState(() => _inventorySearchQuery = value),
              );
            },
          ),
          const SizedBox(height: 8),
          inventory.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e is ApiException
                      ? e.message
                      : 'Could not load inventory.',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.error),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => ref.invalidate(inventoryItemsProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
            data: (list) {
              final q = _inventorySearchQuery.toLowerCase();
              final filtered = list.data
                  .where((item) =>
                      item.name.toLowerCase().contains(q) ||
                      (item.category?.toLowerCase().contains(q) ?? false))
                  .toList();
              final message = q.isEmpty
                  ? 'No inventory catalog items available.'
                  : 'No items match "${_inventorySearchQuery.trim()}".';
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (filtered.isEmpty)
                    Text(
                      message,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    )
                  else ...[
                    for (final row in _inventoryRows)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _InventoryRowCell(
                          // Keyed so adding/removing a sibling row
                          // reconciles by key instead of remounting
                          // (which would wipe the row's FormField error).
                          key: ValueKey(row.id),
                          row: row,
                          items: filtered,
                          onChanged: (itemId) =>
                              setState(() => row.itemId = itemId),
                          onRemove: () => _removeInventoryRow(row),
                        ),
                      ),
                    OutlinedButton.icon(
                      onPressed: _addInventoryRow,
                      icon: const Icon(Icons.add),
                      label: const Text('Add item'),
                    ),
                  ],
                  if (_inventoryError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        _inventoryError!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),

          _FieldTitle('Photos (optional, max 2 MB each)'),
          const SizedBox(height: 8),
          // One card = one column child, so the photo list growing inside it
          // can't shift any sibling slot.
          OpsCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_photoPaths.isEmpty)
                  Text(
                    'No photos attached.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final photo in _photoPaths)
                        SizedBox(
                          width: 110,
                          child: Stack(
                            alignment: Alignment.topRight,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(photo.path),
                                  width: 110,
                                  height: 110,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) =>
                                          Container(
                                    width: 110,
                                    height: 110,
                                    color: theme.colorScheme
                                        .surfaceContainerHighest,
                                    child: const Icon(
                                        Icons.broken_image_outlined),
                                  ),
                                ),
                              ),
                              IconButton(
                                tooltip: 'Remove photo',
                                visualDensity: VisualDensity.compact,
                                style: IconButton.styleFrom(
                                  backgroundColor: theme.colorScheme.surface
                                      .withValues(alpha: 0.9),
                                ),
                                icon: const Icon(Icons.close, size: 18),
                                onPressed: () => _removePhoto(photo),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                const SizedBox(height: 12),
                Center(
                  child: OutlinedButton.icon(
                    onPressed: _pickPhotos,
                    icon: const Icon(Icons.add_a_photo_outlined),
                    label: const Text('Add photo'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Controller catches submit-state errors even when validation
          // prevents a request.
          if (controller.hasError) ...[
            Card(
              color: theme.colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: theme.colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        controller.errorMessage!,
                        style: TextStyle(
                          color: theme.colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          // The submit CTA lives in the parent's sticky bottom bar —
          // [CompleteInstallationFormState.submit] is its entry point.
        ],
      ),
    );
  }

  /// Builds the `inventory_items` payload lines, stripping untouched rows
  /// (no item AND no quantity entered). Valid rows are guaranteed non-null by
  /// the row validators running before this.
  List<InventoryLine> _buildInventoryLines() {
    final lines = <InventoryLine>[];
    for (final row in _inventoryRows) {
      final itemId = row.itemId;
      final text = row.quantityController.text.trim();
      if (itemId == null && text.isEmpty) continue;
      final qty = num.tryParse(text);
      if (itemId == null || qty == null || qty < 1) continue;
      lines.add((itemId: itemId, quantity: qty));
    }
    return lines;
  }

  /// Validates and submits. Public so the parent's sticky bottom CTA can
  /// drive it.
  Future<void> submit() async {
    FocusScope.of(context).unfocus();

    final ownership = _ownership;
    final fatNodeId = _fatNodeId;
    final formValid = _formKey.currentState?.validate() ?? false;

    final wireText = _wireController.text.trim();
    final wire = wireText.isEmpty ? null : num.tryParse(wireText);
    final wireError = wireText.isNotEmpty && (wire == null || wire < 0)
        ? 'Enter a valid amount (0 or more)'
        : null;

    final inventoryError = _inventoryRows.any((row) =>
            row.itemId != null &&
            row.quantityController.text.trim().isEmpty)
        ? 'Enter a quantity for every selected item'
        : null;

    setState(() {
      _ownershipError =
          ownership == null ? 'Select who the OLT device belongs to' : null;
      _wireError = wireError;
      _inventoryError = inventoryError;
    });

    // DP comes from whatever the map card knows right now — the FAT auto-fill
    // or a manual GPS override.
    final dpPoint = ref
        .read(installationMapControllerProvider(widget.requestId))
        .dpLocation;
    if (!formValid ||
        ownership == null ||
        fatNodeId == null ||
        dpPoint == null ||
        wireError != null ||
        inventoryError != null) {
      // Bring the top of this form into view so the ownership / FAT errors
      // (the first fields) are visible.
      final formContext = _formKey.currentContext;
      if (formContext != null) {
        try {
          await Scrollable.ensureVisible(
            formContext,
            alignment: 0.0,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        } catch (_) {
          // Fall back to the list top when the form has no scroll context yet.
          widget.scrollController?.animateTo(
            0,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      } else {
        widget.scrollController?.animateTo(
          0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
      return;
    }

    final notes = _notesController.text.trim();
    final inventoryLines = _buildInventoryLines();
    final photos =
        _photoPaths.isEmpty ? null : List<InstallationPhoto>.of(_photoPaths);

    final result = await ref
        .read(completeInstallationControllerProvider.notifier)
        .submit(
          id: widget.requestId,
          oltDeviceOwnership: ownership,
          connectionFatNodeId: fatNodeId,
          dpLatitude: dpPoint.latitude,
          dpLongitude: dpPoint.longitude,
          totalWireUsed: wire,
          notes: notes.isEmpty ? null : notes,
          inventoryLines: inventoryLines.isEmpty ? null : inventoryLines,
          photos: photos,
          voiceNotePath: _recordedPath,
          voiceNoteMimeType: _recordedMime,
        );
    if (!mounted) return;

    if (result != null) {
      final status = result.data?.status?.replaceAll('_', ' ') ?? '';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: Lottie.asset(
                  'assets/lottie/success_checkmark.json',
                  repeat: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  status.isEmpty
                      ? 'Installation submitted.'
                      : 'Installation submitted → $status',
                ),
              ),
            ],
          ),
        ),
      );
      // Fresh list instance refetches, so the completed request leaves the queue.
      context.go(Routes.installationList);
    }
  }
}

/// Section title used across the completion form (kept sentence-case so
/// test-visible labels stay identical).
class _FieldTitle extends StatelessWidget {
  const _FieldTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: theme.colorScheme.onSurface,
      ),
    );
  }
}

/// One inventory row: a catalog-item dropdown + a glove-friendly quantity
/// stepper, plus a remove control. The item dropdown is a [FormField], so it
/// participates in the form's single [FormState.validate]; the stepper writes
/// into [row]'s quantity controller, and a manual check in [submit] covers the
/// "item picked but no quantity" case (shown as [_inventoryError]).
class _InventoryRowCell extends StatelessWidget {
  const _InventoryRowCell({
    super.key,
    required this.row,
    required this.items,
    required this.onChanged,
    required this.onRemove,
  });

  final _InventoryRow row;
  final List<InventoryItem> items;
  final ValueChanged<String?> onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: row.itemId,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Item'),
                items: [
                  for (final item in items)
                    DropdownMenuItem(
                      value: item.id,
                      child:
                          Text(item.name, overflow: TextOverflow.ellipsis),
                    ),
                ],
                onChanged: onChanged,
                validator: (value) {
                  if (value != null) return null;
                  final text = row.quantityController.text.trim();
                  return text.isEmpty ? null : 'Select an item';
                },
              ),
            ),
            IconButton(
              tooltip: 'Remove item',
              icon: const Icon(Icons.close),
              onPressed: onRemove,
            ),
          ],
        ),
        const SizedBox(height: 8),
        _QuantityStepper(row: row),
      ],
    );
  }
}

/// Glove-friendly − / + stepper bound to the row's quantity controller.
/// Empty means untouched (stripped from the payload); decrementing from 1
/// clears back to untouched.
class _QuantityStepper extends StatefulWidget {
  const _QuantityStepper({required this.row});

  final _InventoryRow row;

  @override
  State<_QuantityStepper> createState() => _QuantityStepperState();
}

class _QuantityStepperState extends State<_QuantityStepper> {
  int get _qty =>
      int.tryParse(widget.row.quantityController.text.trim()) ?? 0;

  void _step(int delta) {
    final next = _qty + delta;
    setState(() {
      widget.row.quantityController.text = next <= 0 ? '' : '$next';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        _StepButton(icon: Icons.remove, onTap: () => _step(-1)),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: theme.colorScheme.outlineVariant),
              color: theme.colorScheme.surfaceContainerLow,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$_qty',
                  style: FieldOpsDesignTokens.dataMd.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  'QTY',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 9,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        _StepButton(icon: Icons.add, onTap: () => _step(1)),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outlineVariant),
          color: theme.colorScheme.surfaceContainerLowest,
        ),
        child: Icon(icon, size: 18, color: theme.colorScheme.primary),
      ),
    );
  }
}
