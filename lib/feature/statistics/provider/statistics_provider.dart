import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notifier/statistics_notifier.dart';
import '../state/statistics_state.dart';

/// Provider for global statistics state management.
final statisticsProvider = NotifierProvider<StatisticsNotifier, StatisticsState>(
  () => StatisticsNotifier(),
);

/// Computed provider for global analytics.
final appAnalyticsProvider = Provider((ref) {
  return ref.watch(statisticsProvider).analytics;
});

/// Computed provider for user-specific performance statistics.
final userStatisticsProvider = Provider((ref) {
  return ref.watch(statisticsProvider).statistics;
});

/// Family provider to watch stats for a specific category.
final categoryStatisticsProvider = Provider.family((ref, String categoryId) {
  return ref.watch(statisticsProvider).categoryStats[categoryId];
});
