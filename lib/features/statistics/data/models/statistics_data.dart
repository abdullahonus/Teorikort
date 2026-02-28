// ─── /statistics/analytics ─────────────────────────────────────────────────

class AppAnalyticsData {
  final int totalUsers;
  final int totalExams;
  final int totalCategories;
  final double averageScore;

  AppAnalyticsData({
    required this.totalUsers,
    required this.totalExams,
    required this.totalCategories,
    required this.averageScore,
  });

  factory AppAnalyticsData.fromJson(Map<String, dynamic> json) {
    return AppAnalyticsData(
      totalUsers: json['total_users'] ?? 0,
      totalExams: json['total_exams'] ?? 0,
      totalCategories: json['total_categories'] ?? 0,
      averageScore: (json['average_score'] ?? 0).toDouble(),
    );
  }
}

// ─── /statistics ────────────────────────────────────────────────────────────

class StatisticsData {
  final int totalExams;
  final double averageScore;
  final double highestScore;
  final List<CategoryPerformance> categoryPerformance;

  StatisticsData({
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
}

class CategoryPerformance {
  final int categoryId;
  final String categoryName;
  final double averageScore;
  final int totalExams;

  CategoryPerformance({
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
}

// ─── /statistics/categories/{id} ───────────────────────────────────────────

class RecentExamResult {
  final int id;
  final double point;
  final DateTime createdAt;

  RecentExamResult({
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
}

class CategoryStatisticsData {
  final int categoryId;
  final String categoryTitle;
  final int totalExams;
  final double averageScore;
  final double highestScore;
  final double lowestScore;
  final List<RecentExamResult> recentExams;

  CategoryStatisticsData({
    required this.categoryId,
    required this.categoryTitle,
    required this.totalExams,
    required this.averageScore,
    required this.highestScore,
    required this.lowestScore,
    required this.recentExams,
  });

  factory CategoryStatisticsData.fromJson(Map<String, dynamic> json) {
    final cat = json['category'] as Map<String, dynamic>? ?? {};
    return CategoryStatisticsData(
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
}
