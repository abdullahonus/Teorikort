import 'package:driving_license_exam/core/providers/theme_provider.dart';
import 'package:driving_license_exam/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:driving_license_exam/features/splash/presentation/splash_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:driving_license_exam/core/localization/app_localization.dart';
import 'package:driving_license_exam/core/providers/locale_provider.dart';
import 'package:driving_license_exam/core/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Sistem dilini al
  final systemLocale = WidgetsBinding.instance.window.locale;
  final initialLocale = systemLocale.languageCode == 'tr' ? 'tr' : 'en';

  // Locale provider'ı başlat
  final container = ProviderContainer();
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
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'Driving License Exam',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: locale,
      supportedLocales: const [
        Locale('tr', 'TR'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        AppLocalization.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const SplashScreen(),
    );
  }
}
