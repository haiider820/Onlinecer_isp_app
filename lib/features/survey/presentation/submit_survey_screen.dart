import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/field_ops_design_tokens.dart';
import '../../../shared/voice/voice_recorder_controller.dart';
import '../../../shared/widgets/branded_header.dart';
import '../../../shared/widgets/ops_widgets.dart';
import '../../../shared/widgets/success_moment.dart';
import 'connection_request_providers.dart';
import 'submit_survey_providers.dart';

/// Collects the feasibility verdict (`feasible` / `not_feasible`, plus a
/// required reason when not feasible), `survey_notes` and an optional
/// recorded voice note, and submits them via `POST .../complete-survey`.
///
/// Voice-first edition (palette #4, kit DESIGN.md Rules 1-14). The notes card leads with a big
/// glowing mic (the shared [VoiceRecorderController] — this screen is the
/// reference pattern every other stage copies), then site
/// photos, a tappable site checklist, and the typed-notes fallback — with a
/// sticky submit shelf. Renders ONLY the fields the API actually accepts
/// (feasibility + reason + notes + voice note); photos and checklist items are on-device helpers and
/// are never submitted.
///
/// [isReview] is the survey-review case (request came back from Inventory,
/// status `survey_review`, `allowed_action` `review_survey`): the same
/// endpoint confirms it, with `survey_feasibility_status: "feasible"` added
/// to the body and no `requested_items` re-sent. The feasibility selector
/// is hidden in review mode — the verdict is already settled there.
class SubmitSurveyScreen extends ConsumerStatefulWidget {
  const SubmitSurveyScreen({super.key, required this.requestId, this.isReview = false});

  final String requestId;

  /// True when this is the Inventory-review confirmation, not a first survey.
  final bool isReview;

  @override
  ConsumerState<SubmitSurveyScreen> createState() => _SubmitSurveyScreenState();
}

class _SubmitSurveyScreenState extends ConsumerState<SubmitSurveyScreen> {
  final _notesController = TextEditingController();
  final _notesFocus = FocusNode();
  final _reasonController = TextEditingController();
  final ImagePicker _photoPicker = ImagePicker();

  /// The shared voice engine (D21): recording + playback state lives in
  /// the controller; this screen only renders it (VoiceRecorderCard +
  /// VoiceNoteBubble + delete) and forwards mic taps.
  late final VoiceRecorderController _voice;

  /// The surveyor's feasibility verdict (D14): `"feasible"` or
  /// `"not_feasible"`, or `null` until picked. The backend requires it on
  /// every normal complete-survey — the submit is blocked until it is set.
  String? _feasibility;

  /// On-device site photos (evidence helpers — not submitted).
  final List<XFile> _photos = [];

  /// On-device site checklist (not submitted).
  final Map<String, bool> _checks = {
    'Customer present at site': false,
    'Pole / DP access available': false,
    'Power available for ONT': false,
    'Drop-wire route is clear': false,
  };

  @override
  void initState() {
    super.initState();
    _voice = VoiceRecorderController(
      filePrefix: 'survey',
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
    _notesController.dispose();
    _notesFocus.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _addPhoto() async {
    try {
      final image = await _photoPicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );
      if (image != null && mounted) {
        setState(() => _photos.add(image));
      }
    } catch (_) {
      _snack('Could not open the camera.');
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final notes = _notesController.text.trim();
    final reason = _reasonController.text.trim();
    final result = await ref
        .read(submitSurveyControllerProvider.notifier)
        .submit(
          id: widget.requestId,
          notes: notes.isEmpty ? null : notes,
          voiceNotePath: _voice.recordedPath,
          voiceNoteMimeType: _voice.recordedMime,
          isReview: widget.isReview,
          // Review mode forces 'feasible' inside the controller; the
          // screen never passes a verdict there (no selector is shown).
          feasibilityStatus: widget.isReview ? null : _feasibility,
          notFeasibleReason:
              _feasibility == 'not_feasible' && reason.isNotEmpty ? reason : null,
        );
    if (!mounted) return;

    if (result != null) {
      // Guide §20: the follow-up voice-note upload may have warned — show
      // it after the success overlay, before leaving (the root
      // ScaffoldMessenger keeps the snackbar visible across the navigation).
      final voiceNoteWarning =
          ref.read(submitSurveyControllerProvider).voiceNoteWarning;
      // The success words (D23): request number + new status from the
      // response, falling back to the detail the screen already loaded.
      // Captured here — the controller's Phase D refetch invalidates the
      // detail, so reading it after the overlay would come back empty.
      final requestNumber = result.data?.requestNumber ??
          ref
              .read(connectionRequestDetailProvider(widget.requestId))
              .valueOrNull
              ?.request
              .requestNumber;
      final statusLabel = result.data?.status?.replaceAll('_', ' ');
      final subtitleParts = [
        if (requestNumber != null) requestNumber,
        if (statusLabel != null) statusLabel,
      ];
      await _showSuccessThenGo(
        voiceNoteWarning: voiceNoteWarning,
        headline: widget.isReview ? 'Review confirmed' : 'Survey submitted',
        subtitle: subtitleParts.isEmpty ? null : subtitleParts.join('  •  '),
      );
    }
  }

  /// D23 success: play the native success moment briefly, then leave the
  /// queue and land back on the survey list.
  ///
  /// The overlay closes itself when its animation completes (~1.4s) and
  /// then [context.go] lands on the list. Completion is ticker-driven (an
  /// [AnimationController] inside [SuccessMoment], no `Timer`), so it
  /// always resolves within a bounded pump and never leaves a pending
  /// timer behind.
  Future<void> _showSuccessThenGo({
    String? voiceNoteWarning,
    required String headline,
    String? subtitle,
  }) async {
    final navigator = Navigator.of(context);
    // Full-screen transparent overlay with the native success moment.
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _SuccessOverlay(
        headline: headline,
        subtitle: subtitle,
        onComplete: () {
          if (mounted) navigator.pop();
        },
      ),
    );
    if (!mounted) return;
    if (voiceNoteWarning != null) _snack(voiceNoteWarning);
    // D24: the submit already invalidated detail + every list + the
    // dashboard (refreshAfterStageSubmit), so the fresh list instance
    // refetches and the completed request leaves the queue.
    context.go(Routes.surveyList);
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
        title: widget.isReview ? 'Review Survey' : 'Complete Survey',
        onBack: () => context.pop(),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                // ── Work order context header ──
                _WorkOrderHeader(requestNumber: request?.requestNumber, customerName: request?.customerName),
                const SizedBox(height: 12),

                // ── Review explainer: confirming approves what Inventory
                // did; items are NOT re-requested (that would send the
                // request back to inventory_pending for a second round).
                if (widget.isReview) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(FieldOpsDesignTokens.radiusLg),
                      border: Border.all(color: theme.colorScheme.primaryContainer),
                    ),
                    child: Text(
                      'Inventory approved the requested items (see the detail screen). Confirming sends feasibility “feasible” with your notes — items are not requested again.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // ── Voice-first notes card ──
                VoiceRecorderCard(
                  title: 'Voice Note',
                  subtitle: 'Tap the mic and describe what you found on site',
                  elapsedLabel: _voice.recordingLabel,
                  isRecording: _voice.isRecording,
                  // Idle bars read as a fake waveform, so hide them until
                  // a recording is actually running.
                  waveformBars: _voice.isRecording
                      ? const [8, 16, 24, 12, 20, 9, 18, 26, 14, 10, 22, 15]
                      : const [],
                  onMicTap: _voice.toggleRecording,
                  onTypeTap: () => _notesFocus.requestFocus(),
                ),
                // Shown only once the permission check has resolved — never
                // on first paint before hasPermission returns.
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
                // ── Recorded playback row ──
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
                const SizedBox(height: 8),

                // ── Feasibility verdict (D14, normal flow only) ──
                // The backend requires `survey_feasibility_status` on every
                // complete-survey; before this card existed the screen had
                // no way to fill it and every normal submit 422d. In review
                // mode the verdict is already settled ('feasible'), so no
                // selector is shown.
                if (!widget.isReview) ...[
                  OpsCard(
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
                                Icons.fact_check_outlined,
                                size: 18,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Feasibility',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Text(
                              'Required',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.error,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SegmentedButton<String>(
                          segments: const [
                            ButtonSegment<String>(
                              value: 'feasible',
                              label: Text('Feasible'),
                              icon: Icon(Icons.check_circle_outline, size: 18),
                            ),
                            ButtonSegment<String>(
                              value: 'not_feasible',
                              label: Text('Not feasible'),
                              icon: Icon(Icons.cancel_outlined, size: 18),
                            ),
                          ],
                          selected: _feasibility == null
                              ? const <String>{}
                              : {_feasibility!},
                          emptySelectionAllowed: true,
                          showSelectedIcon: false,
                          onSelectionChanged: (selection) {
                            setState(() {
                              _feasibility =
                                  selection.isEmpty ? null : selection.first;
                            });
                            // Drop a stale validation banner as soon as the
                            // surveyor picks (or re-picks) a verdict.
                            ref
                                .read(submitSurveyControllerProvider.notifier)
                                .clearError();
                          },
                        ),
                        if (_feasibility == 'not_feasible') ...[
                          const SizedBox(height: 12),
                          TextField(
                            controller: _reasonController,
                            maxLines: 3,
                            maxLength: 500,
                            decoration: const InputDecoration(
                              labelText: 'Reason (required)',
                              hintText:
                                  'e.g. No FAT port is reachable from this address',
                              alignLabelWithHint: true,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

                // ── Field notes (typed fallback) ──
                OpsCard(
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
                        focusNode: _notesFocus,
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

                // ── Site photos (on-device evidence) ──
                OpsCard(
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
                              Icons.photo_camera_outlined,
                              size: 18,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Site Photos',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Text(
                            '${_photos.length}',
                            style: FieldOpsDesignTokens.dataMd.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Kept on this device as field evidence.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                        ),
                        itemCount: _photos.length + 1,
                        itemBuilder: (context, index) {
                          if (index == _photos.length) {
                            return InkWell(
                              onTap: _addPhoto,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: theme.colorScheme.outlineVariant,
                                  ),
                                  color: theme.colorScheme.surfaceContainerLow,
                                ),
                                child: Icon(
                                  Icons.add_a_photo_outlined,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            );
                          }
                          final photo = _photos[index];
                          return Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  File(photo.path),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: InkWell(
                                  onTap: () => setState(() => _photos.removeAt(index)),
                                  customBorder: const CircleBorder(),
                                  child: Container(
                                    width: 26,
                                    height: 26,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: theme.colorScheme.surface.withValues(alpha: 0.85),
                                    ),
                                    child: Icon(
                                      Icons.close,
                                      size: 14,
                                      color: theme.colorScheme.error,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // ── Site checklist (on-device) ──
                Text(
                  'Site Checklist',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                for (final entry in _checks.entries)
                  CheckTile(
                    label: entry.key,
                    checked: entry.value,
                    onTap: () => setState(() => _checks[entry.key] = !entry.value),
                  ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          // ── Sticky submit shelf (flat: surface + 1px top border, no shadow) ──
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                top: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: PressScale(
                  child: SizedBox(
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: controller.isSubmitting ? null : _submit,
                      icon: controller.isSubmitting
                          // Disabled fill is a grey tint in both modes, so
                          // the spinner uses onSurfaceVariant (legible on
                          // grey); the white Lottie spinner was unreadable
                          // on the light-mode disabled fill.
                          ? SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            )
                          : const Icon(Icons.check_circle_outline, size: 20),
                      label: Text(widget.isReview ? 'Confirm Review' : 'Submit Survey'),
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
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
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(FieldOpsDesignTokens.radiusFull),
            ),
            child: Text(
              'Feasibility survey',
              style: TextStyle(
                color: theme.colorScheme.onPrimaryContainer,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.05,
                fontFamily: FieldOpsDesignTokens.bodyFamily,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-screen semi-transparent overlay that plays the native success
/// moment and auto-closes when it completes.
///
/// D23: the Lottie checkmark is gone — the overlay now renders
/// [SuccessMoment] (check pop + Signal ring + success words, ~1.4s).
/// The overlay itself is a plain shell: locked (`barrierDismissible:
/// false`, `PopScope(canPop: false)`) so the user cannot dismiss it
/// mid-success, and it closes only via [onComplete].
class _SuccessOverlay extends StatelessWidget {
  const _SuccessOverlay({
    required this.headline,
    this.subtitle,
    required this.onComplete,
  });

  final String headline;
  final String? subtitle;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopScope(
      canPop: false,
      child: ColoredBox(
        color: theme.colorScheme.surface.withValues(alpha: 0.8),
        child: Center(
          child: SuccessMoment(
            headline: headline,
            subtitle: subtitle,
            onComplete: onComplete,
          ),
        ),
      ),
    );
  }
}
