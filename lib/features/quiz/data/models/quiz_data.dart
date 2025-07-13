class QuizData {
  final ExamInfo examInfo;
  final Map<String, List<QuizQuestion>> questions;

  QuizData({
    required this.examInfo,
    required this.questions,
  });

  factory QuizData.fromJson(Map<String, dynamic> json) {
    return QuizData(
      examInfo: ExamInfo.fromJson(json['exam_info'] ?? {}),
      questions: (json['questions'] as Map<String, dynamic>? ?? {}).map(
        (key, value) => MapEntry(
          key,
          (value as List? ?? [])
              .map((q) => QuizQuestion.fromJson(q ?? {}))
              .toList(),
        ),
      ),
    );
  }
}

class ExamInfo {
  final String id;
  final String title;
  final int durationMinutes;
  final int totalQuestions;
  final int passingScore;

  ExamInfo({
    required this.id,
    required this.title,
    required this.durationMinutes,
    required this.totalQuestions,
    required this.passingScore,
  });

  factory ExamInfo.fromJson(Map<String, dynamic> json) {
    return ExamInfo(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      durationMinutes: json['duration_minutes'] ?? 0,
      totalQuestions: json['total_questions'] ?? 0,
      passingScore: json['passing_score'] ?? 0,
    );
  }
}

class QuizQuestion {
  final String id;
  final Map<String, String> question; // Multi-language support
  final String? imageUrl;
  final List<Option> options;
  final String correctAnswer;
  final Map<String, String> explanation; // Multi-language support
  final String? difficulty;

  QuizQuestion({
    required this.id,
    required this.question,
    this.imageUrl,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    this.difficulty,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] ?? '',
      question: _parseMultiLangField(json['question']),
      imageUrl: json['image_url'],
      options: (json['options'] as List? ?? [])
          .map((option) => Option.fromJson(option ?? {}))
          .toList(),
      correctAnswer: json['correct_answer'] ?? '',
      explanation: _parseMultiLangField(json['explanation']),
      difficulty: json['difficulty'],
    );
  }

  // Helper method to get text in specific language
  String getQuestion([String language = 'tr']) {
    return question[language] ?? question['tr'] ?? question.values.first;
  }

  String getExplanation([String language = 'tr']) {
    return explanation[language] ??
        explanation['tr'] ??
        explanation.values.first;
  }

  // Helper method to parse multi-language fields from API
  static Map<String, String> _parseMultiLangField(dynamic field) {
    if (field is Map<String, dynamic>) {
      return field.map((key, value) => MapEntry(key, value?.toString() ?? ''));
    } else if (field is String) {
      // Fallback for single language (backwards compatibility)
      return {'tr': field};
    }
    return {'tr': ''};
  }
}

class Option {
  final String id;
  final Map<String, String> text; // Multi-language support
  final String? imageUrl;

  Option({
    required this.id,
    required this.text,
    this.imageUrl,
  });

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      id: json['id'] ?? '',
      text: QuizQuestion._parseMultiLangField(json['text']),
      imageUrl: json['image_url'],
    );
  }

  // Helper method to get text in specific language
  String getText([String language = 'tr']) {
    return text[language] ?? text['tr'] ?? text.values.first;
  }
}
