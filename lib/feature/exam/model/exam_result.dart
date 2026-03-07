import 'package:equatable/equatable.dart';

/// Spec: STATE MODEL PATTERN — Equatable + copyWith
class ExamResult extends Equatable {
  final int id;
  final int userId;
  final int categoryId;
  final String categoryTitle;
  final double score;
  final int correctCount;
  final int wrongCount;
  final int emptyCount;
  final int totalQuestions;
  final String createdAt;

  const ExamResult({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.categoryTitle,
    required this.score,
    required this.correctCount,
    required this.wrongCount,
    required this.emptyCount,
    required this.totalQuestions,
    required this.createdAt,
  });

  factory ExamResult.fromJson(Map<String, dynamic> json) {
    // Handling different format variants from API
    final results = json['results'] != null && json['results'] is Map
        ? json['results'] as Map<String, dynamic>
        : (json['results'] is String
            ? {}
            : {}); // simplifies legacy results decoding

    return ExamResult(
      id: _parseInt(json['id']),
      userId: _parseInt(json['user_id']),
      categoryId: _parseInt(json['cat_id']),
      categoryTitle: json['category_title'] ?? '',
      score: (json['point'] ?? json['score_percentage'] ?? 0.0).toDouble(),
      correctCount: _parseInt(json['correct_answers'] ?? results['correct']),
      wrongCount: _parseInt(json['wrong_answers'] ?? results['wrong']),
      emptyCount: _parseInt(json['empty_answers'] ?? results['empty']),
      totalQuestions: _parseInt(json['total_questions']),
      createdAt: json['created_at'] ?? '',
    );
  }

  factory ExamResult.fromLegacy(dynamic legacy) {
    if (legacy is Map<String, dynamic>) return ExamResult.fromJson(legacy);
    return ExamResult.fromJson(legacy.toJson());
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value == null) return 0;
    return int.tryParse(value.toString()) ?? 0;
  }

  ExamResult copyWith({
    int? id,
    int? userId,
    int? categoryId,
    String? categoryTitle,
    double? score,
    int? correctCount,
    int? wrongCount,
    int? emptyCount,
    int? totalQuestions,
    String? createdAt,
  }) =>
      ExamResult(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        categoryId: categoryId ?? this.categoryId,
        categoryTitle: categoryTitle ?? this.categoryTitle,
        score: score ?? this.score,
        correctCount: correctCount ?? this.correctCount,
        wrongCount: wrongCount ?? this.wrongCount,
        emptyCount: emptyCount ?? this.emptyCount,
        totalQuestions: totalQuestions ?? this.totalQuestions,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  List<Object?> get props => [
        id,
        userId,
        categoryId,
        categoryTitle,
        score,
        correctCount,
        wrongCount,
        emptyCount,
        totalQuestions,
        createdAt
      ];
}
