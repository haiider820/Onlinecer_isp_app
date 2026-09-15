import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'core/router/app_router.dart';
import 'core/storage/secure_storage.dart';
import 'core/theme/app_theme.dart';
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

class IspOnlinecerApp extends StatelessWidget {
  const IspOnlinecerApp({super.key, required this.storage});

  final SecureStorage storage;

  @override
  Widget build(BuildContext context) {
    final router = buildAppRouter(storage: storage);

    return MaterialApp.router(
      title: 'ISP OnlineCER',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: router,
    );
  }
}
