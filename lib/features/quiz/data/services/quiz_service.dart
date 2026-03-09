import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:teorikort/features/exam/data/models/exam_data.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/models/api_response.dart';
import '../../../../core/services/base_api_service.dart';
import '../models/quiz_data.dart';

class QuizService extends BaseApiService {
  // Get questions by category ID from API
  Future<ApiResponse<List<QuizQuestion>>> loadQuizQuestions(
    String categoryId, {
    BuildContext? context,
    int limit = 45,
    String? difficulty,
  }) async {
    final language = getCurrentLanguage(context);
    final queryParams = {
      'per_page': limit.toString(),
      'language': language,
      if (difficulty != null) 'difficulty': difficulty,
    };

    try {
      // The API returns { data: { category: {...}, questions: [...], pagination: {...} } }
      // We use handleResponse and extract 'questions' from the nested data object
      final response = await handleResponse<List<QuizQuestion>>(
        get(
          ApiConstants.examCategoryQuestions(categoryId),
          queryParameters: queryParams,
        ),
        (dynamic json) {
          List<dynamic> questionsList = [];
          if (json is Map<String, dynamic>) {
            questionsList = (json['questions'] as List? ??
                json['data'] as List? ??
                json['items'] as List? ??
                []);
          } else if (json is List) {
            questionsList = json;
          }
          return questionsList
              .map((q) => QuizQuestion.fromJson(q as Map<String, dynamic>))
              .toList();
        },
      );
      return response;
    } catch (e) {
      return ApiResponse<List<QuizQuestion>>(
        success: false,
        statusCode: 500,
        message: 'Sorular yüklenemedi: $e',
      );
    }
  }

  // Get exam categories (Main Categories)
  Future<ApiResponse<List<ExamCategory>>> getExamCategories({
    BuildContext? context,
  }) async {
    final language = getCurrentLanguage(context);

    return await handleListResponse<ExamCategory>(
      get(
        ApiConstants.examCategories,
        language: language,
      ),
      ExamCategory.fromJson,
    );
  }

  // Get exam subcategories
  Future<ApiResponse<List<ExamCategory>>> getExamSubCategories(
    String categoryId, {
    BuildContext? context,
  }) async {
    final language = getCurrentLanguage(context);

    return await handleListResponse<ExamCategory>(
      get(
        ApiConstants.examSubCategories(categoryId),
        language: language,
      ),
      ExamCategory.fromJson,
    );
  }

  // Get tests for a subcategory
  Future<ApiResponse<List<ExamCategory>>> getExamTests(
    String subcategoryId, {
    BuildContext? context,
  }) async {
    final language = getCurrentLanguage(context);

    return await handleListResponse<ExamCategory>(
      get(
        ApiConstants.examTests(subcategoryId),
        language: language,
      ),
      ExamCategory.fromJson,
    );
  }

  // Get questions for a specific test
  Future<ApiResponse<List<QuizQuestion>>> loadTestQuestions(
    String testId, {
    BuildContext? context,
    int limit = 10,
  }) async {
    final language = getCurrentLanguage(context);
    final queryParams = {
      'count': limit.toString(),
      'language': language,
    };

    try {
      final response = await handleResponse<List<QuizQuestion>>(
        get(
          ApiConstants.testQuestions(testId),
          queryParameters: queryParams,
        ),
        (dynamic json) {
          List<dynamic> questionsList = [];
          if (json is Map<String, dynamic>) {
            questionsList = (json['questions'] as List? ??
                json['data'] as List? ??
                json['items'] as List? ??
                []);
          } else if (json is List) {
            questionsList = json;
          }
          return questionsList
              .map((q) => QuizQuestion.fromJson(q as Map<String, dynamic>))
              .toList();
        },
      );
      return response;
    } catch (e) {
      return ApiResponse<List<QuizQuestion>>(
        success: false,
        statusCode: 500,
        message: 'Sorular yüklenemedi: $e',
      );
    }
  }

  // Submit exam result
  Future<ApiResponse<ExamResultResponse>> submitExamResult({
    required String category,
    required int correctAnswers,
    required int wrongAnswers,
    required int emptyAnswers,
    required double scorePercentage,
    required DateTime completedAt,
    String? examId,
    String examType = 'mock',
    String difficulty = 'medium',
    int? durationSeconds,
    List<Map<String, dynamic>>? answers,
  }) async {
    // Current backend might still expect the old format,
    // but the documentation specifies a new more detailed format.
    // We'll provide both or the one that matches documentation.

    final requestData = {
      'exam_id': examId ?? 'exam_${DateTime.now().millisecondsSinceEpoch}',
      'category': category,
      'exam_type': examType,
      'difficulty': difficulty,
      'total_questions': correctAnswers + wrongAnswers + emptyAnswers,
      'correct_answers': correctAnswers,
      'wrong_answers': wrongAnswers,
      'empty_answers': emptyAnswers,
      'score_percentage': scorePercentage.round(),
      'duration_seconds': durationSeconds ?? 0,
      'completed_at': completedAt.toIso8601String(),
      'answers': answers ?? [],
    };

    return await handleResponse<ExamResultResponse>(
      post(ApiConstants.examResults, data: requestData),
      ExamResultResponse.fromJson,
    );
  }

  // Get user exam results
  Future<ApiResponse<List<ExamResultItem>>> getUserExamResults({
    int limit = 20,
    int page = 1,
  }) async {
    final queryParams = {
      'per_page': limit.toString(),
      'page': page.toString(),
    };

    // API returns { data: { results: [...], pagination: {...} } }
    return await handleResponse<List<ExamResultItem>>(
      get(
        ApiConstants.examResults,
        queryParameters: queryParams,
      ),
      (dynamic json) {
        List<dynamic> list = [];
        if (json is Map<String, dynamic>) {
          list = (json['results'] as List? ??
              (json['data'] is Map ? json['data']['results'] as List? : null) ??
              (json['data'] is List ? json['data'] as List? : null) ??
              json['items'] as List? ??
              []);
        } else if (json is List) {
          list = json;
        }
        return list
            .map((e) => ExamResultItem.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  // Get detailed exam result
  Future<ApiResponse<ExamResultItem>> getExamResultDetail(int id) async {
    return await handleResponse<ExamResultItem>(
      get(ApiConstants.examResultDetail(id.toString())),
      (dynamic json) => ExamResultItem.fromJson(json as Map<String, dynamic>),
    );
  }
}

class ExamResultResponse {
  final int id;
  final int userId;
  final int catId;
  final double point;
  final String createdAt;

  ExamResultResponse({
    required this.id,
    required this.userId,
    required this.catId,
    required this.point,
    required this.createdAt,
  });

  factory ExamResultResponse.fromJson(Map<String, dynamic> json) {
    return ExamResultResponse(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      userId: json['user_id'] is int
          ? json['user_id']
          : int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      catId: json['cat_id'] is int
          ? json['cat_id']
          : int.tryParse(json['cat_id']?.toString() ?? '0') ?? 0,
      point: (json['point'] ?? 0).toDouble(),
      createdAt: json['created_at'] ?? '',
    );
  }
}

class ExamResultItem {
  final int id;
  final int userId;
  final int catId;
  final String categoryTitle;
  final int correctAnswers;
  final int wrongAnswers;
  final int emptyAnswers;
  final double point;
  final DateTime createdAt;

  ExamResultItem({
    required this.id,
    required this.userId,
    required this.catId,
    required this.categoryTitle,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.emptyAnswers,
    required this.point,
    required this.createdAt,
  });

  int get totalQuestions => correctAnswers + wrongAnswers + emptyAnswers;
  double get scorePercentage => point;
  String get category => catId.toString();

  factory ExamResultItem.fromJson(Map<String, dynamic> json) {
    int correct = 0, wrong = 0, empty = 0;
    final rawResults = json['results'];
    if (rawResults is String && rawResults.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawResults) as Map<String, dynamic>;
        correct = decoded['correct'] ?? 0;
        wrong = decoded['wrong'] ?? 0;
        empty = decoded['empty'] ?? 0;
      } catch (_) {}
    }

    final catObj = json['category'] as Map<String, dynamic>?;

    return ExamResultItem(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      userId: json['user_id'] is int
          ? json['user_id']
          : int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      catId: json['cat_id'] is int
          ? json['cat_id']
          : int.tryParse(json['cat_id']?.toString() ?? '0') ?? 0,
      categoryTitle: catObj?['title'] ?? '',
      correctAnswers: correct,
      wrongAnswers: wrong,
      emptyAnswers: empty,
      point: (json['point'] ?? 0).toDouble(),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}
