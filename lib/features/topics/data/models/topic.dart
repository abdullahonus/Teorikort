class Topic {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final List<String> images;
  final List<SubTopic> subTopics;

  Topic({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.images,
    required this.subTopics,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['image_url'] as String,
      images: List<String>.from(json['images'] ?? []),
      subTopics: (json['sub_topics'] as List)
          .map((subTopic) => SubTopic.fromJson(subTopic))
          .toList(),
    );
  }
}

class SubTopic {
  final String id;
  final String title;
  final String content;
  final List<String> images;

  SubTopic({
    required this.id,
    required this.title,
    required this.content,
    required this.images,
  });

  factory SubTopic.fromJson(Map<String, dynamic> json) {
    return SubTopic(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      images: List<String>.from(json['images'] ?? []),
    );
  }
}
