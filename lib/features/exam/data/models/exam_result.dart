class ExamResult {
  final String id;
  final String userId;
  final String userName;
  final String category;
  final int totalQuestions;
  final int correctAnswers;
  final double scorePercentage;
  final Duration duration;
  final DateTime completedAt;

  ExamResult({
    required this.id,
    required this.userId,
    required this.userName,
    required this.category,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.scorePercentage,
    required this.duration,
    required this.completedAt,
  });

  factory ExamResult.fromJson(Map<String, dynamic> json) {
    return ExamResult(
      id: json['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      userId: json['user_id']?.toString() ?? 'unknown',
      userName: json['user_name']?.toString() ?? 'Unknown User',
      category: json['category']?.toString() ?? '',
      totalQuestions: json['total_questions'] as int? ?? 0,
      correctAnswers: json['correct_answers'] as int? ?? 0,
      scorePercentage: (json['score_percentage'] as num?)?.toDouble() ?? 0.0,
      duration: Duration(seconds: json['duration_seconds'] as int? ?? 0),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'category': category,
      'total_questions': totalQuestions,
      'correct_answers': correctAnswers,
      'score_percentage': scorePercentage,
      'duration_seconds': duration.inSeconds,
      'completed_at': completedAt.toIso8601String(),
    };
  }
}
