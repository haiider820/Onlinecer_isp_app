import 'package:flutter/material.dart';

import '../../core/theme/field_ops_design_tokens.dart';

/// Renders a connection-request / ticket status as a capsule badge using the
/// kit-standard semantic pairs (DESIGN.md Rule 4 + APP_BRIEF §4):
///  - Assigned:                 sky   (assigned bg/fg tokens)
///  - In-Progress:              amber (pending bg/fg tokens)
///  - Completed / Verified:     green (completed bg/fg tokens)
///  - Pending / Scheduled:      amber (pending bg/fg tokens)
///  - Urgent / Outage / Escal.: red   (urgent bg/fg tokens)
///  - Review:                   violet (review bg/fg tokens)
///
/// The badge always shows a dot + word, never colour alone. All colour
/// helpers are brightness-aware: pass [Brightness.dark] (from
/// `Theme.of(context).brightness`) to pick [FieldOpsDarkTokens], otherwise
/// the light [FieldOpsDesignTokens] are used. Unknown statuses fall back to
/// `onSurfaceVariant` ink on `surfaceContainerHighest`.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status, this.ticket = false});

  final String status;

  /// When true the badge maps the ticket lifecycle palette
  /// ([ticketColorForStatus]: open/resolved → green, in-progress →
  /// amber, closed → grey) instead of the request palette above.
  final bool ticket;

  static bool _isDark(Brightness brightness) =>
      brightness == Brightness.dark;

  /// Short sentence-case human label for a raw status enum, e.g.
  /// `installation_in_progress` → `In progress`. Strips lifecycle prefixes
  /// (`installation_` / `survey_` / `connection_`); unknown values fall back
  /// to underscores-as-spaces with only the first letter capitalised.
  static String labelFor(String status) {
    var s = status.trim().toLowerCase();
    for (final prefix in const [
      'installation_',
      'survey_',
      'connection_',
    ]) {
      if (s.startsWith(prefix)) {
        s = s.substring(prefix.length);
        break;
      }
    }
    const labels = <String, String>{
      'assigned': 'Assigned',
      'in_progress': 'In progress',
      'in progress': 'In progress',
      'pending': 'Pending',
      'scheduled': 'Scheduled',
      'completed': 'Completed',
      'done': 'Completed',
      'verified': 'Verified',
      'approved': 'Approved',
      'review': 'Needs review',
      'urgent': 'Urgent',
      'cancelled': 'Cancelled',
      'failed': 'Failed',
      'rejected': 'Rejected',
      'open': 'Open',
      'opened': 'Open',
      'resolved': 'Resolved',
      'closed': 'Closed',
      'waiting_customer': 'Waiting for customer',
      'waiting for customer': 'Waiting for customer',
    };
    final mapped = labels[s];
    if (mapped != null) return mapped;
    final spaced = s.replaceAll('_', ' ');
    if (spaced.isEmpty) return status;
    return spaced[0].toUpperCase() + spaced.substring(1);
  }

  static Color colorForStatus(String status,
      {Brightness brightness = Brightness.light}) {
    final dark = _isDark(brightness);
    final s = status.toLowerCase();
    if (s.contains('completed') ||
        s.contains('done') ||
        s.contains('approved') ||
        s.contains('verified')) {
      return dark
          ? FieldOpsDarkTokens.completedForeground
          : FieldOpsDesignTokens.completedForeground;
    }
    if (s.contains('urgent') ||
        s.contains('cancel') ||
        s.contains('reject') ||
        s.contains('failed')) {
      return dark
          ? FieldOpsDarkTokens.urgentForeground
          : FieldOpsDesignTokens.urgentForeground;
    }
    if (s.contains('review')) {
      return dark
          ? FieldOpsDarkTokens.reviewForeground
          : FieldOpsDesignTokens.reviewForeground;
    }
    // In-progress uses the AMBER pending pair (Haider's fixed system),
    // not the blue assigned pair.
    if (s.contains('pending') ||
        s.contains('scheduled') ||
        s.contains('in_progress') ||
        s.contains('in progress') ||
        s.contains('progress')) {
      return dark
          ? FieldOpsDarkTokens.pendingForeground
          : FieldOpsDesignTokens.pendingForeground;
    }
    if (s.contains('assigned')) {
      return dark
          ? FieldOpsDarkTokens.assignedForeground
          : FieldOpsDesignTokens.assignedForeground;
    }
    return dark
        ? FieldOpsDarkTokens.onSurfaceVariant
        : FieldOpsDesignTokens.onSurfaceVariant;
  }

  /// Soft background paired with the [colorForStatus] ink color.
  static Color backgroundForStatus(String status,
      {Brightness brightness = Brightness.light}) {
    final dark = _isDark(brightness);
    final s = status.toLowerCase();
    if (s.contains('completed') ||
        s.contains('done') ||
        s.contains('approved') ||
        s.contains('verified')) {
      return dark
          ? FieldOpsDarkTokens.completedBackground
          : FieldOpsDesignTokens.completedBackground;
    }
    if (s.contains('urgent') ||
        s.contains('cancel') ||
        s.contains('reject') ||
        s.contains('failed')) {
      return dark
          ? FieldOpsDarkTokens.urgentBackground
          : FieldOpsDesignTokens.urgentBackground;
    }
    if (s.contains('review')) {
      return dark
          ? FieldOpsDarkTokens.reviewBackground
          : FieldOpsDesignTokens.reviewBackground;
    }
    // In-progress uses the AMBER pending pair (Haider's fixed system),
    // not the blue assigned pair.
    if (s.contains('pending') ||
        s.contains('scheduled') ||
        s.contains('in_progress') ||
        s.contains('in progress') ||
        s.contains('progress')) {
      return dark
          ? FieldOpsDarkTokens.pendingBackground
          : FieldOpsDesignTokens.pendingBackground;
    }
    if (s.contains('assigned')) {
      return dark
          ? FieldOpsDarkTokens.assignedBackground
          : FieldOpsDesignTokens.assignedBackground;
    }
    return dark
        ? FieldOpsDarkTokens.surfaceContainerHighest
        : FieldOpsDesignTokens.surfaceContainerHighest;
  }

  /// Accent ink for a ticket lifecycle status: OPEN / RESOLVED → green,
  /// IN_PROGRESS / WAITING_CUSTOMER → amber, CLOSED → grey.
  static Color ticketColorForStatus(String status,
      {Brightness brightness = Brightness.light}) {
    final dark = _isDark(brightness);
    final s = status.toLowerCase();
    if (s.contains('closed')) {
      return dark
          ? FieldOpsDarkTokens.ticketClosedForeground
          : FieldOpsDesignTokens.ticketClosedForeground;
    }
    if (s.contains('completed') ||
        s.contains('approved') ||
        s.contains('verified')) {
      return dark
          ? FieldOpsDarkTokens.ticketOpenedForeground
          : FieldOpsDesignTokens.ticketOpenedForeground;
    }
    if (s.contains('urgent') ||
        s.contains('cancel') ||
        s.contains('reject') ||
        s.contains('failed')) {
      return dark
          ? FieldOpsDarkTokens.urgentForeground
          : FieldOpsDesignTokens.urgentForeground;
    }
    if (s.contains('in_progress') ||
        s.contains('in progress') ||
        s.contains('progress') ||
        s.contains('waiting')) {
      return dark
          ? FieldOpsDarkTokens.ticketInProgressForeground
          : FieldOpsDesignTokens.ticketInProgressForeground;
    }
    if (s.contains('opened') ||
        s.contains('open') ||
        s.contains('resolved')) {
      return dark
          ? FieldOpsDarkTokens.ticketOpenedForeground
          : FieldOpsDesignTokens.ticketOpenedForeground;
    }
    if (s.contains('assigned') ||
        s.contains('pending') ||
        s.contains('scheduled')) {
      return dark
          ? FieldOpsDarkTokens.assignedForeground
          : FieldOpsDesignTokens.assignedForeground;
    }
    return dark
        ? FieldOpsDarkTokens.ticketClosedForeground
        : FieldOpsDesignTokens.ticketClosedForeground;
  }

  /// Background tint that pairs with [ticketColorForStatus].
  static Color ticketBackgroundForStatus(String status,
      {Brightness brightness = Brightness.light}) {
    final dark = _isDark(brightness);
    final s = status.toLowerCase();
    if (s.contains('closed')) {
      return dark
          ? FieldOpsDarkTokens.ticketClosedBackground
          : FieldOpsDesignTokens.ticketClosedBackground;
    }
    if (s.contains('completed') ||
        s.contains('approved') ||
        s.contains('verified')) {
      return dark
          ? FieldOpsDarkTokens.ticketOpenedBackground
          : FieldOpsDesignTokens.ticketOpenedBackground;
    }
    if (s.contains('in_progress') ||
        s.contains('progress') ||
        s.contains('waiting')) {
      return dark
          ? FieldOpsDarkTokens.ticketInProgressBackground
          : FieldOpsDesignTokens.ticketInProgressBackground;
    }
    if (s.contains('urgent') ||
        s.contains('cancel') ||
        s.contains('reject') ||
        s.contains('failed')) {
      return dark
          ? FieldOpsDarkTokens.urgentBackground
          : FieldOpsDesignTokens.urgentBackground;
    }
    if (s.contains('opened') ||
        s.contains('open') ||
        s.contains('resolved')) {
      return dark
          ? FieldOpsDarkTokens.ticketOpenedBackground
          : FieldOpsDesignTokens.ticketOpenedBackground;
    }
    if (s.contains('assigned') ||
        s.contains('pending') ||
        s.contains('scheduled')) {
      return dark
          ? FieldOpsDarkTokens.assignedBackground
          : FieldOpsDesignTokens.assignedBackground;
    }
    return dark
        ? FieldOpsDarkTokens.ticketClosedBackground
        : FieldOpsDesignTokens.ticketClosedBackground;
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final color = ticket
        ? ticketColorForStatus(status, brightness: brightness)
        : colorForStatus(status, brightness: brightness);
    return Container(
      height: FieldOpsDesignTokens.badgeHeight,
      padding: const EdgeInsets.symmetric(
          horizontal: FieldOpsDesignTokens.badgePaddingH),
      decoration: BoxDecoration(
        color: ticket
            ? ticketBackgroundForStatus(status, brightness: brightness)
            : backgroundForStatus(status, brightness: brightness),
        borderRadius:
            BorderRadius.circular(FieldOpsDesignTokens.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Small status dot (6dp circle) + label, per the badge spec.
          Container(
            width: FieldOpsDesignTokens.badgeDotSize,
            height: FieldOpsDesignTokens.badgeDotSize,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              labelFor(status),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.04,
                fontFamily: FieldOpsDesignTokens.bodyFamily,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
