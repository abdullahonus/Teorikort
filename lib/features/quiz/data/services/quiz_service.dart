import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../core/services/base_api_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/models/api_response.dart';
import '../models/quiz_data.dart';
import 'package:teorikort/features/exam/data/models/exam_data.dart';

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

  /// Mock exam sorularını API'den yükler.
  /// API: GET /exam-categories/{id}/mock-exam?count=20
  /// Response: { total_questions, questions } - /mock-exams/questions endpoint'i YOK (404)
  Future<ApiResponse<MockExamData>> getMockExamQuestions({
    String? categoryId,
    String difficulty = 'medium',
    int count = 50,
    BuildContext? context,
  }) async {
    final catId = categoryId ?? '1';
    return await handleResponse<MockExamData>(
      get(
        ApiConstants.mockExamQuestions(catId),
        queryParameters: {'count': count.toString()},
      ),
      MockExamData.fromJson,
    );
  }

  // Get exam categories
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
      'score_percentage': scorePercentage,
      'duration_seconds': durationSeconds ?? 0,
      'completed_at': completedAt.toIso8601String(),
      'answers': answers ?? [],

      // Legacy fields for backward compatibility if needed
      'cat_id': int.tryParse(category) ?? 1,
      'point': scorePercentage,
      'results': jsonEncode({
        'correct': correctAnswers,
        'wrong': wrongAnswers,
        'empty': emptyAnswers,
      }),
      'send_time': completedAt.millisecondsSinceEpoch ~/ 1000,
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
              json['data'] as List? ??
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
}

// These models are kept here for now as they are specific to the Quiz API responses
// but renamed or adjusted to avoid collisions if necessary.
// However, if they are exactly the same as in other files, they should be removed.

class MockExamData {
  final QuizExamInfo examInfo;
  final List<QuizQuestion> questions;

  MockExamData({
    required this.examInfo,
    required this.questions,
  });

  factory MockExamData.fromJson(Map<String, dynamic> json) {
    // API response: { total_questions, questions } - exam_info yok
    final infoJson = json.containsKey('exam_info')
        ? json['exam_info'] as Map<String, dynamic>
        : <String, dynamic>{
            'total_questions': json['total_questions'] ?? 0,
            'duration': 45,
            'passing_score': 70,
          };

    List<dynamic> questionsRaw = json['questions'] as List? ?? [];
    if (questionsRaw.isEmpty && json['data'] is List) {
      questionsRaw = json['data'] as List;
    }

    final questions = questionsRaw
        .where((q) => q is Map<String, dynamic>)
        .map((q) => QuizQuestion.fromJson(q as Map<String, dynamic>))
        .toList();

    return MockExamData(
      examInfo: QuizExamInfo.fromJson(infoJson),
      questions: questions,
    );
  }
}

class QuizExamInfo {
  final String id;
  final Map<String, String> title;
  final Map<String, String> description;
  final int duration;
  final int totalQuestions;
  final int passingScore;
  final String difficulty;

  QuizExamInfo({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.totalQuestions,
    required this.passingScore,
    required this.difficulty,
  });

  factory QuizExamInfo.fromJson(Map<String, dynamic> json) {
    return QuizExamInfo(
      id: json['id']?.toString() ?? '',
      title: _parseMultiLangFieldStatic(json['title']),
      description: _parseMultiLangFieldStatic(json['description']),
      duration: json['duration'] is int
          ? json['duration']
          : int.tryParse(json['duration']?.toString() ?? '45') ?? 45,
      totalQuestions: json['total_questions'] is int
          ? json['total_questions']
          : int.tryParse(json['total_questions']?.toString() ?? '0') ?? 0,
      passingScore: json['passing_score'] is int
          ? json['passing_score']
          : int.tryParse(json['passing_score']?.toString() ?? '35') ??
              35, // Default passing score
      difficulty: json['difficulty']?.toString() ?? 'medium',
    );
  }

  // Helper method for static parsing
  static Map<String, String> _parseMultiLangFieldStatic(dynamic field) {
    if (field is Map<String, dynamic>) {
      return field.map((key, value) => MapEntry(key, value?.toString() ?? ''));
    } else if (field is String) {
      return {'tr': field, 'en': field};
    }
    return {'tr': field?.toString() ?? '', 'en': field?.toString() ?? ''};
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
