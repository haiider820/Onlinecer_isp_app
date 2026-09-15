import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

/// Best-effort device name sent as `device_name` in `POST /login`.
///
/// The backend treats `device_name` as optional, but a stable, short label
/// helps it distinguish sessions. Avoids pulling in `device_info_plus` for a
/// single form field.
abstract final class DeviceInfo {
  DeviceInfo._();

  static String defaultDeviceName() {
    if (kIsWeb) return 'Web';
    final os = defaultTargetPlatform;
    return switch (os) {
      TargetPlatform.android => 'Android',
      TargetPlatform.iOS => 'iOS',
      _ => Platform.operatingSystem,
    };
  }
}