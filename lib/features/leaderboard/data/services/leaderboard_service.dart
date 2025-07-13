import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/services/base_api_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/models/api_response.dart';
import '../models/leaderboard_entry.dart';

class LeaderboardService extends BaseApiService {
  // Get leaderboard from API with fallback to mock data
  Future<ApiResponse<LeaderboardData>> getLeaderboard({
    String period = 'weekly',
    int limit = 50,
    BuildContext? context,
  }) async {
    try {
      final language = getCurrentLanguage(context);
      final queryParams = {
        'period': period,
        'limit': limit.toString(),
        'language': language,
      };

      // Try API first
      try {
        final response = await handleResponse<LeaderboardData>(
          get(
            ApiConstants.leaderboard,
            queryParameters: queryParams,
          ),
          LeaderboardData.fromJson,
        );

        if (response.success && response.data != null) {
          return response;
        }
      } catch (apiError) {
        print(
            'Leaderboard API çağrısı başarısız, mock verilere geçiliyor: $apiError');
      }

      // Fallback to mock data
      return await _loadMockLeaderboard(period, limit);
    } catch (e) {
      return await _loadMockLeaderboard(period, limit);
    }
  }

  // Load mock leaderboard from assets
  Future<ApiResponse<LeaderboardData>> _loadMockLeaderboard(
      String period, int limit) async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/data/mock_users.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      final List<dynamic> usersData = jsonData['users'] ?? [];

      // Convert to leaderboard entries and sort by score
      final List<LeaderboardEntry> entries = usersData.map((userData) {
        final index = usersData.indexOf(userData);
        return LeaderboardEntry(
          id: userData['id']?.toString() ?? 'user_${index + 1}',
          rank: index + 1,
          name: userData['name'] ?? 'Kullanıcı ${index + 1}',
          score: userData['score'] ?? (90 - (index * 2)), // Decreasing scores
          photoUrl: userData['photo_url'] ?? 'https://via.placeholder.com/150',
          isCurrentUser: index == 0, // First user is current user for demo
        );
      }).toList();

      // Limit results
      final limitedEntries = entries.take(limit).toList();

      final currentUser = CurrentUserInfo(
        rank: 1,
        score: limitedEntries.isNotEmpty ? limitedEntries.first.score : 0,
        totalUsers: limitedEntries.length,
      );

      final leaderboardData = LeaderboardData(
        leaderboard: limitedEntries,
        currentUser: currentUser,
        period: period,
        lastUpdated: DateTime.now(),
      );

      return ApiResponse<LeaderboardData>(
        success: true,
        statusCode: 100,
        message: 'Mock lider tablosu başarıyla yüklendi',
        data: leaderboardData,
      );
    } catch (e) {
      // Return empty leaderboard if mock data fails
      final emptyLeaderboard = LeaderboardData(
        leaderboard: [],
        currentUser: CurrentUserInfo(rank: 0, score: 0, totalUsers: 0),
        period: period,
        lastUpdated: DateTime.now(),
      );

      return ApiResponse<LeaderboardData>(
        success: true,
        statusCode: 100,
        message: 'Lider tablosu henüz oluşturulmadı',
        data: emptyLeaderboard,
      );
    }
  }

  // Get user rank with fallback
  Future<ApiResponse<UserRankData>> getUserRank({
    String period = 'weekly',
    BuildContext? context,
  }) async {
    try {
      final language = getCurrentLanguage(context);
      final queryParams = {
        'period': period,
        'language': language,
      };

      // Try API first
      try {
        final response = await handleResponse<UserRankData>(
          get(
            ApiConstants.myRank,
            queryParameters: queryParams,
          ),
          UserRankData.fromJson,
        );

        if (response.success && response.data != null) {
          return response;
        }
      } catch (apiError) {
        print(
            'User rank API çağrısı başarısız, mock verilere geçiliyor: $apiError');
      }

      // Fallback to mock data
      return await _loadMockUserRank(period);
    } catch (e) {
      return await _loadMockUserRank(period);
    }
  }

  // Load mock user rank
  Future<ApiResponse<UserRankData>> _loadMockUserRank(String period) async {
    try {
      final mockUserRank = UserRankData(
        currentRank: 1,
        totalUsers: 100,
        score: 95,
        percentile: 95.0,
        rankChange: '+2',
        periodName: period,
      );

      return ApiResponse<UserRankData>(
        success: true,
        statusCode: 100,
        message: 'Mock kullanıcı sıralaması yüklendi',
        data: mockUserRank,
      );
    } catch (e) {
      return ApiResponse<UserRankData>(
        success: false,
        statusCode: 500,
        message: 'Kullanıcı sıralaması yüklenemedi: $e',
      );
    }
  }
}

// New models for API responses (updated versions)
class LeaderboardData {
  final List<LeaderboardEntry> leaderboard;
  final CurrentUserInfo currentUser;
  final String period;
  final DateTime lastUpdated;

  LeaderboardData({
    required this.leaderboard,
    required this.currentUser,
    required this.period,
    required this.lastUpdated,
  });

  factory LeaderboardData.fromJson(Map<String, dynamic> json) {
    return LeaderboardData(
      leaderboard: (json['leaderboard'] as List? ?? [])
          .map((entry) => LeaderboardEntry.fromJson(entry))
          .toList(),
      currentUser: CurrentUserInfo.fromJson(json['current_user'] ?? {}),
      period: json['period'] ?? 'weekly',
      lastUpdated: DateTime.parse(
          json['last_updated'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class CurrentUserInfo {
  final int rank;
  final int score;
  final int totalUsers;

  CurrentUserInfo({
    required this.rank,
    required this.score,
    required this.totalUsers,
  });

  factory CurrentUserInfo.fromJson(Map<String, dynamic> json) {
    return CurrentUserInfo(
      rank: json['rank'] ?? 0,
      score: json['score'] ?? 0,
      totalUsers: json['total_users'] ?? 0,
    );
  }
}

class UserRankData {
  final int currentRank;
  final int totalUsers;
  final int score;
  final double percentile;
  final String rankChange;
  final String periodName;

  UserRankData({
    required this.currentRank,
    required this.totalUsers,
    required this.score,
    required this.percentile,
    required this.rankChange,
    required this.periodName,
  });

  factory UserRankData.fromJson(Map<String, dynamic> json) {
    return UserRankData(
      currentRank: json['current_rank'] ?? 0,
      totalUsers: json['total_users'] ?? 0,
      score: json['score'] ?? 0,
      percentile: (json['percentile'] ?? 0).toDouble(),
      rankChange: json['rank_change'] ?? '0',
      periodName: json['period_name'] ?? 'weekly',
    );
  }
}
