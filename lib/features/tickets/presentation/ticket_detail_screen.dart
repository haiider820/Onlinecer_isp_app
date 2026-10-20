import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exceptions.dart';
import '../../../core/theme/field_ops_design_tokens.dart';
import '../../../models/ticket.dart';
import '../../../shared/widgets/branded_header.dart';
import '../../../shared/widgets/ops_widgets.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../survey/presentation/dashboard_providers.dart';
import 'ticket_providers.dart';

/// One ticket's full detail (`GET /tickets/{id}`), matching the stitch
/// ticket-detail mockup: branded header, ticket banner (number + title +
/// priority/status pills), details card, and a left-rail activity timeline.
///
/// The "Advance to {next}" action is preserved verbatim (label, dialog, note
/// limit, invalidations) — the backend drives the allowed next status.
class TicketDetailScreen extends ConsumerStatefulWidget {
  const TicketDetailScreen({super.key, required this.ticketId});
  final String ticketId;

  @override
  ConsumerState<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends ConsumerState<TicketDetailScreen> {
  bool _isAdvancing = false;

  Future<void> _startAdvance(TicketDetail detail) async {
    if (_isAdvancing) return;
    setState(() => _isAdvancing = true);

    final note = await _showAdvanceDialog();
    if (!mounted) return;
    if (note == null) {
      setState(() => _isAdvancing = false);
      return;
    }
    if (note.length > 2000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('The note must be 2,000 characters or fewer.')),
      );
      setState(() => _isAdvancing = false);
      return;
    }

    try {
      final result = await ref
          .read(ticketRepositoryProvider)
          .advance(detail.ticket.id, note: note.trim().isEmpty ? null : note);
      if (!mounted) return;
      final status = result.status ?? detail.nextStatus ?? 'the next status';
      // Floating above the bottom action shelf so an advance confirmation never
      // covers the next available action.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 92),
          content: Text('Ticket advanced to ${status.replaceAll('_', ' ')}.'),
        ),
      );
      ref.invalidate(ticketDetailProvider(widget.ticketId));
      ref.invalidate(dashboardSummaryProvider);
      ref.read(ticketListRefreshProvider.notifier).state++;
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not advance ticket. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isAdvancing = false);
    }
  }

  Future<String?> _showAdvanceDialog() async {
    final controller = TextEditingController();
    final note = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Advance ticket'),
        content: TextField(
          controller: controller,
          autofocus: true,
          minLines: 3,
          maxLines: 5,
          maxLength: 2000,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Note (optional)',
            alignLabelWithHint: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    controller.dispose();
    return note;
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(ticketDetailProvider(widget.ticketId));
    return Scaffold(
      appBar: BrandedHeader(
        title: 'Ticket Details',
        onBack: () => context.pop(),
      ),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorView(
          message: error is ApiException ? error.message : 'Could not load ticket.',
          onRetry: () => ref.invalidate(ticketDetailProvider(widget.ticketId)),
        ),
        data: (ticket) => _TicketDetailBody(
          detail: ticket,
          isAdvancing: _isAdvancing,
          onAdvance: () => _startAdvance(ticket),
        ),
      ),
    );
  }
}

class _TicketDetailBody extends StatelessWidget {
  const _TicketDetailBody({
    required this.detail,
    required this.isAdvancing,
    required this.onAdvance,
  });
  final TicketDetail detail;
  final bool isAdvancing;
  final VoidCallback onAdvance;

  @override
  Widget build(BuildContext context) {
    final ticket = detail.ticket;
    final theme = Theme.of(context);
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              // ── Ticket banner ──
              _TicketBanner(ticket: ticket),

              // ── Details card ──
              SectionCard(
                title: 'Details',
                icon: Icons.description_outlined,
                children: [
                  if (detail.description?.isNotEmpty == true)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        detail.description!,
                        style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                      ),
                    ),
                  if (detail.customerName != null) InfoRow(label: 'Customer', value: detail.customerName!),
                  if (detail.category != null) InfoRow(label: 'Category', value: detail.category!),
                  if (detail.channel != null) InfoRow(label: 'Channel', value: detail.channel!),
                  if (detail.assignedTeam != null) InfoRow(label: 'Assigned team', value: detail.assignedTeam!),
                ],
              ),

              // ── Discussion thread ──
              _DiscussionSection(detail: detail),
            ],
          ),
        ),
        // ── Sticky composer ──
        _DiscussionComposer(),

        // ── Advance action shelf ──
        if (detail.nextStatus != null)
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
                    onPressed: isAdvancing ? null : onAdvance,
                    icon: isAdvancing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.arrow_forward),
                    label: Text(
                      'Advance to ${detail.nextStatus!.replaceAll('_', ' ')}',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Header banner: priority + status pills, ticket number, issue title.
class _TicketBanner extends StatelessWidget {
  const _TicketBanner({required this.ticket});

  final Ticket ticket;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      width: double.infinity,
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
          Text(
            ticket.ticketNumber ?? ticket.id,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            ticket.subject ?? 'Ticket',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          // Priority + status sit on one line beneath the subject so the pair
          // reads as a single meta row instead of stacking vertically.
          Row(
            children: [
              if (ticket.priority != null) _PriorityBadge(priority: ticket.priority!),
              if (ticket.priority != null && ticket.status != null)
                const SizedBox(width: 8),
              if (ticket.status != null) StatusBadge(status: ticket.status!, ticket: true),
            ],
          ),
        ],
      ),
    );
  }
}

/// Chat-style discussion thread replacing the old activity timeline.
///
/// Maps each [TicketActivity] onto a thread item:
///  - status change → tiny "Status changed" caption + centered glowing
///    [SystemPill] ("OPEN → IN_PROGRESS · 09:00"),
///  - internal note → violet dashed [InternalNoteCard],
///  - message → [ChatBubble] (right-aligned + cyan-tinted when the author is
///    the signed-in technician).
///
/// Filter chips (All / Messages / Status / Internal) filter the rendered list
/// locally; no backend query changes.
class _DiscussionSection extends ConsumerStatefulWidget {
  const _DiscussionSection({required this.detail});

  final TicketDetail detail;

  @override
  ConsumerState<_DiscussionSection> createState() =>
      _DiscussionSectionState();
}

class _DiscussionSectionState extends ConsumerState<_DiscussionSection> {
  String _filter = 'all';

  static const _options = [
    FilterOption('all', 'All'),
    FilterOption('messages', 'Messages'),
    FilterOption('status', 'Status'),
    FilterOption('internal', 'Internal'),
  ];

  bool _visible(TicketActivity a) => switch (_filter) {
        'messages' => !a.isStatusChange && !a.isInternal,
        'status' => a.isStatusChange,
        'internal' => a.isInternal,
        _ => true,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activities =
        widget.detail.activities.where(_visible).toList(growable: false);
    // The signed-in technician's name, for right-aligning their own messages.
    final myName =
        ref.watch(dashboardSummaryProvider).valueOrNull?.employee?.name;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.forum_outlined,
                size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Discussion',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        FilterChips(
          options: [
            for (final o in _options)
              FilterOption(
                o.value,
                o.label,
                widget.detail.activities
                    .where((a) => o.value == 'all' ? true : _matches(o.value, a))
                    .length,
              ),
          ],
          selected: _filter,
          onSelected: (v) => setState(() => _filter = v),
        ),
        const SizedBox(height: 14),
        if (activities.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text('No activity recorded yet.',
                style: theme.textTheme.bodySmall),
          )
        else
          for (var i = 0; i < activities.length; i++) ...[
            _ThreadItem(
              activity: activities[i],
              isMine: myName != null &&
                  activities[i].author != null &&
                  activities[i].author == myName,
            ),
            if (i < activities.length - 1) const SizedBox(height: 12),
          ],
      ],
    );
  }

  static bool _matches(String filter, TicketActivity a) => switch (filter) {
        'messages' => !a.isStatusChange && !a.isInternal,
        'status' => a.isStatusChange,
        'internal' => a.isInternal,
        _ => true,
      };
}

/// One activity rendered as a chat-thread item.
class _ThreadItem extends StatelessWidget {
  const _ThreadItem({required this.activity, required this.isMine});

  final TicketActivity activity;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final time = _timeLabel(activity.createdAt);

    if (activity.isStatusChange) {
      final old = activity.oldValue ?? '—';
      final newValue = activity.newValue ?? '—';
      return Column(
        children: [
          // Exact string kept: existing tests assert find.text('Status changed').
          Text(
            'Status changed',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          SystemPill(text: '$old → $newValue', timeLabel: time),
        ],
      );
    }

    if (activity.isInternal) {
      return InternalNoteCard(
        message: activity.message ?? '',
        author: activity.author ?? 'Staff',
        timeLabel: time,
      );
    }

    return ChatBubble(
      message: activity.message ?? '',
      author: activity.author ?? 'Unknown',
      timeLabel: time,
      isMine: isMine,
    );
  }

  /// 'HH:MM' from an ISO timestamp; falls back to the raw value.
  static String _timeLabel(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    final local = parsed.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }
}

/// Sticky bottom composer for the discussion thread.
///
/// There is no backend post endpoint for discussion notes on this screen, so
/// every action currently explains itself with a SnackBar instead of
/// inventing an API call.
class _DiscussionComposer extends StatefulWidget {
  const _DiscussionComposer();

  @override
  State<_DiscussionComposer> createState() => _DiscussionComposerState();
}

class _DiscussionComposerState extends State<_DiscussionComposer> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _soon(String what) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$what coming soon')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return OpsComposer(
      controller: _controller,
      hintText: 'Write a note…',
      onAttach: () => _soon('Attachments'),
      onMic: () => _soon('Voice notes'),
      onSend: () => _soon('Notes posting'),
    );
  }
}

/// Compact priority pill using the DESIGN.md urgent/amber/neutral inks.
class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({required this.priority});
  final String priority;
  @override
  Widget build(BuildContext context) {
    final lower = priority.toLowerCase();
    final urgent = lower.contains('high') ||
        lower.contains('urgent') ||
        lower.contains('critical');
    final medium = lower.contains('medium') ||
        lower.contains('normal') ||
        lower.contains('low');
    final bg = urgent
        ? FieldOpsDesignTokens.urgentBackground
        : medium
            ? FieldOpsDesignTokens.pendingBackground
            : const Color(0xFFF1F5F9);
    final fg = urgent
        ? FieldOpsDesignTokens.urgentForeground
        : medium
            ? FieldOpsDesignTokens.pendingForeground
            : const Color(0xFF475569);
    return Container(
      height: FieldOpsDesignTokens.badgeHeight,
      padding: const EdgeInsets.symmetric(horizontal: FieldOpsDesignTokens.badgePaddingH),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(FieldOpsDesignTokens.radiusFull),
        border: Border.all(color: fg.withValues(alpha: 0.25)),
      ),
      child: Text(
        priority.toUpperCase(),
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.04,
          fontFamily: 'Inter',
        ),
      ),
    );
  }
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