import 'package:flutter_riverpod/flutter_riverpod.dart';
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
