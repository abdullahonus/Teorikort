import 'package:equatable/equatable.dart';

/// Spec: STATE MODEL PATTERN — Equatable + copyWith
class Topic extends Equatable {
  final int id;
  final String title;
  final String description;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Topic({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      content: json['content'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Topic copyWith({
    int? id,
    String? title,
    String? description,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Topic(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props =>
      [id, title, description, content, createdAt, updatedAt];
}

class TopicDetail extends Equatable {
  final Topic topic;
  final List<dynamic> questions; // Placeholder until specific model needed

  const TopicDetail({
    required this.topic,
    required this.questions,
  });

  factory TopicDetail.fromJson(Map<String, dynamic> json) {
    return TopicDetail(
      topic: Topic.fromJson(json['course'] ?? {}),
      questions: json['questions'] as List? ?? [],
    );
  }

  @override
  List<Object?> get props => [topic, questions];
}

class SubTopic extends Equatable {
  final int id;
  final String title;
  final String content;

  const SubTopic({
    required this.id,
    required this.title,
    required this.content,
  });

  factory SubTopic.fromJson(Map<String, dynamic> json) {
    return SubTopic(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
    );
  }

  @override
  List<Object?> get props => [id, title, content];
}
