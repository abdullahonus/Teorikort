import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/profile/data/models/about_model.dart';
import '../../../features/profile/data/services/about_service.dart';
import '../../../product/provider/service_providers.dart';

final aboutProvider = StateNotifierProvider<AboutNotifier, AsyncValue<AboutModel>>((ref) {
  return AboutNotifier(ref.watch(aboutServiceProvider));
});

class AboutNotifier extends StateNotifier<AsyncValue<AboutModel>> {
  final AboutService _service;

  AboutNotifier(this._service) : super(const AsyncValue.loading()) {
    fetchAbout();
  }

  Future<void> fetchAbout() async {
    state = const AsyncValue.loading();
    try {
      final response = await _service.getAbout();
      if (response.success && response.data != null) {
        state = AsyncValue.data(response.data!);
      } else {
        state = AsyncValue.error(response.message ?? 'Hata oluştu', StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
