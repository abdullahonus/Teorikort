import 'dart:convert';

class QuizQuestion {
  final String id;
  final String question;
  final String? imageUrl;
  final List<QuizOption> options;
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
          .map((option) => QuizOption.fromJson(option))
          .toList(),
      correctAnswer: json['correct_answer'] ?? '',
      explanation: json['explanation'] ?? '',
    );
  }
}

class QuizOption {
  final String id;
  final String text;
  final String? imageUrl;

  QuizOption({
    required this.id,
    required this.text,
    this.imageUrl,
  });

  factory QuizOption.fromJson(Map<String, dynamic> json) {
    return QuizOption(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      imageUrl: json['image_url'],
    );
  }
}
