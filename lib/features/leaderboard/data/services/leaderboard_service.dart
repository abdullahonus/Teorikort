import 'package:flutter/material.dart';
import '../../../../core/services/base_api_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/models/api_response.dart';
import '../models/leaderboard_entry.dart';

class LeaderboardService extends BaseApiService {
  // GET /leaderboard — data is a flat List
  Future<ApiResponse<List<LeaderboardEntry>>> getLeaderboard({
    BuildContext? context,
  }) async {
    final language = getCurrentLanguage(context);
    return await handleListResponse<LeaderboardEntry>(
      get(ApiConstants.leaderboard, language: language),
      LeaderboardEntry.fromJson,
    );
  }

  // GET /leaderboard/my-rank — data is a single LeaderboardEntry object
  Future<ApiResponse<LeaderboardEntry>> getMyRank({
    BuildContext? context,
  }) async {
    final language = getCurrentLanguage(context);
    return await handleResponse<LeaderboardEntry>(
      get(ApiConstants.myRank, language: language),
      LeaderboardEntry.fromJson,
    );
  }
}
