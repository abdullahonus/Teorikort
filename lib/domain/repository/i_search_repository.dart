import 'package:teorikort/core/models/api_response.dart';
import 'package:teorikort/feature/exam/model/exam_question.dart';

abstract class ISearchRepository {
  /// Searches for questions based on a query.
  Future<ApiResponse<List<ExamQuestion>>> searchQuestions(String query, {int page = 1});
}
