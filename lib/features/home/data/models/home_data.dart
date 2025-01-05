import 'package:flutter/material.dart';

class HomeData {
  final User user;
  final List<Test> todayTests;
  final Exam lastExam;
  final Notifications notifications;

  HomeData({
    required this.user,
    required this.todayTests,
    required this.lastExam,
    required this.notifications,
  });

  factory HomeData.fromJson(Map<String, dynamic> json) {
    return HomeData(
      user: User.fromJson(json['user']),
      todayTests: (json['today_tests'] as List)
          .map((test) => Test.fromJson(test))
          .toList(),
      lastExam: Exam.fromJson(json['last_exam']),
      notifications: Notifications.fromJson(json['notifications']),
    );
  }
}

class User {
  final String id;
  final String name;
  final String avatar;
  final Progress progress;

  User({
    required this.id,
    required this.name,
    required this.avatar,
    required this.progress,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      avatar: json['avatar'],
      progress: Progress.fromJson(json['progress']),
    );
  }
}

class Progress {
  final int weeklyRank;
  final int totalExams;
  final int completedExams;
  final int averageScore;

  Progress({
    required this.weeklyRank,
    required this.totalExams,
    required this.completedExams,
    required this.averageScore,
  });

  factory Progress.fromJson(Map<String, dynamic> json) {
    return Progress(
      weeklyRank: json['weekly_rank'],
      totalExams: json['total_exams'],
      completedExams: json['completed_exams'],
      averageScore: json['average_score'],
    );
  }
}

class Test {
  final String id;
  final String title;
  final String subtitle;
  final int durationMinutes;
  final int questionCount;
  final String difficulty;
  final String color;
  final String icon;

  Test({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.durationMinutes,
    required this.questionCount,
    required this.difficulty,
    required this.color,
    required this.icon,
  });

  factory Test.fromJson(Map<String, dynamic> json) {
    return Test(
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'],
      durationMinutes: json['duration_minutes'],
      questionCount: json['question_count'],
      difficulty: json['difficulty'],
      color: json['color'],
      icon: json['icon'],
    );
  }
}

class Exam {
  final String id;
  final String title;
  final String completedAt;
  final int score;
  final int durationMinutes;
  final int correctAnswers;
  final int totalQuestions;
  final String icon;

  Exam({
    required this.id,
    required this.title,
    required this.completedAt,
    required this.score,
    required this.durationMinutes,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.icon,
  });

  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      id: json['id'],
      title: json['title'],
      completedAt: json['completed_at'],
      score: json['score'],
      durationMinutes: json['duration_minutes'],
      correctAnswers: json['correct_answers'],
      totalQuestions: json['total_questions'],
      icon: json['icon'],
    );
  }
}

class Notifications {
  final int unreadCount;
  final int messagesCount;

  Notifications({
    required this.unreadCount,
    required this.messagesCount,
  });

  factory Notifications.fromJson(Map<String, dynamic> json) {
    return Notifications(
      unreadCount: json['unread_count'],
      messagesCount: json['messages_count'],
    );
  }
}
