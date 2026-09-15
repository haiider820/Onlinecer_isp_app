import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exceptions.dart';
import '../../../core/theme/field_ops_design_tokens.dart';
import '../../../models/ticket.dart';
import '../../../shared/widgets/branded_header.dart';
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

              // ── Activity timeline ──
              SectionCard(
                title: 'Activity',
                icon: Icons.timeline_outlined,
                children: [
                  if (detail.activities.isEmpty)
                    Text('No activity recorded yet.', style: theme.textTheme.bodySmall)
                  else
                    _Timeline(activities: detail.activities),
                ],
              ),
            ],
          ),
        ),
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

/// Vertical activity timeline with a 1px connecting rail.
class _Timeline extends StatelessWidget {
  const _Timeline({required this.activities});

  final List<TicketActivity> activities;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < activities.length; i++)
          _TimelineRow(
            activity: activities[i],
            isLast: i == activities.length - 1,
          ),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.activity, required this.isLast});

  final TicketActivity activity;
  final bool isLast;

  Color _barColor(BuildContext context) {
    final theme = Theme.of(context);
    return activity.isStatusChange
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant;
  }

  @override
  Widget build(BuildContext context) {
    final barColor = _barColor(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      // IntrinsicHeight gives the Row a finite height so the rail's
      // CrossAxisAlignment.stretch can resolve. Without it the Row (which
      // lives inside an unbounded-height scroll column) would be laid out
      // with an infinite height constraint and throw every frame.
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 4,
              child: Container(color: barColor),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ActivityEntry(activity: activity, barColor: barColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityEntry extends StatelessWidget {
  const _ActivityEntry({required this.activity, required this.barColor});
  final TicketActivity activity;
  final Color barColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final author = activity.author;
    final isStatus = activity.isStatusChange;
    final bgColor = isStatus
        ? theme.colorScheme.primary.withValues(alpha: 0.06)
        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius:
            BorderRadius.circular(FieldOpsDesignTokens.radiusMd),
        border: Border.all(color: barColor.withValues(alpha: 0.2)),
        boxShadow: FieldOpsDesignTokens.shadowLevel1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: barColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isStatus ? Icons.refresh : Icons.notes_outlined,
                  size: 13,
                  color: barColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isStatus) ...[
                      Text(
                        'Status changed',
                        style:
                            theme.textTheme.labelLarge?.copyWith(color: barColor),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          if (activity.oldValue != null)
                            StatusBadge(status: activity.oldValue!, ticket: true),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_forward,
                            size: 12,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          if (activity.newValue != null)
                            StatusBadge(status: activity.newValue!, ticket: true),
                        ],
                      ),
                    ] else if (activity.message?.isNotEmpty == true)
                      Text(activity.message!),
                    if (activity.isInternal)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          'Internal note',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (author != null || activity.createdAt != null) ...[
            const SizedBox(height: 6),
            Text(
              [if (author != null) author,
                      if (activity.createdAt != null) activity.createdAt!]
                  .join(' · '),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
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