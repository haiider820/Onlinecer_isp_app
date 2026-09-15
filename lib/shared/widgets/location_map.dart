import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

/// Test-overridable map tile source. Defaults to the free OpenStreetMap tile
/// servers (no API key — see the module plan's provider decision); widget tests
/// override this with a deterministic in-memory provider so no tile HTTP
/// requests leave the test runner.
final mapTileProviderProvider = Provider<TileProvider>((ref) {
  return NetworkTileProvider();
});

/// Free OSM tile endpoint (browse-friendly, no key required).
const String defaultMapTileUrlTemplate = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

/// The User-Agent package name we identify ourselves with on the tile server.
const String defaultMapUserAgent = 'com.example.isp_onlinecer';

/// Interactive map showing the installation's two landmarks — the **user**
/// (technician/installation spot) and the **DP** (Fiber Access Terminal) — plus
/// an optional route polyline between them.
///
/// The widget is deliberately presentation-only: it receives points and a
/// route and renders them; it never fetches. Point/route state lives in
/// [InstallationMapController] so the map, the coordinate inputs above/below
/// it, and the auto-debounced route call stay in sync.
class LocationMap extends ConsumerStatefulWidget {
  const LocationMap({
    super.key,
    this.userLocation,
    this.dpLocation,
    this.route,
    this.height = 260,
  });

  /// The user/installation marker, or `null` when unknown.
  final LatLng? userLocation;

  /// The DP marker, or `null` when unknown.
  final LatLng? dpLocation;

  /// Decoded route line between the two points (or the straight-line
  /// fallback); `null` renders no polyline.
  final List<LatLng>? route;

  /// Fixed height of the map box.
  final double height;

  /// Session-local landmark; defaults to Malé, Maldives so a lone marker still
  /// has a sane viewport on first launch.
  static const LatLng _defaultCenter = LatLng(4.1755, 73.5093);

  @override
  ConsumerState<LocationMap> createState() => _LocationMapState();
}

class _LocationMapState extends ConsumerState<LocationMap> {
  final MapController _mapController = MapController();

  bool get _hasAnyPoint =>
      widget.userLocation != null || widget.dpLocation != null;

  @override
  void didUpdateWidget(covariant LocationMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-fit the camera whenever a marker moves or the route arrives/changes,
    // so the newly-relevant points stay in view (Phase 4 auto-update).
    _fitToPoints();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tileProvider = ref.watch(mapTileProviderProvider);
    final user = widget.userLocation;
    final dp = widget.dpLocation;
    final route = widget.route;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: _hasAnyPoint
            ? FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: user ?? dp ?? LocationMap._defaultCenter,
                  initialZoom: 15,
                  minZoom: 3,
                  maxZoom: 19,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  interactionOptions: const InteractionOptions(
                    // Panning and pinch-zoom yes; rotation is rarely wanted for
                    // a field-ops map.
                    flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                  ),
                  onMapReady: _fitToPoints,
                ),
                children: [
                  TileLayer(
                    urlTemplate: defaultMapTileUrlTemplate,
                    userAgentPackageName: defaultMapUserAgent,
                    tileProvider: tileProvider,
                  ),
                  if (route != null && route.length >= 2)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: route,
                          strokeWidth: 4,
                          color: theme.colorScheme.primary,
                        ),
                      ],
                    ),
                  if (user != null || dp != null)
                    MarkerLayer(
                      markers: [
                        if (user != null)
                          Marker(
                            point: user,
                            width: 44,
                            height: 44,
                            child: const Icon(
                              Icons.pin_drop,
                              key: Key('location-map-user-marker'),
                              size: 40,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        if (dp != null)
                          Marker(
                            point: dp,
                            width: 44,
                            height: 44,
                            child: const Icon(
                              Icons.pin_drop,
                              key: Key('location-map-dp-marker'),
                              size: 40,
                              color: Color(0xFF1565C0),
                            ),
                          ),
                      ],
                    ),
                ],
              )
            : Container(
                color: theme.colorScheme.surfaceContainerHighest,
                alignment: Alignment.center,
                child: Text(
                  'No location captured yet.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
      ),
    );
  }

  void _fitToPoints() {
    if (!_hasAnyPoint) return;
    final points = <LatLng>[
      if (widget.userLocation != null) widget.userLocation!,
      if (widget.dpLocation != null) widget.dpLocation!,
      if (widget.route != null) ...widget.route!,
    ];
    if (points.isEmpty) return;
    try {
      // `camera`/`fitCamera` throw until the FlutterMap has rendered once
      // (pre-mount calls from didUpdateWidget are swallowed here; the
      // onMapReady callback re-invokes us once it has).
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(points),
          padding: const EdgeInsets.all(48),
        ),
      );
    } catch (_) {
      // Not mounted yet, or a too-small bounds box (identical points) threw;
      // a no-op fit is fine — the map keeps its previous camera.
    }
  }
}