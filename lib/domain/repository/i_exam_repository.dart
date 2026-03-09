import 'package:teorikort/core/models/api_response.dart';
import 'package:teorikort/feature/exam/model/exam_category.dart';
import 'package:teorikort/feature/exam/model/exam_question.dart';
import 'package:teorikort/feature/exam/model/exam_result.dart';

abstract class IExamRepository {
  /// Fetches all available exam categories (topics).
  Future<ApiResponse<List<ExamCategory>>> getCategories();

  /// Fetches subcategories for a specific category.
  Future<ApiResponse<List<ExamCategory>>> getSubCategories(String categoryId);

  /// Fetches tests for a specific subcategory.
  Future<ApiResponse<List<ExamCategory>>> getTests(String subcategoryId);

  /// Fetches questions for a specific category.
  Future<ApiResponse<QuestionListResponse>> getQuestions(String categoryId);

  /// Fetches questions for a specific test.
  Future<ApiResponse<QuestionListResponse>> getTestQuestions(String testId,
      {int limit = 10});

  /// Fetches mock exam questions based on difficulty.

  /// Submits the result of a completed exam session.
  Future<ApiResponse<ExamResult>> submitExamResult({
    required String categoryId,
    required double scorePercentage,
    required int correctAnswers,
    required int wrongAnswers,
    required int emptyAnswers,
    required Duration duration,
    String examType = 'final',
    List<Map<String, dynamic>>? answers,
  });

  /// Fetches the user's exam history.
  Future<ApiResponse<List<ExamResult>>> getExamHistory();
}
