import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/constants/app_constants.dart';
import '../../survey/data/location_service.dart';
import '../../survey/presentation/route_providers.dart';

/// Live map/route state for one connection request's installation screen.
///
/// Holds the two markers the map renders — the **user** (technician /
/// installation spot) and the **DP** (the selected FAT node, or a manually
/// captured override) — and the decoded route line between them.
///
/// The route is the result of `POST /connection-requests/{id}/route`, called
/// automatically with a ~500 ms debounce once both points exist. It degrades
/// gracefully per the module plan: geometry that doesn't decode → straight
/// line; API failure → markers only plus a note.
class InstallationMapState {
  const InstallationMapState({
    this.userLocation,
    this.dpLocation,
    this.dpFromManual = false,
    this.isRouteCalculating = false,
    this.route,
    this.routeNote,
  });

  /// User/installation marker, or `null` when unknown.
  final LatLng? userLocation;

  /// DP marker, or `null` when unknown.
  final LatLng? dpLocation;

  /// Whether the DP point came from a manual GPS capture rather than the
  /// selected FAT node. A manual capture overrides the FAT auto-fill (Phase 5).
  final bool dpFromManual;

  /// A debounced route request is in flight.
  final bool isRouteCalculating;

  /// Decoded route points (or the straight-line fallback). `null` when there
  /// is no line to draw.
  final List<LatLng>? route;

  /// A human note when the route is missing/falling back; `null` when fine.
  final String? routeNote;

  InstallationMapState copyWith({
    LatLng? userLocation,
    LatLng? dpLocation,
    bool? dpFromManual,
    bool? isRouteCalculating,
    List<LatLng>? route,
    String? routeNote,
    bool clearRoute = false,
    bool clearRouteNote = false,
  }) {
    return InstallationMapState(
      userLocation: userLocation ?? this.userLocation,
      dpLocation: dpLocation ?? this.dpLocation,
      dpFromManual: dpFromManual ?? this.dpFromManual,
      isRouteCalculating: isRouteCalculating ?? this.isRouteCalculating,
      route: clearRoute ? null : (route ?? this.route),
      routeNote: clearRouteNote ? null : (routeNote ?? this.routeNote),
    );
  }
}

/// Coordinates + route for the merged installation screen, keyed by request id.
///
/// A [FamilyNotifier] so each request's map state stays scoped to that screen:
/// the family argument (the request id) is exposed as [arg].
class InstallationMapController
    extends FamilyNotifier<InstallationMapState, String> {
  static const Duration _routeDebounce = Duration(milliseconds: 500);

  Timer? _debounce;

  String get _requestId => arg;

  @override
  InstallationMapState build(String requestId) {
    ref.onDispose(() => _debounce?.cancel());
    return const InstallationMapState();
  }

  /// Seeds the map from already-saved request locations (e.g. a partial
  /// attempt reopened later). Only fills points still empty so a live edit is
  /// never clobbered by a refetch.
  void seed({LatLng? userLocation, LatLng? dpLocation, bool dpFromManual = false}) {
    final current = state;
    final next = InstallationMapState(
      userLocation: current.userLocation ?? userLocation,
      dpLocation: current.dpLocation ?? dpLocation,
      dpFromManual: current.dpFromManual || dpFromManual,
      isRouteCalculating: current.isRouteCalculating,
      route: current.route,
      routeNote: current.routeNote,
    );
    if (_samePoint(next.userLocation, current.userLocation) &&
        _samePoint(next.dpLocation, current.dpLocation)) {
      return;
    }
    state = next;
    _scheduleRoute();
  }

  /// Moves the user marker (from the "Use my location" button or elsewhere).
  void setUserLocation(LatLng? point) {
    if (_samePoint(point, state.userLocation)) return;
    state = state.copyWith(
      userLocation: point,
      clearRoute: true,
      clearRouteNote: true,
    );
    _scheduleRoute();
  }

  /// Auto-fills the DP marker from the selected FAT node (Phase 4/5). A manual
  /// capture ([captureDpLocation]) supersedes this until the FAT changes again.
  void setDpFromFat(LatLng? point) {
    if (_samePoint(point, state.dpLocation) && !state.dpFromManual) return;
    state = state.copyWith(
      dpLocation: point,
      dpFromManual: false,
      clearRoute: true,
      clearRouteNote: true,
    );
    _scheduleRoute();
  }

  /// Captures the device position for the DP marker, overriding a FAT auto-fill.
  /// Returns a snackbar-ready error message, or `null` on success.
  Future<String?> captureDpLocation() async {
    try {
      final position = await ref.read(locationServiceProvider).getCurrentPosition();
      state = state.copyWith(
        dpLocation: LatLng(position.latitude, position.longitude),
        dpFromManual: true,
        clearRoute: true,
        clearRouteNote: true,
      );
      _scheduleRoute();
      return null;
    } on LocationException catch (e) {
      return e.message;
    } catch (_) {
      return AppStrings.snackbarLocationFailed;
    }
  }

  /// Captures the device position for the user marker.
  Future<String?> captureUserLocation() async {
    try {
      final position = await ref.read(locationServiceProvider).getCurrentPosition();
      setUserLocation(LatLng(position.latitude, position.longitude));
      return null;
    } on LocationException catch (e) {
      return e.message;
    } catch (_) {
      return AppStrings.snackbarLocationFailed;
    }
  }

  void _scheduleRoute() {
    _debounce?.cancel();
    final user = state.userLocation;
    final dp = state.dpLocation;
    if (user == null || dp == null) {
      // Not enough points → no line. Drop any stale route from a prior state.
      if (state.isRouteCalculating || state.route != null || state.routeNote != null) {
        state = state.copyWith(
          isRouteCalculating: false,
          clearRoute: true,
          clearRouteNote: true,
        );
      }
      return;
    }
    state = state.copyWith(isRouteCalculating: true);
    _debounce = Timer(_routeDebounce, () => _calculateRoute(user, dp));
  }

  Future<void> _calculateRoute(LatLng user, LatLng dp) async {
    try {
      final result = await ref.read(routeRepositoryProvider).calculateRoute(
            _requestId,
            userLatitude: user.latitude,
            userLongitude: user.longitude,
            dpLatitude: dp.latitude,
            dpLongitude: dp.longitude,
          );
      // Ignore a stale result if the points moved again while the call ran.
      final current = state;
      if (!_samePoint(current.userLocation, user) ||
          !_samePoint(current.dpLocation, dp)) {
        return;
      }
      // The route result is already decoded into `points` by
      // [RouteResult.fromJson] — a real multi-point OSRM path, not a straight
      // line. The straight-line fallback below is ONLY for the genuine
      // failure case (backend returned no points).
      final decoded = result.points;
      if (decoded != null && decoded.length >= 2) {
        state = current.copyWith(
          route: decoded,
          routeNote: null,
          clearRouteNote: true,
          isRouteCalculating: false,
        );
      } else {
        state = current.copyWith(
          route: [user, dp],
          routeNote: AppStrings.mapRouteStraightLine,
          isRouteCalculating: false,
        );
      }
    } on Exception {
      state = state.copyWith(
        clearRoute: true,
        routeNote: AppStrings.mapRouteUnavailable,
        isRouteCalculating: false,
      );
    }
  }

  static bool _samePoint(LatLng? a, LatLng? b) {
    if (a == null || b == null) return a == b;
    return a.latitude == b.latitude && a.longitude == b.longitude;
  }
}

/// Coordinates + route state for the merged installation detail screen.
final installationMapControllerProvider =
    NotifierProvider.family<InstallationMapController, InstallationMapState, String>(
  InstallationMapController.new,
);