import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/repository/i_leaderboard_repository.dart';
import '../state/leaderboard_state.dart';

class LeaderboardNotifier extends StateNotifier<LeaderboardState> {
  final ILeaderboardRepository _repository;

  LeaderboardNotifier(this._repository) : super(const LeaderboardState());

  Future<void> loadLeaderboard() async {
    state = state.copyWith(isLoading: true);

    try {
      final leaderboardRes = await _repository.getLeaderboard();
      final myRankRes = await _repository.getMyRank();

      if (leaderboardRes.success && leaderboardRes.data != null) {
        state = state.copyWith(
          entries: leaderboardRes.data!,
          myRank: myRankRes.success ? myRankRes.data : null,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: leaderboardRes.message ?? 'Unknown error',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    await loadLeaderboard();
  }
}
