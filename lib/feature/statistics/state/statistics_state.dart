import 'package:equatable/equatable.dart';
import '../model/app_analytics.dart';
import '../model/statistics_data.dart';
import '../model/category_statistics.dart';

/// Spec: STATE MODEL PATTERN — Equatable + copyWith
class StatisticsState extends Equatable {
  final bool isLoading;
  final String? error;
  final AppAnalytics? analytics;
  final StatisticsData? statistics;
  final Map<String, CategoryStatistics> categoryStats;

  const StatisticsState({
    this.isLoading = false,
    this.error,
    this.analytics,
    this.statistics,
    this.categoryStats = const {},
  });

  StatisticsState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    AppAnalytics? analytics,
    StatisticsData? statistics,
    Map<String, CategoryStatistics>? categoryStats,
  }) =>
      StatisticsState(
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
        analytics: analytics ?? this.analytics,
        statistics: statistics ?? this.statistics,
        categoryStats: categoryStats ?? this.categoryStats,
      );

  @override
  List<Object?> get props =>
      [isLoading, error, analytics, statistics, categoryStats];
}
