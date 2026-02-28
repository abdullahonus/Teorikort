import 'package:teorikort/core/models/api_response.dart';
import 'package:teorikort/core/services/logger_service.dart';
import 'package:teorikort/domain/repository/i_leaderboard_repository.dart';
import 'package:teorikort/feature/leaderboard/model/leaderboard_entry.dart' as model;
import 'package:teorikort/features/leaderboard/data/services/leaderboard_service.dart';

class LeaderboardRepositoryImpl implements ILeaderboardRepository {
  final LeaderboardService _service;

  LeaderboardRepositoryImpl(this._service);

  @override
  Future<ApiResponse<List<model.LeaderboardEntry>>> getLeaderboard() async {
    try {
      final response = await _service.getLeaderboard();
      if (response.success && response.data != null) {
        final entries = response.data!
            .map((e) => model.LeaderboardEntry(
                  rank: e.rank,
                  userId: e.userId,
                  name: e.name,
                  score: e.score,
                  totalExams: e.totalExams,
                  averageScore: e.averageScore,
                  isCurrentUser: e.isCurrentUser,
                ))
            .toList();

        return ApiResponse<List<model.LeaderboardEntry>>(
          success: true,
          statusCode: response.statusCode,
          data: entries,
        );
      }
      return ApiResponse<List<model.LeaderboardEntry>>(
        success: false,
        message: response.message,
        statusCode: response.statusCode,
      );
    } catch (e) {
      LoggerService.error('LeaderboardRepositoryImpl.getLeaderboard', e);
      return ApiResponse<List<model.LeaderboardEntry>>(
        success: false,
        message: e.toString(),
        statusCode: 500,
      );
    }
  }

  @override
  Future<ApiResponse<model.LeaderboardEntry>> getMyRank() async {
    try {
      final response = await _service.getMyRank();
      if (response.success && response.data != null) {
        final e = response.data!;
        return ApiResponse<model.LeaderboardEntry>(
          success: true,
          statusCode: response.statusCode,
          data: model.LeaderboardEntry(
            rank: e.rank,
            userId: e.userId,
            name: e.name,
            score: e.score,
            totalExams: e.totalExams,
            averageScore: e.averageScore,
            isCurrentUser: e.isCurrentUser,
          ),
        );
      }
      return ApiResponse<model.LeaderboardEntry>(
        success: false,
        message: response.message,
        statusCode: response.statusCode,
      );
    } catch (e) {
      LoggerService.error('LeaderboardRepositoryImpl.getMyRank', e);
      return ApiResponse<model.LeaderboardEntry>(
        success: false,
        message: e.toString(),
        statusCode: 500,
      );
    }
  }
}
