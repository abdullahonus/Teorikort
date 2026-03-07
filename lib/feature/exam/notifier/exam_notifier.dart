import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/api_response.dart';
import '../../../core/services/logger_service.dart';
import '../../../domain/repository/i_exam_repository.dart';
import '../../../product/provider/service_providers.dart';
import '../state/exam_state.dart';

class ExamNotifier extends Notifier<ExamState> {
  @override
  ExamState build() {
    // Standard practice: auto-load exams on build
    Future.microtask(loadExams);
    return const ExamState(isLoading: true);
  }

  IExamRepository get _repository => ref.read(examRepositoryProvider);

  Future<void> loadExams() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final responses = await Future.wait([
        _repository.getCategories(),
        _repository.getExamHistory(),
      ]);

      final categoriesResponse = responses[0] as ApiResponse;
      final historyResponse = responses[1] as ApiResponse;

      state = state.copyWith(
        categories: categoriesResponse.success
            ? categoriesResponse.data
            : state.categories,
        history: historyResponse.success ? historyResponse.data : state.history,
        isLoading: false,
        error: categoriesResponse.success ? null : categoriesResponse.message,
      );
    } catch (e) {
      LoggerService.error('ExamNotifier.loadExams', e);
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    await loadExams();
  }
}
