class WelcomeMessage {
  final String message;
  final String? title;
  final String? subtitle;

  const WelcomeMessage({
    required this.message,
    this.title,
    this.subtitle,
  });

  factory WelcomeMessage.fromJson(Map<String, dynamic> json) {
    return WelcomeMessage(
      message: json['message'] ?? '',
      title: json['title'],
      subtitle: json['subtitle'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'title': title,
      'subtitle': subtitle,
    };
  }

  @override
  String toString() {
    return 'WelcomeMessage(message: $message, title: $title, subtitle: $subtitle)';
  }
}
