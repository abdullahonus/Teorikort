import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/profile/data/models/policy_model.dart';
import '../../../features/profile/data/services/policy_service.dart';
import '../../../product/provider/service_providers.dart';

final policyProvider = StateNotifierProvider<PolicyNotifier, AsyncValue<PolicyModel>>((ref) {
  return PolicyNotifier(ref.watch(policyServiceProvider));
});

class PolicyNotifier extends StateNotifier<AsyncValue<PolicyModel>> {
  final PolicyService _service;

  PolicyNotifier(this._service) : super(const AsyncValue.loading()) {
    fetchPolicy();
  }

  Future<void> fetchPolicy() async {
    state = const AsyncValue.loading();
    try {
      final response = await _service.getPolicy();
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
