import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/services/base_api_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/models/api_response.dart';
import '../models/statistics_data.dart';

class StatisticsService extends BaseApiService {
  // Get user statistics from API with fallback to mock data
  Future<ApiResponse<StatisticsData>> getStatisticsData({
    BuildContext? context,
  }) async {
    try {
      final language = getCurrentLanguage(context);

      // Try API first
      try {
        final response = await handleResponse<StatisticsData>(
          get(
            ApiConstants.statistics,
            language: language,
          ),
          StatisticsData.fromJson,
        );

        if (response.success && response.data != null) {
          return response;
        }
      } catch (apiError) {
        print(
            'Statistics API çağrısı başarısız, mock verilere geçiliyor: $apiError');
      }

      // Fallback to mock data
      return await _loadMockStatistics();
    } catch (e) {
      return await _loadMockStatistics();
    }
  }

  // Load mock statistics from assets
  Future<ApiResponse<StatisticsData>> _loadMockStatistics() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/data/statistics_data.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      final statisticsData = StatisticsData.fromJson(jsonData);

      return ApiResponse<StatisticsData>(
        success: true,
        statusCode: 100,
        message: 'Mock istatistikler başarıyla yüklendi',
        data: statisticsData,
      );
    } catch (e) {
      // Create default empty statistics if mock data fails
      final defaultStats = StatisticsData(
        overallStats: OverallStats(
          totalExamsTaken: 0,
          totalAvailableExams: 12,
          averageScore: 0,
          bestScore: 0,
          totalStudyTime: 0,
          totalQuestionsAnswered: 0,
          correctAnswersRate: 0,
        ),
        categoryPerformance: [],
        recentExams: [],
      );

      return ApiResponse<StatisticsData>(
        success: true,
        statusCode: 100,
        message: 'Varsayılan istatistikler yüklendi',
        data: defaultStats,
      );
    }
  }

  // Get category statistics with fallback
  Future<ApiResponse<CategoryStatistics>> getCategoryStatistics(
    String categoryId, {
    BuildContext? context,
  }) async {
    try {
      final language = getCurrentLanguage(context);

      // Try API first
      try {
        final response = await handleResponse<CategoryStatistics>(
          get(
            ApiConstants.categoryStatistics(categoryId),
            language: language,
          ),
          CategoryStatistics.fromJson,
        );

        if (response.success && response.data != null) {
          return response;
        }
      } catch (apiError) {
        print(
            'Category statistics API çağrısı başarısız, mock verilere geçiliyor: $apiError');
      }

      // Fallback to mock data
      return await _loadMockCategoryStatistics(categoryId);
    } catch (e) {
      return await _loadMockCategoryStatistics(categoryId);
    }
  }

  // Load mock category statistics
  Future<ApiResponse<CategoryStatistics>> _loadMockCategoryStatistics(
      String categoryId) async {
    try {
      // Create default category statistics
      final defaultCategoryStats = CategoryStatistics(
        categoryId: categoryId,
        categoryName: _getCategoryName(categoryId),
        totalQuestions: 20,
        completedQuestions: 0,
        correctAnswers: 0,
        averageScore: 0,
        bestScore: 0,
        lastAttempt: null,
        weakTopics: [],
        strongTopics: [],
        timeSpentMinutes: 0,
        improvementTrend: 'stable',
      );

      return ApiResponse<CategoryStatistics>(
        success: true,
        statusCode: 100,
        message: 'Varsayılan kategori istatistikleri yüklendi',
        data: defaultCategoryStats,
      );
    } catch (e) {
      return ApiResponse<CategoryStatistics>(
        success: false,
        statusCode: 500,
        message: 'Kategori istatistikleri yüklenemedi: $e',
      );
    }
  }

  // Helper method to get category name
  String _getCategoryName(String categoryId) {
    switch (categoryId) {
      case 'traffic_signs':
        return 'Trafik İşaretleri';
      case 'traffic_rules':
        return 'Trafik Kuralları';
      case 'first_aid':
        return 'İlk Yardım';
      case 'vehicle_tech':
        return 'Araç Tekniği';
      default:
        return 'Bilinmeyen Kategori';
    }
  }
}

// Category statistics model (if not already defined)
class CategoryStatistics {
  final String categoryId;
  final String categoryName;
  final int totalQuestions;
  final int completedQuestions;
  final int correctAnswers;
  final double averageScore;
  final double bestScore;
  final DateTime? lastAttempt;
  final List<String> weakTopics;
  final List<String> strongTopics;
  final int timeSpentMinutes;
  final String improvementTrend;

  CategoryStatistics({
    required this.categoryId,
    required this.categoryName,
    required this.totalQuestions,
    required this.completedQuestions,
    required this.correctAnswers,
    required this.averageScore,
    required this.bestScore,
    this.lastAttempt,
    required this.weakTopics,
    required this.strongTopics,
    required this.timeSpentMinutes,
    required this.improvementTrend,
  });

  factory CategoryStatistics.fromJson(Map<String, dynamic> json) {
    return CategoryStatistics(
      categoryId: json['category_id'] ?? '',
      categoryName: json['category_name'] ?? '',
      totalQuestions: json['total_questions'] ?? 0,
      completedQuestions: json['completed_questions'] ?? 0,
      correctAnswers: json['correct_answers'] ?? 0,
      averageScore: (json['average_score'] ?? 0).toDouble(),
      bestScore: (json['best_score'] ?? 0).toDouble(),
      lastAttempt: json['last_attempt'] != null
          ? DateTime.parse(json['last_attempt'])
          : null,
      weakTopics: List<String>.from(json['weak_topics'] ?? []),
      strongTopics: List<String>.from(json['strong_topics'] ?? []),
      timeSpentMinutes: json['time_spent_minutes'] ?? 0,
      improvementTrend: json['improvement_trend'] ?? 'stable',
    );
  }
}
