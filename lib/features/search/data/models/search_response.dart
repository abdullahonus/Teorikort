import 'package:teorikort/features/quiz/data/models/quiz_data.dart';

class SearchResponseData {
  final String query;
  final List<QuizQuestion> questions;
  final SearchPagination pagination;

  SearchResponseData({
    required this.query,
    required this.questions,
    required this.pagination,
  });

  factory SearchResponseData.fromJson(Map<String, dynamic> json) {
    return SearchResponseData(
      query: json['query'] ?? '',
      questions: (json['questions'] as List? ?? [])
          .map((q) => QuizQuestion.fromJson(q))
          .toList(),
      pagination: SearchPagination.fromJson(json['pagination'] ?? {}),
    );
  }
}

class SearchPagination {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  SearchPagination({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory SearchPagination.fromJson(Map<String, dynamic> json) {
    return SearchPagination(
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 20,
      total: json['total'] ?? 0,
    );
  }
}
