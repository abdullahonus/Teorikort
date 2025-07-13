import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
      id: json['id'] as int,
      title: _parseMultiLangField(json['title']),
      content: _parseMultiLangField(json['content']),
      category: json['category'] as String,
      icon: json['icon'] as String,
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
  // Get daily tip from API with fallback to mock data
  Future<DailyTip?> getDailyTip({BuildContext? context}) async {
    try {
      final language = getCurrentLanguage(context);

      // Try API first
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
      } catch (apiError) {
        print(
            'Daily tip API çağrısı başarısız, mock verilere geçiliyor: $apiError');
      }

      // Fallback to mock data
      return await _loadMockDailyTip();
    } catch (e) {
      print('Daily tip yükleme hatası: $e');
      return await _loadMockDailyTip();
    }
  }

  // Load mock daily tip from assets
  Future<DailyTip?> _loadMockDailyTip() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/data/daily_tips.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      final List<dynamic> tips = jsonData['tips'] ?? [];
      if (tips.isEmpty) return null;

      // Get saved index or random
      final prefs = await SharedPreferences.getInstance();
      final today =
          DateTime.now().toIso8601String().split('T')[0]; // YYYY-MM-DD
      final savedDate = prefs.getString('daily_tip_date');

      int tipIndex;
      if (savedDate == today) {
        // Same day, use saved index
        tipIndex = prefs.getInt('daily_tip_index') ?? 0;
      } else {
        // New day, get random tip
        tipIndex = DateTime.now().day % tips.length;
        await prefs.setString('daily_tip_date', today);
        await prefs.setInt('daily_tip_index', tipIndex);
      }

      final tipData = tips[tipIndex] as Map<String, dynamic>;
      return DailyTip.fromJson(tipData);
    } catch (e) {
      print('Mock daily tip yükleme hatası: $e');
      return null;
    }
  }

  // Get daily tip from API (for direct API usage)
  Future<ApiResponse<DailyTip>> getDailyTipFromApi({
    BuildContext? context,
  }) async {
    try {
      final language = getCurrentLanguage(context);

      // Try API first
      try {
        final response = await handleResponse<DailyTip>(
          get(
            ApiConstants.dailyTips,
            language: language,
          ),
          DailyTip.fromJson,
        );

        if (response.success && response.data != null) {
          return response;
        }
      } catch (apiError) {
        print(
            'Daily tip API çağrısı başarısız, mock verilere geçiliyor: $apiError');
      }

      // Fallback to mock data
      final mockTip = await _loadMockDailyTip();
      if (mockTip != null) {
        return ApiResponse<DailyTip>(
          success: true,
          statusCode: 100,
          message: 'Mock günlük ipucu yüklendi',
          data: mockTip,
        );
      }

      return ApiResponse<DailyTip>(
        success: false,
        statusCode: 404,
        message: 'Günlük ipucu bulunamadı',
      );
    } catch (e) {
      return ApiResponse<DailyTip>(
        success: false,
        statusCode: 500,
        message: 'Günlük ipucu yüklenemedi: $e',
      );
    }
  }
}
