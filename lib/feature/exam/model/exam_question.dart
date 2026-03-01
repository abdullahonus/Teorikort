import 'package:equatable/equatable.dart';

/// Spec: STATE MODEL PATTERN — Equatable + copyWith
class ExamQuestion extends Equatable {
  final String id;
  final String question;
  final String? imageUrl;
  final List<ExamOption> options;
  final String correctAnswer;
  final String explanation;

  const ExamQuestion({
    required this.id,
    required this.question,
    this.imageUrl,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
  });

  factory ExamQuestion.fromJson(Map<String, dynamic> json) {
    return ExamQuestion(
      id: json['id']?.toString() ?? '',
      question: _parseField(json['question']),
      imageUrl: json['image_url'],
      options: (json['options'] as List? ?? [])
          .map((option) => ExamOption.fromJson(option))
          .toList(),
      correctAnswer: (json['correct_answer'] ?? '').toString(),
      explanation: _parseField(json['explanation']),
    );
  }

  static String _parseField(dynamic field) {
    if (field is Map<String, dynamic>) {
      return field['tr']?.toString() ??
          field['en']?.toString() ??
          (field.values.isNotEmpty ? field.values.first?.toString() ?? '' : '');
    }
    return field?.toString() ?? '';
  }

  factory ExamQuestion.fromLegacy(dynamic legacy) {
    if (legacy is Map<String, dynamic>) return ExamQuestion.fromJson(legacy);
    return ExamQuestion.fromJson(legacy.toJson());
  }

  ExamQuestion copyWith({
    String? id,
    String? question,
    String? imageUrl,
    List<ExamOption>? options,
    String? correctAnswer,
    String? explanation,
  }) {
    return ExamQuestion(
      id: id ?? this.id,
      question: question ?? this.question,
      imageUrl: imageUrl ?? this.imageUrl,
      options: options ?? this.options,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      explanation: explanation ?? this.explanation,
    );
  }

  @override
  List<Object?> get props =>
      [id, question, imageUrl, options, correctAnswer, explanation];
}

class ExamOption extends Equatable {
  final String id;
  final String text;
  final String? imageUrl;

  const ExamOption({
    required this.id,
    required this.text,
    this.imageUrl,
  });

  factory ExamOption.fromJson(Map<String, dynamic> json) {
    return ExamOption(
      id: (json['id'] ?? '').toString(),
      text: ExamQuestion._parseField(json['text']),
      imageUrl: json['image_url'],
    );
  }

  @override
  List<Object?> get props => [id, text, imageUrl];
}
