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
import '../../../models/fat_node.dart';
import '../../../models/inventory_item.dart';
import '../../../shared/widgets/voice_note_section.dart';
import '../../survey/presentation/route_providers.dart';
import '../data/complete_installation_network.dart';
import 'installation_map_providers.dart';
import 'installation_providers.dart';

/// Collects the installation fields — OLT device ownership (segmented
/// control), the FAT node used (dropdown backed by the FAT-node lookup the
/// survey flow already uses), optional wire usage and notes, and repeatable
/// inventory item rows — then submits them via `POST .../complete-installation`.
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
/// On success: confirms the new request status, then returns to the request
/// list (fresh instance → refetch, moving the completed request out of the
/// installation queue per the API checklist).
class CompleteInstallationForm extends ConsumerStatefulWidget {
  const CompleteInstallationForm({
    super.key,
    required this.requestId,
    this.scrollController,
  });

  final String requestId;

  /// The parent (merged detail screen) list controller, used to reveal the
  /// top of this form when validation fails.
  final ScrollController? scrollController;

  @override
  ConsumerState<CompleteInstallationForm> createState() =>
      _CompleteInstallationFormState();
}

/// One editable inventory row: the catalog item (id) plus its quantity.
class _InventoryRow {
  _InventoryRow({required this.id}) : quantityController = TextEditingController();

  final int id;
  final TextEditingController quantityController;

  /// Selected catalog item id; `null` until the user picks one.
  String? itemId;
}

class _CompleteInstallationFormState
    extends ConsumerState<CompleteInstallationForm> {
  final _formKey = GlobalKey<FormState>();
  final _wireController = TextEditingController();
  final _notesController = TextEditingController();

  /// Owned by the customer (user) or the company; `null` until chosen.
  String? _ownership;
  String? _ownershipError;

  /// Selected FAT node id; sent as `connection_fat_node_id`.
  String? _fatNodeId;

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
    _inventorySearch.dispose();
    _inventorySearchDebounce?.cancel();
    for (final row in _inventoryRows) {
      row.quantityController.dispose();
    }
    _recorder.dispose();
    _player.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = ref.watch(completeInstallationControllerProvider);
    final fatNodes = ref.watch(fatNodesProvider(widget.requestId));
    final inventory = ref.watch(inventoryItemsProvider);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionTitle(title: 'OLT device ownership', icon: Icons.devices_other_outlined),
          const SizedBox(height: 8),
          // The segmented control and its inline error share ONE cell so the
          // parent list's child set keeps a constant shape; a
          // conditionally-inserted sibling above the FAT dropdown would shift
          // every later child's slot and remount the dropdown, wiping its
          // validator error on submit.
          SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Quiet-surface card housing the ownership segmented control.
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: OltOwnership.user,
                        label: Text('User'),
                        icon: Icon(Icons.person_outline),
                      ),
                      ButtonSegment(
                        value: OltOwnership.company,
                        label: Text('Company'),
                        icon: Icon(Icons.domain_outlined),
                      ),
                    ],
                    selected: _ownership == null
                        ? const <String>{}
                        : {_ownership!},
                    emptySelectionAllowed: true,
                    onSelectionChanged: (selection) {
                      setState(() {
                        _ownership = selection.isEmpty ? null : selection.first;
                        _ownershipError = null;
                      });
                    },
                  ),
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
          ),
          const SizedBox(height: 16),

          _SectionTitle(title: 'FAT node', icon: Icons.account_tree_outlined),
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
            data: (list) => DropdownButtonFormField<String>(
              initialValue: _fatNodeId,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'FAT node',
                hintText: 'Select the FAT node used',
              ),
              items: list.data
                  .map(
                    (node) => DropdownMenuItem(
                      value: node.id,
                      child: Text(node.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() => _fatNodeId = value);
                FatNode? node;
                for (final n in list.data) {
                  if (n.id == value) {
                    node = n;
                    break;
                  }
                }
                // DP auto-fills from the FAT node; the map card above reacts
                // instantly through the shared map controller (Phase 4).
                ref
                    .read(installationMapControllerProvider(widget.requestId).notifier)
                    .setDpFromFat(
                      node == null
                          ? null
                          : LatLng(node.latitude, node.longitude),
                    );
              },
              validator: (value) =>
                  value == null ? 'Select a FAT node' : null,
            ),
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _wireController,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: false,
            ),
            decoration: const InputDecoration(
              labelText: 'Total wire used (m)',
              hintText: 'Optional',
            ),
            validator: (value) {
              final text = value?.trim() ?? '';
              if (text.isEmpty) return null;
              final parsed = num.tryParse(text);
              if (parsed == null || parsed < 0) {
                return 'Enter a valid amount (0 or more)';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _notesController,
            maxLines: 4,
            maxLength: 1000,
            decoration: const InputDecoration(
              labelText: 'Installation notes',
              hintText: 'Optional',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 16),

          _SectionTitle(title: 'Inventory used (optional)', icon: Icons.inventory_2_outlined),
          const SizedBox(height: 8),
          // Search filter for the inventory catalog dropdown items.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _inventorySearch,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search, size: 20),
                hintText: 'Search items…',
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
              ),
              onChanged: (value) {
                _inventorySearchDebounce?.cancel();
                _inventorySearchDebounce = Timer(
                  const Duration(milliseconds: 250),
                  () => setState(() => _inventorySearchQuery = value),
                );
              },
            ),
          ),
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
                final filtered = list.data.where((item) =>
                    item.name.toLowerCase().contains(q) ||
                    (item.category?.toLowerCase().contains(q) ?? false)).toList();
                final message = q.isEmpty
                    ? 'No inventory catalog items available.'
                    : 'No items match "${_inventorySearchQuery.trim()}".';
                return filtered.isEmpty
                ? Text(
                    message,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final row in _inventoryRows)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _InventoryRowCell(
                            // Keyed so adding/removing a sibling row
                            // reconciles by key instead of remounting
                            // (which would wipe the row's two FormField errors).
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
                  );
            },
          ),
          const SizedBox(height: 8),

          _SectionTitle(title: 'Photos (optional, max 2 MB each)', icon: Icons.photo_library_outlined),
          const SizedBox(height: 8),
          // One Card = one column child, so the photo list growing inside it
          // can't shift any sibling slot (Phase 4 rule).
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
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
                                    errorBuilder: (context, error, stackTrace) =>
                                        Container(
                                      width: 110,
                                      height: 110,
                                      color: theme.colorScheme.surfaceContainerHighest,
                                      child: const Icon(Icons.broken_image_outlined),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Remove photo',
                                  visualDensity: VisualDensity.compact,
                                  style: IconButton.styleFrom(
                                    backgroundColor: theme
                                        .colorScheme.surface
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
          ),
          const SizedBox(height: 16),

          _SectionTitle(title: 'Voice note (optional, max 10 MB)', icon: Icons.mic_none),
          const SizedBox(height: 8),
          VoiceNoteSection(
            hasPermission: _micPermission,
            isBusy: _micBusy,
            isRecording: _isRecording,
            recordingLabel: _recordingLabel,
            recordedPath: _recordedPath,
            onToggle: _toggleRecording,
            onClear: () => setState(() {
              _recordedPath = null;
              _recordedMime = null;
              _recordingTime = Duration.zero;
            }),
            onPlay: _playRecording,
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

          FilledButton.icon(
            onPressed: controller.isSubmitting ? null : _submit,
            icon: controller.isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_circle_outline),
            label: const Text('Complete Installation'),
          ),
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

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    final ownership = _ownership;
    final fatNodeId = _fatNodeId;
    final formValid = _formKey.currentState?.validate() ?? false;
    setState(() {
      _ownershipError = ownership == null
          ? 'Select who the OLT device belongs to'
          : null;
    });

    // DP comes from whatever the map card knows right now — the FAT auto-fill
    // or a manual GPS override.
    final dpPoint = ref
        .read(installationMapControllerProvider(widget.requestId))
        .dpLocation;
    if (!formValid || ownership == null || fatNodeId == null || dpPoint == null) {
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

    final wireText = _wireController.text.trim();
    final wire = wireText.isEmpty ? null : num.tryParse(wireText);
    final notes = _notesController.text.trim();
    final inventoryLines = _buildInventoryLines();
    final photos = _photoPaths.isEmpty ? null : List<InstallationPhoto>.of(_photoPaths);

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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.icon = Icons.tag});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 14,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

/// One inventory row: a catalog-item dropdown + a quantity field, plus a
/// remove control. Both members are `FormField`s, so they participate in the
/// form's single [FormState.validate]. An untouched row (no item, no
/// quantity) passes both validators and is stripped from the payload.
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
    return Row(
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
                  child: Text(item.name, overflow: TextOverflow.ellipsis),
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
        const SizedBox(width: 8),
        Expanded(
          child: TextFormField(
            controller: row.quantityController,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: false,
            ),
            decoration: const InputDecoration(labelText: 'Quantity'),
            validator: (value) {
              final text = value?.trim() ?? '';
              if (row.itemId == null && text.isEmpty) return null; // untouched
              if (text.isEmpty) return 'Enter a quantity';
              final qty = num.tryParse(text);
              if (qty == null || qty < 1) {
                return 'Enter a valid quantity (1 or more)';
              }
              return null;
            },
          ),
        ),
        IconButton(
          tooltip: 'Remove item',
          icon: const Icon(Icons.close),
          onPressed: onRemove,
        ),
      ],
    );
  }
}