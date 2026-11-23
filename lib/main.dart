import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import 'core/router/app_router.dart';
import 'core/storage/secure_storage.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_provider.dart';
import 'features/auth/presentation/providers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = SecureStorage(const FlutterSecureStorage());

  runApp(
    ProviderScope(
      overrides: [secureStorageProvider.overrideWithValue(storage)],
      child: IspOnlinecerApp(storage: storage),
    ),
  );
}

class IspOnlinecerApp extends ConsumerStatefulWidget {
  const IspOnlinecerApp({super.key, required this.storage});

  final SecureStorage storage;

  @override
  ConsumerState<IspOnlinecerApp> createState() => _IspOnlinecerAppState();
}

class _IspOnlinecerAppState extends ConsumerState<IspOnlinecerApp> {
  /// Built exactly once. Rebuilding the router on every widget rebuild
  /// (e.g. a theme toggle, which watches [themeModeProvider]) dropped the
  /// navigation stack back to /boot and re-ran the boot gate (D2).
  late final GoRouter _router = buildAppRouter(storage: widget.storage);

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'ISP OnlineCER',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: _router,
    );
  }
}
