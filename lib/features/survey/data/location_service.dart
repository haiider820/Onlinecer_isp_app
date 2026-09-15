import 'package:geolocator/geolocator.dart';

/// Location failure with a message safe to show directly to the user.
class LocationException implements Exception {
  const LocationException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Thin seam over the geolocator plugin so the route screen can be tested
/// without a real device GPS. Mirrors the network-seam pattern: the UI depends
/// on this interface, and a fake can be swapped in for widget tests.
abstract interface class LocationService {
  /// Returns the device's current position, throwing [LocationException] with a
  /// user-presentable message when services are off, permission is missing, or
  /// the fix fails.
  Future<Position> getCurrentPosition();
}