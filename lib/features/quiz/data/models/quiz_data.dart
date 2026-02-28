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
    // Parse and filter options (drop entries with empty text)
    final rawOptions = (json['options'] as List? ?? []);
    final parsedOptions = rawOptions
        .map((option) => Option.fromJson(option ?? {}))
        .where((o) => o.getText().isNotEmpty)
        .toList();

    final correctAnswerRaw = json['correct_answer'];
    String correctAnswer = '';
    
    // Try to get as int (either directly or parsing string)
    int? correctIdx;
    if (correctAnswerRaw is int) {
      correctIdx = correctAnswerRaw;
    } else if (correctAnswerRaw is String) {
      correctIdx = int.tryParse(correctAnswerRaw);
    }
    
    if (correctIdx != null) {
      const letters = ['a', 'b', 'c', 'd', 'e'];
      final idx = correctIdx - 1;
      if (idx >= 0 && idx < letters.length) {
        correctAnswer = letters[idx];
      }
    } else {
      correctAnswer = correctAnswerRaw?.toString() ?? '';
    }

    return QuizQuestion(
      id: json['id']?.toString() ?? '',
      question: _parseMultiLangField(json['question']),
      imageUrl: json['image_url']?.toString().isEmpty == true ? null : json['image_url'],
      options: parsedOptions,
      correctAnswer: correctAnswer,
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
      return {'tr': field, 'en': field};
    }
    return {'tr': '', 'en': ''};
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
      id: json['id']?.toString() ?? '',
      text: QuizQuestion._parseMultiLangField(json['text']),
      imageUrl: json['image_url']?.toString(),
    );
  }

  // Helper method to get text in specific language
  String getText([String language = 'tr']) {
    return text[language] ?? text['tr'] ?? text.values.first;
  }
}
