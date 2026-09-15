import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../core/theme/field_ops_design_tokens.dart';
import '../../../models/connection_request.dart';
import '../../../models/locations.dart';
import '../../../shared/formatting/format_minor_price.dart';
import '../../../shared/widgets/branded_header.dart';
import '../../../shared/widgets/location_map.dart';
import '../../../shared/widgets/navigate_action.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../survey/presentation/connection_request_providers.dart';
import 'complete_installation_screen.dart';
import 'installation_map_providers.dart';

/// The merged installation screen for one connection request (module Phase 1).
///
/// One scroll view carries, top to bottom:
///  1. read-only customer/request info,
///  2. the **pricing** cards — Subscription Charges from the requested plan's
///     `price_minor`, plus the Connection Charges placeholder (Phase 2),
///  3. the **route map** with the User + DP markers and the debounced route
///     line (Phases 3–4),
///  4. and, when the backend grants it via `allowed_action`, the editable
///     completion form, ending in the Complete Installation submit (Phase 1).
///
/// When `allowed_action` is anything other than `complete_installation` the
/// form is hidden and only the read-only view renders.
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

    return Scaffold(
      appBar: BrandedHeader(
        title: 'Installation Detail',
        onBack: () => context.pop(),
      ),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(
          message: e is ApiException ? e.message : 'Something went wrong.',
          onRetry: () => ref.invalidate(connectionRequestDetailProvider(widget.requestId)),
        ),
        data: (d) => _DetailBody(detail: d, scrollController: _scrollController),
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

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.detail, required this.scrollController});

  final ConnectionRequestDetail detail;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final request = detail.request;
    final surveyNotes = request.stageData?.surveyNotes?.trim();
    final actionable =
        detail.action == ConnectionRequestAction.completeInstallation;

    return RefreshIndicator(
      onRefresh: () async {},
      child: SingleChildScrollView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        // A fixed document of read-only cards + one form — non-lazy, so every
        // section (survey notes, saved locations, map) is always present in the
        // tree regardless of scroll position.
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          // Header banner: request number + semantic status + area line.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(FieldOpsDesignTokens.cardRadius),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: FieldOpsDesignTokens.shadowLevel1,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.requestNumber,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (request.customerArea != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: theme.colorScheme.outline,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                request.customerArea!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                StatusBadge(status: request.status),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Navigate — uses the DP coordinates (or installation point fallback)
          // for the maps deep-link. Disabled until coordinates exist.
          NavigateButton(
            latitude: request.locations?.dp?.latitude ??
                request.locations?.installation?.latitude,
            longitude: request.locations?.dp?.longitude ??
                request.locations?.installation?.longitude,
            label: 'Navigate to Customer',
          ),
          const SizedBox(height: 4),

          // Customer info
          SectionCard(
            title: 'Customer',
            icon: Icons.person_outline,
            children: [
              InfoRow(label: 'Name', value: request.customerName),
              if (request.customerType != null)
                InfoRow(label: 'Type', value: request.customerType),
              if (request.customerPhone != null)
                InfoRow(label: 'Phone', value: request.customerPhone),
              if (request.customerArea != null)
                InfoRow(label: 'Area', value: request.customerArea),
              if (request.customerAddress != null)
                InfoRow(label: 'Address', value: request.customerAddress),
            ],
          ),

          // Request info
          SectionCard(
            title: 'Request',
            icon: Icons.router_outlined,
            children: [
              InfoRow(label: 'Status', value: request.status.replaceAll('_', ' ')),
              if (request.requestedPlan != null)
                InfoRow(label: 'Plan', value: request.requestedPlan!.name),
              if (request.currentTeam != null)
                InfoRow(label: 'Team', value: request.currentTeam!.name),
            ],
          ),

          // Pricing card (Phase 2): subscription charge from the requested
          // plan; connection charge is a placeholder until the backend exposes
          // the field on the detail response (contract note).
          _PriceCard(request: request),

          // Read-only survey-stage notes. Rendered independently of whether the
          // installation stage has written any data yet.
          if (surveyNotes != null && surveyNotes.isNotEmpty)
            SectionCard(
              title: 'Survey Notes',
              icon: Icons.notes,
              children: [
                Text(
                  request.stageData!.surveyNotes!,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                ),
              ],
            ),

          // Locations already captured on this request (e.g. a partial attempt),
          // read-only.
          if (request.locations != null)
            _LocationsSection(locations: request.locations!),

          // Route map with live User + DP markers and auto-debounced route
          // (Phases 3–4).
          _MapCard(requestId: request.id, actionable: actionable),

          // Editable tail (Phase 1): only when the team may complete.
          if (actionable)
            CompleteInstallationForm(
              requestId: request.id,
              scrollController: scrollController,
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
        ),
      ),
    );
  }
}

/// Phase 2 pricing card: the requested plan's subscription charge (from
/// `price_minor`, already on the detail response) plus the connection charge
/// placeholder.
class _PriceCard extends StatelessWidget {
  const _PriceCard({required this.request});

  final ConnectionRequest request;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final plan = request.requestedPlan;
    final priceMinor = plan?.priceMinor;

    return SectionCard(
      title: 'Pricing',
      icon: Icons.payments_outlined,
      children: [
        InfoRow(
          label: 'Subscription',
          value: priceMinor != null ? formatMinorPrice(priceMinor) : '—',
        ),
        InfoRow(label: 'Connection', value: AppStrings.connectionChargePending),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            AppStrings.connectionChargeNote,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

/// Route map card: the live map plus, for the actionable form, the GPS capture
/// buttons that seed the User/DP markers (Phase 4/5).
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
                Text(AppStrings.mapRouteCalculating, style: theme.textTheme.bodySmall),
              ],
            ),
          ),

        // Graceful fallback notes (Phase 6): route API failure or undecodable
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  Future<void> _captureDp(BuildContext context, WidgetRef ref) async {
    final error = await ref
        .read(installationMapControllerProvider(requestId).notifier)
        .captureDpLocation();
    if (error != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
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