import 'package:teorikort/core/models/api_response.dart';
import 'package:teorikort/feature/exam/model/exam_category.dart';
import 'package:teorikort/feature/exam/model/exam_question.dart';
import 'package:teorikort/feature/exam/model/exam_result.dart';

abstract class IExamRepository {
  /// Fetches all available exam categories (topics).
  Future<ApiResponse<List<ExamCategory>>> getCategories();

  /// Fetches questions for a specific category.
  Future<ApiResponse<List<ExamQuestion>>> getQuestions(String categoryId);

  /// Fetches mock exam questions based on difficulty.
  Future<List<ExamQuestion>> getMockQuestions(String difficulty);

  /// Submits the result of a completed exam session.
  Future<ApiResponse<ExamResult>> submitExamResult({
    required String categoryId,
    required double scorePercentage,
    required int correctAnswers,
    required int wrongAnswers,
    required int emptyAnswers,
    required Duration duration,
    String examType = 'final',
  });

  /// Fetches the user's exam history.
  Future<ApiResponse<List<ExamResult>>> getExamHistory();
}
