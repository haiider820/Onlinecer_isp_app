import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/field_ops_design_tokens.dart';
import '../../../models/connection_request.dart';
import '../../../models/locations.dart';
import '../../../shared/formatting/format_minor_price.dart';
import '../../../shared/widgets/location_map.dart';
import '../../../shared/widgets/navigate_action.dart';
import '../../../shared/widgets/ops_widgets.dart';
import '../../../shared/widgets/section_card.dart';
import '../../survey/presentation/connection_request_providers.dart';
import 'complete_installation_screen.dart';
import 'installation_map_providers.dart';
import 'installation_providers.dart';

/// The merged installation screen for one connection request — the
/// "Mission Console" layout (Midnight Ops design system).
///
/// A sticky mission header (mono request number, live status pill, 5-stage
/// stepper) sits above a sticky tab bar (Overview / Route / Work). The tabs
/// jump to anchored sections of ONE scroll view (not a TabBarView), so every
/// section stays in the tree and deep-link/scroll semantics never break:
///
///  1. **Overview** — hero customer card, Call/Navigate/WhatsApp action dock,
///     glowing-mono pricing, the survey notes as a voice-quote card, and any
///     already-saved locations (read-only).
///  2. **Route** — the route map with the User + DP markers and the debounced
///     route line, plus the GPS capture buttons when the team may complete.
///  3. **Work** — the editable completion form, ending in the sticky bottom
///     CTA with checklist progress (only when the backend grants
///     `allowed_action == complete_installation`).
///
/// All data loading, providers, navigation and submit logic are unchanged —
/// only the presentation/layout was restructured.
class InstallationRequestDetailScreen extends ConsumerStatefulWidget {
  const InstallationRequestDetailScreen({super.key, required this.requestId});

  final String requestId;

  @override
  ConsumerState<InstallationRequestDetailScreen> createState() =>
      _InstallationRequestDetailScreenState();
}

class _InstallationRequestDetailScreenState
    extends ConsumerState<InstallationRequestDetailScreen> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(connectionRequestDetailProvider(widget.requestId));

    // Seed the live map from any already-saved request locations (e.g. prior
    // survey-era/user positions or a partial attempt) the first time they
    // arrive. `seed` only fills empty markers, so a live GPS capture keeps
    // overriding this.
    ref.listen(connectionRequestDetailProvider(widget.requestId), (previous, next) {
      next.whenOrNull(data: (d) {
        final locations = d.request.locations;
        final user =
            _coords(locations?.userDevice) ?? _coords(locations?.installation);
        final dp = _coords(locations?.dp) ?? _coords(locations?.fatNode);
        ref
            .read(installationMapControllerProvider(widget.requestId).notifier)
            .seed(userLocation: user, dpLocation: dp);
      });
    });

    return detail.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Installation Detail')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Installation Detail')),
        body: _ErrorView(
          message: e is ApiException ? e.message : 'Something went wrong.',
          onRetry: () =>
              ref.invalidate(connectionRequestDetailProvider(widget.requestId)),
        ),
      ),
      data: (d) => _DetailScaffold(
        detail: d,
        scrollController: _scrollController,
      ),
    );
  }

  static LatLng? _coords(GeoPoint? point) {
    final lat = point?.latitude;
    final lng = point?.longitude;
    if (lat == null || lng == null) return null;
    return LatLng(lat, lng);
  }
}

/// The mission-console scaffold: sticky mission header, sticky tab bar,
/// single anchored scroll view, and the sticky bottom CTA (when actionable).
class _DetailScaffold extends ConsumerStatefulWidget {
  const _DetailScaffold({required this.detail, required this.scrollController});

  final ConnectionRequestDetail detail;
  final ScrollController scrollController;

  @override
  ConsumerState<_DetailScaffold> createState() => _DetailScaffoldState();
}

class _DetailScaffoldState extends ConsumerState<_DetailScaffold> {
  static const _steps = [
    'Assigned',
    'En route',
    'On site',
    'Installing',
    'Done',
  ];

  int _tab = 0;
  final _overviewKey = GlobalKey();
  final _routeKey = GlobalKey();
  final _workKey = GlobalKey();
  final _formKey = GlobalKey<CompleteInstallationFormState>();
  final _progress = ValueNotifier<double>(0);

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  static int _stepIndex(String status) {
    final s = status.toLowerCase();
    if (s.contains('complete') ||
        s.contains('done') ||
        s.contains('verif')) {
      return 4;
    }
    if (s.contains('installing')) return 3;
    if (s.contains('on_site') || s.contains('on site')) return 2;
    if (s.contains('en_route') || s.contains('en route')) return 1;
    return 0;
  }

  void _jumpTo(int index) {
    setState(() => _tab = index);
    final key = [_overviewKey, _routeKey, _workKey][index];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = key.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          alignment: 0,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final detail = widget.detail;
    final request = detail.request;
    final actionable =
        detail.action == ConnectionRequestAction.completeInstallation;
    final submitting =
        ref.watch(completeInstallationControllerProvider).isSubmitting;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(124),
        child: SafeArea(
          child: MissionHeader(
            requestId: request.requestNumber,
            statusLabel: request.status.replaceAll('_', ' '),
            steps: _steps,
            currentStep: _stepIndex(request.status),
            onBack: () => context.pop(),
          ),
        ),
      ),
      body: Column(
        children: [
          _SectionTabBar(selected: _tab, onSelect: _jumpTo),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {},
              child: SingleChildScrollView(
                controller: widget.scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                // One non-lazy scroll view: every section (pricing, map, form)
                // is always in the tree regardless of scroll position.
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _OverviewSection(
                      key: _overviewKey,
                      detail: detail,
                    ),
                    _RouteSection(
                      key: _routeKey,
                      requestId: request.id,
                      actionable: actionable,
                    ),
                    _WorkSection(
                      key: _workKey,
                      detail: detail,
                      formKey: _formKey,
                      progress: _progress,
                      scrollController: widget.scrollController,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: actionable
          ? _StickyCta(
              progress: _progress,
              submitting: submitting,
              onSubmit: () => _formKey.currentState?.submit(),
            )
          : null,
    );
  }
}

/// Sticky tab bar: Overview / Route / Work jump to their anchored sections.
class _SectionTabBar extends StatelessWidget {
  const _SectionTabBar({required this.selected, required this.onSelect});

  final int selected;
  final ValueChanged<int> onSelect;

  static const _labels = ['Overview', 'Route', 'Work'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            for (var i = 0; i < _labels.length; i++)
              Expanded(
                child: GestureDetector(
                  onTap: () => onSelect(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: selected == i
                          ? theme.colorScheme.primary
                          : Colors.transparent,
                      boxShadow:
                          selected == i ? opsGlow(context) : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _labels[i],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: selected == i
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Overview ─────────────────────────────────────────────────────────────

class _OverviewSection extends StatelessWidget {
  const _OverviewSection({super.key, required this.detail});

  final ConnectionRequestDetail detail;

  @override
  Widget build(BuildContext context) {
    final request = detail.request;
    final surveyNotes = request.stageData?.surveyNotes?.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CustomerHeroCard(request: request),
        const SizedBox(height: 12),
        _ActionDockRow(request: request),
        const OpsSectionLabel('Pricing'),
        _PricingCard(request: request),
        if (surveyNotes != null && surveyNotes.isNotEmpty) ...[
          const SizedBox(height: 4),
          _SurveyQuoteCard(notes: surveyNotes),
        ],
        if (request.locations != null) ...[
          const SizedBox(height: 4),
          _LocationsSection(locations: request.locations!),
        ],
        const SizedBox(height: 8),
      ],
    );
  }
}

/// Hero customer card: gradient avatar, name, mono phone, area line.
class _CustomerHeroCard extends StatelessWidget {
  const _CustomerHeroCard({required this.request});

  final ConnectionRequest request;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final area = request.customerArea;
    final address = request.customerAddress;
    return OpsCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OpsAvatar(
            initials:
                OpsAvatar.initialsOf(request.customerName ?? '—'),
            size: 54,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.customerName ?? '—',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (request.customerPhone != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    request.customerPhone!,
                    style: FieldOpsDesignTokens.dataMd.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
                if (area != null || address != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: theme.colorScheme.outline,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          [if (area != null) area, if (address != null) address]
                              .join(' · '),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: muted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (request.currentTeam?.name != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.groups_outlined,
                        size: 14,
                        color: theme.colorScheme.outline,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        request.currentTeam!.name,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: muted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
                if (request.requestedPlan != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.router_outlined,
                        size: 14,
                        color: theme.colorScheme.outline,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          request.requestedPlan!.name,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: muted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Call / Navigate / WhatsApp action dock.
class _ActionDockRow extends StatelessWidget {
  const _ActionDockRow({required this.request});

  final ConnectionRequest request;

  LatLng? _target() {
    final locs = request.locations;
    if (locs == null) return null;
    for (final p in [
      locs.dp,
      locs.installation,
      locs.userDevice,
      locs.fatNode
    ]) {
      if (p?.latitude != null && p?.longitude != null) {
        return LatLng(p!.latitude!, p.longitude!);
      }
    }
    return null;
  }

  Future<void> _call(BuildContext context, String phone) async {
    final digits = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (digits.isEmpty) return;
    final uri = Uri.parse('tel:$digits');
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) _snack(context, 'Could not open the phone app.');
    } catch (_) {
      if (context.mounted) _snack(context, 'Could not open the phone app.');
    }
  }

  Future<void> _whatsapp(BuildContext context, String phone) async {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return;
    final uri = Uri.parse('https://wa.me/$digits');
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) _snack(context, 'Could not open WhatsApp.');
    } catch (_) {
      if (context.mounted) _snack(context, 'Could not open WhatsApp.');
    }
  }

  void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final phone = request.customerPhone;
    final target = _target();
    return ActionDock(
      actions: [
        if (phone != null)
          DockAction(
            label: 'Call',
            icon: Icons.call_outlined,
            onTap: () => _call(context, phone),
          ),
        DockAction(
          label: 'Navigate',
          icon: Icons.navigation_outlined,
          primary: true,
          onTap: target == null
              ? null
              : () => NavigateButton.openMaps(
                    context,
                    latitude: target.latitude,
                    longitude: target.longitude,
                  ),
        ),
        if (phone != null)
          DockAction(
            label: 'WhatsApp',
            icon: Icons.chat_outlined,
            onTap: () => _whatsapp(context, phone),
          ),
      ],
    );
  }
}

/// Pricing with glowing mono figures: subscription charge from the requested
/// plan's `price_minor`, plus the connection charge placeholder (the backend
/// doesn't expose the field on the detail response yet — contract note).
class _PricingCard extends StatelessWidget {
  const _PricingCard({required this.request});

  final ConnectionRequest request;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final priceMinor = request.requestedPlan?.priceMinor;
    return OpsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Subscription',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Text(
                priceMinor != null ? formatMinorPrice(priceMinor) : '—',
                style: FieldOpsDesignTokens.dataLg.copyWith(
                  color: primary,
                  shadows: [
                    Shadow(
                      color: primary.withValues(alpha: 0.45),
                      blurRadius: 14,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Divider(
              height: 1,
              color:
                  theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Connection',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Text(
                AppStrings.connectionChargePending,
                style: FieldOpsDesignTokens.dataMd.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.connectionChargeNote,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Survey-stage notes rendered as a voice-quote card.
class _SurveyQuoteCard extends StatelessWidget {
  const _SurveyQuoteCard({required this.notes});

  final String notes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return OpsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.format_quote, size: 18, color: primary),
              const SizedBox(width: 6),
              Text(
                'SURVEY NOTES',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.only(left: 12),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: primary, width: 3),
              ),
            ),
            child: Text(
              notes,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontStyle: FontStyle.italic,
                height: 1.55,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '— captured during survey',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationsSection extends StatelessWidget {
  const _LocationsSection({required this.locations});

  final Locations locations;

  static String _format(double? value) {
    if (value == null) return '';
    return value.toStringAsFixed(6);
  }

  /// Renders a point as ISO-style latitude, longitude; falls back to an id /
  /// address only when the point has no coordinates.
  static String _point(GeoPoint? point) {
    if (point == null) return '—';
    final lat = _format(point.latitude);
    final lng = _format(point.longitude);
    if (lat.isNotEmpty || lng.isNotEmpty) {
      return [if (lat.isNotEmpty) lat, if (lng.isNotEmpty) lng].join(', ');
    }
    return point.nodeId ?? point.address ?? '—';
  }

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Saved Locations',
      icon: Icons.place_outlined,
      children: [
        InfoRow(label: 'Installation', value: _point(locations.installation)),
        InfoRow(label: 'DP', value: _point(locations.dp)),
        InfoRow(label: 'User device', value: _point(locations.userDevice)),
        InfoRow(label: 'FAT node', value: _point(locations.fatNode)),
      ],
    );
  }
}

// ─── Route ──────────────────────────────────────────────────────────────

class _RouteSection extends StatelessWidget {
  const _RouteSection({
    super.key,
    required this.requestId,
    required this.actionable,
  });

  final String requestId;
  final bool actionable;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const OpsSectionLabel('Route'),
        _MapCard(requestId: requestId, actionable: actionable),
        const SizedBox(height: 8),
      ],
    );
  }
}

/// Route map card: the live map plus, for the actionable form, the GPS capture
/// buttons that seed the User/DP markers.
class _MapCard extends ConsumerWidget {
  const _MapCard({required this.requestId, required this.actionable});

  final String requestId;
  final bool actionable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final mapState = ref.watch(installationMapControllerProvider(requestId));

    return SectionCard(
      title: 'Route Map',
      icon: Icons.map_outlined,
      children: [
        LocationMap(
          userLocation: mapState.userLocation,
          dpLocation: mapState.dpLocation,
          route: mapState.route,
        ),
        const SizedBox(height: 8),

        if (mapState.isRouteCalculating)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 8),
                Text(AppStrings.mapRouteCalculating,
                    style: theme.textTheme.bodySmall),
              ],
            ),
          ),

        // Graceful fallback notes: route API failure or undecodable
        // geometry is reported rather than silently leaving the map empty.
        if (mapState.routeNote != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.route_outlined,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    mapState.routeNote!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),

        if (actionable)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => _captureUser(context, ref),
                icon: const Icon(Icons.my_location),
                label: const Text(AppStrings.mapUseMyLocation),
              ),
              OutlinedButton.icon(
                onPressed: () => _captureDp(context, ref),
                icon: const Icon(Icons.add_location_alt_outlined),
                label: const Text(AppStrings.mapCaptureDpLocation),
              ),
            ],
          ),
      ],
    );
  }

  Future<void> _captureUser(BuildContext context, WidgetRef ref) async {
    final error = await ref
        .read(installationMapControllerProvider(requestId).notifier)
        .captureUserLocation();
    if (error != null && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    }
  }

  Future<void> _captureDp(BuildContext context, WidgetRef ref) async {
    final error = await ref
        .read(installationMapControllerProvider(requestId).notifier)
        .captureDpLocation();
    if (error != null && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    }
  }
}

// ─── Work ───────────────────────────────────────────────────────────────

class _WorkSection extends StatelessWidget {
  const _WorkSection({
    super.key,
    required this.detail,
    required this.formKey,
    required this.progress,
    required this.scrollController,
  });

  final ConnectionRequestDetail detail;
  final GlobalKey<CompleteInstallationFormState> formKey;
  final ValueNotifier<double> progress;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final actionable =
        detail.action == ConnectionRequestAction.completeInstallation;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const OpsSectionLabel('Work'),
        if (actionable)
          CompleteInstallationForm(
            key: formKey,
            requestId: detail.request.id,
            scrollController: scrollController,
            progress: progress,
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'No action available for this request.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }
}

/// Sticky bottom CTA: completion-checklist progress + the submit action.
/// The submit itself is disabled while a submission is in flight.
class _StickyCta extends StatelessWidget {
  const _StickyCta({
    required this.progress,
    required this.submitting,
    required this.onSubmit,
  });

  final ValueNotifier<double> progress;
  final bool submitting;
  final VoidCallback onSubmit;

  static const _requiredCount = 3;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            top: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ValueListenableBuilder<double>(
              valueListenable: progress,
              builder: (_, value, __) {
                final done = (value * _requiredCount).round();
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Completion checklist',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '$done / $_requiredCount',
                          style:
                              FieldOpsDesignTokens.dataSm.copyWith(
                            color: primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: value,
                        minHeight: 6,
                        backgroundColor: theme
                            .colorScheme.surfaceContainerHighest,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(primary),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                );
              },
            ),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: submitting ? null : onSubmit,
                icon: submitting
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.colorScheme.onPrimary,
                        ),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: const Text('Complete Installation'),
              ),
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
