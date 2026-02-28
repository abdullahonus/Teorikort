import 'package:flutter/material.dart';
import '../../../../core/services/base_api_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/models/api_response.dart';

class DailyTip {
  final int id;
  final Map<String, String> title; // Multi-language support
  final Map<String, String> content; // Multi-language support
  final String category;
  final String icon;
  final String? date;

  DailyTip({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.icon,
    this.date,
  });

  factory DailyTip.fromJson(Map<String, dynamic> json) {
    return DailyTip(
      id: json['id'] as int? ?? 0,
      title: _parseMultiLangField(json['title']),
      content: _parseMultiLangField(json['content']),
      category: json['category'] as String? ?? 'general',
      icon: json['icon'] as String? ?? 'lightbulb',
      date: json['date'] as String?,
    );
  }

  // Helper method to get text in specific language
  String getTitle([String language = 'tr']) {
    return title[language] ?? title['tr'] ?? title.values.first;
  }

  String getContent([String language = 'tr']) {
    return content[language] ?? content['tr'] ?? content.values.first;
  }

  // Helper method to parse multi-language fields from API
  static Map<String, String> _parseMultiLangField(dynamic field) {
    if (field is Map<String, dynamic>) {
      return field.map((key, value) => MapEntry(key, value?.toString() ?? ''));
    } else if (field is String) {
      // Fallback for single language (backwards compatibility)
      return {'tr': field, 'en': field};
    }
    return {'tr': field?.toString() ?? '', 'en': field?.toString() ?? ''};
  }
}

class DailyTipService extends BaseApiService {
  // Get daily tip from API
  Future<DailyTip?> getDailyTip({BuildContext? context}) async {
    final language = getCurrentLanguage(context);

    try {
      final response = await handleResponse<DailyTip>(
        get(
          ApiConstants.dailyTips,
          language: language,
        ),
        DailyTip.fromJson,
      );

      if (response.success && response.data != null) {
        return response.data;
      }
    } catch (e) {
      print('Daily tip yükleme hatası: $e');
    }
    return null;
  }

  // Get daily tip from API
  Future<ApiResponse<DailyTip>> getDailyTipFromApi({
    BuildContext? context,
  }) async {
    final language = getCurrentLanguage(context);

    return await handleResponse<DailyTip>(
      get(
        ApiConstants.dailyTips,
        language: language,
      ),
      DailyTip.fromJson,
    );
  }
}
