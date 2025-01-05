class StatisticsData {
  final OverallStats overallStats;
  final List<CategoryPerformance> categoryPerformance;
  final List<RecentExam> recentExams;

  StatisticsData({
    required this.overallStats,
    required this.categoryPerformance,
    required this.recentExams,
  });

  factory StatisticsData.fromJson(Map<String, dynamic> json) {
    return StatisticsData(
      overallStats: OverallStats.fromJson(json['overall_stats']),
      categoryPerformance: (json['category_performance'] as List)
          .map((category) => CategoryPerformance.fromJson(category))
          .toList(),
      recentExams: (json['recent_exams'] as List)
          .map((exam) => RecentExam.fromJson(exam))
          .toList(),
    );
  }
}

class OverallStats {
  final int totalExamsTaken;
  final int totalAvailableExams;
  final int averageScore;
  final int bestScore;
  final int totalStudyTime;
  final int totalQuestionsAnswered;
  final int correctAnswersRate;

  OverallStats({
    required this.totalExamsTaken,
    required this.totalAvailableExams,
    required this.averageScore,
    required this.bestScore,
    required this.totalStudyTime,
    required this.totalQuestionsAnswered,
    required this.correctAnswersRate,
  });

  factory OverallStats.fromJson(Map<String, dynamic> json) {
    return OverallStats(
      totalExamsTaken: json['total_exams_taken'],
      totalAvailableExams: json['total_available_exams'],
      averageScore: json['average_score'],
      bestScore: json['best_score'],
      totalStudyTime: json['total_study_time'],
      totalQuestionsAnswered: json['total_questions_answered'],
      correctAnswersRate: json['correct_answers_rate'],
    );
  }
}

class CategoryPerformance {
  final String categoryId;
  final String name;
  final int examsTaken;
  final int averageScore;
  final int bestScore;
  final int progress;
  final List<String> weakAreas;
  final List<String> strongAreas;

  CategoryPerformance({
    required this.categoryId,
    required this.name,
    required this.examsTaken,
    required this.averageScore,
    required this.bestScore,
    required this.progress,
    required this.weakAreas,
    required this.strongAreas,
  });

  factory CategoryPerformance.fromJson(Map<String, dynamic> json) {
    return CategoryPerformance(
      categoryId: json['category_id'],
      name: json['name'],
      examsTaken: json['exams_taken'],
      averageScore: json['average_score'],
      bestScore: json['best_score'],
      progress: json['progress'],
      weakAreas: List<String>.from(json['weak_areas']),
      strongAreas: List<String>.from(json['strong_areas']),
    );
  }
}

class RecentExam {
  final String id;
  final String title;
  final String category;
  final String completedAt;
  final int score;
  final int durationMinutes;
  final int correctAnswers;
  final int totalQuestions;
  final String improvement;

  RecentExam({
    required this.id,
    required this.title,
    required this.category,
    required this.completedAt,
    required this.score,
    required this.durationMinutes,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.improvement,
  });

  factory RecentExam.fromJson(Map<String, dynamic> json) {
    return RecentExam(
      id: json['id'],
      title: json['title'],
      category: json['category'],
      completedAt: json['completed_at'],
      score: json['score'],
      durationMinutes: json['duration_minutes'],
      correctAnswers: json['correct_answers'],
      totalQuestions: json['total_questions'],
      improvement: json['improvement'],
    );
  }
}
