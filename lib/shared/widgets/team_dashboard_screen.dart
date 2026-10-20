import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../core/network/api_exceptions.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/field_ops_design_tokens.dart';
import '../../features/auth/presentation/providers.dart';
import '../../features/notifications/presentation/notification_providers.dart';
import '../../features/survey/presentation/dashboard_providers.dart';
import '../../models/dashboard.dart';
import '../../models/ticket.dart';
import 'branded_header.dart';
import 'ops_widgets.dart';
import 'request_card.dart';
import 'ticket_card.dart';

/// Shared logged-in dashboard for a functional team.
///
/// One dashboard per team type: same layout (employee header, stat row, recent
/// requests), different labels and navigation targets. Feature screens stay
/// thin parameterized wrappers; the data comes from the shared
/// [dashboardSummaryProvider] (`GET /dashboard`).
class TeamDashboardScreen extends ConsumerWidget {
  const TeamDashboardScreen({
    super.key,
    required this.featureName,
    required this.defaultEmployeeLabel,
    required this.defaultTeamLabel,
    this.pendingLabel = 'Pending',
    required this.viewAllLabel,
    required this.listRoute,
    this.detailRouteFor,
  });

  /// Short feature name used for the AppBar title, e.g. `'Splicing'`.
  ///
  /// Kept to a single short word on purpose: the AppBar also carries the brand
  /// logo, the notifications bell and the logout action, so a longer string
  /// such as 'Fiber Splicing Dashboard' ellipsised on 360dp phones.
  final String featureName;

  /// Placeholder label when the backend omits the employee name.
  final String defaultEmployeeLabel;

  /// Placeholder label when the backend omits the team name.
  final String defaultTeamLabel;

  /// Label for the pending-count tile; splicing uses "Pending Splicing".
  final String pendingLabel;

  /// Text of the bottom "View All" button, e.g. 'View All Survey Requests'.
  final String viewAllLabel;

  /// Route for the full request list (pushed, so the dashboard stays below it).
  final String listRoute;

  /// Concrete detail path for a given request id.
  final String Function(String id)? detailRouteFor;

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(dashboardSummaryProvider);
    await ref.read(dashboardSummaryProvider.future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(dashboardSummaryProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmLogout(context, ref);
      },
      child: Scaffold(
        // Branded header: logo, title, notifications bell, logout button.
        appBar: BrandedHeader(
          title: featureName,
          onLogout: () => _confirmLogout(context, ref),
          actions: [
            _NotificationBellAction(
              onTap: () => context.push(Routes.notifications),
            ),
          ],
        ),
        body: summary.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _ErrorView(
            message: e is ApiException ? e.message : 'Something went wrong.',
            onRetry: () => ref.invalidate(dashboardSummaryProvider),
          ),
          data: (data) => _DashboardBody(
            summary: data,
            onRefresh: () => _refresh(ref),
            onViewAll: () => context.push(listRoute),
            pendingLabel: pendingLabel,
            defaultEmployeeLabel: defaultEmployeeLabel,
            defaultTeamLabel: defaultTeamLabel,
            viewAllLabel: viewAllLabel,
            detailRouteFor: detailRouteFor,
            onTicketsTap: () => context.push(Routes.ticketsList),
            onNotificationsTap: () => context.push(Routes.notifications),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will be signed out and return to the login screen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      _logout(context, ref);
    }
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    await ref.read(secureStorageProvider).clearSession();
    ref.invalidate(dashboardSummaryProvider);
    if (context.mounted) context.go(Routes.login);
  }
}

/// Notification bell action in the shared dashboard header — shows an unread
/// dot only when there is at least one unread notification (driven by
/// [notificationUnreadCountProvider]).
class _NotificationBellAction extends ConsumerWidget {
  const _NotificationBellAction({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(notificationUnreadCountProvider);
    final hasUnread = (unread.valueOrNull ?? 0) > 0;

    return IconButton(
      tooltip: 'Notifications',
      onPressed: onTap,
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.notifications_outlined),
          if (hasUnread)
            Positioned(
              right: -2,
              top: -2,
              child: IgnorePointer(
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({
    required this.summary,
    required this.onRefresh,
    required this.onViewAll,
    required this.pendingLabel,
    required this.defaultEmployeeLabel,
    required this.defaultTeamLabel,
    required this.viewAllLabel,
    this.detailRouteFor,
    required this.onTicketsTap,
    required this.onNotificationsTap,
  });

  final DashboardSummary summary;
  final Future<void> Function() onRefresh;
  final VoidCallback onViewAll;
  final String pendingLabel;
  final String defaultEmployeeLabel;
  final String defaultTeamLabel;
  final String viewAllLabel;
  final String Function(String id)? detailRouteFor;
  final VoidCallback onTicketsTap;
  final VoidCallback onNotificationsTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final employee = summary.employee;
    final counts = summary.stats?.connectionRequests;
    final recent = summary.recentConnectionRequests ?? const [];
    final ticketCounts = summary.stats?.tickets;
    final recentTickets = (summary.recentTickets ?? const [])
        .whereType<Map>()
        .map((item) => Ticket.fromJson(Map<String, dynamic>.from(item)))
        .take(5)
        .toList(growable: false);

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
        children: [
          // ── Gradient greeting banner ──
          _GreetingBanner(
            employeeName: employee?.name ?? defaultEmployeeLabel,
            teamName: employee?.team?.name ?? defaultTeamLabel,
            onNotificationsTap: onNotificationsTap,
          ),

          // ── Stat cards: mono instrument readouts ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Row(
              children: [
                StatTile(
                  label: pendingLabel,
                  value: '${counts?.pending ?? 0}',
                  accent: true,
                ),
                const SizedBox(width: 10),
                StatTile(
                  label: 'Completed',
                  value: '${counts?.completed ?? 0}',
                ),
                const SizedBox(width: 10),
                StatTile(
                  label: 'Total',
                  value: '${counts?.total ?? 0}',
                ),
              ],
            ),
          ),

          // ── My Tickets strip ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: OpsCard(
              onTap: onTicketsTap,
              child: Row(children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    Icons.confirmation_number_outlined,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Tickets',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${ticketCounts?.pending ?? 0} open · ${ticketCounts?.total ?? 0} total',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ]),
            ),
          ),

          // ── Recent tickets ──
          if (recentTickets.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Tickets',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextButton(
                    onPressed: onTicketsTap,
                    child: const Text('View All'),
                  ),
                ],
              ),
            ),
            for (final ticket in recentTickets)
              TicketCard(
                ticket: ticket,
                onTap: () => context.push(Routes.ticketDetailFor(ticket.id)),
              ),
          ],

          // ── Recent Requests ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Text(
                  'Recent Requests',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                // Count badge.
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: FieldOpsDesignTokens.secondaryFixed,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${recent.length}',
                    style: TextStyle(
                      color: FieldOpsDesignTokens.onSecondaryFixed,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
                const Spacer(),
                TextButton(onPressed: onViewAll, child: const Text('View All')),
              ],
            ),
          ),

          if (recent.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              child: Column(
                children: [
                  SizedBox(
                    height: 120,
                    width: 120,
                    child: Lottie.asset(
                      'assets/lottie/empty_list.json',
                      repeat: true,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No requests assigned yet.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          else
            for (final request in recent.take(3))
              RequestCard(
                request: request,
                onTap: detailRouteFor == null
                    ? null
                    : () => context.push(detailRouteFor!(request.id)),
              ),

          // ── View All button ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: OutlinedButton.icon(
              onPressed: onViewAll,
              icon: const Icon(Icons.list_alt),
              label: Text(viewAllLabel),
            ),
          ),
        ],
      ),
    );
  }
}

/// Midnight Ops hero: night gradient, glow orbs, gradient avatar, greeting,
/// team line and a live GPS ribbon.
class _GreetingBanner extends StatelessWidget {
  const _GreetingBanner({
    required this.employeeName,
    required this.teamName,
    required this.onNotificationsTap,
  });

  final String employeeName;
  final String teamName;
  final VoidCallback onNotificationsTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark
              ? const [Color(0xFF0A1230), Color(0xFF05080F)]
              : const [Color(0xFF0E3A52), Color(0xFF0B1220)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -60,
            right: -40,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withValues(alpha: 0.25),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  OpsAvatar(
                    initials: OpsAvatar.initialsOf(employeeName),
                    size: 52,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          greeting,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color:
                                Colors.white.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          employeeName,
                          style: FieldOpsDesignTokens.headlineMd
                              .copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.work_outline,
                    size: 15,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      teamName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Live GPS ribbon.
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.14),
                  ),
                ),
                child: Row(
                  children: [
                    PulseDot(color: const Color(0xFF34D399)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'GPS SIGNAL ACTIVE',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                    Text(
                      '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                      style: FieldOpsDesignTokens.dataSm.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ],
        ),
      ),
    );
  }
}