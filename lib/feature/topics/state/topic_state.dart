import 'package:equatable/equatable.dart';
import '../model/topic.dart';

/// Spec: STATE MODEL PATTERN — Equatable + copyWith
class TopicState extends Equatable {
  final bool isLoading;
  final String? error;
  final List<Topic> topics;
  final Map<String, TopicDetail> topicDetails;

  const TopicState({
    this.isLoading = false,
    this.error,
    this.topics = const [],
    this.topicDetails = const {},
  });

  TopicState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    List<Topic>? topics,
    Map<String, TopicDetail>? topicDetails,
  }) =>
      TopicState(
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
        topics: topics ?? this.topics,
        topicDetails: topicDetails ?? this.topicDetails,
      );

  @override
  List<Object?> get props => [isLoading, error, topics, topicDetails];
}
