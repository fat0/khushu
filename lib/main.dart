import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/storage/hive_service.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/settings_provider.dart';
import 'navigation/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  runApp(const ProviderScope(child: KhushuApp()));
}

class KhushuApp extends ConsumerWidget {
  const KhushuApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final router = ref.watch(routerProvider);

    final themeMode = switch (settings.darkMode) {
      true => ThemeMode.dark,
      false => ThemeMode.light,
      null => ThemeMode.system,
    };

    return MaterialApp.router(
      title: 'Khushu',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
