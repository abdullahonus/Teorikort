import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/services/user_service.dart';
import '../../../domain/repository/i_home_repository.dart';
import '../../../product/provider/service_providers.dart';
import '../state/home_state.dart';

/// Spec NOTIFIER PATTERN: extends Notifier<HomeState>
/// Repo inject: ref.read(homeRepositoryProvider)
class HomeNotifier extends Notifier<HomeState> {
  @override
  HomeState build() {
    // Widget tree hazır olduğunda fetch et
    Future.microtask(fetchHomeData);
    return const HomeState(isLoading: true);
  }

  IHomeRepository get _repo => ref.read(homeRepositoryProvider);
  UserService get _userService => ref.read(userServiceProvider);

  Future<void> fetchHomeData() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final homeResponse = await _repo.getHomeData();
      final dailyTip = await _repo.getDailyTip();

      if (homeResponse.success) {
        LoggerService.info('HomeNotifier: home data loaded');
        state = state.copyWith(
          isLoading: false,
          homeData: homeResponse.data,
          dailyTip: dailyTip,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: homeResponse.message ?? 'Ana sayfa verisi yüklenemedi',
        );
      }
    } catch (e) {
      LoggerService.error('HomeNotifier.fetchHomeData', e);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() => fetchHomeData();

  String get currentUserFirstName => _userService.currentUserFirstName;
}
