class ExamData {
  final List<ExamCategory> categories;
  final List<CompletedExam> completedExams;

  ExamData({
    required this.categories,
    required this.completedExams,
  });

  factory ExamData.fromJson(Map<String, dynamic> json) {
    return ExamData(
      categories: (json['categories'] as List)
          .map((category) => ExamCategory.fromJson(category))
          .toList(),
      completedExams: (json['completed_exams'] as List)
          .map((exam) => CompletedExam.fromJson(exam))
          .toList(),
    );
  }
}

class ExamCategory {
  final String id;
  final String title;
  final String icon;
  final int totalQuestions;
  final List<ExamItem> exams;

  ExamCategory({
    required this.id,
    required this.title,
    required this.icon,
    required this.totalQuestions,
    required this.exams,
  });

  factory ExamCategory.fromJson(Map<String, dynamic> json) {
    return ExamCategory(
      id: json['id'],
      title: json['title'],
      icon: json['icon'],
      totalQuestions: json['total_questions'],
      exams: (json['exams'] as List)
          .map((exam) => ExamItem.fromJson(exam))
          .toList(),
    );
  }
}

class ExamItem {
  final String id;
  final String title;
  final String subtitle;
  final int durationMinutes;
  final int questionCount;
  final String difficulty;
  final int requiredScore;
  final String icon;
  final bool isLocked;
  final List<String> prerequisites;

  ExamItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.durationMinutes,
    required this.questionCount,
    required this.difficulty,
    required this.requiredScore,
    required this.icon,
    required this.isLocked,
    required this.prerequisites,
  });

  factory ExamItem.fromJson(Map<String, dynamic> json) {
    return ExamItem(
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'],
      durationMinutes: json['duration_minutes'],
      questionCount: json['question_count'],
      difficulty: json['difficulty'],
      requiredScore: json['required_score'],
      icon: json['icon'],
      isLocked: json['is_locked'],
      prerequisites: List<String>.from(json['prerequisites']),
    );
  }
}

class CompletedExam {
  final String id;
  final String examId;
  final String title;
  final String completedAt;
  final int score;
  final int durationTaken;
  final int correctAnswers;
  final int totalQuestions;
  final String icon;

  CompletedExam({
    required this.id,
    required this.examId,
    required this.title,
    required this.completedAt,
    required this.score,
    required this.durationTaken,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.icon,
  });

  factory CompletedExam.fromJson(Map<String, dynamic> json) {
    return CompletedExam(
      id: json['id'],
      examId: json['exam_id'],
      title: json['title'],
      completedAt: json['completed_at'],
      score: json['score'],
      durationTaken: json['duration_taken'],
      correctAnswers: json['correct_answers'],
      totalQuestions: json['total_questions'],
      icon: json['icon'],
    );
  }
}
