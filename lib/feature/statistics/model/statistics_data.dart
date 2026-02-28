import 'package:equatable/equatable.dart';

/// Spec: STATE MODEL PATTERN — Equatable + copyWith
class StatisticsData extends Equatable {
  final int totalExams;
  final double averageScore;
  final double highestScore;
  final List<CategoryPerformance> categoryPerformance;

  const StatisticsData({
    required this.totalExams,
    required this.averageScore,
    required this.highestScore,
    required this.categoryPerformance,
  });

  factory StatisticsData.fromJson(Map<String, dynamic> json) {
    return StatisticsData(
      totalExams: json['total_exams'] ?? 0,
      averageScore: (json['average_score'] ?? 0).toDouble(),
      highestScore: (json['highest_score'] ?? 0).toDouble(),
      categoryPerformance: (json['category_performance'] as List? ?? [])
          .map((c) => CategoryPerformance.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }

  StatisticsData copyWith({
    int? totalExams,
    double? averageScore,
    double? highestScore,
    List<CategoryPerformance>? categoryPerformance,
  }) {
    return StatisticsData(
      totalExams: totalExams ?? this.totalExams,
      averageScore: averageScore ?? this.averageScore,
      highestScore: highestScore ?? this.highestScore,
      categoryPerformance: categoryPerformance ?? this.categoryPerformance,
    );
  }

  @override
  List<Object?> get props =>
      [totalExams, averageScore, highestScore, categoryPerformance];
}

class CategoryPerformance extends Equatable {
  final int categoryId;
  final String categoryName;
  final double averageScore;
  final int totalExams;

  const CategoryPerformance({
    required this.categoryId,
    required this.categoryName,
    required this.averageScore,
    required this.totalExams,
  });

  factory CategoryPerformance.fromJson(Map<String, dynamic> json) {
    return CategoryPerformance(
      categoryId: json['category_id'] is int
          ? json['category_id']
          : int.tryParse(json['category_id']?.toString() ?? '0') ?? 0,
      categoryName: json['category_name'] ?? '',
      averageScore: (json['average_score'] ?? 0).toDouble(),
      totalExams: json['total_exams'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [categoryId, categoryName, averageScore, totalExams];
}
