import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../core/router/app_router.dart';
import '../../../shared/voice/voice_recorder_controller.dart';
import '../../../shared/widgets/ops_widgets.dart';
import 'splicing_providers.dart';

/// Complete splicing accepts no notes or inventory fields: only an optional
/// voice note is sent using multipart/form-data.
///
/// Voice UI is the survey pattern (D21): VoiceRecorderCard + VoiceNoteBubble
/// + delete, driven by the shared [VoiceRecorderController] — no Re-record
/// button, no dead Play button.
class CompleteSplicingForm extends ConsumerStatefulWidget {
  const CompleteSplicingForm({super.key, required this.requestId});
  final String requestId;
  @override
  ConsumerState<CompleteSplicingForm> createState() => _CompleteSplicingFormState();
}

class _CompleteSplicingFormState extends ConsumerState<CompleteSplicingForm> {
  /// The shared voice engine (D21). The old local state machine is gone:
  /// the controller owns the recorder, the 10 MB cap, the busy guard
  /// (double-tap during start used to double-start the recorder) and the
  /// play/pause reset on natural finish.
  late final VoiceRecorderController _voice;

  @override
  void initState() {
    super.initState();
    _voice = VoiceRecorderController(
      filePrefix: 'splicing',
      onMessage: _snack,
    )..addListener(_onVoiceChanged)
    ..initMic();
  }

  void _onVoiceChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _voice.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final result = await ref.read(completeSplicingControllerProvider.notifier)
        .submit(id: widget.requestId, voiceNotePath: _voice.recordedPath, voiceNoteMimeType: _voice.recordedPath == null ? null : 'audio/mp4');
    if (!mounted || result == null) return;
    final status = result.status?.replaceAll('_', ' ');
    final message = status == null || status.isEmpty
        ? 'Splicing submitted.'
        : 'Splicing submitted → $status';
    // Guide §20: the follow-up voice-note upload may have warned — the
    // stage is complete regardless, so the warning rides along with the
    // success message instead of failing the submit.
    final voiceNoteWarning =
        ref.read(completeSplicingControllerProvider).voiceNoteWarning;
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
    context.go(Routes.splicingList);
  }

  void _snack(String message) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message))); }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(completeSplicingControllerProvider);
    final theme = Theme.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text('Voice note (optional, max 10 MB)', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
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
      if (state.hasError) Padding(padding: const EdgeInsets.only(top: 8), child: Text(state.errorMessage!,
        style: TextStyle(color: theme.colorScheme.error))),
      const SizedBox(height: 16),
      FilledButton.icon(onPressed: state.isSubmitting ? null : _submit, icon: const Icon(Icons.check_circle_outline),
        label: Text(state.isSubmitting ? 'Submitting...' : 'Complete Splicing')),
    ]);
  }
}
