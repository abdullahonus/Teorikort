import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/config/http_log_manager.dart';

/// Uygulama başlatma mantığını merkezi olarak yönetir.
/// main.dart sadece bunu çağırır; DI, storage, bootstrap burada yaşar.
class AppBootstrap {
  const AppBootstrap._();

  /// Flutter binding + ağ/log başlatma, ilk ProviderContainer oluşturma.
  static Future<ProviderContainer> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Chucker HTTP logger
    HttpLogManager.check();

    // ProviderContainer: shared_preferences gibi async bağımlılıklar
    // gerektiğinde burada override edilebilir.
    final container = ProviderContainer(
      overrides: [
        // Örnek: sharedPreferencesProvider.overrideWithValue(prefs),
      ],
    );

    return container;
  }

  /// Sistem dilinden başlangıç locale'ini belirler.
  static String resolveInitialLocale() {
    final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
    return systemLocale.languageCode == 'tr' ? 'tr' : 'en';
  }
}
