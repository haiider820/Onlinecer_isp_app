import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/providers.dart';
import '../storage/secure_storage.dart';

/// Persisted UI theme choice, surfaced as a [ThemeMode].
///
/// `null`/missing storage value means [ThemeMode.system]. The choice survives
/// restarts via [SecureStorage].
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return ThemeModeNotifier(storage)..load();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier(this._storage) : super(ThemeMode.system);

  final SecureStorage _storage;

  Future<void> load() async {
    final raw = await _storage.getThemeMode();
    if (!mounted) return;
    state = _fromWire(raw);
  }

  /// Cycles system → light → dark → system.
  Future<void> cycle() async {
    final next = switch (state) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    };
    await set(next);
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    await _storage.setThemeMode(_toWire(mode));
  }

  static ThemeMode _fromWire(String? raw) {
    return switch (raw) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  static String? _toWire(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => null,
    };
  }
}
