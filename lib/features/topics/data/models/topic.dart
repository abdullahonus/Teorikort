class Topic {
  final int id;
  final String title;
  final String description;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  Topic({
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
}

class TopicDetail {
  final Topic course;
  final List<dynamic>
      questions; // Use dynamic for now as we haven't defined a question model for this specific nested case yet or will reuse QuizQuestion later

  TopicDetail({
    required this.course,
    required this.questions,
  });

  factory TopicDetail.fromJson(Map<String, dynamic> json) {
    return TopicDetail(
      course: Topic.fromJson(json['course'] ?? {}),
      questions: json['questions'] as List? ?? [],
    );
  }
}

class SubTopic {
  final int id;
  final String title;
  final String content;

  SubTopic({
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
}
