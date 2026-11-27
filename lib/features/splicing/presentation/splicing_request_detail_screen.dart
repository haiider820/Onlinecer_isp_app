import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exceptions.dart';
import '../../../core/router/functional_team.dart';
import '../../../core/router/team_module.dart';
import '../../../models/splicing.dart';
import '../../../shared/voice/voice_recorder_controller.dart';
import '../../../shared/widgets/ops_widgets.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/stage_chips.dart';
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

class _DetailBody extends StatefulWidget {
  const _DetailBody({required this.detail});
  final SplicingDetail detail;

  @override
  State<_DetailBody> createState() => _DetailBodyState();
}

class _DetailBodyState extends State<_DetailBody> {
  /// The shared voice engine (D21), used here only for remote-URL playback
  /// of the previous notes' voice recordings: one player, toggle-by-URL,
  /// and the play/pause icon resets on natural finish.
  late final VoiceRecorderController _voice;

  /// D21: previous-stage data is collapsed by default — the index of the
  /// open chip, or null when all are closed. Only stages that have data
  /// get a chip.
  int? _openStage;

  @override
  void initState() {
    super.initState();
    _voice = VoiceRecorderController(
      filePrefix: 'detail',
      onMessage: _snack,
    )..addListener(_onVoiceChanged);
  }

  void _onVoiceChanged() {
    if (mounted) setState(() {});
  }

  void _snack(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  void dispose() {
    _voice.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detail = widget.detail;
    final theme = Theme.of(context);
    // One chip per previous-stage block that actually has data.
    final chips = <String>[
      if (detail.surveyNotes?.isNotEmpty == true) 'Survey',
      if (detail.installationNotes?.isNotEmpty == true) 'Installation',
      if (detail.notes.isNotEmpty) 'Notes',
    ];
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
        // D21: previous-stage data behind top chips, collapsed by default —
        // tap a chip to show that stage, tap it again to hide it.
        if (chips.isNotEmpty) ...[
          StageChips(
            labels: chips,
            selected: _openStage,
            onSelect: (index) => setState(
              () => _openStage = _openStage == index ? null : index,
            ),
          ),
          const SizedBox(height: 8),
          if (_openStage != null) _previousStage(detail, chips[_openStage!]),
        ],
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

  /// The one open previous-stage block. The chip labels are built from the
  /// same conditions, so the label always matches its content.
  Widget _previousStage(SplicingDetail detail, String chip) {
    switch (chip) {
      case 'Survey':
        return _NotesCard(title: 'Survey notes', text: detail.surveyNotes!);
      case 'Installation':
        return _NotesCard(
            title: 'Installation notes', text: detail.installationNotes!);
      default: // 'Notes'
        return SectionCard(title: 'Previous notes', icon: Icons.notes_outlined, children: [
          for (final note in detail.notes) ...[
            Text(note.type ?? 'Note', style: Theme.of(context).textTheme.labelLarge),
            if (note.note?.isNotEmpty == true) Text(note.note!),
            // D21: a voice note used to render as raw URL text with no way
            // to play it — it is now a survey-style bubble (no duration:
            // the server provides none for remote notes).
            if (note.voiceNoteUrl?.isNotEmpty == true)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: VoiceNoteBubble(
                  onPlay: () => _voice.playUrl(note.voiceNoteUrl!),
                  isPlaying: _voice.playingUrl == note.voiceNoteUrl,
                ),
              ),
            const SizedBox(height: 8),
          ],
        ]);
    }
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
