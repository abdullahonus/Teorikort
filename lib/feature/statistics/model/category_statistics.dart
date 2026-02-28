import 'package:equatable/equatable.dart';

/// Spec: STATE MODEL PATTERN — Equatable + copyWith
class CategoryStatistics extends Equatable {
  final int categoryId;
  final String categoryTitle;
  final int totalExams;
  final double averageScore;
  final double highestScore;
  final double lowestScore;
  final List<RecentExamResult> recentExams;

  const CategoryStatistics({
    required this.categoryId,
    required this.categoryTitle,
    required this.totalExams,
    required this.averageScore,
    required this.highestScore,
    required this.lowestScore,
    required this.recentExams,
  });

  factory CategoryStatistics.fromJson(Map<String, dynamic> json) {
    final cat = json['category'] as Map<String, dynamic>? ?? {};
    return CategoryStatistics(
      categoryId: cat['id'] is int
          ? cat['id']
          : int.tryParse(cat['id']?.toString() ?? '0') ?? 0,
      categoryTitle: cat['title'] ?? '',
      totalExams: json['total_exams'] ?? 0,
      averageScore: (json['average_score'] ?? 0).toDouble(),
      highestScore: (json['highest_score'] ?? 0).toDouble(),
      lowestScore: (json['lowest_score'] ?? 0).toDouble(),
      recentExams: (json['recent_exams'] as List? ?? [])
          .map((e) => RecentExamResult.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  CategoryStatistics copyWith({
    int? categoryId,
    String? categoryTitle,
    int? totalExams,
    double? averageScore,
    double? highestScore,
    double? lowestScore,
    List<RecentExamResult>? recentExams,
  }) {
    return CategoryStatistics(
      categoryId: categoryId ?? this.categoryId,
      categoryTitle: categoryTitle ?? this.categoryTitle,
      totalExams: totalExams ?? this.totalExams,
      averageScore: averageScore ?? this.averageScore,
      highestScore: highestScore ?? this.highestScore,
      lowestScore: lowestScore ?? this.lowestScore,
      recentExams: recentExams ?? this.recentExams,
    );
  }

  @override
  List<Object?> get props => [
        categoryId,
        categoryTitle,
        totalExams,
        averageScore,
        highestScore,
        lowestScore,
        recentExams,
      ];
}

class RecentExamResult extends Equatable {
  final int id;
  final double point;
  final DateTime createdAt;

  const RecentExamResult({
    required this.id,
    required this.point,
    required this.createdAt,
  });

  factory RecentExamResult.fromJson(Map<String, dynamic> json) {
    return RecentExamResult(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      point: (json['point'] ?? 0).toDouble(),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, point, createdAt];
}
