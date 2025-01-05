import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:driving_license_exam/features/leaderboard/data/models/leaderboard_entry.dart';
import 'package:driving_license_exam/features/exam/data/services/exam_result_service.dart';
import 'package:driving_license_exam/core/services/user_service.dart';

class LeaderboardService {
  final ExamResultService _examResultService = ExamResultService();
  final UserService _userService = UserService();

  Future<List<Map<String, dynamic>>> _loadMockUsers() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/data/mock_users.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      return List<Map<String, dynamic>>.from(jsonData['users']);
    } catch (e) {
      print('Error loading mock users: $e');
      return [];
    }
  }

  Future<List<LeaderboardEntry>> getLeaderboard() async {
    try {
      // Get current user's exam results
      final examResults = await _examResultService.getExamResults();
      final mockUsers = await _loadMockUsers();

      // Calculate current user's best score
      int currentUserBestScore = 0;
      if (examResults.isNotEmpty) {
        currentUserBestScore = examResults
            .map((result) => result.scorePercentage.round())
            .reduce((max, score) => score > max ? score : max);
      }

      // Create leaderboard entries including mock users and current user
      final List<LeaderboardEntry> entries = [];

      // Add mock users
      entries.addAll(mockUsers.map((user) => LeaderboardEntry(
            id: user['id'],
            name: user['name'],
            photoUrl: user['photo_url'],
            score: user['score'],
            rank: 0, // Will be set after sorting
            isCurrentUser: false,
          )));

      // Her zaman mevcut kullanıcıyı ekle
      entries.add(LeaderboardEntry(
        id: _userService.currentUserId,
        name: _userService.currentUserName,
        photoUrl: _userService.currentUserPhoto,
        score: currentUserBestScore > 0 ? currentUserBestScore : 0,
        rank: 0, // Will be set after sorting
        isCurrentUser: true,
      ));

      // Sort by score in descending order
      entries.sort((a, b) => b.score.compareTo(a.score));

      // Assign ranks
      for (var i = 0; i < entries.length; i++) {
        final entry = entries[i];
        final rank = i + 1;
        entries[i] = LeaderboardEntry(
          id: entry.id,
          name: entry.name,
          photoUrl: entry.photoUrl,
          score: entry.score,
          rank: rank,
          isCurrentUser: entry.isCurrentUser,
        );
      }

      return entries;
    } catch (e) {
      print('Error fetching leaderboard: $e');
      return [];
    }
  }
}
