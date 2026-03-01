
class SplashResponseModel {
  final VersionModel? version;
  final MaintenanceModel? maintenance;
  final List<LanguageModel>? languages;
  final String? deviceKey;

  SplashResponseModel({
    this.version,
    this.maintenance,
    this.languages,
    this.deviceKey,
  });

  factory SplashResponseModel.fromJson(Map<String, dynamic> json) {
    return SplashResponseModel(
      version: json['version'] != null ? VersionModel.fromJson(json['version']) : null,
      maintenance: json['maintenance'] != null ? MaintenanceModel.fromJson(json['maintenance']) : null,
      languages: json['languages'] != null 
          ? (json['languages'] as List).map((i) => LanguageModel.fromJson(i)).toList() 
          : null,
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
      name: json['name'] ?? 'Turkish',
      flag: json['flag'],
      isDefault: json['is_default'] as bool? ?? false,
    );
  }
}
