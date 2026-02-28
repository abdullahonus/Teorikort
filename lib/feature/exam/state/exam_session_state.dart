import 'package:equatable/equatable.dart';
import '../model/exam_question.dart';
import '../model/exam_result.dart';

class ExamSessionState extends Equatable {
  final List<ExamQuestion> questions;
  final int currentQuestionIndex;
  // Map of question ID to selected option ID
  final Map<String, String?> userAnswers;
  final int remainingSeconds;
  final bool isFinished;
  final bool isLoading;
  final String? error;
  final ExamResult? lastResult;

  const ExamSessionState({
    this.questions = const [],
    this.currentQuestionIndex = 0,
    this.userAnswers = const {},
    this.remainingSeconds = 0,
    this.isFinished = false,
    this.isLoading = false,
    this.error,
    this.lastResult,
  });

  ExamQuestion? get currentQuestion =>
      questions.isNotEmpty && currentQuestionIndex < questions.length
          ? questions[currentQuestionIndex]
          : null;

  int get correctCount {
    int count = 0;
    for (var q in questions) {
      if (userAnswers[q.id] == q.correctAnswer) count++;
    }
    return count;
  }

  int get wrongCount {
    int count = 0;
    for (var q in questions) {
      final answer = userAnswers[q.id];
      if (answer != null && answer != q.correctAnswer) count++;
    }
    return count;
  }

  int get emptyCount {
    int count = 0;
    for (var q in questions) {
      if (userAnswers[q.id] == null) count++;
    }
    return count;
  }

  double get scorePercentage =>
      questions.isEmpty ? 0 : (correctCount / questions.length) * 100;

  ExamSessionState copyWith({
    List<ExamQuestion>? questions,
    int? currentQuestionIndex,
    Map<String, String?>? userAnswers,
    int? remainingSeconds,
    bool? isFinished,
    bool? isLoading,
    String? error,
    ExamResult? lastResult,
    bool clearError = false,
  }) =>
      ExamSessionState(
        questions: questions ?? this.questions,
        currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
        userAnswers: userAnswers ?? this.userAnswers,
        remainingSeconds: remainingSeconds ?? this.remainingSeconds,
        isFinished: isFinished ?? this.isFinished,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
        lastResult: lastResult ?? this.lastResult,
      );

  @override
  List<Object?> get props => [
        questions,
        currentQuestionIndex,
        userAnswers,
        remainingSeconds,
        isFinished,
        isLoading,
        error,
        lastResult
      ];
}
