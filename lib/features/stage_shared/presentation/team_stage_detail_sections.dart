import 'package:flutter/material.dart';

import '../../../shared/formatting/format_minor_price.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/status_badge.dart';
import '../models/team_stage_detail.dart';

/// Reusable read-only detail body for Verification and Closing. A future
/// screen supplies the completion widget beneath this context and the audio
/// callback used by inline voice-note controls.
class TeamStageDetailSections extends StatelessWidget {
  const TeamStageDetailSections({
    super.key,
    required this.detail,
    this.onPlayVoiceNote,
    this.completion,
  });

  final TeamStageDetail detail;
  final ValueChanged<String>? onPlayVoiceNote;
  final Widget? completion;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
        if (detail.notes.isNotEmpty) _notes(context),
        if (detail.items.isNotEmpty) _items(context),
        if (detail.documents.isNotEmpty) _documents(context),
        if (detail.charges != null) _charges(),
        if (detail.timestamps.isNotEmpty) _timestamps(),
        if (detail.stageData.isNotEmpty) _stageData(),
        if (completion != null) ...[const SizedBox(height: 8), completion!],
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
    for (final note in detail.notes) _NoteRow(note: note, onPlay: onPlayVoiceNote),
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
    for (final document in detail.documents) ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(document.name ?? document.type ?? 'Document'),
      subtitle: Text(document.url ?? 'Unavailable', maxLines: 1, overflow: TextOverflow.ellipsis),
    ),
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
  const _NoteRow({required this.note, this.onPlay});
  final TeamStageNote note;
  final ValueChanged<String>? onPlay;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (note.type != null) Text(note.type!, style: Theme.of(context).textTheme.labelLarge),
      if (note.text?.isNotEmpty == true) Text(note.text!),
      if (note.voiceNoteUrl?.isNotEmpty == true) TextButton.icon(
        onPressed: onPlay == null ? null : () => onPlay!(note.voiceNoteUrl!),
        icon: const Icon(Icons.play_circle_outline), label: const Text('Play voice note')),
    ]),
  );
}
