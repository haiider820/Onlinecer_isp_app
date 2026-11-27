import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/network/api_exceptions.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/field_ops_design_tokens.dart';
import '../../core/theme/theme_mode_provider.dart';
import '../../features/auth/presentation/providers.dart';
import '../../features/dashboard/presentation/dashboard_tiles_providers.dart';
import '../../features/lookups/presentation/sub_branch_providers.dart';
import '../../features/notifications/presentation/notification_providers.dart';
import '../../features/survey/presentation/dashboard_providers.dart';
import '../../models/connection_request.dart';
import '../../models/dashboard.dart';
import 'branded_header.dart';
import 'ops_widgets.dart';

/// Shared logged-in dashboard for a functional team.
///
/// D20 layout (approved 2026-11-27, per the 3rd reference screenshot):
/// a compact header (employee name + team, settings gear, logout), five
/// count tiles (Connection Flow, My Tickets, Inventory Items, Waiting ONUs,
/// ONU Authorization) and one primary "+ New request" button. No greeting
/// hero, no GPS strip, no stat row, no Recent Requests — the team's queue
/// stays reachable through the tiles (see [_DashboardBody] for the exact
/// per-tile target). The data comes from the tile providers
/// (`dashboard_tiles_providers.dart`), one endpoint per tile; the header
/// still comes from the shared [dashboardSummaryProvider]
/// (`GET /dashboard`).
///
/// D22 (2026-11-27, Haider's UI fixes — layout only, no data/logic
/// change): the tile count+label sits in a fixed-width (88dp) centered
/// column with an ellipsized title; all action icons are grouped in the
/// app bar (theme, bell, settings) and logout moved into the settings
/// sheet (same confirmation dialog); the "+ New request" button is pinned
/// at the bottom; the team subtitle uses the stronger `subtitleStrong`
/// tone; the logo renders at 32dp tall.
class TeamDashboardScreen extends ConsumerWidget {
  const TeamDashboardScreen({
    super.key,
    required this.featureName,
    required this.defaultEmployeeLabel,
    required this.defaultTeamLabel,
    required this.listRoute,
    this.detailRouteFor,
    this.showNewRequest = false,
  });

  /// Short feature name used for the AppBar title, e.g. `'Splicing'`.
  ///
  /// Kept to a single short word on purpose: the AppBar also carries the brand
  /// logo, the notifications bell and the theme toggle, so a longer string
  /// such as 'Fiber Splicing Dashboard' ellipsised on 360dp phones.
  final String featureName;

  /// Placeholder label when the backend omits the employee name.
  final String defaultEmployeeLabel;

  /// Placeholder label when the backend omits the team name.
  final String defaultTeamLabel;

  /// Route for the full request list (pushed, so the dashboard stays below it).
  final String listRoute;

  /// Concrete detail path for a given request id.
  final String Function(String id)? detailRouteFor;

  /// Show the "New request" entry (ISPFINAL Phase C). Survey team only:
  /// a new request always starts at survey, so other teams never see it.
  final bool showNewRequest;

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(dashboardSummaryProvider);
    ref.invalidate(dashboardTeamFlowCountProvider);
    ref.invalidate(dashboardOpenTicketCountProvider);
    ref.invalidate(dashboardInventoryCountProvider);
    ref.invalidate(dashboardWaitingOnuCountProvider);
    ref.invalidate(dashboardPendingAuthorizationProvider);
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
        // Branded header: logo, title, and ALL action icons grouped on the
        // right (D22) — theme toggle, notifications bell, settings. No
        // logout action here: logout lives inside the settings sheet, and
        // the D20 compact header below no longer carries its own icons.
        appBar: BrandedHeader(
          title: featureName,
          brandMarkHeight: 32,
          actions: [
            _ThemeToggleAction(),
            _NotificationBellAction(
              onTap: () => context.push(Routes.notifications),
            ),
            IconButton(
              tooltip: 'Settings',
              onPressed: () => _showSettingsSheet(
                context,
                onLogout: () => _confirmLogout(context, ref),
              ),
              icon: const Icon(Icons.settings_outlined),
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
            onNewRequest: showNewRequest
                ? () => context.push(Routes.newRequest)
                : null,
            listRoute: listRoute,
            detailRouteFor: detailRouteFor,
            defaultEmployeeLabel: defaultEmployeeLabel,
            defaultTeamLabel: defaultTeamLabel,
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
        content: const Text(
          'You will be signed out and return to the login screen.',
        ),
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
    // Phase B: a stale sub-branch scope must not survive into the next
    // employee's session.
    invalidateSubBranchState(ref);
    ref.invalidate(dashboardSummaryProvider);
    if (context.mounted) context.go(Routes.login);
  }
}

/// Theme toggle in the shared dashboard header — cycles system → light →
/// dark. The choice is persisted by [ThemeModeNotifier].
class _ThemeToggleAction extends ConsumerWidget {
  const _ThemeToggleAction();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final icon = switch (mode) {
      ThemeMode.light => Icons.light_mode_outlined,
      ThemeMode.dark => Icons.dark_mode_outlined,
      ThemeMode.system => Icons.brightness_auto_outlined,
    };
    final label = switch (mode) {
      ThemeMode.light => 'Theme: light (tap for dark)',
      ThemeMode.dark => 'Theme: dark (tap for system)',
      ThemeMode.system => 'Theme: system (tap for light)',
    };
    return IconButton(
      tooltip: label,
      onPressed: () => ref.read(themeModeProvider.notifier).cycle(),
      icon: Icon(icon),
    );
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

/// D20 dashboard body: compact header + five count tiles + one primary
/// "+ New request" button. No Recent Requests section (removed 2026-11-27
/// on Haider's word) — the queue stays reachable through the tiles:
///
/// * Connection Flow → the team's request list ([listRoute]) (D23:
///   it used to open the New Request form on the survey team; the
///   create flow lives on the pinned "+ New request" button now).
///   NOTE: the list is stage-scoped, so the survey list can be empty
///   while the tile says 2 Available — existing list behaviour, not
///   something the tile change creates.
/// * My Tickets → the tickets list.
/// * Inventory Items → the team's request list. GAP: no standalone
///   inventory-catalog screen exists yet (see D20) — inventory is reached
///   from a request's installation detail/form.
/// * Waiting ONUs → the OLT list for the first request awaiting
///   authorization (the waiting-ONU list is request-scoped, there is no
///   global waiting-ONU screen — see D20); with no pending request, the
///   team's request list.
/// * ONU Authorization → the first awaiting request's (stage-aware) detail,
///   which carries the Authorize ONU entry; with no pending request, the
///   team's request list.
class _DashboardBody extends ConsumerWidget {
  const _DashboardBody({
    required this.summary,
    required this.onRefresh,
    this.onNewRequest,
    required this.listRoute,
    this.detailRouteFor,
    required this.defaultEmployeeLabel,
    required this.defaultTeamLabel,
  });

  final DashboardSummary summary;
  final Future<void> Function() onRefresh;

  /// Opens the create-request form (ISPFINAL Phase C). `null` on teams
  /// that never create requests — the button is then not rendered at all.
  /// The Connection Flow tile no longer uses this (D23: it always opens
  /// the team's request list); only the pinned "+ New request" button
  /// calls it.
  final VoidCallback? onNewRequest;
  final String listRoute;
  final String Function(String id)? detailRouteFor;
  final String defaultEmployeeLabel;
  final String defaultTeamLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employee = summary.employee;
    final pendingAuth = ref.watch(dashboardPendingAuthorizationProvider);
    final firstPending = _firstInstallationAssigned(pendingAuth.valueOrNull);

    // D22: the cards scroll in a ListView inside an Expanded, and the
    // "+ New request" button is pinned at the bottom of the dashboard's
    // own layout (SafeArea + 16dp margins, kit Rule 12). The dashboard
    // is NOT inside a bottom-nav shell — DashboardShell only dispatches
    // to the team's screen — so no second bottom bar can clash with it.
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: onRefresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: 24,
              ),
              children: [
                // ── Compact header: name + team only (D22) ──
                // The settings gear and logout moved to the app bar /
                // settings sheet, so this is just the employee identity.
                _CompactHeader(
                  employeeName: employee?.name ?? defaultEmployeeLabel,
                  teamName: employee?.team?.name ?? defaultTeamLabel,
                ),
                const SizedBox(height: 16),

                // ── Connection Flow ──
                _DashboardTile(
                  title: 'Connection Flow',
                  icon: Icons.link,
                  style: const _TileStyle(
                    light: Color(0xFF2563EB),
                    dark: Color(0xFF60A5FA),
                  ),
                  count: ref.watch(dashboardTeamFlowCountProvider),
                  label: 'Available',
                  // D23: always the team's request list. The tile used to
                  // open the New Request form when the team could create
                  // (survey); the create flow lives on the pinned
                  // "+ New request" button now, so the tile shows the
                  // queue it counts.
                  onTap: () => context.push(listRoute),
                ),
                const SizedBox(height: 10),

                // ── My Tickets ──
                _DashboardTile(
                  title: 'My Tickets',
                  icon: Icons.confirmation_number_outlined,
                  style: const _TileStyle(
                    light: Color(0xFF16A34A),
                    dark: Color(0xFF4ADE80),
                  ),
                  count: ref.watch(dashboardOpenTicketCountProvider),
                  label: 'Open',
                  onTap: () => context.push(Routes.ticketsList),
                ),
                const SizedBox(height: 10),

                // ── Inventory Items ──
                _DashboardTile(
                  title: 'Inventory Items',
                  icon: Icons.layers_outlined,
                  style: const _TileStyle(
                    light: Color(0xFF7C3AED),
                    dark: Color(0xFFA78BFA),
                  ),
                  count: ref.watch(dashboardInventoryCountProvider),
                  label: 'Total',
                  onTap: () => context.push(listRoute),
                ),
                const SizedBox(height: 10),

                // ── Waiting ONUs ──
                _DashboardTile(
                  title: 'Waiting ONUs',
                  icon: Icons.router_outlined,
                  style: const _TileStyle(
                    light: Color(0xFFD97706),
                    dark: Color(0xFFFBBF24),
                  ),
                  count: ref.watch(dashboardWaitingOnuCountProvider),
                  label: 'Waiting',
                  onTap: () {
                    if (firstPending != null) {
                      context.push(Routes.oltListFor(firstPending.id));
                    } else {
                      context.push(listRoute);
                    }
                  },
                ),
                const SizedBox(height: 10),

                // ── ONU Authorization ──
                _DashboardTile(
                  title: 'ONU Authorization',
                  icon: Icons.shield_outlined,
                  style: const _TileStyle(
                    light: Color(0xFFDC2626),
                    dark: Color(0xFFF87171),
                  ),
                  count: pendingAuth.whenData(
                    (page) => page.meta.total ?? page.data.length,
                  ),
                  label: 'Pending',
                  onTap: () {
                    if (firstPending != null && detailRouteFor != null) {
                      context.push(
                        Routes.detailRouteForRequest(
                          firstPending,
                          detailRouteFor!,
                        ),
                      );
                    } else {
                      context.push(listRoute);
                    }
                  },
                ),
              ],
            ),
          ),
        ),

        // ── New request (ISPFINAL Phase C, survey team only) ──
        // Pinned at the bottom (D22): the dashboard's one primary button
        // (kit Rule 3 + Rule 12) — sky fill with dark-navy ink, never
        // white on sky. It no longer scrolls away with the tiles, so the
        // empty space below it in the D20 layout is gone.
        if (onNewRequest != null)
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: onNewRequest,
                  icon: const Icon(Icons.add),
                  label: const Text('New request'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF5BC0DE),
                    foregroundColor: const Color(0xFF0B132B),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// First `installation_assigned` row of the pending-authorization page, or
/// `null` when the page is not loaded yet or holds no such row. The
/// Waiting ONUs / ONU Authorization tiles navigate through this request —
/// the OLT list and the authorize flow are both request-scoped, so there
/// is no request-free target for them.
ConnectionRequest? _firstInstallationAssigned(ConnectionRequestPage? page) {
  if (page == null) return null;
  for (final request in page.data) {
    if (request.status == ConnectionStatus.installationAssigned) {
      return request;
    }
  }
  return null;
}

/// Compact D20 header, D22: employee name (bold) + team (muted) only.
/// The settings gear and the logout button moved out — all action icons
/// now live grouped in the app bar (theme, bell, settings), and logout
/// lives inside the settings sheet. The red-tinted logout circle is gone.
class _CompactHeader extends StatelessWidget {
  const _CompactHeader({required this.employeeName, required this.teamName});

  final String employeeName;
  final String teamName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // D22: the team subtitle uses the stronger muted tone
    // (subtitleStrong: 7.14:1 light / 7.17:1 dark) instead of
    // onSurfaceVariant (5.18:1 light), which read washed out at 14px.
    final subtitleColor = theme.brightness == Brightness.dark
        ? FieldOpsDarkTokens.subtitleStrong
        : FieldOpsDesignTokens.subtitleStrong;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                employeeName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: FieldOpsDesignTokens.headlineMd.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                teamName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: subtitleColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// One D20 count tile: tinted icon chip, title, big coloured number +
/// small label, chevron. The number counts up (kit Rule 4); while its
/// count is loading the tile shows a dash, on error it shows 0 — a failed
/// count never crashes the dashboard or blocks the other tiles.
///
/// Size spec (Haider, 2026-11-27): COMPACT — 85% of the screen width
/// (centred, equal margins both sides) and ~47px tall: 32px icon chip,
/// 14px title, 20px number, 7px vertical padding, 10px tile gap. The
/// header and the "+ New request" button stay full width.
///
/// D22: the number + label sit in a centered column with a fixed
/// minimum width (88dp) and the title ellipsizes (maxLines 1) with a
/// 12dp gap, so a long title never collides with the count block and
/// all five tiles share one center line for their counts.
class _DashboardTile extends StatelessWidget {
  const _DashboardTile({
    required this.title,
    required this.icon,
    required this.style,
    required this.count,
    required this.label,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final _TileStyle style;
  final AsyncValue<int> count;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = style.resolve(theme.brightness);
    final numberStyle = FieldOpsDesignTokens.dataLg.copyWith(
      fontSize: 20,
      height: 1.0,
      color: color,
    );
    final labelStyle = FieldOpsDesignTokens.labelSm.copyWith(
      fontWeight: FontWeight.w500,
      height: 1.0,
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.85,
        child: OpsCard(
          onTap: onTap,
          padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 12),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: FieldOpsDesignTokens.labelLg.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              // D22: the count + label live in a column with a FIXED
              // minimum width (88dp) and centered alignment, so the number
              // and its label share one center line on every tile instead
              // of zig-zagging with their own widths. It is a min-width,
              // not a hard width: on a real phone every label fits in 88dp
              // (longest is "Available" at ~60dp in Plus Jakarta Sans),
              // but a wider font (e.g. the widget-test fallback, where
              // "Available" needs ~101dp) grows the column instead of
              // wrapping the label to two lines and breaking the tile
              // height. The 12dp gap keeps a long title (e.g.
              // "ONU Authorization") from ever touching the count block.
              const SizedBox(width: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 88),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    count.when(
                      data: (value) => DefaultTextStyle(
                        style: numberStyle,
                        child: CountUp(value: value),
                      ),
                      loading: () => Text('–', style: numberStyle),
                      error: (_, __) => Text('0', style: numberStyle),
                    ),
                    const SizedBox(height: 2),
                    Text(label, style: labelStyle),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tile accent colour, one hue in two brightnesses: the reference hue in
/// light mode, its lighter Tailwind-400 sibling in dark mode so the number
/// stays readable on the dark surface. The hues are the approved D20
/// reference design (one colour per tile), not status colours.
class _TileStyle {
  const _TileStyle({required this.light, required this.dark});

  final Color light;
  final Color dark;

  Color resolve(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;
}

/// Settings sheet for the header gear.
///
/// GAP (D20): no dedicated settings screen exists in the app yet, so the
/// gear opens this sheet instead of a route. It currently holds the one
/// setting the app already owns — the persisted theme choice
/// ([themeModeProvider]) — and nothing invented. D22: logout also lives
/// here now (it used to be a red-tinted circle in the compact header);
/// tapping it closes the sheet and runs the SAME confirmation dialog the
/// dashboard has always used — no second dialog was built.
Future<void> _showSettingsSheet(
  BuildContext context, {
  required VoidCallback onLogout,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) => _SettingsSheet(onLogout: onLogout),
  );
}

class _SettingsSheet extends ConsumerWidget {
  const _SettingsSheet({required this.onLogout});

  /// Shows the existing logout confirmation dialog (see
  /// [TeamDashboardScreen._confirmLogout]).
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final mode = ref.watch(themeModeProvider);
    const options = [
      (ThemeMode.system, 'System'),
      (ThemeMode.light, 'Light'),
      (ThemeMode.dark, 'Dark'),
    ];
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text('Theme', style: theme.textTheme.titleMedium),
            RadioGroup<ThemeMode>(
              groupValue: mode,
              onChanged: (next) {
                if (next != null) {
                  ref.read(themeModeProvider.notifier).set(next);
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final (value, label) in options)
                    RadioListTile<ThemeMode>(title: Text(label), value: value),
                ],
              ),
            ),
            const Divider(),
            // D22: logout as a plain text row — no bright red background.
            // The destructive colour is text + icon only.
            ListTile(
              leading: Icon(Icons.logout, color: theme.colorScheme.error),
              title: Text(
                'Log out',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
                onLogout();
              },
            ),
          ],
        ),
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
