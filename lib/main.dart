import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teorikort/core/services/navigation_service.dart';

import 'core/localization/app_localization.dart';
import 'core/providers/locale_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/theme/app_theme.dart';
import 'feature/splash/splash_view.dart';
import 'product/init/app_bootstrap.dart';

void main() async {
  final container = await AppBootstrap.initialize();

  // Başlangıç locale'ini çöz ve ayarla
  final initialLocale = AppBootstrap.resolveInitialLocale();
  container.read(localeProvider.notifier).setLocale(initialLocale);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);
    final availableLanguages = ref.watch(availableLanguagesProvider);

    // Splash API'den gelen dil listesi → supportedLocales
    final supportedLocales =
        availableLanguages.map((l) => Locale(l.code)).toList();

    // Fallback: en az tr ve en olsun
    if (supportedLocales.isEmpty) {
      supportedLocales.addAll([const Locale('tr'), const Locale('en')]);
    }

    return MaterialApp(
      navigatorKey: NavigationService.navigatorKey,
      title: 'Teorikort',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: locale,
      navigatorObservers: [ChuckerFlutter.navigatorObserver],
      supportedLocales: supportedLocales,
      localizationsDelegates: const [
        AppLocalization.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const SplashView(),
    );
  }
}
