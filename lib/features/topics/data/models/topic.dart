class Topic {
  final String id;
  final Map<String, String> title; // Multi-language support
  final Map<String, String> description; // Multi-language support
  final String imageUrl;
  final List<String> images;
  final List<SubTopic> subTopics;
  final int? subTopicsCount;
  final int? imagesCount;
  final int? estimatedReadTime;
  final String? difficulty;

  Topic({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.images,
    required this.subTopics,
    this.subTopicsCount,
    this.imagesCount,
    this.estimatedReadTime,
    this.difficulty,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'] as String,
      title: _parseMultiLangField(json['title']),
      description: _parseMultiLangField(json['description']),
      imageUrl: json['image_url'] as String,
      images: List<String>.from(json['images'] ?? []),
      subTopics: (json['sub_topics'] as List? ?? [])
          .map((subTopic) => SubTopic.fromJson(subTopic))
          .toList(),
      subTopicsCount: json['sub_topics_count'] as int?,
      imagesCount: json['images_count'] as int?,
      estimatedReadTime: json['estimated_read_time'] as int?,
      difficulty: json['difficulty'] as String?,
    );
  }

  // Helper method to get text in specific language
  String getTitle([String language = 'tr']) {
    return title[language] ?? title['tr'] ?? title.values.first;
  }

  String getDescription([String language = 'tr']) {
    return description[language] ??
        description['tr'] ??
        description.values.first;
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

class SubTopic {
  final String id;
  final Map<String, String> title; // Multi-language support
  final Map<String, String> content; // Multi-language support
  final List<String> images;
  final int? order;
  final List<RelatedQuestion>? relatedQuestions;
  final SubTopicNavigation? nextSubtopic;
  final SubTopicNavigation? previousSubtopic;

  SubTopic({
    required this.id,
    required this.title,
    required this.content,
    required this.images,
    this.order,
    this.relatedQuestions,
    this.nextSubtopic,
    this.previousSubtopic,
  });

  factory SubTopic.fromJson(Map<String, dynamic> json) {
    return SubTopic(
      id: json['id'],
      title: Topic._parseMultiLangField(json['title']),
      content: Topic._parseMultiLangField(json['content']),
      images: List<String>.from(json['images'] ?? []),
      order: json['order'] as int?,
      relatedQuestions: (json['related_questions'] as List? ?? [])
          .map((q) => RelatedQuestion.fromJson(q))
          .toList(),
      nextSubtopic: json['next_subtopic'] != null
          ? SubTopicNavigation.fromJson(json['next_subtopic'])
          : null,
      previousSubtopic: json['previous_subtopic'] != null
          ? SubTopicNavigation.fromJson(json['previous_subtopic'])
          : null,
    );
  }

  // Helper method to get text in specific language
  String getTitle([String language = 'tr']) {
    return title[language] ?? title['tr'] ?? title.values.first;
  }

  String getContent([String language = 'tr']) {
    return content[language] ?? content['tr'] ?? content.values.first;
  }
}

class RelatedQuestion {
  final String id;
  final String question;
  final String category;

  RelatedQuestion({
    required this.id,
    required this.question,
    required this.category,
  });

  factory RelatedQuestion.fromJson(Map<String, dynamic> json) {
    return RelatedQuestion(
      id: json['id'] as String,
      question: json['question'] as String,
      category: json['category'] as String,
    );
  }
}

class SubTopicNavigation {
  final String id;
  final String title;

  SubTopicNavigation({
    required this.id,
    required this.title,
  });

  factory SubTopicNavigation.fromJson(Map<String, dynamic> json) {
    return SubTopicNavigation(
      id: json['id'] as String,
      title: json['title'] as String,
    );
  }
}
