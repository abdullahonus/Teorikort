import 'package:teorikort/core/models/api_response.dart';
import 'package:teorikort/core/services/logger_service.dart';
import 'package:teorikort/domain/repository/i_search_repository.dart';
import 'package:teorikort/feature/exam/model/exam_question.dart';
import 'package:teorikort/features/search/data/services/search_service.dart';

class SearchRepositoryImpl implements ISearchRepository {
  final SearchService _service;

  SearchRepositoryImpl(this._service);

  @override
  Future<ApiResponse<List<ExamQuestion>>> searchQuestions(String query, {int page = 1}) async {
    try {
      final response = await _service.searchQuestions(query, page: page);
      if (response.success && response.data != null) {
        final questions = response.data!.questions
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
      LoggerService.error('SearchRepositoryImpl.searchQuestions', e);
      return ApiResponse<List<ExamQuestion>>(
        success: false,
        message: e.toString(),
        statusCode: 500,
      );
    }
  }
}
