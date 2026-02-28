import 'package:teorikort/core/models/api_response.dart';
import 'package:teorikort/feature/topics/model/topic.dart';
import 'package:teorikort/feature/topics/model/traffic_sign.dart';

abstract class ITopicRepository {
  /// Fetches all general topics.
  Future<ApiResponse<List<Topic>>> getTopics();

  /// Fetches details for a specific topic by its version.
  Future<ApiResponse<TopicDetail>> getTopicById(String topicId);

  /// Fetches paginated traffic signs.
  Future<ApiResponse<TrafficSignResponse>> getTrafficSigns({int page = 1});

  /// Fetches specific traffic sign details.
  Future<ApiResponse<TrafficSign>> getTrafficSignById(String id);
}
