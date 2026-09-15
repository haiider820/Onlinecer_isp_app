import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../models/fat_node.dart';
import '../../../models/route_result.dart';
import '../../../shared/maps/route_geometry_decoder.dart';
import '../../../shared/widgets/location_map.dart';
import '../data/location_service.dart';
import 'route_providers.dart';

/// Screen for calculating a route from the user's current position to a
/// selected FAT node. Uses device GPS via geolocator and calls
/// `POST /connection-requests/{id}/route` with the coordinates.
///
/// Scope: GPS capture + route map + summary card. The summary card shows the
/// backend's real road-following `distance_meters`; the map draws the
/// multi-point OSRM route returned in `points`, degrading to a documented
/// straight line only when OSRM could not compute a route (empty/missing
/// `points`).
class SurveyRouteScreen extends ConsumerStatefulWidget {
  const SurveyRouteScreen({super.key, required this.requestId});

  final String requestId;

  @override
  ConsumerState<SurveyRouteScreen> createState() => _SurveyRouteScreenState();
}

class _SurveyRouteScreenState extends ConsumerState<SurveyRouteScreen> {
  FatNode? _selectedNode;
  Position? _userPosition;
  bool _fetchingLocation = false;
  String? _locationError;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fatNodesAsync = ref.watch(fatNodesProvider(widget.requestId));
    final routeState = ref.watch(routeCalcControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Plan Route')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          // ── FAT node selection ──
          Text(
            'Select FAT node',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          fatNodesAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (e, _) => _ErrorCard(
              message: e is ApiException ? e.message : 'Failed to load FAT nodes.',
              onRetry: () => ref.invalidate(fatNodesProvider(widget.requestId)),
            ),
            data: (nodeList) => _buildNodeList(nodeList, theme),
          ),

          const SizedBox(height: 16),

          // ── User location ──
          Text(
            'Your location',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          _LocationSection(
            position: _userPosition,
            isFetching: _fetchingLocation,
            error: _locationError,
            onUseMyLocation: _useMyLocation,
          ),

          const SizedBox(height: 24),

          // ── Calculate button ──
          FilledButton.icon(
            onPressed: (_selectedNode != null && _userPosition != null && !routeState.isCalculating)
                ? _calculateRoute
                : null,
            icon: routeState.isCalculating
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.directions),
            label: Text(routeState.isCalculating ? 'Calculating…' : 'Calculate Route'),
          ),

          // ── Error card ──
          if (routeState.hasError) ...[
            const SizedBox(height: 12),
            _ErrorCard(
              message: routeState.errorMessage!,
              onRetry: () => ref.read(routeCalcControllerProvider.notifier).clearError(),
            ),
          ],

          // ── Result card ──
          if (routeState.hasResult) ...[
            const SizedBox(height: 16),
            _ResultCard(result: routeState.result!),
          ],

          // ── Route map: the real multi-point OSRM path, with a documented
          // straight-line fallback only when the backend returned no points ──
          if (routeState.hasResult && _userPosition != null && _selectedNode != null) ...[
            const SizedBox(height: 16),
            Text(
              'Route Map',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            _RouteMap(
              userLocation: LatLng(_userPosition!.latitude, _userPosition!.longitude),
              dpLocation: LatLng(_selectedNode!.latitude, _selectedNode!.longitude),
              route: routeState.result!.points,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNodeList(FatNodeList nodeList, ThemeData theme) {
    if (nodeList.data.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'No FAT nodes found for this request.',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
      );
    }

    return Card(
      margin: EdgeInsets.zero,
      child: RadioGroup<FatNode>(
        groupValue: _selectedNode,
        onChanged: (value) => setState(() => _selectedNode = value),
        child: Column(
          children: nodeList.data.map((node) {
            return RadioListTile<FatNode>(
              title: Text(node.name),
              subtitle: Text(
                '${node.nodeType} · ${node.latitude.toStringAsFixed(4)}, ${node.longitude.toStringAsFixed(4)}',
                style: theme.textTheme.bodySmall,
              ),
              value: node,
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _useMyLocation() async {
    setState(() {
      _fetchingLocation = true;
      _locationError = null;
    });

    try {
      final position = await ref.read(locationServiceProvider).getCurrentPosition();
      if (mounted) {
        setState(() {
          _userPosition = position;
          _fetchingLocation = false;
        });
      }
    } on LocationException catch (e) {
      if (mounted) {
        setState(() {
          _locationError = e.message;
          _fetchingLocation = false;
        });
      }
    } catch (e) {
      // Unexpected failure from the plugin — surface a generic message.
      if (mounted) {
        setState(() {
          _locationError = 'Could not get location. Please try again. ($e)';
          _fetchingLocation = false;
        });
      }
    }
  }

  Future<void> _calculateRoute() async {
    final node = _selectedNode!;
    final pos = _userPosition!;

    await ref.read(routeCalcControllerProvider.notifier).calculate(
          connectionRequestId: widget.requestId,
          userLatitude: pos.latitude,
          userLongitude: pos.longitude,
          dpLatitude: node.latitude,
          dpLongitude: node.longitude,
        );
  }
}

// ─── Sub-widgets ────────────────────────────────────────────────────────────

class _LocationSection extends StatelessWidget {
  const _LocationSection({
    required this.position,
    required this.isFetching,
    required this.error,
    required this.onUseMyLocation,
  });

  final Position? position;
  final bool isFetching;
  final String? error;
  final VoidCallback onUseMyLocation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (position != null)
              Text(
                '${position!.latitude.toStringAsFixed(6)}, ${position!.longitude.toStringAsFixed(6)}',
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              )
            else
              Text(
                'No location captured yet.',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            if (error != null) ...[
              const SizedBox(height: 8),
              Text(
                error!,
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
              ),
            ],
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: isFetching ? null : onUseMyLocation,
              icon: isFetching
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location, size: 18),
              label: Text(isFetching ? 'Getting location…' : 'Use my location'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Route map: draws the user + FAT/Dp markers and the full multi-point OSRM
/// route returned in `points`. When the backend returned no computeable route
/// (empty/missing `points`), it falls back to a documented straight line.
class _RouteMap extends StatelessWidget {
  const _RouteMap({
    required this.userLocation,
    required this.dpLocation,
    required this.route,
  });

  final LatLng userLocation;
  final LatLng dpLocation;

  /// Already-decoded route points from [RouteResult.points]; `null` when the
  /// backend could not compute a route.
  final List<LatLng>? route;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasRoute = route != null && route!.length >= 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LocationMap(
          userLocation: userLocation,
          dpLocation: dpLocation,
          route: hasRoute ? route : straightLineFallback(userLocation, dpLocation),
        ),
        if (!hasRoute) ...[
          const SizedBox(height: 8),
          Text(
            AppStrings.mapRouteStraightLine,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});

  final RouteResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.route, color: theme.colorScheme.onPrimaryContainer),
                const SizedBox(width: 8),
                Text(
                  'Route Summary',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (result.distanceMeters != null)
              _ResultRow(
                icon: Icons.straighten,
                label: 'Distance',
                value: _formatDistance(result.distanceMeters!),
              ),
            if (result.durationSeconds != null)
              _ResultRow(
                icon: Icons.schedule,
                label: 'Duration',
                value: _formatDuration(result.durationSeconds!),
              ),
            if (result.summary != null) ...[
              const SizedBox(height: 8),
              Text(
                result.summary!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ],
            if (result.distanceMeters == null &&
                result.durationSeconds == null &&
                result.summary == null)
              Text(
                'Route calculated but no summary data returned.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
          ],
        ),
      ),
    );
  }

  static String _formatDistance(double meters) {
    if (meters < 1000) return '${meters.round()} m';
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  static String _formatDuration(double seconds) {
    final mins = (seconds / 60).round();
    if (mins < 60) return '~$mins min';
    final hrs = mins ~/ 60;
    final remainMins = mins % 60;
    return '~${hrs}h ${remainMins}m';
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.onPrimaryContainer),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onPrimaryContainer),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: theme.colorScheme.onErrorContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: theme.colorScheme.onErrorContainer),
              ),
            ),
            if (onRetry != null)
              TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
