import 'package:equatable/equatable.dart';

/// Spec: STATE MODEL PATTERN — Equatable + copyWith
class AppAnalytics extends Equatable {
  final int totalUsers;
  final int totalExams;
  final int totalCategories;
  final double averageScore;

  const AppAnalytics({
    required this.totalUsers,
    required this.totalExams,
    required this.totalCategories,
    required this.averageScore,
  });

  factory AppAnalytics.fromJson(Map<String, dynamic> json) {
    return AppAnalytics(
      totalUsers: json['total_users'] ?? 0,
      totalExams: json['total_exams'] ?? 0,
      totalCategories: json['total_categories'] ?? 0,
      averageScore: (json['average_score'] ?? 0).toDouble(),
    );
  }

  AppAnalytics copyWith({
    int? totalUsers,
    int? totalExams,
    int? totalCategories,
    double? averageScore,
  }) {
    return AppAnalytics(
      totalUsers: totalUsers ?? this.totalUsers,
      totalExams: totalExams ?? this.totalExams,
      totalCategories: totalCategories ?? this.totalCategories,
      averageScore: averageScore ?? this.averageScore,
    );
  }

  @override
  List<Object?> get props => [totalUsers, totalExams, totalCategories, averageScore];
}
