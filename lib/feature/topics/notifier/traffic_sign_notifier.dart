import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/logger_service.dart';
import '../../../domain/repository/i_topic_repository.dart';
import '../../../product/provider/service_providers.dart';
import '../state/traffic_sign_state.dart';

class TrafficSignNotifier extends Notifier<TrafficSignState> {
  @override
  TrafficSignState build() {
    return const TrafficSignState();
  }

  ITopicRepository get _repository => ref.read(topicRepositoryProvider);

  Future<void> loadSigns({int page = 1}) async {
    if (page == 1) {
      state = state.copyWith(isLoading: true, clearError: true, signs: []);
    } else {
      state = state.copyWith(isLoading: true);
    }
    
    try {
      final response = await _repository.getTrafficSigns(page: page);
      if (response.success && response.data != null) {
        final newData = response.data!;
        state = state.copyWith(
          signs: page == 1 ? newData.signs : [...state.signs, ...newData.signs],
          currentPage: newData.pagination.currentPage,
          lastPage: newData.pagination.lastPage,
          total: newData.pagination.total,
          isLoading: false,
        );
      } else {
        state = state.copyWith(error: response.message, isLoading: false);
      }
    } catch (e) {
      LoggerService.error('TrafficSignNotifier.loadSigns', e);
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> loadNextPage() async {
    if (state.currentPage < state.lastPage && !state.isLoading) {
      await loadSigns(page: state.currentPage + 1);
    }
  }

  Future<void> refresh() async {
    await loadSigns(page: 1);
  }
}
