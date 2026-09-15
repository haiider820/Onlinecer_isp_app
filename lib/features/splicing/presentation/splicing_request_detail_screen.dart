import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exceptions.dart';
import '../../../core/router/functional_team.dart';
import '../../../core/router/team_module.dart';
import '../../../models/splicing.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/status_badge.dart';
import 'complete_splicing_screen.dart';
import 'splicing_providers.dart';

class SplicingRequestDetailScreen extends ConsumerWidget {
  const SplicingRequestDetailScreen({super.key, required this.requestId});
  final String requestId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(splicingDetailProvider(requestId));
    return Scaffold(
      appBar: AppBar(
        title: Text(TeamModule.forTeam(FunctionalTeamType.fiberSplicing).detailTitle),
      ),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorView(
          message: error is ApiException ? error.message : 'Could not load splicing detail.',
          onRetry: () => ref.invalidate(splicingDetailProvider(requestId)),
        ),
        data: (item) => _DetailBody(detail: item),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.detail});
  final SplicingDetail detail;

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
        ]),
        SectionCard(title: 'Feeding FAT node', icon: Icons.hub_outlined, children: [
          InfoRow(label: 'Node', value: detail.connectionFatNode?.name ?? 'Not provided'),
          if (detail.connectionFatNode?.id != null)
            InfoRow(label: 'ID', value: detail.connectionFatNode!.id!),
          if (detail.connectionFatNode?.latitude != null && detail.connectionFatNode?.longitude != null)
            InfoRow(label: 'Coordinates', value:
              '${detail.connectionFatNode!.latitude!.toStringAsFixed(6)}, ${detail.connectionFatNode!.longitude!.toStringAsFixed(6)}'),
        ]),
        if (detail.installationLatitude != null && detail.installationLongitude != null)
          SectionCard(title: 'Installation location', icon: Icons.location_on_outlined, children: [
            InfoRow(label: 'Coordinates', value:
              '${detail.installationLatitude!.toStringAsFixed(6)}, ${detail.installationLongitude!.toStringAsFixed(6)}'),
          ]),
        if (detail.surveyNotes?.isNotEmpty == true)
          _NotesCard(title: 'Survey notes', text: detail.surveyNotes!),
        if (detail.installationNotes?.isNotEmpty == true)
          _NotesCard(title: 'Installation notes', text: detail.installationNotes!),
        if (detail.notes.isNotEmpty)
          SectionCard(title: 'Previous notes', icon: Icons.notes_outlined, children: [
            for (final note in detail.notes) ...[
              Text(note.type ?? 'Note', style: theme.textTheme.labelLarge),
              if (note.note?.isNotEmpty == true) Text(note.note!),
              if (note.voiceNoteUrl?.isNotEmpty == true)
                Text('Voice note: ${note.voiceNoteUrl}', style: theme.textTheme.bodySmall),
              const SizedBox(height: 8),
            ],
          ]),
        if (detail.splicer?.name != null || detail.splicedAt != null)
          SectionCard(title: 'Splicing', icon: Icons.settings_input_component_outlined, children: [
            if (detail.splicer?.name != null) InfoRow(label: 'Splicer', value: detail.splicer!.name!),
            if (detail.splicedAt != null) InfoRow(label: 'Spliced at', value: detail.splicedAt!),
          ]),
        const SizedBox(height: 8),
        if (detail.canComplete)
          CompleteSplicingForm(requestId: detail.id)
        else
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text('No splicing action available for this request.', textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ),
      ],
    );
  }
}

class _NotesCard extends StatelessWidget {
  const _NotesCard({required this.title, required this.text});
  final String title;
  final String text;
  @override
  Widget build(BuildContext context) => SectionCard(
    title: title, icon: Icons.notes_outlined, children: [Text(text)],
  );
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(child: Padding(
    padding: const EdgeInsets.all(32),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.error_outline, size: 48), const SizedBox(height: 12),
      Text(message, textAlign: TextAlign.center), const SizedBox(height: 12),
      OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
    ]),
  ));
}
