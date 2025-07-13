import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/services/base_api_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/models/api_response.dart';

class HomeService extends BaseApiService {
  // Get home data from API with fallback to mock data
  Future<ApiResponse<HomeData>> getHomeData({
    BuildContext? context,
  }) async {
    try {
      final language = getCurrentLanguage(context);

      // Try API first
      try {
        final response = await handleResponse<HomeData>(
          get(
            ApiConstants.home,
            language: language,
          ),
          HomeData.fromJson,
        );

        if (response.success && response.data != null) {
          return response;
        }
      } catch (apiError) {
        print(
            'Home data API çağrısı başarısız, mock verilere geçiliyor: $apiError');
      }

      // Fallback to mock data
      return await _loadMockHomeData();
    } catch (e) {
      return await _loadMockHomeData();
    }
  }

  // Load mock home data from assets
  Future<ApiResponse<HomeData>> _loadMockHomeData() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/data/home_data.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      final homeData = HomeData.fromJson(jsonData);

      return ApiResponse<HomeData>(
        success: true,
        statusCode: 100,
        message: 'Mock ana sayfa verileri başarıyla yüklendi',
        data: homeData,
      );
    } catch (e) {
      // Create default home data if mock fails
      final defaultHomeData = HomeData(
        welcomeMessage: {'tr': 'Hoş Geldiniz!', 'en': 'Welcome!'},
        motivationalQuote: {
          'tr': 'Başarıya giden yolda her adım önemlidir.',
          'en': 'Every step on the road to success is important.'
        },
        todaysGoal: {'tr': 'Bugün 5 soru çöz', 'en': 'Solve 5 questions today'},
        userProgress: UserProgress(
          completedExams: 0,
          totalExams: 12,
          averageScore: 0,
          lastActivity: null,
        ),
        featuredTopics: [],
      );

      return ApiResponse<HomeData>(
        success: true,
        statusCode: 100,
        message: 'Varsayılan ana sayfa verileri yüklendi',
        data: defaultHomeData,
      );
    }
  }

  // Get welcome message with fallback
  Future<ApiResponse<WelcomeMessage>> getWelcomeMessage({
    BuildContext? context,
  }) async {
    try {
      final language = getCurrentLanguage(context);

      // Try API first
      try {
        final response = await handleResponse<WelcomeMessage>(
          get(
            ApiConstants.home,
            language: language,
          ),
          WelcomeMessage.fromJson,
        );

        if (response.success && response.data != null) {
          return response;
        }
      } catch (apiError) {
        print(
            'Welcome message API çağrısı başarısız, mock verilere geçiliyor: $apiError');
      }

      // Fallback to mock data
      return await _loadMockWelcomeMessage();
    } catch (e) {
      return await _loadMockWelcomeMessage();
    }
  }

  // Load mock welcome message
  Future<ApiResponse<WelcomeMessage>> _loadMockWelcomeMessage() async {
    try {
      final mockWelcomeMessage = WelcomeMessage(
        title: {'tr': 'Hoş Geldiniz!', 'en': 'Welcome!'},
        subtitle: {
          'tr': 'Ehliyet sınavına hazırlanmaya başlayalım',
          'en': 'Let\'s start preparing for the driving license exam'
        },
        ctaText: {'tr': 'Hemen Başla', 'en': 'Start Now'},
      );

      return ApiResponse<WelcomeMessage>(
        success: true,
        statusCode: 100,
        message: 'Mock hoş geldin mesajı yüklendi',
        data: mockWelcomeMessage,
      );
    } catch (e) {
      return ApiResponse<WelcomeMessage>(
        success: false,
        statusCode: 500,
        message: 'Hoş geldin mesajı yüklenemedi: $e',
      );
    }
  }
}

// Home data models
class HomeData {
  final Map<String, String> welcomeMessage;
  final Map<String, String> motivationalQuote;
  final Map<String, String> todaysGoal;
  final UserProgress userProgress;
  final List<FeaturedTopic> featuredTopics;

  HomeData({
    required this.welcomeMessage,
    required this.motivationalQuote,
    required this.todaysGoal,
    required this.userProgress,
    required this.featuredTopics,
  });

  factory HomeData.fromJson(Map<String, dynamic> json) {
    return HomeData(
      welcomeMessage: _parseMultiLangField(json['welcome_message']),
      motivationalQuote: _parseMultiLangField(json['motivational_quote']),
      todaysGoal: _parseMultiLangField(json['todays_goal']),
      userProgress: UserProgress.fromJson(json['user_progress'] ?? {}),
      featuredTopics: (json['featured_topics'] as List? ?? [])
          .map((topic) => FeaturedTopic.fromJson(topic))
          .toList(),
    );
  }

  // Helper method to parse multi-language fields
  static Map<String, String> _parseMultiLangField(dynamic field) {
    if (field is Map<String, dynamic>) {
      return field.map((key, value) => MapEntry(key, value?.toString() ?? ''));
    } else if (field is String) {
      return {'tr': field, 'en': field};
    }
    return {'tr': field?.toString() ?? '', 'en': field?.toString() ?? ''};
  }
}

class UserProgress {
  final int completedExams;
  final int totalExams;
  final double averageScore;
  final DateTime? lastActivity;

  UserProgress({
    required this.completedExams,
    required this.totalExams,
    required this.averageScore,
    this.lastActivity,
  });

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      completedExams: json['completed_exams'] ?? 0,
      totalExams: json['total_exams'] ?? 0,
      averageScore: (json['average_score'] ?? 0).toDouble(),
      lastActivity: json['last_activity'] != null
          ? DateTime.parse(json['last_activity'])
          : null,
    );
  }
}

class FeaturedTopic {
  final String id;
  final Map<String, String> title;
  final Map<String, String> description;
  final String imageUrl;
  final int questionCount;

  FeaturedTopic({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.questionCount,
  });

  factory FeaturedTopic.fromJson(Map<String, dynamic> json) {
    return FeaturedTopic(
      id: json['id'] ?? '',
      title: HomeData._parseMultiLangField(json['title']),
      description: HomeData._parseMultiLangField(json['description']),
      imageUrl: json['image_url'] ?? '',
      questionCount: json['question_count'] ?? 0,
    );
  }
}

class WelcomeMessage {
  final Map<String, String> title;
  final Map<String, String> subtitle;
  final Map<String, String> ctaText;

  WelcomeMessage({
    required this.title,
    required this.subtitle,
    required this.ctaText,
  });

  factory WelcomeMessage.fromJson(Map<String, dynamic> json) {
    return WelcomeMessage(
      title: HomeData._parseMultiLangField(json['title']),
      subtitle: HomeData._parseMultiLangField(json['subtitle']),
      ctaText: HomeData._parseMultiLangField(json['cta_text']),
    );
  }
}
