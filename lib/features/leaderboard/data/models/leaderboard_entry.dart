class LeaderboardEntry {
  final int rank;
  final int userId;
  final String name;
  final int score;
  final int totalExams;
  final double averageScore;
  final bool isCurrentUser;

  LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.name,
    required this.score,
    required this.totalExams,
    required this.averageScore,
    this.isCurrentUser = false,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: json['rank'] ?? 0,
      userId: json['user_id'] is int
          ? json['user_id']
          : int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      name: json['name'] ?? '',
      score: json['score'] is int
          ? json['score']
          : int.tryParse(json['score']?.toString() ?? '0') ?? 0,
      totalExams: json['total_exams'] ?? 0,
      averageScore: (json['average_score'] ?? 0).toDouble(),
      isCurrentUser: json['is_current_user'] ?? false,
    );
  }
}
