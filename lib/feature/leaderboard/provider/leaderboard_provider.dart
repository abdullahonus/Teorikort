import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../product/provider/service_providers.dart';
import '../notifier/leaderboard_notifier.dart';
import '../state/leaderboard_state.dart';

/// Provider for Leaderboard state
final leaderboardProvider =
    StateNotifierProvider<LeaderboardNotifier, LeaderboardState>((ref) {
  final repo = ref.watch(leaderboardRepositoryProvider);
  return LeaderboardNotifier(repo);
});
