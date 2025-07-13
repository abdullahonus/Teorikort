import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/services/base_api_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/models/api_response.dart';
import '../../../../core/localization/app_localization.dart';
import '../models/quiz_data.dart';

class QuizService extends BaseApiService {
  // Valid exam categories
  static const validCategories = {
    'traffic_signs',
    'traffic_rules',
    'first_aid',
    'vehicle_tech'
  };

  // Get questions by category with fallback to mock data
  Future<ApiResponse<List<QuizQuestion>>> loadQuizQuestions(
    String category, {
    BuildContext? context,
    int limit = 10,
    String? difficulty,
  }) async {
    try {
      // Validate category
      if (!validCategories.contains(category)) {
        return ApiResponse<List<QuizQuestion>>(
          success: false,
          statusCode: 400,
          message: 'Geçersiz kategori: $category',
        );
      }

      final language = getCurrentLanguage(context);
      final queryParams = {
        'limit': limit.toString(),
        'language': language,
        if (difficulty != null) 'difficulty': difficulty,
      };

      // Try API first
      try {
        final response = await handleListResponse<QuizQuestion>(
          get(
            ApiConstants.examCategoryQuestions(category),
            queryParameters: queryParams,
          ),
          QuizQuestion.fromJson,
        );

        if (response.success && response.data != null) {
          return response;
        }
      } catch (apiError) {
        print('API çağrısı başarısız, mock verilere geçiliyor: $apiError');
      }

      // Fallback to mock data
      return await _loadMockQuizQuestions(category, limit);
    } catch (e) {
      // Final fallback
      return await _loadMockQuizQuestions(category, limit);
    }
  }

  // Load mock questions from assets
  Future<ApiResponse<List<QuizQuestion>>> _loadMockQuizQuestions(
    String category,
    int limit,
  ) async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/data/quiz_questions.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      List<Map<String, dynamic>> categoryQuestions = [];

      // Get questions by category or use default
      if (jsonData.containsKey(category)) {
        categoryQuestions = List<Map<String, dynamic>>.from(jsonData[category]);
      } else if (jsonData.containsKey('traffic_signs')) {
        categoryQuestions =
            List<Map<String, dynamic>>.from(jsonData['traffic_signs']);
      } else {
        // If no specific category, get all questions
        categoryQuestions = [];
        for (var categoryData in jsonData.values) {
          if (categoryData is List) {
            categoryQuestions
                .addAll(List<Map<String, dynamic>>.from(categoryData));
          }
        }
      }

      // Limit questions
      if (categoryQuestions.length > limit) {
        categoryQuestions = categoryQuestions.take(limit).toList();
      }

      // Convert to QuizQuestion objects
      final List<QuizQuestion> questions =
          categoryQuestions.map((questionData) {
        // Convert old format to new multi-language format if needed
        return QuizQuestion(
          id: questionData['id']?.toString() ??
              '${DateTime.now().millisecondsSinceEpoch}',
          question: _convertToMultiLang(questionData['question']),
          imageUrl: questionData['image_url'] as String?,
          options: _convertOptions(questionData['options'] ?? []),
          correctAnswer: questionData['correct_answer']?.toString() ?? '0',
          explanation: _convertToMultiLang(questionData['explanation']),
          difficulty: questionData['difficulty'] as String?,
        );
      }).toList();

      return ApiResponse<List<QuizQuestion>>(
        success: true,
        statusCode: 100,
        message: 'Mock veriler başarıyla yüklendi',
        data: questions,
      );
    } catch (e) {
      return ApiResponse<List<QuizQuestion>>(
        success: false,
        statusCode: 500,
        message: 'Mock veriler yüklenemedi: $e',
        data: [],
      );
    }
  }

  // Convert options to new format
  List<Option> _convertOptions(List<dynamic> optionsData) {
    return optionsData.asMap().entries.map((entry) {
      final index = entry.key;
      final value = entry.value;

      return Option(
        id: index.toString(),
        text: _convertToMultiLang(value),
      );
    }).toList();
  }

  // Convert to multi-language format
  Map<String, String> _convertToMultiLang(dynamic field) {
    if (field is Map<String, dynamic>) {
      return field.map((key, value) => MapEntry(key, value?.toString() ?? ''));
    } else if (field is String) {
      return {'tr': field, 'en': field}; // Fallback for old format
    }
    return {'tr': field?.toString() ?? '', 'en': field?.toString() ?? ''};
  }

  // Get mock exam questions with fallback
  Future<ApiResponse<MockExamData>> getMockExamQuestions({
    String difficulty = 'medium',
    int count = 10,
    BuildContext? context,
  }) async {
    try {
      final language = getCurrentLanguage(context);
      final queryParams = {
        'difficulty': difficulty,
        'count': count.toString(),
        'language': language,
      };

      // Try API first
      try {
        final response = await handleResponse<MockExamData>(
          get(
            ApiConstants.mockExamQuestions,
            queryParameters: queryParams,
          ),
          MockExamData.fromJson,
        );

        if (response.success && response.data != null) {
          return response;
        }
      } catch (apiError) {
        print(
            'Mock exam API çağrısı başarısız, mock verilere geçiliyor: $apiError');
      }

      // Fallback to mock data
      return await _loadMockExamData(difficulty, count);
    } catch (e) {
      return await _loadMockExamData(difficulty, count);
    }
  }

  // Load mock exam data from assets
  Future<ApiResponse<MockExamData>> _loadMockExamData(
    String difficulty,
    int count,
  ) async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/data/mock_exam_questions.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      List<Map<String, dynamic>> questions = [];

      // Get questions by difficulty
      if (jsonData.containsKey(difficulty)) {
        final difficultyData = jsonData[difficulty];
        if (difficultyData is Map && difficultyData.containsKey('questions')) {
          questions =
              List<Map<String, dynamic>>.from(difficultyData['questions']);
        }
      }

      // If no questions found, use medium difficulty
      if (questions.isEmpty && jsonData.containsKey('medium')) {
        final mediumData = jsonData['medium'];
        if (mediumData is Map && mediumData.containsKey('questions')) {
          questions = List<Map<String, dynamic>>.from(mediumData['questions']);
        }
      }

      // Shuffle and limit
      questions.shuffle();
      if (questions.length > count) {
        questions = questions.take(count).toList();
      }

      // Convert to QuizQuestion objects
      final List<QuizQuestion> convertedQuestions = questions.map((q) {
        return QuizQuestion(
          id: q['id']?.toString() ?? '${DateTime.now().millisecondsSinceEpoch}',
          question: _convertToMultiLang(q['question']),
          imageUrl: q['image_url'] as String?,
          options: _convertOptions(q['options'] ?? []),
          correctAnswer: q['correct_answer']?.toString() ?? '0',
          explanation: _convertToMultiLang(q['explanation']),
          difficulty: difficulty,
        );
      }).toList();

      final examInfo = ExamInfo(
        id: 'mock_$difficulty',
        title: {
          'tr': 'Mock Sınav ($difficulty)',
          'en': 'Mock Exam ($difficulty)'
        },
        description: {
          'tr': 'Mock sınav açıklaması',
          'en': 'Mock exam description'
        },
        duration: 45,
        totalQuestions: convertedQuestions.length,
        difficulty: difficulty,
      );

      final mockExamData = MockExamData(
        examInfo: examInfo,
        questions: convertedQuestions,
      );

      return ApiResponse<MockExamData>(
        success: true,
        statusCode: 100,
        message: 'Mock sınav verileri başarıyla yüklendi',
        data: mockExamData,
      );
    } catch (e) {
      return ApiResponse<MockExamData>(
        success: false,
        statusCode: 500,
        message: 'Mock sınav verileri yüklenemedi: $e',
      );
    }
  }

  // Get exam categories with fallback
  Future<ApiResponse<List<ExamCategory>>> getExamCategories({
    BuildContext? context,
  }) async {
    try {
      final language = getCurrentLanguage(context);

      // Try API first
      try {
        final response = await handleListResponse<ExamCategory>(
          get(
            ApiConstants.examCategories,
            language: language,
          ),
          ExamCategory.fromJson,
        );

        if (response.success && response.data != null) {
          return response;
        }
      } catch (apiError) {
        print(
            'Categories API çağrısı başarısız, mock verilere geçiliyor: $apiError');
      }

      // Fallback to mock data
      return await _loadMockCategories();
    } catch (e) {
      return await _loadMockCategories();
    }
  }

  // Load mock categories from assets
  Future<ApiResponse<List<ExamCategory>>> _loadMockCategories() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/data/categories_data.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      final List<ExamCategory> categories = [];

      jsonData.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          categories.add(ExamCategory(
            id: key,
            name: _convertToMultiLang(value['name']),
            description: _convertToMultiLang(value['description']),
            icon: value['icon'] as String? ?? 'traffic',
            questionCount: value['question_count'] as int? ?? 10,
            isActive: value['is_active'] as bool? ?? true,
          ));
        }
      });

      return ApiResponse<List<ExamCategory>>(
        success: true,
        statusCode: 100,
        message: 'Mock kategoriler başarıyla yüklendi',
        data: categories,
      );
    } catch (e) {
      return ApiResponse<List<ExamCategory>>(
        success: false,
        statusCode: 500,
        message: 'Mock kategoriler yüklenemedi: $e',
        data: [],
      );
    }
  }

  // Submit exam result
  Future<ApiResponse<ExamResultResponse>> submitExamResult({
    required String examId,
    required String category,
    required String examType,
    required String difficulty,
    required int totalQuestions,
    required int correctAnswers,
    required int wrongAnswers,
    required int emptyAnswers,
    required double scorePercentage,
    required int durationSeconds,
    required List<AnswerData> answers,
    required DateTime completedAt,
  }) async {
    try {
      final requestData = {
        'exam_id': examId,
        'category': category,
        'exam_type': examType,
        'difficulty': difficulty,
        'total_questions': totalQuestions,
        'correct_answers': correctAnswers,
        'wrong_answers': wrongAnswers,
        'empty_answers': emptyAnswers,
        'score_percentage': scorePercentage,
        'duration_seconds': durationSeconds,
        'answers': answers.map((a) => a.toJson()).toList(),
        'completed_at': completedAt.toIso8601String(),
      };

      // Try API first
      try {
        final response = await handleResponse<ExamResultResponse>(
          post(ApiConstants.examResults, data: requestData),
          ExamResultResponse.fromJson,
        );

        if (response.success) {
          return response;
        }
      } catch (apiError) {
        print(
            'Exam result submit API başarısız, mock response dönülüyor: $apiError');
      }

      // Mock response for fallback
      return ApiResponse<ExamResultResponse>(
        success: true,
        statusCode: 100,
        message: 'Sınav sonucu kaydedildi (mock)',
        data: ExamResultResponse(
          resultId: 'mock_${DateTime.now().millisecondsSinceEpoch}',
          scorePercentage: scorePercentage,
          passed: scorePercentage >= 70,
          rank: 1,
          totalParticipants: 100,
        ),
      );
    } catch (e) {
      return ApiResponse<ExamResultResponse>(
        success: false,
        statusCode: 500,
        message: 'Sınav sonucu kaydedilemedi: $e',
      );
    }
  }

  // Get user exam results with fallback
  Future<ApiResponse<List<ExamResultItem>>> getUserExamResults({
    String? category,
    int limit = 10,
    int page = 1,
  }) async {
    try {
      final queryParams = {
        'limit': limit.toString(),
        'page': page.toString(),
        if (category != null) 'category': category,
      };

      // Try API first
      try {
        final response = await handleListResponse<ExamResultItem>(
          get(
            ApiConstants.examResults,
            queryParameters: queryParams,
          ),
          ExamResultItem.fromJson,
        );

        if (response.success && response.data != null) {
          return response;
        }
      } catch (apiError) {
        print(
            'User exam results API başarısız, boş liste dönülüyor: $apiError');
      }

      // Return empty list for fallback
      return ApiResponse<List<ExamResultItem>>(
        success: true,
        statusCode: 100,
        message: 'Henüz sınav sonucu bulunmuyor',
        data: [],
      );
    } catch (e) {
      return ApiResponse<List<ExamResultItem>>(
        success: false,
        statusCode: 500,
        message: 'Sınav sonuçları yüklenemedi: $e',
        data: [],
      );
    }
  }
}

// Existing model classes...
class MockExamData {
  final ExamInfo examInfo;
  final List<QuizQuestion> questions;

  MockExamData({
    required this.examInfo,
    required this.questions,
  });

  factory MockExamData.fromJson(Map<String, dynamic> json) {
    return MockExamData(
      examInfo: ExamInfo.fromJson(json['exam_info'] ?? {}),
      questions: (json['questions'] as List? ?? [])
          .map((q) => QuizQuestion.fromJson(q))
          .toList(),
    );
  }
}

class ExamInfo {
  final String id;
  final Map<String, String> title;
  final Map<String, String> description;
  final int duration;
  final int totalQuestions;
  final String difficulty;

  ExamInfo({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.totalQuestions,
    required this.difficulty,
  });

  factory ExamInfo.fromJson(Map<String, dynamic> json) {
    return ExamInfo(
      id: json['id'] ?? '',
      title: _parseMultiLangFieldStatic(json['title']),
      description: _parseMultiLangFieldStatic(json['description']),
      duration: json['duration'] ?? 45,
      totalQuestions: json['total_questions'] ?? 0,
      difficulty: json['difficulty'] ?? 'medium',
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

class ExamCategory {
  final String id;
  final Map<String, String> name;
  final Map<String, String> description;
  final String icon;
  final int questionCount;
  final bool isActive;

  ExamCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.questionCount,
    required this.isActive,
  });

  factory ExamCategory.fromJson(Map<String, dynamic> json) {
    return ExamCategory(
      id: json['id'] ?? '',
      name: ExamInfo._parseMultiLangFieldStatic(json['name']),
      description: ExamInfo._parseMultiLangFieldStatic(json['description']),
      icon: json['icon'] ?? 'traffic',
      questionCount: json['question_count'] ?? 0,
      isActive: json['is_active'] ?? true,
    );
  }
}

class ExamResultResponse {
  final String resultId;
  final double scorePercentage;
  final bool passed;
  final int rank;
  final int totalParticipants;

  ExamResultResponse({
    required this.resultId,
    required this.scorePercentage,
    required this.passed,
    required this.rank,
    required this.totalParticipants,
  });

  factory ExamResultResponse.fromJson(Map<String, dynamic> json) {
    return ExamResultResponse(
      resultId: json['result_id'] ?? '',
      scorePercentage: (json['score_percentage'] ?? 0).toDouble(),
      passed: json['passed'] ?? false,
      rank: json['rank'] ?? 0,
      totalParticipants: json['total_participants'] ?? 0,
    );
  }
}

class AnswerData {
  final String questionId;
  final String? selectedAnswer;
  final String correctAnswer;
  final bool isCorrect;
  final int timeSpent;

  AnswerData({
    required this.questionId,
    this.selectedAnswer,
    required this.correctAnswer,
    required this.isCorrect,
    required this.timeSpent,
  });

  Map<String, dynamic> toJson() {
    return {
      'question_id': questionId,
      'selected_answer': selectedAnswer,
      'correct_answer': correctAnswer,
      'is_correct': isCorrect,
      'time_spent': timeSpent,
    };
  }
}

class ExamResultItem {
  final String id;
  final String category;
  final double scorePercentage;
  final int correctAnswers;
  final int totalQuestions;
  final DateTime completedAt;

  ExamResultItem({
    required this.id,
    required this.category,
    required this.scorePercentage,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.completedAt,
  });

  factory ExamResultItem.fromJson(Map<String, dynamic> json) {
    return ExamResultItem(
      id: json['id'] ?? '',
      category: json['category'] ?? '',
      scorePercentage: (json['score_percentage'] ?? 0).toDouble(),
      correctAnswers: json['correct_answers'] ?? 0,
      totalQuestions: json['total_questions'] ?? 0,
      completedAt: DateTime.parse(
          json['completed_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}
