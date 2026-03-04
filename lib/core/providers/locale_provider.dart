import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teorikort/data/splash_response_model.dart';

// ─── Available Languages Provider (Splash'tan doldurulur) ──────────────────────
final availableLanguagesProvider = StateProvider<List<LanguageModel>>((ref) => [
      LanguageModel(code: 'tr', name: 'Türkçe', flag: '🇹🇷', isDefault: true),
      LanguageModel(
          code: 'en', name: 'English', flag: '🇬🇧', isDefault: false),
    ]);

// ─── Locale Provider ──────────────────────────────────────────────────────────
final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);

// ─── Notifier ─────────────────────────────────────────────────────────────────
class LocaleNotifier extends Notifier<Locale> {
  static const _key = 'locale';

  @override
  Locale build() {
    _loadSavedLocale();
    return const Locale('tr');
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString(_key) ?? 'tr';
    state = Locale(savedLocale);
  }

  /// Splash API'sinden gelen dil verisiyle başlatılır.
  /// [languages] — splash'tan gelen dil listesi
  /// [selectedLanguage] — splash'ın önerdiği dil kodu ('tr', 'en', vb.)
  Future<void> initFromSplash({
    required List<LanguageModel> languages,
    String? selectedLanguage,
  }) async {
    // 1. Dil listesini güncelle
    ref.read(availableLanguagesProvider.notifier).state = languages;

    // 2. SharedPreferences'de kayıtlı dil varsa onu kullan,
    //    yoksa splash'ın önerdiği dile ya da default'a geç
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);

    final supportedCodes = languages.map((l) => l.code).toList();

    String targetCode;
    if (saved != null && supportedCodes.contains(saved)) {
      // Kullanıcının önceki tercihi
      targetCode = saved;
    } else if (selectedLanguage != null &&
        supportedCodes.contains(selectedLanguage)) {
      // Splash'ın önerisi
      targetCode = selectedLanguage;
    } else {
      // Varsayılan (is_default: true)
      targetCode = languages
          .firstWhere((l) => l.isDefault, orElse: () => languages.first)
          .code;
    }

    await prefs.setString(_key, targetCode);
    state = Locale(targetCode);
  }

  /// Kullanıcı ayarlardan/login ekranından dil değiştirdiğinde
  Future<void> setLocale(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, languageCode);
    state = Locale(languageCode);
  }

  /// Desteklenen dil kodları
  List<String> get supportedCodes {
    return ref.read(availableLanguagesProvider).map((l) => l.code).toList();
  }
}
