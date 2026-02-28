class ExamData {
  final List<ExamCategory> categories;
  final List<CompletedExam> completedExams;

  ExamData({
    required this.categories,
    required this.completedExams,
  });

  factory ExamData.fromJson(Map<String, dynamic> json) {
    return ExamData(
      categories: (json['categories'] as List? ?? [])
          .map((category) => ExamCategory.fromJson(category))
          .toList(),
      completedExams: (json['completed_exams'] as List? ?? [])
          .map((exam) => CompletedExam.fromJson(exam))
          .toList(),
    );
  }
}

class ExamCategory {
  final int id;
  final String title;
  final int top;
  final String description;
  final int timeSecound;
  final int successPint;
  final String image;
  final int content;
  final int totalQuestions;
  final String createdAt;
  final String updatedAt;

  ExamCategory({
    required this.id,
    required this.title,
    required this.top,
    required this.description,
    required this.timeSecound,
    required this.successPint,
    required this.image,
    required this.content,
    required this.totalQuestions,
    required this.createdAt,
    required this.updatedAt,
  });

  String get icon => image; // fallback backward compat

  static String _parseField(dynamic field) {
    if (field is Map<String, dynamic>) {
      return field['tr']?.toString() ??
          field['en']?.toString() ??
          (field.values.isNotEmpty ? field.values.first?.toString() ?? '' : '');
    }
    return field?.toString() ?? '';
  }

  factory ExamCategory.fromJson(Map<String, dynamic> json) {
    // If the data is nested under a 'category' key, use that
    final data = json.containsKey('category')
        ? json['category'] as Map<String, dynamic>
        : json;

    return ExamCategory(
      id: data['id'] is int
          ? data['id']
          : int.tryParse(data['id']?.toString() ?? '0') ?? 0,
      title: _parseField(data['title']),
      top: data['top'] ?? 0,
      description: _parseField(data['description']),
      timeSecound: data['time_secound'] ?? 2700,
      successPint: data['success_pint'] ?? 70,
      image: data['image'] ?? '',
      content: data['content'] ?? 0,
      totalQuestions: data['total_questions'] ?? 45,
      createdAt: data['created_at'] ?? '',
      updatedAt: data['updated_at'] ?? '',
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
