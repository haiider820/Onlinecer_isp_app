import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/field_ops_design_tokens.dart';
import '../../features/installation/presentation/installation_map_providers.dart';
import 'location_map.dart';
import 'section_card.dart';

/// The web console's "Installation Locations" block, ported for mobile:
///
///  1. two capture panels — **User Device Location** and **Connection DP
///     (Distribution Point) Location** — each a one-tap GPS button;
///  2. **then** the OpenStreetMap layer with both markers and the routed
///     polyline between them.
///
/// The capture buttons sit ABOVE the map on purpose (the web layout does the
/// same) so the sequence reads "capture → line on the map". The captured
/// coordinates themselves stay in the controller: they feed the map markers,
/// the route, and the submission payload without being echoed as form
/// fields.
///
/// Everything is driven by [InstallationMapController], keyed by request id,
/// so this card stays in sync with the FAT dropdown's DP auto-fill and with
/// the submission payload regardless of which screen embeds it.
class InstallationLocationsCard extends ConsumerWidget {
  const InstallationLocationsCard({
    super.key,
    required this.requestId,
    this.title = AppStrings.mapCardTitle,
    this.icon = Icons.place_outlined,
    this.showCapture = true,
    this.mapHeight = 260,
    this.footer,
  });

  /// Connection request whose coordinates/route this card renders.
  final String requestId;

  /// Card header title.
  final String title;

  /// Header icon.
  final IconData icon;

  /// Whether the two GPS capture panels render. Read-only presentations
  /// (a request that already moved past this stage) pass `false`.
  final bool showCapture;

  /// Height of the map layer.
  final double mapHeight;

  /// Optional trailing content under the map (e.g. a Navigate action).
  final Widget? footer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final mapState = ref.watch(installationMapControllerProvider(requestId));

    return SectionCard(
      title: title,
      icon: icon,
      children: [
        if (showCapture) ...[
          LayoutBuilder(
            builder: (context, constraints) {
              final user = _CapturePanel(
                title: AppStrings.mapUserPanelTitle,
                icon: Icons.phone_android_outlined,
                accent: Theme.of(context).colorScheme.primary,
                buttonLabel: AppStrings.mapUseMyLocation,
                onPressed: () => _capture(
                  context,
                  () => ref
                      .read(installationMapControllerProvider(requestId).notifier)
                      .captureUserLocation(),
                ),
              );
              final dp = _CapturePanel(
                title: AppStrings.mapDpPanelTitle,
                icon: Icons.cell_tower_outlined,
                accent: Theme.of(context).colorScheme.tertiary,
                buttonLabel: AppStrings.mapCaptureDpLocation,
                onPressed: () => _capture(
                  context,
                  () => ref
                      .read(installationMapControllerProvider(requestId).notifier)
                      .captureDpLocation(),
                ),
              );
              // Two columns once there is room (web console is side-by-side);
              // stacked on a phone.
              if (constraints.maxWidth >= 560) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: user),
                    const SizedBox(width: 12),
                    Expanded(child: dp),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  user,
                  const SizedBox(height: 12),
                  dp,
                ],
              );
            },
          ),
          const SizedBox(height: 12),
        ],
        Row(
          children: [
            Icon(Icons.map_outlined, size: 16, color: theme.colorScheme.primary),
            const SizedBox(width: 6),
            Text(
              AppStrings.mapLayerTitle,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LocationMap(
          userLocation: mapState.userLocation,
          dpLocation: mapState.dpLocation,
          route: mapState.route,
          height: mapHeight,
        ),
        if (mapState.isRouteCalculating)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 8),
                Text(
                  AppStrings.mapRouteCalculating,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        // Graceful fallbacks: route API failure or undecodable geometry is
        // reported rather than silently leaving the map with no line.
        if (mapState.routeNote != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
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
        if (footer != null) ...[
          const SizedBox(height: 12),
          footer!,
        ],
      ],
    );
  }

  /// Runs a controller capture and surfaces a GPS failure as a snackbar.
  ///
  /// [capture] is invoked synchronously (so the provider `ref` is read while
  /// this widget is definitely still alive), then awaited for the GPS fix.
  Future<void> _capture(BuildContext context, Future<String?> Function() capture) async {
    final error = await capture();
    if (error != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }
}

/// One capture panel: title, accent GPS button — nothing else. The fix (or
/// the FAT auto-fill) lands straight in the map controller.
class _CapturePanel extends StatelessWidget {
  const _CapturePanel({
    required this.title,
    required this.icon,
    required this.accent,
    required this.buttonLabel,
    required this.onPressed,
  });

  final String title;
  final IconData icon;
  final Color accent;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(FieldOpsDesignTokens.radiusLg),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: accent),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 44),
            ),
            icon: const Icon(Icons.my_location, size: 18),
            label: Text(
              buttonLabel,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
