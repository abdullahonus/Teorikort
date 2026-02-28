# 🌍 Localization (Dil Desteği) Kılavuzu

Bu dokümanda **Teorikort** projesindeki dil desteği sisteminin nasıl çalıştığını ve yeni dil metinleri ekleme adımlarını bulabilirsiniz.

## 📁 Dosya Yapısı

```
lib/
├── core/
│   ├── localization/
│   │   └── app_localization.dart     # Ana localization sınıfı
│   └── providers/
│       └── locale_provider.dart      # Dil değiştirme yönetimi
├── main.dart                         # Localization konfigürasyonu
assets/
└── data/
    ├── en.json                       # İngilizce metinler
    └── tr.json                       # Türkçe metinler
```

## 🔧 Sistem Nasıl Çalışır?

### 1. Ana Yapılandırma (`main.dart`)

```dart
MaterialApp(
  locale: locale,                     // Aktif dil
  supportedLocales: const [
    Locale('tr', 'TR'),              // Türkçe
    Locale('en', 'US'),              // İngilizce
  ],
  localizationsDelegates: const [
    AppLocalization.delegate,         // Özel localization delegate
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
)
```

### 2. Dil Dosyaları (`assets/data/`)

**EN.json örneği:**
```json
{
  "app_name": "Driving License",
  "common": {
    "save": "Save",
    "cancel": "Cancel"
  },
  "home": {
    "welcome": "Welcome",
    "quick_start": "Quick Start"
  }
}
```

**TR.json örneği:**
```json
{
  "app_name": "Ehliyet Sınavı",
  "common": {
    "save": "Kaydet",
    "cancel": "İptal"
  },
  "home": {
    "welcome": "Hoş Geldiniz",
    "quick_start": "Hızlı Başlangıç"
  }
}
```

### 3. Localization Sınıfı (`app_localization.dart`)

```dart
class AppLocalization {
  String translate(String key) {
    List<String> keys = key.split('.');
    dynamic value = _localizedStrings;
    
    // "home.welcome" -> ["home", "welcome"]
    for (String k in keys) {
      value = value[k];
    }
    
    return value?.toString() ?? key;
  }
}
```

### 4. Dil Değiştirme (`locale_provider.dart`)

```dart
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  Future<void> setLocale(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', languageCode);
    state = Locale(languageCode);
  }
}
```

## 🎯 Kullanım Örnekleri

### Basit Metin
```dart
Text(AppLocalization.of(context).translate('app_name'))
```

### İçiçe Metin (Nested)
```dart
Text(AppLocalization.of(context).translate('home.welcome'))
```

### Dinamik Metin
```dart
Text('${user.name} ${AppLocalization.of(context).translate('home.welcome')}')
```

## ➕ Yeni Metin Ekleme Adımları

### Adım 1: Dil Dosyalarına Ekle

**1.1 EN.json'a ekle:**
```json
{
  "exam": {
    "new_feature": "New Feature",
    "description": "This is a new feature description"
  }
}
```

**1.2 TR.json'a ekle:**
```json
{
  "exam": {
    "new_feature": "Yeni Özellik", 
    "description": "Bu yeni özellik açıklamasıdır"
  }
}
```

### Adım 2: Kodda Kullan

```dart
// Widget'ınızda
Text(AppLocalization.of(context).translate('exam.new_feature'))

// Açıklama için
Text(AppLocalization.of(context).translate('exam.description'))
```

## 📋 Kategori Örnekleri

### Genel Metinler
```json
"common": {
  "save": "Save" / "Kaydet",
  "cancel": "Cancel" / "İptal",
  "delete": "Delete" / "Sil",
  "edit": "Edit" / "Düzenle"
}
```

### Ekran Başlıkları
```json
"statistics": {
  "screen_title": "Statistics" / "İstatistikler"
}
```

### Buton Metinleri
```json
"auth": {
  "sign_in": "Sign In" / "Giriş Yap",
  "sign_up": "Sign Up" / "Kayıt Ol"
}
```

### Hata Mesajları
```json
"errors": {
  "network_error": "Network Error" / "Ağ Hatası",
  "invalid_input": "Invalid Input" / "Geçersiz Giriş"
}
```

## 🔄 Dil Değiştirme

### Kullanıcı Arayüzünde
```dart
// Language Selector Widget'ı
DropdownButton<String>(
  value: currentLocale,
  items: [
    DropdownMenuItem(value: 'tr', child: Text('Türkçe')),
    DropdownMenuItem(value: 'en', child: Text('English')),
  ],
  onChanged: (locale) {
    ref.read(localeProvider.notifier).setLocale(locale!);
  },
)
```

### Programatik Olarak
```dart
// Türkçe'ye geç
ref.read(localeProvider.notifier).setLocale('tr');

// İngilizce'ye geç
ref.read(localeProvider.notifier).setLocale('en');
```

## ⚠️ Önemli Notlar

### 1. JSON Dosya Senkronizasyonu
- Her iki dil dosyasında da **aynı key yapısı** olmalı
- Eksik key'ler fallback olarak key'in kendisini gösterir

### 2. Hot Reload
- JSON dosyalarında değişiklik yaptıktan sonra **hot restart** gerekir
- Sadece hot reload yeterli değil

### 3. Key Naming Convention
```json
{
  "section": {
    "subsection": {
      "specific_text": "value"
    }
  }
}
```

### 4. Pluralization
```json
{
  "items": {
    "one": "1 item",
    "other": "%d items"
  }
}
```

## 🚀 Pratik İpuçları

### 1. Organizasyon
- Ekran bazında grupla: `home.*`, `profile.*`
- Ortak metinler için: `common.*`
- Hata mesajları için: `errors.*`

### 2. Naming
- Snake_case kullan: `new_feature`
- Açıklayıcı isimler: `welcome_message` ✅ `msg1` ❌

### 3. Testing
```dart
// Test için
AppLocalization.of(context).translate('test.key')

// Çıktı: Eğer key yoksa, key'in kendisini döner
```

## 📝 Örnek: Yeni Özellik Ekleme

Diyelim ki bir "Quiz Timer" özelliği ekliyorsunuz:

### 1. EN.json
```json
{
  "quiz": {
    "timer": {
      "title": "Quiz Timer",
      "remaining": "Time Remaining",
      "expired": "Time Expired",
      "minutes": "minutes",
      "seconds": "seconds"
    }
  }
}
```

### 2. TR.json
```json
{
  "quiz": {
    "timer": {
      "title": "Quiz Zamanlayıcısı",
      "remaining": "Kalan Süre",
      "expired": "Süre Doldu", 
      "minutes": "dakika",
      "seconds": "saniye"
    }
  }
}
```

### 3. Widget'ta Kullanım
```dart
class QuizTimer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(AppLocalization.of(context).translate('quiz.timer.title')),
        Text('${minutes} ${AppLocalization.of(context).translate('quiz.timer.minutes')}'),
        Text('${seconds} ${AppLocalization.of(context).translate('quiz.timer.seconds')}'),
      ],
    );
  }
}
```

Bu kılavuz ile projenizdeki tüm metinleri kolayca çok dilli hale getirebilirsiniz! 🎉 