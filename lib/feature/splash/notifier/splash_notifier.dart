import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teorikort/core/providers/locale_provider.dart';
import 'package:teorikort/domain/repository/version_repository.dart';

import 'splash_state.dart';

class SplashNotifier extends StateNotifier<SplashState> {
  final IVersionRepository _repository;
  final Ref _ref;

  SplashNotifier(this._repository, this._ref) : super(const SplashState());

  Future<void> initialize() async {
    state = state.copyWith(status: SplashStatus.loading);

    try {
      final response = await _repository.getAppVersion();

      if (response.success && response.data != null) {
        final data = response.data!;

        // 1. Splash'tan gelen dil listesini uygula
        if (data.languages != null && data.languages!.isNotEmpty) {
          await _ref.read(localeProvider.notifier).initFromSplash(
                languages: data.languages!,
                selectedLanguage: data.selectedLanguage,
              );
        }

        // 2. Check Maintenance
        if (data.maintenance?.status == true) {
          state = state.copyWith(
            status: SplashStatus.maintenance,
            data: data,
          );
          return;
        }

        // 3. Check Force Update
        if (data.version?.forceUpdate == true) {
          state = state.copyWith(
            status: SplashStatus.forceUpdate,
            data: data,
          );
          return;
        }

        // Configuration success
        state = state.copyWith(
          status: SplashStatus.completed,
          data: data,
        );
      } else {
        state = state.copyWith(
          status: SplashStatus.error,
          errorMessage: response.message ?? 'Config load failed',
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: SplashStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
}
