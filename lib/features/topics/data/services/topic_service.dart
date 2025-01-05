import 'package:driving_license_exam/core/services/json_service.dart';
import '../models/topic.dart';

class TopicService {
  Future<List<Topic>> getTopics() async {
    final json = await JsonService.loadJson('topics_data.json');
    return (json['topics'] as List)
        .map((topic) => Topic.fromJson(topic))
        .toList();
  }

  Future<Topic> getTopicById(String id) async {
    final topics = await getTopics();
    return topics.firstWhere((topic) => topic.id == id);
  }

  Future<SubTopic> getSubTopicById(String topicId, String subTopicId) async {
    final topic = await getTopicById(topicId);
    return topic.subTopics.firstWhere((subTopic) => subTopic.id == subTopicId);
  }
}
