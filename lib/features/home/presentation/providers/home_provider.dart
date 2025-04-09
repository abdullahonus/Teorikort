import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/logger_service.dart';
import '../../data/models/welcome_message.dart';
import '../../data/repositories/home_repository.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository(Dio());
});

final homeStateProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  final repository = ref.watch(homeRepositoryProvider);
  return HomeNotifier(repository);
});

class HomeState {
  final WelcomeMessage? welcomeMessage;
  final bool isLoading;
  final String? error;

  const HomeState({
    this.welcomeMessage,
    this.isLoading = false,
    this.error,
  });

  HomeState copyWith({
    WelcomeMessage? welcomeMessage,
    bool? isLoading,
    String? error,
  }) {
    return HomeState(
      welcomeMessage: welcomeMessage ?? this.welcomeMessage,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class HomeNotifier extends StateNotifier<HomeState> {
  final HomeRepository _repository;

  HomeNotifier(this._repository) : super(const HomeState());

  Future<void> fetchWelcomeMessage(String token) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _repository.getWelcomeMessage(token);

      if (response.success && response.data != null) {
        state = state.copyWith(
          welcomeMessage: response.data,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          error: response.message,
          isLoading: false,
        );
      }
    } catch (e) {
      LoggerService.error('Welcome Message Provider Error:', e);
      state = state.copyWith(
        error: 'Failed to fetch welcome message',
        isLoading: false,
      );
    }
  }
}
