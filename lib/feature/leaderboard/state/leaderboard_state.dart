import 'package:equatable/equatable.dart';
import '../model/leaderboard_entry.dart';

/// Spec: STATE MODEL PATTERN — Equatable + copyWith
class LeaderboardState extends Equatable {
  final bool isLoading;
  final String? error;
  final List<LeaderboardEntry> entries;
  final LeaderboardEntry? myRank;

  const LeaderboardState({
    this.isLoading = false,
    this.error,
    this.entries = const [],
    this.myRank,
  });

  LeaderboardState copyWith({
    bool? isLoading,
    String? error,
    List<LeaderboardEntry>? entries,
    LeaderboardEntry? myRank,
  }) {
    return LeaderboardState(
      isLoading: isLoading ?? this.isLoading,
      error: error, // Can be nullified unless specifically passed as a new string
      entries: entries ?? this.entries,
      myRank: myRank ?? this.myRank,
    );
  }

  @override
  List<Object?> get props => [isLoading, error, entries, myRank];
}
