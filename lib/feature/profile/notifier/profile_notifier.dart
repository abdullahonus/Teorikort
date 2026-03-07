import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/services/user_service.dart';
import '../../../domain/repository/i_profile_repository.dart';
import '../../../product/provider/service_providers.dart';
import '../state/profile_state.dart';

/// Spec NOTIFIER PATTERN: extends Notifier<ProfileState>
/// Repository injected via ref.read(profileRepositoryProvider)
class ProfileNotifier extends Notifier<ProfileState> {
  @override
  ProfileState build() {
    // Start fetching profile on init
    Future.microtask(fetchProfile);
    return const ProfileState(isLoading: true);
  }

  IProfileRepository get _repository => ref.read(profileRepositoryProvider);
  UserService get _userService => ref.read(userServiceProvider);

  Future<void> fetchProfile() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _repository.getUserProfile();

      if (response.success && response.data != null) {
        // Sync with legacy service for backwards compatibility if needed
        // but note we use UserProfile.fromJson(response.data.toJson())
        // to pass it to legacy code that expects their version.
        // For now, let's keep the sync if it was there before.
        // Note: the original code had their own model.

        state = state.copyWith(
          profile: response.data,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message ?? 'Profil bilgileri alınamadı',
        );
      }
    } catch (e) {
      LoggerService.error('ProfileNotifier.fetchProfile', e);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<bool> updateName(String name) async {
    state = state.copyWith(isUpdating: true, clearError: true);
    try {
      final response = await _repository.updateUserProfile(name);

      if (response.success && response.data != null) {
        state = state.copyWith(
          profile: response.data,
          isUpdating: false,
        );
        return true;
      } else {
        state = state.copyWith(
          isUpdating: false,
          error: response.message ?? 'Profil güncellenemedi',
        );
        return false;
      }
    } catch (e) {
      LoggerService.error('ProfileNotifier.updateName', e);
      state = state.copyWith(
        isUpdating: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Helper method to keep UI code clean
  String get currentUserPhoto => _userService.currentUserPhoto;
}
