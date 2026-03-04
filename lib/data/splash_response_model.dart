class SplashResponseModel {
  final VersionModel? version;
  final MaintenanceModel? maintenance;
  final List<LanguageModel>? languages;
  final String? selectedLanguage;
  final String? deviceKey;

  SplashResponseModel({
    this.version,
    this.maintenance,
    this.languages,
    this.selectedLanguage,
    this.deviceKey,
  });

  /// API yapısı:
  /// "languages": {
  ///   "selectedlanguage": "tr",
  ///   "list": [ { "code": "tr", ... }, ... ]
  /// }
  factory SplashResponseModel.fromJson(Map<String, dynamic> json) {
    // languages alanı object mi (yeni format) yoksa array mi (eski format)?
    final rawLanguages = json['languages'];
    List<LanguageModel>? parsedLanguages;
    String? parsedSelectedLanguage;

    if (rawLanguages is Map<String, dynamic>) {
      // Yeni format: { "selectedlanguage": "tr", "list": [...] }
      parsedSelectedLanguage = (rawLanguages['selectedlanguage'] ??
          rawLanguages['selectedLanguage']) as String?;
      final list = rawLanguages['list'];
      if (list is List) {
        parsedLanguages = list
            .map((i) => LanguageModel.fromJson(i as Map<String, dynamic>))
            .toList();
      }
    } else if (rawLanguages is List) {
      // Eski format: direkt array
      parsedLanguages = rawLanguages
          .map((i) => LanguageModel.fromJson(i as Map<String, dynamic>))
          .toList();
    }

    return SplashResponseModel(
      version: json['version'] != null
          ? VersionModel.fromJson(json['version'])
          : null,
      maintenance: json['maintenance'] != null
          ? MaintenanceModel.fromJson(json['maintenance'])
          : null,
      languages: parsedLanguages,
      // Hem yeni format (languages objesi içinde) hem de eski (data root'ta)
      selectedLanguage:
          parsedSelectedLanguage ?? json['selectedLanguage'] as String?,
      deviceKey: json['device_key'],
    );
  }
}

class VersionModel {
  final String? ios;
  final String? android;
  final bool? forceUpdate;
  final String? updateUrl;
  final String? title;
  final String? description;

  VersionModel({
    this.ios,
    this.android,
    this.forceUpdate,
    this.updateUrl,
    this.title,
    this.description,
  });

  factory VersionModel.fromJson(Map<String, dynamic> json) {
    return VersionModel(
      ios: json['ios'],
      android: json['android'],
      forceUpdate: json['force_update'] as bool? ?? false,
      updateUrl: json['update_url'],
      title: json['title'],
      description: json['description'],
    );
  }
}

class MaintenanceModel {
  final bool status;
  final String? title;
  final String? description;
  final String? endTime;

  MaintenanceModel({
    required this.status,
    this.title,
    this.description,
    this.endTime,
  });

  factory MaintenanceModel.fromJson(Map<String, dynamic> json) {
    return MaintenanceModel(
      status: json['status'] as bool? ?? false,
      title: json['title'],
      description: json['description'],
      endTime: json['end_time'],
    );
  }
}

class LanguageModel {
  final String code;
  final String name;
  final String? flag;
  final bool isDefault;

  LanguageModel({
    required this.code,
    required this.name,
    this.flag,
    this.isDefault = false,
  });

  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    return LanguageModel(
      code: json['code'] ?? 'tr',
      name: json['name'] ?? 'Türkçe',
      flag: json['flag'],
      isDefault: json['is_default'] as bool? ?? false,
    );
  }
}
