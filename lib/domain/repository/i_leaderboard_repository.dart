import 'package:teorikort/core/models/api_response.dart';
import 'package:teorikort/feature/leaderboard/model/leaderboard_entry.dart';

abstract class ILeaderboardRepository {
  /// Fetches global leaderboard.
  Future<ApiResponse<List<LeaderboardEntry>>> getLeaderboard();

  /// Fetches the current user's rank.
  Future<ApiResponse<LeaderboardEntry>> getMyRank();
}
