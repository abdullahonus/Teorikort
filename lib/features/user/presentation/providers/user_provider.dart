import 'package:dio/dio.dart';
import 'package:driving_license_exam/core/services/logger_service.dart';
import 'package:driving_license_exam/features/user/data/repositories/user_repository.dart';
import 'package:driving_license_exam/features/user/domain/models/user_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:driving_license_exam/core/services/user_service.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(Dio());
});

final userStateProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return UserNotifier(repository);
});

class UserState {
  final UserProfile? profile;
  final bool isLoading;
  final String? error;

  const UserState({
    this.profile,
    this.isLoading = false,
    this.error,
  });

  UserState copyWith({
    UserProfile? profile,
    bool? isLoading,
    String? error,
  }) {
    return UserState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class UserNotifier extends StateNotifier<UserState> {
  final UserRepository _repository;

  UserNotifier(this._repository) : super(const UserState());

  Future<void> getUserProfile(String token) async {
    try {
      LoggerService.debug(
          'Fetching user profile...', 'Token: ${token.substring(0, 10)}...');

      state = state.copyWith(isLoading: true, error: null);
      final response = await _repository.getUserProfile(token);

      if (response.success && response.data != null) {
        LoggerService.info(
          'User profile fetched successfully',
          'Name: ${response.data!.fullName}, Email: ${response.data!.email}',
        );

        await UserService().updateUserFromApi(response.data!);

        state = state.copyWith(
          profile: response.data,
          isLoading: false,
        );
      } else {
        LoggerService.error(
          'Failed to fetch user profile',
          'Error: ${response.message}',
        );

        state = state.copyWith(
          error: response.message,
          isLoading: false,
        );
      }
    } catch (e, stackTrace) {
      LoggerService.error(
        'User Profile Provider Error',
        e,
        stackTrace,
      );

      state = state.copyWith(
        error: 'Failed to fetch user profile',
        isLoading: false,
      );
    }
  }
}
