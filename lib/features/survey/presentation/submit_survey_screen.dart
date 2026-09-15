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
import '../../../core/router/app_router.dart';
import '../../../core/theme/field_ops_design_tokens.dart';
import '../../../shared/widgets/branded_header.dart';
import '../../../shared/widgets/voice_note_section.dart';
import 'connection_request_providers.dart';
import 'submit_survey_providers.dart';

/// Collects `survey_notes` + an optional recorded voice note and submits them
/// via `POST .../complete-survey`.
///
/// Layout matches the stitch survey-completion mockup — work-order header,
/// field notes card with live counter, audio memo card and a sticky
/// submit shelf — while rendering ONLY the fields the API actually accepts
/// (notes + voice note). The mockup's feasibility/drop-wire/length controls
/// were removed in an earlier reality-check pass and are not re-added.
class SubmitSurveyScreen extends ConsumerStatefulWidget {
  const SubmitSurveyScreen({super.key, required this.requestId});

  final String requestId;

  @override
  ConsumerState<SubmitSurveyScreen> createState() => _SubmitSurveyScreenState();
}

class _SubmitSurveyScreenState extends ConsumerState<SubmitSurveyScreen> {
  final _notesController = TextEditingController();
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

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
    _notesController.dispose();
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _initMic() async {
    bool granted;
    try {
      granted = await _recorder.hasPermission();
    } catch (_) {
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
      final path = '${dir.path}/survey_${DateTime.now().millisecondsSinceEpoch}.m4a';
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

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final notes = _notesController.text.trim();
    final result = await ref
        .read(submitSurveyControllerProvider.notifier)
        .submit(
          id: widget.requestId,
          notes: notes.isEmpty ? null : notes,
          voiceNotePath: _recordedPath,
          voiceNoteMimeType: _recordedMime,
        );
    if (!mounted) return;

    if (result != null) {
      await _showSuccessThenGo();
    }
  }

  /// Phase 3 success: play the checkmark animation briefly, then leave the
  /// queue and land back on the survey list.
  ///
  /// The overlay closes itself when its animation completes (~2s) and then
  /// [context.go] lands on the list. Completion is ticker-driven (an
  /// [AnimationController], no `Timer`), so it always resolves within a bounded
  /// pump and never leaves a pending timer behind.
  Future<void> _showSuccessThenGo() async {
    final navigator = Navigator.of(context);
    // Full-screen transparent overlay with the success Lottie.
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _SuccessOverlay(
        onComplete: () {
          if (mounted) navigator.pop();
        },
      ),
    );
    if (!mounted) return;
    // Fresh list instance refetches, so the completed request leaves the queue.
    context.go(Routes.surveyList);
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  String get _recordingLabel {
    final m = _recordingTime.inMinutes;
    final s = _recordingTime.inSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = ref.watch(submitSurveyControllerProvider);
    // Real work-order context, reused from the detail provider — the submit
    // card header shows the same request number/customer the technician just
    // opened. Renders nothing while it's still loading.
    final detailAsync = ref.watch(connectionRequestDetailProvider(widget.requestId));
    final request = detailAsync.valueOrNull?.request;

    return Scaffold(
      appBar: BrandedHeader(
        title: 'Complete Survey',
        onBack: () => context.pop(),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
          // ── Work order context header ──
          _WorkOrderHeader(requestNumber: request?.requestNumber, customerName: request?.customerName),
          const SizedBox(height: 12),

          // ── Field Notes card ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(FieldOpsDesignTokens.cardRadius),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: FieldOpsDesignTokens.shadowLevel1,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.edit_note,
                        size: 18,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Field Notes & Findings',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _notesController,
                  maxLines: 5,
                  maxLength: 2000,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Customer location verified. Pole and FAT access available.',
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ── Submit-state error banner ──
          if (controller.hasError) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(FieldOpsDesignTokens.radiusLg),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 18,
                    color: theme.colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      controller.errorMessage!,
                      style: TextStyle(color: theme.colorScheme.onErrorContainer),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],

          // ── Audio Memo card ──
          Text(
            'Audio Memo (optional, max 10 MB)',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
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
          const SizedBox(height: 24),
              ],
            ),
          ),
          // ── Sticky submit shelf ──
          Material(
            color: Colors.white,
            elevation: 8,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: SizedBox(
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: controller.isSubmitting ? null : _submit,
                    icon: controller.isSubmitting
                        ? SizedBox(
                            height: 22,
                            width: 22,
                            child: Lottie.asset('assets/lottie/login_loading.json', repeat: true),
                          )
                        : const Icon(Icons.check_circle_outline, size: 20),
                    label: const Text('Submit Survey'),
                    style: FilledButton.styleFrom(
                      // Hold the enabled blue fill during submit so the white
                      // spinner stays legible instead of sitting on Material's
                      // pale-grey disabled fill.
                      backgroundColor: controller.isSubmitting
                          ? FieldOpsDesignTokens.secondary
                          : null,
                      disabledBackgroundColor:
                          FieldOpsDesignTokens.secondary,
                      textStyle: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Slim context strip: REQ number + customer + "FEASIBILITY SURVEY" badge.
class _WorkOrderHeader extends StatelessWidget {
  const _WorkOrderHeader({this.requestNumber, this.customerName});

  final String? requestNumber;
  final String? customerName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(FieldOpsDesignTokens.cardRadius),
        border: Border.all(color: theme.colorScheme.primaryContainer),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (requestNumber != null)
                  Text(
                    requestNumber!,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                if (customerName != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    customerName!,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: FieldOpsDesignTokens.secondaryFixed,
              borderRadius: BorderRadius.circular(FieldOpsDesignTokens.radiusFull),
            ),
            child: Text(
              'FEASIBILITY SURVEY',
              style: TextStyle(
                color: FieldOpsDesignTokens.onSecondaryFixed,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.05,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-screen semi-transparent overlay that plays the success checkmark
/// animation and auto-closes when it completes.
///
/// Uses an [AnimationController] (ticker-driven, not a [Timer]) so
/// `pumpAndSettle` always advances through the full duration and no pending
/// timers are left behind at test teardown.
class _SuccessOverlay extends StatefulWidget {
  const _SuccessOverlay({required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<_SuccessOverlay> createState() => _SuccessOverlayState();
}

class _SuccessOverlayState extends State<_SuccessOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      // 1.8s — comfortably under the checkmark asset's 3s frame count
      // so the Lottie still has frames to display, but short enough
      // that a test's pumpAndSettle resolves quickly.
      duration: const Duration(milliseconds: 1800),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onComplete();
        }
      });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: ColoredBox(
        color: const Color(0xCCFFFFFF),
        child: Center(
          child: SizedBox(
            width: 180,
            height: 180,
            child: Lottie.asset(
              'assets/lottie/success_checkmark.json',
              controller: _controller,
              repeat: false,
            ),
          ),
        ),
      ),
    );
  }
}