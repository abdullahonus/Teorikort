import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/logger_service.dart';
import '../../../domain/repository/i_statistics_repository.dart';
import '../../../product/provider/service_providers.dart';
import '../state/statistics_state.dart';

class StatisticsNotifier extends Notifier<StatisticsState> {
  @override
  StatisticsState build() {
    return const StatisticsState();
  }

  IStatisticsRepository get _repository =>
      ref.read(statisticsRepositoryProvider);

  Future<void> loadAnalytics() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _repository.getAnalytics();
      if (response.success) {
        state = state.copyWith(analytics: response.data, isLoading: false);
      } else {
        state = state.copyWith(error: response.message, isLoading: false);
      }
    } catch (e) {
      LoggerService.error('StatisticsNotifier.loadAnalytics', e);
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> loadUserStatistics() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _repository.getStatistics();
      if (response.success) {
        state = state.copyWith(statistics: response.data, isLoading: false);
      } else {
        state = state.copyWith(error: response.message, isLoading: false);
      }
    } catch (e) {
      LoggerService.error('StatisticsNotifier.loadUserStatistics', e);
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> loadCategoryStats(String categoryId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _repository.getCategoryStatistics(categoryId);
      if (response.success && response.data != null) {
        final currentMap = Map<String, dynamic>.from(state.categoryStats);
        currentMap[categoryId] = response.data;
        state = state.copyWith(
          categoryStats: Map<String, dynamic>.from(currentMap)
              .cast<String, dynamic>()
              .map((k, v) => MapEntry(k, v)),
          // Wait, casting is easier
          isLoading: false,
        );
        // Correct way to update map in immutable state
        final updatedStats = {
          ...state.categoryStats,
          categoryId: response.data!
        };
        state = state.copyWith(categoryStats: updatedStats, isLoading: false);
      } else {
        state = state.copyWith(error: response.message, isLoading: false);
      }
    } catch (e) {
      LoggerService.error('StatisticsNotifier.loadCategoryStats', e);
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> refreshAll() async {
    await Future.wait([
      loadAnalytics(),
      loadUserStatistics(),
    ]);
  }
}
