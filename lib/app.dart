// lib/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/services/sync_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/providers/auth_providers.dart';

class KrishiSetuRiderApp extends ConsumerWidget {
  const KrishiSetuRiderApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final selectedLanguage = ref.watch(selectedLanguageProvider);

    // Initialize background sync listener
    ref.watch(syncServiceProvider);

    return MaterialApp.router(
      title: 'KrishiSetu Rider',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
      locale: Locale(selectedLanguage.code),
      supportedLocales: const [
        Locale('en', ''),
        Locale('hi', ''),
        Locale('mr', ''),
        Locale('ta', ''),
        Locale('te', ''),
        Locale('kn', ''),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
