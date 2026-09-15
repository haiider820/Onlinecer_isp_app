import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/theme/field_ops_design_tokens.dart';

/// Presentational card for recording/attaching a voice note, styled to match
/// the stitch completion-form mockups (mic badge header + waveform readout +
/// Play / Re-record / Delete controls).
///
/// The recording engine ([AudioRecorder]), permission, and timer state live in
/// the owning screen (survey and installation submit screens both host the
/// same state machine); this widget only renders one of four states that the
/// caller derives from its own state:
///  - no microphone permission,
///  - recording in progress (with a live [recordingLabel] timer),
///  - a ready recording (`[recordedPath]` non-null, with a discard button),
///  - nothing recorded yet.
///
/// [onPlay] is optional; when provided it renders an enabled Play button.
class VoiceNoteSection extends StatelessWidget {
  const VoiceNoteSection({
    super.key,
    required this.hasPermission,
    required this.isBusy,
    required this.isRecording,
    required this.recordingLabel,
    required this.recordedPath,
    required this.onToggle,
    required this.onClear,
    this.onPlay,
  });

  final bool hasPermission;
  final bool isBusy;
  final bool isRecording;
  final String recordingLabel;
  final String? recordedPath;
  final VoidCallback onToggle;
  final VoidCallback onClear;

  /// Optional playback hook; `null` renders a disabled Play button.
  final VoidCallback? onPlay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasRecording = recordedPath != null;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
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
          // Header: mic badge + title + state chip.
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.mic,
                  size: 18,
                  color: theme.colorScheme.secondary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Audio Memo / Voice Note',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _StatusChip(
                isRecording: isRecording,
                hasRecording: hasRecording,
                hasPermission: hasPermission,
                label: recordingLabel,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Body: waveform readout or permission notice.
          if (!hasPermission)
            Text(
              'Microphone permission needed to record a voice note.',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
            )
          else if (isRecording)
            _WaveformCard(
              titleLabel: 'Recording…',
              durationLabel: recordingLabel,
              active: true,
            )
          else if (hasRecording)
            _WaveformCard(
              titleLabel: _shortPath(recordedPath!),
              durationLabel: recordingLabel,
              active: false,
            )
          else
            Text(
              'No voice note recorded yet.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          const SizedBox(height: 12),
          // Controls row: Play / Re-record / Delete.
          Row(
            children: [
              FilledButton.icon(
                onPressed: hasRecording
                    ? onPlay ??
                        () {} // No player wired up: keep callback alive visually.
                    : null,
                icon: const Icon(Icons.play_arrow, size: 20),
                label: const Text('Play Memo'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 44),
                  textStyle: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Re-record (toggle): starts when idle, stops while recording.
              OutlinedButton.icon(
                onPressed: isBusy ? null : onToggle,
                icon: Icon(
                  isRecording ? Icons.stop_outlined : Icons.replay,
                  size: 18,
                ),
                label: Text(isRecording ? 'Stop' : 'Re-record'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 44),
                  textStyle: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Discard recording',
                onPressed: hasRecording ? onClear : null,
                icon: const Icon(Icons.delete_outline, size: 20),
                color: theme.colorScheme.error,
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _shortPath(String path) {
    final parts = path.split(Platform.pathSeparator);
    return parts.isEmpty ? path : parts.last;
  }
}

/// Small capsule showing the recording state (live timer / "Recorded").
class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.isRecording,
    required this.hasRecording,
    required this.hasPermission,
    required this.label,
  });

  final bool isRecording;
  final bool hasRecording;
  final bool hasPermission;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (!hasPermission) return const SizedBox.shrink();

    final Color bg;
    final Color fg;
    final IconData icon;
    String text;
    if (isRecording) {
      bg = theme.colorScheme.tertiaryContainer;
      fg = theme.colorScheme.onTertiaryContainer;
      icon = Icons.sync;
      text = 'Recording $label';
    } else if (hasRecording) {
      bg = FieldOpsDesignTokens.completedBackground;
      fg = FieldOpsDesignTokens.completedForeground;
      icon = Icons.check_circle_outline;
      text = 'Recorded';
    } else {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: fg,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.02,
            ),
          ),
        ],
      ),
    );
  }
}

/// Inner readout card: filename/duration row + decorative waveform bars.
class _WaveformCard extends StatelessWidget {
  const _WaveformCard({
    required this.titleLabel,
    required this.durationLabel,
    required this.active,
  });

  final String titleLabel;
  final String durationLabel;
  final bool active;

  /// Decorative bar heights (secondary for the played portion, faded after).
  static const List<double> _bars = [
    3, 5, 8, 4, 7, 9, 6, 8, 5, 3, 6, 9, 7, 4, 2, 3, 2, 1, 3, 2,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(FieldOpsDesignTokens.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  titleLabel,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                durationLabel,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 28,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: List.generate(_bars.length, (i) {
                final dim = !active && i >= (_bars.length * 0.6).round();
                return Expanded(
                  child: Container(
                    height: _bars[i] * 2.6,
                    margin: const EdgeInsets.symmetric(horizontal: 1.5),
                    decoration: BoxDecoration(
                      color: dim
                          ? theme.colorScheme.outlineVariant
                          : theme.colorScheme.secondary.withValues(alpha: active ? 1 : 0.85),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}