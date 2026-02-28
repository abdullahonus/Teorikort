import 'package:equatable/equatable.dart';
import '../model/exam_category.dart';
import '../model/exam_result.dart';

class ExamState extends Equatable {
  final List<ExamCategory> categories;
  final List<ExamResult> history;
  final bool isLoading;
  final String? error;

  const ExamState({
    this.categories = const [],
    this.history = const [],
    this.isLoading = false,
    this.error,
  });

  ExamState copyWith({
    List<ExamCategory>? categories,
    List<ExamResult>? history,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) =>
      ExamState(
        categories: categories ?? this.categories,
        history: history ?? this.history,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
      );

  @override
  List<Object?> get props => [categories, history, isLoading, error];
}
