import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/logger_service.dart';
import '../../../domain/repository/i_exam_repository.dart';
import '../../../product/provider/service_providers.dart';
import '../state/exam_session_state.dart';

class ExamSessionNotifier extends AutoDisposeNotifier<ExamSessionState> {
  Timer? _timer;

  @override
  ExamSessionState build() {
    ref.onDispose(() {
      _timer?.cancel();
    });
    return const ExamSessionState();
  }

  IExamRepository get _repository => ref.read(examRepositoryProvider);

  Future<void> startExam(String categoryId, int initialSeconds,
      {String examType = 'final'}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = examType == 'practice'
          ? await _repository
              .getTestQuestions(categoryId) // testId is passed as categoryId
          : await _repository.getQuestions(categoryId);
      if (response.success && response.data != null) {
        state = state.copyWith(
          questions: response.data!.questions,
          isDemo: response.data!.isDemo,
          remainingSeconds: initialSeconds,
          initialSeconds: initialSeconds,
          isLoading: false,
          userAnswers: {},
          currentQuestionIndex: 0,
        );
        _startTimer();
      } else {
        state = state.copyWith(isLoading: false, error: response.message);
      }
    } catch (e) {
      LoggerService.error('ExamSessionNotifier.startExam', e);
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds > 0) {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      } else {
        finishExam();
      }
    });
  }

  void nextQuestion() {
    if (state.currentQuestionIndex < state.questions.length - 1) {
      state =
          state.copyWith(currentQuestionIndex: state.currentQuestionIndex + 1);
    }
  }

  void previousQuestion() {
    if (state.currentQuestionIndex > 0) {
      state =
          state.copyWith(currentQuestionIndex: state.currentQuestionIndex - 1);
    }
  }

  void jumpToQuestion(int index) {
    if (index >= 0 && index < state.questions.length) {
      state = state.copyWith(currentQuestionIndex: index);
    }
  }

  void selectOption(String questionId, String optionId) {
    final updatedAnswers = Map<String, String?>.from(state.userAnswers);
    updatedAnswers[questionId] = optionId;
    state = state.copyWith(userAnswers: updatedAnswers);
  }

  Future<void> finishExam(
      {String categoryId = '1', String examType = 'final'}) async {
    _timer?.cancel();
    if (state.isFinished) return;

    state = state.copyWith(isLoading: true);

    try {
      final score = (state.correctCount / state.questions.length) * 100;

      // Prepare answers for API
      final answers = state.questions.map((q) {
        final selectedOptionId = state.userAnswers[q.id];
        return {
          'question_id': q.id,
          'selected_option': selectedOptionId ?? '',
          'is_correct': selectedOptionId == q.correctAnswer,
        };
      }).toList();

      final response = await _repository.submitExamResult(
        categoryId: categoryId,
        scorePercentage: score,
        correctAnswers: state.correctCount,
        wrongAnswers: state.wrongCount,
        emptyAnswers: state.emptyCount,
        duration:
            Duration(seconds: state.initialSeconds - state.remainingSeconds),
        examType: examType,
        answers: answers,
      );

      state = state.copyWith(
        isLoading: false,
        isFinished: true,
        lastResult: response.data,
      );
    } catch (e) {
      LoggerService.error('ExamSessionNotifier.finishExam', e);
      state = state.copyWith(isLoading: false, isFinished: true);
    }
  }
}
