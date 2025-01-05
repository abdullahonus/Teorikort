class LeaderboardEntry {
  final String id;
  final String name;
  final String photoUrl;
  final int score;
  final int rank;
  final bool isCurrentUser;

  LeaderboardEntry({
    required this.id,
    required this.name,
    required this.photoUrl,
    required this.score,
    required this.rank,
    this.isCurrentUser = false,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      id: json['id'] as String,
      name: json['name'] as String,
      photoUrl: json['photo_url'] as String,
      score: json['score'] as int,
      rank: json['rank'] as int,
      isCurrentUser: json['is_current_user'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'photo_url': photoUrl,
      'score': score,
      'rank': rank,
      'is_current_user': isCurrentUser,
    };
  }
}
