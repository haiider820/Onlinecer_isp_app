import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../core/network/api_exceptions.dart';
import '../../../core/router/app_router.dart';
import '../../../models/connection_request.dart';
import '../../../shared/voice/voice_recorder_controller.dart';
import '../../../shared/widgets/ops_widgets.dart';
import '../../auth/presentation/providers.dart';
import '../../closing/presentation/closing_success_screen.dart';
import '../../survey/presentation/connection_request_providers.dart';
import '../../voice_notes/presentation/voice_note_providers.dart';
import '../data/team_stage_completion_network.dart';
import '../data/team_stage_completion_repository.dart';
import '../models/team_stage_detail.dart';
import '../team_stage_config.dart';
import 'team_stage_detail_sections.dart';

/// Generic read-only detail screen for Verification and Closing. Its only
/// stage-specific inputs are supplied by [TeamStageConfig].
class TeamStageDetailScreen extends ConsumerStatefulWidget {
  const TeamStageDetailScreen({
    super.key,
    required this.requestId,
    required this.config,
    required this.title,
    required this.detailProvider,
    required this.listRoute,
    required this.listPageProvider,
  });

  final String requestId;
  final TeamStageConfig config;
  final String title;
  final FutureProviderFamily<TeamStageDetail, String> detailProvider;
  final String listRoute;
  final FutureProviderFamily<ConnectionRequestPage, int> listPageProvider;

  @override
  ConsumerState<TeamStageDetailScreen> createState() => _TeamStageDetailScreenState();
}

class _TeamStageDetailScreenState extends ConsumerState<TeamStageDetailScreen> {
  /// The shared voice engine (D21), used here only for remote-URL playback
  /// of the Notes rows: one player, toggle-by-URL, and the play/pause icon
  /// resets on natural finish (the old `_play` never reset it).
  late final VoiceRecorderController _voice;

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
    final detail = ref.watch(widget.detailProvider(widget.requestId));
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _DetailError(
          message: error is ApiException ? error.message : 'Could not load request detail.',
          onRetry: () => ref.invalidate(widget.detailProvider(widget.requestId)),
        ),
        data: (item) => TeamStageDetailSections(
          detail: item,
          onPlayVoiceNote: _voice.playUrl,
          playingVoiceNoteUrl: _voice.playingUrl,
          completion: item.allows(widget.config.allowedAction)
              ? TeamStageCompletionForm(
                  config: widget.config,
                  requestId: item.id,
                  detailProvider: widget.detailProvider,
                  listRoute: widget.listRoute,
                  listPageProvider: widget.listPageProvider,
                )
              : null,
        ),
      ),
    );
  }
}

final _completionRepositoryProvider = Provider<TeamStageCompletionRepository>(
  (ref) => TeamStageCompletionRepository(
    network: DioTeamStageCompletionNetwork(ref.watch(apiClientProvider)),
  ),
);

/// Config-driven completion form for the two JSON-or-multipart stages.
class TeamStageCompletionForm extends ConsumerStatefulWidget {
  const TeamStageCompletionForm({
    super.key,
    required this.config,
    required this.requestId,
    required this.detailProvider,
    required this.listRoute,
    required this.listPageProvider,
  });

  final TeamStageConfig config;
  final String requestId;

  /// The stage's own detail provider, refetched after a successful
  /// completion (Phase D) alongside the shared request detail.
  final FutureProviderFamily<TeamStageDetail, String> detailProvider;
  final String listRoute;
  final FutureProviderFamily<ConnectionRequestPage, int> listPageProvider;

  @override
  ConsumerState<TeamStageCompletionForm> createState() =>
      _TeamStageCompletionFormState();
}

class _TeamStageCompletionFormState extends ConsumerState<TeamStageCompletionForm> {
  final _notes = TextEditingController();

  /// The shared voice engine (D21): recording + playback state lives in
  /// the controller; this form only renders the survey pattern
  /// (VoiceRecorderCard + VoiceNoteBubble + delete).
  late final VoiceRecorderController _voice;

  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _voice = VoiceRecorderController(
      filePrefix: 'stage',
      onMessage: _show,
    )..addListener(_onVoiceChanged)
    ..initMic();
  }

  void _onVoiceChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _voice.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() { _submitting = true; _error = null; });
    try {
      final result = await ref.read(_completionRepositoryProvider).submit(
        config: widget.config,
        requestId: widget.requestId,
        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
        voiceNotePath: _voice.recordedPath,
        voiceNoteMimeType: _voice.recordedPath == null ? null : 'audio/mp4',
      );
      if (!mounted) return;
      // Guide §20: stage completion may not save the voice note, so the
      // recording is uploaded separately as a best-effort follow-up. The
      // stage is already complete — a failure here only warns, never fails
      // or rolls back the submit.
      final voiceNoteWarning = await ref
          .read(voiceNoteRepositoryProvider)
          .uploadBestEffort(
            requestId: widget.requestId,
            voiceNotePath: _voice.recordedPath,
            voiceNoteMimeType: _voice.recordedPath == null ? null : 'audio/mp4',
          );
      if (!mounted) return;
      // D24: refresh detail + every list + dashboard BEFORE navigating, so
      // the list the user returns to is already fresh (no manual refresh).
      // The old code only refetched the detail + one list page, which is
      // why the list kept showing the old phase.
      refreshAfterStageSubmit(ref.invalidate, widget.requestId);
      if (widget.config.isTerminal) {
        // Closing (D24): the activation credentials live on their own
        // locked success screen — back cannot dismiss it. The list is
        // already refreshed, so Close lands on the `connected` request.
        if (!mounted) return;
        context.push(
          Routes.closingSuccessFor(widget.requestId),
          extra: ClosingSuccessArgs(
            message: result.message,
            activation: result.activation,
            voiceNoteWarning: voiceNoteWarning,
            listRoute: widget.listRoute,
          ),
        );
        return;
      }
      final message =
          '${widget.config.featureName} completed: ${result.status?.replaceAll('_', ' ') ?? 'moved to next team'}';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
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
                voiceNoteWarning == null
                    ? message
                    : '$message\n$voiceNoteWarning',
              ),
            ),
          ],
        ),
      ));
      context.go(widget.listRoute);
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _show(String message) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.config.actionLabel;
    final theme = Theme.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      TextField(
        controller: _notes,
        maxLines: 4,
        maxLength: 2000,
        decoration: InputDecoration(
          labelText: widget.config.notesLabel,
          alignLabelWithHint: true,
        ),
      ),
      const SizedBox(height: 12),
      // Voice-note recording + playback, survey pattern (D21):
      // VoiceRecorderCard + VoiceNoteBubble + delete, no re-record.
      VoiceRecorderCard(
        title: 'Voice Note',
        subtitle: 'Tap the mic to record a voice note',
        elapsedLabel: _voice.recordingLabel,
        isRecording: _voice.isRecording,
        // Idle bars read as a fake waveform, so hide them until a
        // recording is actually running (survey pattern).
        waveformBars: _voice.isRecording
            ? const [8, 16, 24, 12, 20, 9, 18, 26, 14, 10, 22, 15]
            : const [],
        onMicTap: _voice.toggleRecording,
      ),
      if (_voice.micChecked && !_voice.micPermission) ...[
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                'Microphone permission needed to record a voice note.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: _voice.retryMicPermission,
              child: const Text('Open settings'),
            ),
          ],
        ),
      ],
      if (_voice.recordedPath != null && !_voice.isRecording) ...[
        const SizedBox(height: 10),
        OpsCard(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: VoiceNoteBubble(
                  durationLabel: _voice.recordingLabel,
                  onPlay: _voice.playRecording,
                  isPlaying: _voice.isPlaying,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Discard recording',
                onPressed: _voice.clearRecording,
                icon: const Icon(Icons.delete_outline, size: 20),
                color: theme.colorScheme.error,
              ),
            ],
          ),
        ),
      ],
      if (_error != null) Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
      ),
      const SizedBox(height: 16),
      FilledButton.icon(
        onPressed: _submitting ? null : _submit,
        icon: _submitting
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.check_circle_outline),
        label: Text(_submitting ? 'Submitting...' : label),
      ),
    ]);
  }
}

class _DetailError extends StatelessWidget {
  const _DetailError({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline, size: 48),
        const SizedBox(height: 12),
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: 12),
        OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
      ]),
    ),
  );
}
