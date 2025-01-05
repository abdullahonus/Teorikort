class ProfileData {
  final ProfileUser user;
  final LearningStats learningStats;
  final List<Achievement> achievements;
  final Preferences preferences;

  ProfileData({
    required this.user,
    required this.learningStats,
    required this.achievements,
    required this.preferences,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      user: ProfileUser.fromJson(json['user']),
      learningStats: LearningStats.fromJson(json['learning_stats']),
      achievements: (json['achievements'] as List)
          .map((achievement) => Achievement.fromJson(achievement))
          .toList(),
      preferences: Preferences.fromJson(json['preferences']),
    );
  }
}

class ProfileUser {
  final String id;
  final String name;
  final String email;
  final String avatar;
  final String joinedDate;
  final String subscriptionStatus;
  final String subscriptionExpires;

  ProfileUser({
    required this.id,
    required this.name,
    required this.email,
    required this.avatar,
    required this.joinedDate,
    required this.subscriptionStatus,
    required this.subscriptionExpires,
  });

  factory ProfileUser.fromJson(Map<String, dynamic> json) {
    return ProfileUser(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      avatar: json['avatar'],
      joinedDate: json['joined_date'],
      subscriptionStatus: json['subscription_status'],
      subscriptionExpires: json['subscription_expires'],
    );
  }
}

class LearningStats {
  final int totalStudyDays;
  final int currentStreak;
  final int bestStreak;
  final int totalStudyTime;
  final int averageDailyTime;

  LearningStats({
    required this.totalStudyDays,
    required this.currentStreak,
    required this.bestStreak,
    required this.totalStudyTime,
    required this.averageDailyTime,
  });

  factory LearningStats.fromJson(Map<String, dynamic> json) {
    return LearningStats(
      totalStudyDays: json['total_study_days'],
      currentStreak: json['current_streak'],
      bestStreak: json['best_streak'],
      totalStudyTime: json['total_study_time'],
      averageDailyTime: json['average_daily_time'],
    );
  }
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final String achievedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.achievedAt,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      icon: json['icon'],
      achievedAt: json['achieved_at'],
    );
  }
}

class Preferences {
  final String language;
  final bool notificationsEnabled;
  final bool darkMode;
  final bool soundEnabled;

  Preferences({
    required this.language,
    required this.notificationsEnabled,
    required this.darkMode,
    required this.soundEnabled,
  });

  factory Preferences.fromJson(Map<String, dynamic> json) {
    return Preferences(
      language: json['language'],
      notificationsEnabled: json['notifications_enabled'],
      darkMode: json['dark_mode'],
      soundEnabled: json['sound_enabled'],
    );
  }
}
