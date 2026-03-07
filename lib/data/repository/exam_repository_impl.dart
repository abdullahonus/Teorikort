import 'package:teorikort/core/models/api_response.dart';
import 'package:teorikort/core/services/logger_service.dart';
import 'package:teorikort/domain/repository/i_exam_repository.dart';
import 'package:teorikort/feature/exam/model/exam_category.dart';
import 'package:teorikort/feature/exam/model/exam_question.dart';
import 'package:teorikort/feature/exam/model/exam_result.dart';
import 'package:teorikort/features/exam/data/services/exam_service.dart';
import 'package:teorikort/features/quiz/data/services/quiz_service.dart';

/// Concrete implementation of [IExamRepository].
/// Combines results from various internal services.
class ExamRepositoryImpl implements IExamRepository {
  final ExamService _examService;
  final QuizService _quizService;

  ExamRepositoryImpl(
    this._examService,
    this._quizService,
  );

  @override
  Future<ApiResponse<List<ExamCategory>>> getCategories() async {
    try {
      final response = await _examService.getExamCategories();
      if (response.success && response.data != null) {
        final categories = response.data!
            .map((c) => ExamCategory.fromJson({
                  'id': c.id,
                  'title': c.title,
                  'description': c.description,
                  'time_secound': c.timeSecound,
                  'success_pint': c.successPint,
                  'image': c.image,
                  'total_questions': c.totalQuestions,
                }))
            .toList();

        return ApiResponse<List<ExamCategory>>(
          success: true,
          statusCode: response.statusCode,
          data: categories,
        );
      }
      return ApiResponse<List<ExamCategory>>(
        success: false,
        message: response.message,
        statusCode: response.statusCode,
      );
    } catch (e) {
      LoggerService.error('ExamRepositoryImpl.getCategories', e);
      return ApiResponse<List<ExamCategory>>(
        success: false,
        message: e.toString(),
        statusCode: 500,
      );
    }
  }

  @override
  Future<ApiResponse<List<ExamCategory>>> getSubCategories(
      String categoryId) async {
    try {
      final response = await _quizService.getExamSubCategories(categoryId);
      if (response.success && response.data != null) {
        final categories = response.data!
            .map((c) => ExamCategory.fromJson({
                  'id': c.id,
                  'title': c.title,
                  'description': c.description,
                  'time_secound': c.timeSecound,
                  'success_pint': c.successPint,
                  'image': c.image,
                  'total_questions': c.totalQuestions,
                }))
            .toList();

        return ApiResponse<List<ExamCategory>>(
          success: true,
          statusCode: response.statusCode,
          data: categories,
        );
      }
      return ApiResponse<List<ExamCategory>>(
        success: false,
        message: response.message,
        statusCode: response.statusCode,
      );
    } catch (e) {
      LoggerService.error('ExamRepositoryImpl.getSubCategories', e);
      return ApiResponse<List<ExamCategory>>(
        success: false,
        message: e.toString(),
        statusCode: 500,
      );
    }
  }

  @override
  Future<ApiResponse<List<ExamCategory>>> getTests(String subcategoryId) async {
    try {
      final response = await _quizService.getExamTests(subcategoryId);
      if (response.success && response.data != null) {
        final categories = response.data!
            .map((c) => ExamCategory.fromJson({
                  'id': c.id,
                  'title': c.title,
                  'description': c.description,
                  'time_secound': c.timeSecound,
                  'success_pint': c.successPint,
                  'image': c.image,
                  'total_questions': c.totalQuestions,
                }))
            .toList();

        return ApiResponse<List<ExamCategory>>(
          success: true,
          statusCode: response.statusCode,
          data: categories,
        );
      }
      return ApiResponse<List<ExamCategory>>(
        success: false,
        message: response.message,
        statusCode: response.statusCode,
      );
    } catch (e) {
      LoggerService.error('ExamRepositoryImpl.getTests', e);
      return ApiResponse<List<ExamCategory>>(
        success: false,
        message: e.toString(),
        statusCode: 500,
      );
    }
  }

  @override
  Future<ApiResponse<List<ExamQuestion>>> getQuestions(
      String categoryId) async {
    try {
      final response = await _quizService.loadQuizQuestions(categoryId);
      if (response.success && response.data != null) {
        final questions = response.data!
            .map((q) => ExamQuestion.fromJson({
                  'id': q.id,
                  'question': q.question,
                  'image_url': q.imageUrl,
                  'options': q.options
                      .map((o) =>
                          {'id': o.id, 'text': o.text, 'image_url': o.imageUrl})
                      .toList(),
                  'correct_answer': q.correctAnswer,
                  'explanation': q.explanation,
                }))
            .toList();

        return ApiResponse<List<ExamQuestion>>(
          success: true,
          statusCode: response.statusCode,
          data: questions,
        );
      }
      return ApiResponse<List<ExamQuestion>>(
        success: false,
        message: response.message,
        statusCode: response.statusCode,
      );
    } catch (e) {
      LoggerService.error('ExamRepositoryImpl.getQuestions', e);
      return ApiResponse<List<ExamQuestion>>(
        success: false,
        message: e.toString(),
        statusCode: 500,
      );
    }
  }

  @override
  Future<ApiResponse<List<ExamQuestion>>> getTestQuestions(String testId,
      {int limit = 10}) async {
    try {
      final response =
          await _quizService.loadTestQuestions(testId, limit: limit);
      if (response.success && response.data != null) {
        final questions = response.data!
            .map((q) => ExamQuestion.fromJson({
                  'id': q.id,
                  'question': q.question,
                  'image_url': q.imageUrl,
                  'options': q.options
                      .map((o) =>
                          {'id': o.id, 'text': o.text, 'image_url': o.imageUrl})
                      .toList(),
                  'correct_answer': q.correctAnswer,
                  'explanation': q.explanation,
                }))
            .toList();

        return ApiResponse<List<ExamQuestion>>(
          success: true,
          statusCode: response.statusCode,
          data: questions,
        );
      }
      return ApiResponse<List<ExamQuestion>>(
        success: false,
        message: response.message,
        statusCode: response.statusCode,
      );
    } catch (e) {
      LoggerService.error('ExamRepositoryImpl.getTestQuestions', e);
      return ApiResponse<List<ExamQuestion>>(
        success: false,
        message: e.toString(),
        statusCode: 500,
      );
    }
  }

  @override
  Future<ApiResponse<List<ExamResult>>> getExamHistory() async {
    try {
      final response = await _quizService.getUserExamResults();
      if (response.success && response.data != null) {
        final results = response.data!.map((item) {
          return ExamResult.fromJson({
            'id': item.id,
            'user_id': item.userId,
            'cat_id': item.catId,
            'category_title': item.categoryTitle,
            'point': item.point,
            'correct_answers': item.correctAnswers,
            'wrong_answers': item.wrongAnswers,
            'empty_answers': item.emptyAnswers,
            'total_questions': item.totalQuestions,
            'created_at': item.createdAt.toIso8601String(),
          });
        }).toList();

        return ApiResponse<List<ExamResult>>(
          success: true,
          statusCode: response.statusCode,
          data: results,
        );
      }
      return ApiResponse<List<ExamResult>>(
        success: false,
        message: response.message,
        statusCode: response.statusCode,
      );
    } catch (e) {
      LoggerService.error('ExamRepositoryImpl.getExamHistory', e);
      return ApiResponse<List<ExamResult>>(
        success: false,
        message: e.toString(),
        statusCode: 500,
      );
    }
  }

  @override
  Future<ApiResponse<ExamResult>> submitExamResult({
    required String categoryId,
    required double scorePercentage,
    required int correctAnswers,
    required int wrongAnswers,
    required int emptyAnswers,
    required Duration duration,
    String examType = 'final',
    String difficulty = 'medium',
  }) async {
    try {
      final response = await _quizService.submitExamResult(
        category: categoryId,
        correctAnswers: correctAnswers,
        wrongAnswers: wrongAnswers,
        emptyAnswers: emptyAnswers,
        scorePercentage: scorePercentage,
        completedAt: DateTime.now(),
        examType: examType,
        difficulty: difficulty,
        durationSeconds: duration.inSeconds,
      );

      if (response.success && response.data != null) {
        return ApiResponse<ExamResult>(
          success: true,
          statusCode: response.statusCode,
          data: ExamResult.fromJson({
            'id': response.data!.id,
            'user_id': response.data!.userId,
            'cat_id': response.data!.catId,
            'point': response.data!.point,
            'created_at': response.data!.createdAt,
            'correct_answers': correctAnswers,
            'wrong_answers': wrongAnswers,
            'empty_answers': emptyAnswers,
            'total_questions': correctAnswers + wrongAnswers + emptyAnswers,
          }),
        );
      }
      return ApiResponse<ExamResult>(
        success: false,
        message: response.message,
        statusCode: response.statusCode,
      );
    } catch (e) {
      LoggerService.error('ExamRepositoryImpl.submitExamResult', e);
      return ApiResponse<ExamResult>(
        success: false,
        message: e.toString(),
        statusCode: 500,
      );
    }
  }
}
