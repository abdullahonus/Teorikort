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
  final String question;
  final String? imageUrl;
  final List<Option> options;
  final String correctAnswer;
  final String explanation;

  QuizQuestion({
    required this.id,
    required this.question,
    this.imageUrl,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] ?? '',
      question: json['question'] ?? '',
      imageUrl: json['image_url'],
      options: (json['options'] as List? ?? [])
          .map((option) => Option.fromJson(option ?? {}))
          .toList(),
      correctAnswer: json['correct_answer'] ?? '',
      explanation: json['explanation'] ?? '',
    );
  }
}

class Option {
  final String id;
  final String text;
  final String? imageUrl;

  Option({
    required this.id,
    required this.text,
    this.imageUrl,
  });

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      imageUrl: json['image_url'],
    );
  }
}
