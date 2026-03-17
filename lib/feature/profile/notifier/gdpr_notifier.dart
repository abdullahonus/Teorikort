import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/profile/data/models/gdpr_model.dart';
import '../../../features/profile/data/services/gdpr_service.dart';
import '../../../product/provider/service_providers.dart';

final gdprProvider = StateNotifierProvider<GDPRNotifier, AsyncValue<GDPRModel>>((ref) {
  return GDPRNotifier(ref.watch(gdprServiceProvider));
});

class GDPRNotifier extends StateNotifier<AsyncValue<GDPRModel>> {
  final GDPRService _service;

  GDPRNotifier(this._service) : super(const AsyncValue.loading()) {
    fetchGDPR();
  }

  Future<void> fetchGDPR() async {
    state = const AsyncValue.loading();
    try {
      final response = await _service.getGDPR();
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
