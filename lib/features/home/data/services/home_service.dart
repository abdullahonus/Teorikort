import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/services/base_api_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/models/api_response.dart';
import 'daily_tip_service.dart';

class HomeService extends BaseApiService {
  // Get home data from API
  Future<ApiResponse<HomeData>> getHomeData({
    BuildContext? context,
  }) async {
    final language = getCurrentLanguage(context);

    return await handleResponse<HomeData>(
      get(
        ApiConstants.home,
        language: language,
      ),
      HomeData.fromJson,
    );
  }

  // Get welcome message
  Future<ApiResponse<WelcomeMessage>> getWelcomeMessage({
    BuildContext? context,
  }) async {
    final language = getCurrentLanguage(context);

    return await handleResponse<WelcomeMessage>(
      get(
        ApiConstants.home,
        language: language,
      ),
      WelcomeMessage.fromJson,
    );
  }
}

// Home data models
class HomeData {
  final Map<String, String> welcomeMessage;
  final Map<String, String> motivationalQuote;
  final Map<String, String> todaysGoal;
  final UserProgress userProgress;
  final List<FeaturedTopic> featuredTopics;
  final DailyTip? dailyTip;

  HomeData({
    required this.welcomeMessage,
    required this.motivationalQuote,
    required this.todaysGoal,
    required this.userProgress,
    required this.featuredTopics,
    this.dailyTip,
  });

  factory HomeData.fromJson(Map<String, dynamic> json) {
    return HomeData(
      welcomeMessage: _parseMultiLangField(json['welcome_message']),
      motivationalQuote: _parseMultiLangField(
          json['motivational_quote'] ?? 'Başarıya giden yolda her adım önemlidir.'),
      todaysGoal: _parseMultiLangField(json['todays_goal'] ?? 'Bugün 5 soru çöz'),
      userProgress: UserProgress.fromJson(json['user_progress'] ?? {}),
      featuredTopics: (json['featured_topics'] as List? ?? [])
          .map((topic) => FeaturedTopic.fromJson(topic))
          .toList(),
      dailyTip: json['daily_tip'] != null
          ? DailyTip.fromJson(json['daily_tip'])
          : null,
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
  final int completedCategories;
  final int totalCategories;
  final double progressPercentage;

  UserProgress({
    required this.completedExams,
    required this.totalExams,
    required this.averageScore,
    this.lastActivity,
    this.completedCategories = 0,
    this.totalCategories = 0,
    this.progressPercentage = 0,
  });

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      completedExams: json['completed_exams'] ?? 0,
      totalExams: json['total_exams'] ?? 0,
      averageScore: (json['average_score'] ?? 0).toDouble(),
      lastActivity: json['last_activity'] != null
          ? DateTime.parse(json['last_activity'])
          : null,
      completedCategories: json['completed_categories'] ?? 0,
      totalCategories: json['total_categories'] ?? 4,
      progressPercentage: (json['progress_percentage'] ?? 0).toDouble(),
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
