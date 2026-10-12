import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';
import 'shared/theme/app_theme.dart';
import 'shared/utils/app_providers.dart';

class SocFirApp extends ConsumerWidget {
  const SocFirApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(isDarkModeProvider);
    final accentColor = ref.watch(accentColorProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'SocFir',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(accentColor),
      darkTheme: AppTheme.dark(accentColor),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
    );
  }
}
