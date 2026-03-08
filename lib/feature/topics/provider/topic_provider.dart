import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../product/provider/service_providers.dart';
import '../model/traffic_sign.dart';
import '../notifier/topic_notifier.dart';
import '../notifier/traffic_sign_notifier.dart';
import '../state/topic_state.dart';
import '../state/traffic_sign_state.dart';

/// Provider for topic list and details.
final topicProvider = NotifierProvider<TopicNotifier, TopicState>(
  () => TopicNotifier(),
);

/// Provider for traffic signs.
final trafficSignProvider =
    NotifierProvider<TrafficSignNotifier, TrafficSignState>(
  () => TrafficSignNotifier(),
);

/// Computed provider for specific topic details.
final topicDetailProvider = Provider.family((ref, String topicId) {
  return ref.watch(topicProvider).topicDetails[topicId];
});

/// Provider for specific traffic sign detail.
final trafficSignDetailProvider =
    FutureProvider.family<TrafficSign, String>((ref, id) async {
  final repository = ref.watch(topicRepositoryProvider);
  final response = await repository.getTrafficSignById(id);
  if (response.success && response.data != null) {
    return response.data!;
  }
  throw Exception(response.message ?? 'Hata oluştu');
});
