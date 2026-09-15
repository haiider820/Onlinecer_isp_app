import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../models/connection_request.dart';
import '../../../shared/widgets/voice_note_section.dart';
import '../../auth/presentation/providers.dart';
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
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _playingUrl;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _play(String url) async {
    try {
      if (_playingUrl == url) {
        await _audioPlayer.stop();
        if (mounted) setState(() => _playingUrl = null);
        return;
      }
      await _audioPlayer.play(UrlSource(url));
      if (mounted) setState(() => _playingUrl = url);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not play this voice note.')),
        );
      }
    }
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
          onPlayVoiceNote: _play,
          completion: item.allows(widget.config.allowedAction)
              ? TeamStageCompletionForm(
                  config: widget.config,
                  requestId: item.id,
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
    required this.listRoute,
    required this.listPageProvider,
  });

  final TeamStageConfig config;
  final String requestId;
  final String listRoute;
  final FutureProviderFamily<ConnectionRequestPage, int> listPageProvider;

  @override
  ConsumerState<TeamStageCompletionForm> createState() =>
      _TeamStageCompletionFormState();
}

class _TeamStageCompletionFormState extends ConsumerState<TeamStageCompletionForm> {
  final _notes = TextEditingController();
  final _recorder = AudioRecorder();
  final _player = AudioPlayer();
  Timer? _ticker;
  bool _hasPermission = false;
  bool _recording = false;
  bool _recordingBusy = false;
  bool _submitting = false;
  String? _error;
  String? _voiceNotePath;
  Duration _elapsed = Duration.zero;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _loadPermission();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _notes.dispose();
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _loadPermission() async {
    final granted = await _recorder.hasPermission();
    if (mounted) setState(() => _hasPermission = granted);
  }

  Future<void> _toggleRecording() async {
    if (_recording) return _stopRecording();
    if (!_hasPermission) {
      _show('Microphone permission is required to record a voice note.');
      return;
    }
    setState(() => _recordingBusy = true);
    try {
      final directory = await getTemporaryDirectory();
      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: '${directory.path}/stage_${DateTime.now().millisecondsSinceEpoch}.m4a',
      );
      final stopwatch = Stopwatch()..start();
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _elapsed = stopwatch.elapsed);
      });
      if (mounted) {
        setState(() {
          _recording = true;
          _elapsed = Duration.zero;
          _voiceNotePath = null;
        });
      }
    } catch (_) {
      _show('Could not record voice note. Please try again.');
    } finally {
      if (mounted) setState(() => _recordingBusy = false);
    }
  }

  Future<void> _stopRecording() async {
    setState(() => _recordingBusy = true);
    _ticker?.cancel();
    try {
      final path = await _recorder.stop();
      if (path == null || !File(path).existsSync()) {
        _show('Could not record voice note. Please try again.');
      } else if (await File(path).length() > maxVoiceNoteBytes) {
        _show('Voice note is too large (max 10 MB).');
      } else if (mounted) {
        setState(() => _voiceNotePath = path);
      }
    } catch (_) {
      _show('Could not record voice note. Please try again.');
    } finally {
      if (mounted) setState(() { _recording = false; _recordingBusy = false; });
    }
  }

  Future<void> _playRecording() async {
    if (_voiceNotePath == null || !mounted) return;
    try {
      if (_isPlaying) {
        await _player.stop();
        if (mounted) setState(() => _isPlaying = false);
        return;
      }
      await _player.play(DeviceFileSource(_voiceNotePath!));
      if (mounted) setState(() => _isPlaying = true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not play voice note: $error')),
        );
      }
    }
  }

  Future<void> _submit() async {
    setState(() { _submitting = true; _error = null; });
    try {
      final result = await ref.read(_completionRepositoryProvider).submit(
        config: widget.config,
        requestId: widget.requestId,
        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
        voiceNotePath: _voiceNotePath,
        voiceNoteMimeType: _voiceNotePath == null ? null : 'audio/mp4',
      );
      if (!mounted) return;
      ref.invalidate(widget.listPageProvider(1));
      final message = widget.config.isTerminal
          ? 'Job closed.'
          : '${widget.config.featureName} completed: ${result.status?.replaceAll('_', ' ') ?? 'moved to next team'}';
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
            Expanded(child: Text(message)),
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

  String get _recordingLabel =>
      '${_elapsed.inMinutes.toString().padLeft(2, '0')}:${(_elapsed.inSeconds % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final label = widget.config.actionLabel;
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
      VoiceNoteSection(
        hasPermission: _hasPermission,
        isBusy: _recordingBusy,
        isRecording: _recording,
        recordingLabel: _recordingLabel,
        recordedPath: _voiceNotePath,
        onToggle: _toggleRecording,
        onClear: () => setState(() { _voiceNotePath = null; _elapsed = Duration.zero; }),
        onPlay: _playRecording,
      ),
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
