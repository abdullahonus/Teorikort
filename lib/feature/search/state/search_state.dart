import 'package:equatable/equatable.dart';
import '../../exam/model/exam_question.dart';

/// Spec: STATE MODEL PATTERN — Equatable + copyWith
class SearchState extends Equatable {
  final bool isLoading;
  final String? error;
  final List<ExamQuestion> results;
  final bool hasSearched;
  final String query;

  const SearchState({
    this.isLoading = false,
    this.error,
    this.results = const [],
    this.hasSearched = false,
    this.query = '',
  });

  SearchState copyWith({
    bool? isLoading,
    String? error,
    List<ExamQuestion>? results,
    bool? hasSearched,
    String? query,
  }) {
    return SearchState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      results: results ?? this.results,
      hasSearched: hasSearched ?? this.hasSearched,
      query: query ?? this.query,
    );
  }

  @override
  List<Object?> get props => [isLoading, error, results, hasSearched, query];
}
