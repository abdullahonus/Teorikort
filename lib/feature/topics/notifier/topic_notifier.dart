import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/logger_service.dart';
import '../../../domain/repository/i_topic_repository.dart';
import '../../../product/provider/service_providers.dart';
import '../state/topic_state.dart';

class TopicNotifier extends Notifier<TopicState> {
  @override
  TopicState build() {
    return const TopicState();
  }

  ITopicRepository get _repository => ref.read(topicRepositoryProvider);

  Future<void> loadTopics() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _repository.getTopics();
      if (response.success && response.data != null) {
        state = state.copyWith(topics: response.data, isLoading: false);
      } else {
        state = state.copyWith(error: response.message, isLoading: false);
      }
    } catch (e) {
      LoggerService.error('TopicNotifier.loadTopics', e);
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> loadTopicDetail(String topicId) async {
    // If already loaded, we could skip or just reload.
    // Usually for details, we might want to refresh.
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _repository.getTopicById(topicId);
      if (response.success && response.data != null) {
        final updatedDetails = {...state.topicDetails, topicId: response.data!};
        state = state.copyWith(topicDetails: updatedDetails, isLoading: false);
      } else {
        state = state.copyWith(error: response.message, isLoading: false);
      }
    } catch (e) {
      LoggerService.error('TopicNotifier.loadTopicDetail', e);
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> refresh() async {
    await loadTopics();
  }
}
