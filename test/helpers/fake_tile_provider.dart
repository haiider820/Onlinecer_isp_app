import 'package:flutter/painting.dart';
import 'package:flutter_map/flutter_map.dart';

/// Deterministic, network-free [TileProvider] for widget tests.
///
/// Every tile renders the package's own 1×1 transparent PNG, so no tile HTTP
/// request leaves the test runner while the map still lays out, fits its
/// camera and paints markers/polylines normally. Override
/// `mapTileProviderProvider` with this in `ProviderScope` overrides.
class FakeTileProvider extends TileProvider {
  FakeTileProvider();

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    return MemoryImage(TileProvider.transparentImage);
  }
}