import 'package:flutter/material.dart';

import '../../core/theme/field_ops_design_tokens.dart';
import '../../models/ticket.dart';
import 'status_badge.dart';

/// Ticket summary card matching the stitch ticket-list mockup:
///  - header row: ticket number + priority pill (error-tint for HIGH) + status
///    pill (secondary-fixed tint for IN PROGRESS);
///  - issue title, customer/sector metadata, category band and timestamp;
///  - trailing call quick-action.
class TicketCard extends StatelessWidget {
  const TicketCard({
    super.key,
    required this.ticket,
    this.onTap,
    this.onCall,
  });

  final Ticket ticket;
  final VoidCallback? onTap;

  /// Callback for the call quick-action; `null` disables the button.
  final VoidCallback? onCall;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final priority = ticket.priority;
    final status = ticket.status;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(FieldOpsDesignTokens.cardRadius),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: FieldOpsDesignTokens.shadowLevel1,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ticket number.
              Row(
                children: [
                  Expanded(
                    child: Text(
                      ticket.ticketNumber ?? 'Ticket',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              // Subject / title line.
              if (ticket.subject?.isNotEmpty == true) ...[
                const SizedBox(height: 10),
                Text(
                  ticket.subject!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
              // Priority + status badges, side by side beneath the title.
              if (priority != null || status != null) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    if (priority != null) ...[
                      _PriorityPill(priority: priority),
                      const SizedBox(width: 6),
                    ],
                    if (status != null) StatusBadge(status: status, ticket: true),
                  ],
                ),
              ],
              if (ticket.customerName?.isNotEmpty == true) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 15,
                      color: theme.colorScheme.outline,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        ticket.customerName!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (ticket.updatedAt?.isNotEmpty == true) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 14,
                      color: theme.colorScheme.outline,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _agoLabel(ticket.updatedAt!),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    const Spacer(),
                    // Call quick-action (48dp touch target, primary-ghost).
                    IconButton(
                      tooltip: 'Call about ticket',
                      onPressed: onCall,
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.call_outlined, size: 20),
                      color: theme.colorScheme.secondary,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Compact human label for an ISO/backend timestamp string; falls back to
  /// the raw value when the format isn't recognised.
  static String _agoLabel(String raw) {
    final date = DateTime.tryParse(raw);
    if (date == null) return raw;
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return 'Updated $raw';
  }
}

/// Compact priority pill using the DESIGN.md urgent/amber/neutral inks.
class _PriorityPill extends StatelessWidget {
  const _PriorityPill({required this.priority});

  final String priority;

  @override
  Widget build(BuildContext context) {
    final lower = priority.toLowerCase();
    final urgent = lower.contains('high') || lower.contains('urgent') || lower.contains('critical');
    final medium = lower.contains('medium') || lower.contains('normal') || lower.contains('low');
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
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(FieldOpsDesignTokens.radiusFull),
      ),
      alignment: Alignment.center,
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