import 'package:flutter/material.dart';

import '../../core/theme/field_ops_design_tokens.dart';

/// Renders a connection-request / ticket status as a capsule badge using the
/// four-color semantic map from DESIGN.md:
///  - Assigned / In-Progress:   soft blue   (#EBF2FE / #1D4ED8)
///  - Completed / Verified:     soft green  (#E8F8F0 / #0D7A4A)
///  - Pending / Scheduled:      soft amber  (#FEF3C7 / #B45309)
///  - Urgent / Outage / Escal.: soft red    (#FEE2E2 / #B91C1C)
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status, this.ticket = false});

  final String status;

  /// When true the badge maps the ticket lifecycle palette
  /// ([ticketColorForStatus]: open/resolved → green, in-progress →
  /// amber, closed → grey) instead of the request palette above.
  final bool ticket;

  static Color colorForStatus(String status) {
    final s = status.toLowerCase();
    if (s.contains('completed') || s.contains('approved') || s.contains('verified')) {
      return FieldOpsDesignTokens.completedForeground;
    }
    if (s.contains('urgent') || s.contains('cancel') || s.contains('reject') || s.contains('failed')) {
      return FieldOpsDesignTokens.urgentForeground;
    }
    if (s.contains('pending') || s.contains('assigned')) {
      return FieldOpsDesignTokens.assignedForeground;
    }
    return const Color(0xFF475569);
  }

  /// Soft background paired with the [colorForStatus] ink color.
  static Color backgroundForStatus(String status) {
    final s = status.toLowerCase();
    if (s.contains('completed') || s.contains('approved') || s.contains('verified')) {
      return FieldOpsDesignTokens.completedBackground;
    }
    if (s.contains('urgent') || s.contains('cancel') || s.contains('reject') || s.contains('failed')) {
      return FieldOpsDesignTokens.urgentBackground;
    }
    if (s.contains('pending') || s.contains('assigned')) {
      return FieldOpsDesignTokens.assignedBackground;
    }
    return const Color(0xFFF1F5F9);
  }

  /// Accent ink for a ticket lifecycle status: OPEN / RESOLVED → green,
  /// IN_PROGRESS / WAITING_CUSTOMER → amber, CLOSED → grey.
  static Color ticketColorForStatus(String status) {
    final s = status.toLowerCase();
    if (s.contains('closed')) {
      return FieldOpsDesignTokens.ticketClosedForeground;
    }
    if (s.contains('completed') || s.contains('approved') || s.contains('verified')) {
      return FieldOpsDesignTokens.ticketOpenedForeground;
    }
    if (s.contains('urgent') || s.contains('cancel') || s.contains('reject') || s.contains('failed')) {
      return FieldOpsDesignTokens.urgentForeground;
    }
    if (s.contains('in_progress') || s.contains('in progress') || s.contains('progress') ||
        s.contains('waiting')) {
      return FieldOpsDesignTokens.ticketInProgressForeground;
    }
    if (s.contains('opened') || s.contains('open') || s.contains('resolved')) {
      return FieldOpsDesignTokens.ticketOpenedForeground;
    }
    if (s.contains('assigned') || s.contains('pending') || s.contains('scheduled')) {
      return FieldOpsDesignTokens.assignedForeground;
    }
    return FieldOpsDesignTokens.ticketClosedForeground;
  }

  /// Background tint that pairs with [ticketColorForStatus].
  static Color ticketBackgroundForStatus(String status) {
    final s = status.toLowerCase();
    if (s.contains('closed')) {
      return FieldOpsDesignTokens.ticketClosedBackground;
    }
    if (s.contains('completed') || s.contains('approved') || s.contains('verified')) {
      return FieldOpsDesignTokens.ticketOpenedBackground;
    }
    if (s.contains('in_progress') || s.contains('progress') || s.contains('waiting')) {
      return FieldOpsDesignTokens.ticketInProgressBackground;
    }
    if (s.contains('urgent') || s.contains('cancel') || s.contains('reject') || s.contains('failed')) {
      return FieldOpsDesignTokens.urgentBackground;
    }
    if (s.contains('assigned') || s.contains('pending') || s.contains('scheduled')) {
      return FieldOpsDesignTokens.assignedBackground;
    }
    return FieldOpsDesignTokens.ticketClosedBackground;
  }

  @override
  Widget build(BuildContext context) {
    final color = ticket ? ticketColorForStatus(status) : colorForStatus(status);
    return Container(
      height: FieldOpsDesignTokens.badgeHeight,
      padding: const EdgeInsets.symmetric(horizontal: FieldOpsDesignTokens.badgePaddingH),
      decoration: BoxDecoration(
        color: ticket
            ? ticketBackgroundForStatus(status)
            : backgroundForStatus(status),
        borderRadius: BorderRadius.circular(FieldOpsDesignTokens.radiusFull),
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
          Text(
            status.replaceAll('_', ' ').toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.04,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}