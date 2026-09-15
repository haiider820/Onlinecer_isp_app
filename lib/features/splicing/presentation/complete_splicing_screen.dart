import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/voice_note_section.dart';
import 'splicing_providers.dart';

/// Complete splicing accepts no notes or inventory fields: only an optional
/// voice note is sent using multipart/form-data.
class CompleteSplicingForm extends ConsumerStatefulWidget {
  const CompleteSplicingForm({super.key, required this.requestId});
  final String requestId;
  @override
  ConsumerState<CompleteSplicingForm> createState() => _CompleteSplicingFormState();
}

class _CompleteSplicingFormState extends ConsumerState<CompleteSplicingForm> {
  final AudioRecorder _recorder = AudioRecorder();
  Timer? _ticker;
  bool _hasPermission = false;
  bool _busy = false;
  bool _recording = false;
  Duration _elapsed = Duration.zero;
  String? _path;

  @override
  void initState() { super.initState(); _loadPermission(); }
  @override
  void dispose() { _ticker?.cancel(); _recorder.dispose(); super.dispose(); }

  Future<void> _loadPermission() async {
    final granted = await _recorder.hasPermission();
    if (mounted) setState(() => _hasPermission = granted);
  }

  Future<void> _toggle() async {
    if (_recording) return _stop();
    if (!_hasPermission) return _snack(AppStrings.snackbarMicPermission);
    setState(() => _busy = true);
    try {
      final dir = await getTemporaryDirectory();
      await _recorder.start(const RecordConfig(encoder: AudioEncoder.aacLc),
        path: '${dir.path}/splicing_${DateTime.now().millisecondsSinceEpoch}.m4a');
      final clock = Stopwatch()..start();
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _elapsed = clock.elapsed);
      });
      if (mounted) setState(() { _recording = true; _elapsed = Duration.zero; _path = null; });
    } catch (_) { _snack(AppStrings.snackbarRecordFailed); }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _stop() async {
    setState(() => _busy = true);
    _ticker?.cancel();
    try {
      final path = await _recorder.stop();
      if (path == null || !File(path).existsSync() || await File(path).length() > maxVoiceNoteBytes) {
        _snack(path == null ? AppStrings.snackbarRecordFailed : 'Voice note is too large (max 10 MB).');
      } else if (mounted) { setState(() => _path = path); }
    } catch (_) { _snack(AppStrings.snackbarRecordFailed); }
    if (mounted) setState(() { _recording = false; _busy = false; });
  }

  Future<void> _submit() async {
    final result = await ref.read(completeSplicingControllerProvider.notifier)
        .submit(id: widget.requestId, voiceNotePath: _path, voiceNoteMimeType: _path == null ? null : 'audio/mp4');
    if (!mounted || result == null) return;
    final status = result.status?.replaceAll('_', ' ');
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
              status == null || status.isEmpty
                  ? 'Splicing submitted.'
                  : 'Splicing submitted → $status',
            ),
          ),
        ],
      ),
    ));
    context.go(Routes.splicingList);
  }

  void _snack(String message) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message))); }
  String get _label => '${_elapsed.inMinutes.toString().padLeft(2, '0')}:${(_elapsed.inSeconds % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(completeSplicingControllerProvider);
    final theme = Theme.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text('Voice note (optional, max 10 MB)', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      VoiceNoteSection(hasPermission: _hasPermission, isBusy: _busy, isRecording: _recording,
        recordingLabel: _label, recordedPath: _path, onToggle: _toggle,
        onClear: () => setState(() { _path = null; _elapsed = Duration.zero; })),
      if (state.hasError) Padding(padding: const EdgeInsets.only(top: 8), child: Text(state.errorMessage!,
        style: TextStyle(color: theme.colorScheme.error))),
      const SizedBox(height: 16),
      FilledButton.icon(onPressed: state.isSubmitting ? null : _submit, icon: const Icon(Icons.check_circle_outline),
        label: Text(state.isSubmitting ? 'Submitting...' : 'Complete Splicing')),
    ]);
  }
}
