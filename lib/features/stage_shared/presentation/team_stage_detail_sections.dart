import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/formatting/format_minor_price.dart';
import '../../../shared/widgets/ops_widgets.dart';
import '../../../shared/widgets/pppoe_inventory_cards.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/stage_chips.dart';
import '../../../shared/widgets/status_badge.dart';
import '../data/document_download.dart';
import '../models/team_stage_detail.dart';
import 'document_download_providers.dart';

/// Reusable read-only detail body for Verification and Closing. A future
/// screen supplies the completion widget beneath this context and the audio
/// callback used by inline voice-note controls.
///
/// D21: the accumulated previous-stage blocks (Notes, Items, Documents,
/// PPPoE & inventory, Charges, Timeline, Stage data) sit behind top chips
/// and are collapsed by default — tap a chip to show that group, tap it
/// again to hide it. Only groups that have data get a chip. Customer,
/// FAT node, locations and assigned users are this request's context, not
/// previous-stage work, so they stay visible; the completion form stays
/// at the bottom.
class TeamStageDetailSections extends StatefulWidget {
  const TeamStageDetailSections({
    super.key,
    required this.detail,
    this.onPlayVoiceNote,
    this.playingVoiceNoteUrl,
    this.completion,
  });

  final TeamStageDetail detail;
  final ValueChanged<String>? onPlayVoiceNote;

  /// The remote voice-note URL currently playing, if any — its bubble
  /// shows the pause state.
  final String? playingVoiceNoteUrl;
  final Widget? completion;

  @override
  State<TeamStageDetailSections> createState() =>
      _TeamStageDetailSectionsState();
}

class _TeamStageDetailSectionsState extends State<TeamStageDetailSections> {
  /// Index into [_groups] of the open chip, or null when all are collapsed
  /// (the default).
  int? _openGroup;

  TeamStageDetail get detail => widget.detail;

  /// (Chip label, builder) for every previous-stage group that has data.
  /// The true per-stage attribution is not in the payload — notes carry
  /// only a free-text type and `stage_data` is a flat map — so groups are
  /// by section, not by stage.
  List<(String, Widget Function())> get _groups {
    final detail = widget.detail;
    return [
      if (detail.notes.isNotEmpty)
        ('Notes', () => _notes(context)),
      if (detail.items.isNotEmpty)
        ('Items', () => _items(context)),
      if (detail.documents.isNotEmpty)
        ('Documents', () => _documents(context)),
      if (detail.pppoeCredentials != null ||
          detail.installationInventory != null)
        (
          'PPPoE & inventory',
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PppoeCredentialsCard(credentials: detail.pppoeCredentials),
              InstallationInventoryCard(inventory: detail.installationInventory),
            ],
          ),
        ),
      if (detail.charges != null) ('Charges', () => _charges()),
      if (detail.timestamps.isNotEmpty)
        ('Timeline', () => _timestamps()),
      if (detail.stageData.isNotEmpty)
        ('Stage data', () => _stageData()),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final detail = widget.detail;
    final theme = Theme.of(context);
    final groups = _groups;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Row(children: [
          Expanded(child: Text(detail.requestNumber,
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700))),
          StatusBadge(status: detail.status),
        ]),
        const SizedBox(height: 16),
        SectionCard(title: 'Customer', icon: Icons.person_outline, children: [
          if (detail.customerName != null) InfoRow(label: 'Name', value: detail.customerName!),
          if (detail.customerPhone != null) InfoRow(label: 'Phone', value: detail.customerPhone!),
          if (detail.customerAddress != null) InfoRow(label: 'Address', value: detail.customerAddress!),
          if (detail.customerArea != null) InfoRow(label: 'Area', value: detail.customerArea!),
          if (detail.requestedPlanName != null) InfoRow(label: 'Plan', value: detail.requestedPlanName!),
          if (detail.currentTeamName != null) InfoRow(label: 'Current team', value: detail.currentTeamName!),
        ]),
        if (detail.fatNode != null) _fatNode(),
        if (detail.locations.isNotEmpty) _locations(),
        if (detail.assignedUsers.isNotEmpty) _users(),
        if (groups.isNotEmpty) ...[
          StageChips(
            labels: [for (final group in groups) group.$1],
            selected: _openGroup,
            onSelect: (index) => setState(
              () => _openGroup = _openGroup == index ? null : index,
            ),
          ),
          if (_openGroup != null) ...[
            const SizedBox(height: 8),
            groups[_openGroup!].$2(),
          ],
        ],
        if (widget.completion != null) ...[const SizedBox(height: 8), widget.completion!],
      ],
    );
  }

  Widget _fatNode() => SectionCard(title: 'Feeding FAT node', icon: Icons.hub_outlined, children: [
    InfoRow(label: 'Name', value: detail.fatNode!.name ?? 'Not provided'),
    if (detail.fatNode!.id != null) InfoRow(label: 'ID', value: detail.fatNode!.id!),
    if (detail.fatNode!.latitude != null && detail.fatNode!.longitude != null)
      InfoRow(label: 'Coordinates', value: '${detail.fatNode!.latitude}, ${detail.fatNode!.longitude}'),
  ]);

  Widget _users() => SectionCard(title: 'Assigned users', icon: Icons.group_outlined, children: [
    for (final user in detail.assignedUsers) InfoRow(label: user.role, value: user.name),
  ]);

  Widget _locations() => SectionCard(title: 'Locations', icon: Icons.location_on_outlined, children: [
    for (final entry in detail.locations.entries)
      InfoRow(label: entry.key.replaceAll('_', ' '), value: _location(entry.value)),
  ]);

  String _location(TeamStageLocation location) {
    if (location.latitude != null && location.longitude != null) {
      return '${location.latitude!.toStringAsFixed(6)}, ${location.longitude!.toStringAsFixed(6)}';
    }
    return location.name ?? location.id ?? 'Not provided';
  }

  Widget _notes(BuildContext context) => SectionCard(title: 'Notes', icon: Icons.notes_outlined, children: [
    for (final note in detail.notes) _NoteRow(
      note: note,
      onPlay: widget.onPlayVoiceNote,
      isPlaying: note.voiceNoteUrl != null &&
          note.voiceNoteUrl!.isNotEmpty &&
          widget.playingVoiceNoteUrl == note.voiceNoteUrl,
    ),
  ]);

  Widget _items(BuildContext context) {
    final columns = <String>{
      for (final item in detail.items) ...item.values.keys,
    }.toList(growable: false);
    return SectionCard(
      title: 'Items used',
      icon: Icons.inventory_2_outlined,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: [for (final column in columns) DataColumn(label: Text(column.replaceAll('_', ' ')))],
            rows: [
              for (final item in detail.items)
                DataRow(cells: [for (final column in columns) DataCell(Text(item.values[column] ?? '-'))]),
            ],
          ),
        ),
      ],
    );
  }

  Widget _documents(BuildContext context) => SectionCard(title: 'Documents', icon: Icons.description_outlined, children: [
    for (final document in detail.documents) _DocumentRow(document: document),
  ]);

  Widget _charges() => SectionCard(title: 'Charges', icon: Icons.payments_outlined, children: [
    if (detail.charges!.connectionChargesMinor != null) InfoRow(label: 'Connection', value: formatMinorPrice(detail.charges!.connectionChargesMinor!)),
    if (detail.charges!.subscriptionChargesMinor != null) InfoRow(label: 'Subscription', value: formatMinorPrice(detail.charges!.subscriptionChargesMinor!)),
    if (detail.charges!.inventoryCostMinor != null) InfoRow(label: 'Inventory', value: formatMinorPrice(detail.charges!.inventoryCostMinor!)),
  ]);

  Widget _timestamps() => SectionCard(title: 'Timeline', icon: Icons.schedule_outlined, children: [
    for (final entry in detail.timestamps.entries) InfoRow(label: entry.key.replaceAll('_', ' '), value: entry.value),
  ]);

  Widget _stageData() => SectionCard(title: 'Stage data', icon: Icons.info_outline, children: [
    for (final entry in detail.stageData.entries)
      InfoRow(label: entry.key.replaceAll('_', ' '), value: entry.value),
  ]);
}

class _NoteRow extends StatelessWidget {
  const _NoteRow({required this.note, this.onPlay, this.isPlaying = false});
  final TeamStageNote note;
  final ValueChanged<String>? onPlay;
  final bool isPlaying;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (note.type != null) Text(note.type!, style: Theme.of(context).textTheme.labelLarge),
      if (note.text?.isNotEmpty == true) Text(note.text!),
      // D21: the voice note used to be a plain "Play voice note" button
      // with no playing state — it is now the survey-style bubble (no
      // duration: the server provides none for remote notes). No bubble
      // when no player is wired (the button used to render disabled).
      if (note.voiceNoteUrl?.isNotEmpty == true && onPlay != null)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: VoiceNoteBubble(
            onPlay: () => onPlay!(note.voiceNoteUrl!),
            isPlaying: isPlaying,
          ),
        ),
    ]),
  );
}

/// One document row: tapping downloads the file through the authenticated
/// client (guide §21) and opens it with the system viewer. While a
/// download is in flight the row shows a spinner and ignores further taps;
/// a failed download shows the error and never crashes the detail screen.
/// When the file downloads but no viewer can open it, the saved temp path
/// is shown so the technician can find it in a file manager.
class _DocumentRow extends ConsumerStatefulWidget {
  const _DocumentRow({required this.document});

  final TeamStageDocument document;

  @override
  ConsumerState<_DocumentRow> createState() => _DocumentRowState();
}

class _DocumentRowState extends ConsumerState<_DocumentRow> {
  bool _downloading = false;

  Future<void> _download() async {
    if (_downloading) return;
    final document = widget.document;
    if (document.url == null || document.url!.isEmpty) {
      _snack('Document is unavailable.');
      return;
    }
    setState(() => _downloading = true);
    try {
      final result =
          await ref.read(documentDownloaderProvider).download(document);
      if (!mounted) return;
      if (result.opened) {
        _snack('Document downloaded.');
      } else {
        _snack('Saved to ${result.savedPath} — no app could open it.');
      }
    } on DocumentDownloadException catch (e) {
      if (mounted) _snack('Could not download document: ${e.message}');
    } catch (_) {
      if (mounted) _snack('Could not download document.');
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final document = widget.document;
    final unavailable = document.url == null || document.url!.isEmpty;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(document.name ?? document.type ?? 'Document'),
      subtitle: Text(
        document.url ?? 'Unavailable',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: _downloading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.download_outlined),
      onTap: unavailable ? null : _download,
    );
  }
}
