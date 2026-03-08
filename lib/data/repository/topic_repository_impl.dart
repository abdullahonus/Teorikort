import '../../../core/models/api_response.dart';
import '../../../core/services/logger_service.dart';
import '../../../domain/repository/i_topic_repository.dart';
import '../../../feature/exam/model/exam_question.dart';
import '../../../feature/topics/model/topic.dart' as topic_model;
import '../../../feature/topics/model/traffic_sign.dart' as sign_model;
import '../../../features/topics/data/services/topic_service.dart';
import '../../../features/topics/data/services/traffic_sign_service.dart';

class TopicRepositoryImpl implements ITopicRepository {
  final TopicService _topicService;
  final TrafficSignService _trafficSignService;

  TopicRepositoryImpl({
    required TopicService topicService,
    required TrafficSignService trafficSignService,
  })  : _topicService = topicService,
        _trafficSignService = trafficSignService;

  @override
  Future<ApiResponse<List<topic_model.Topic>>> getTopics() async {
    try {
      final response = await _topicService.getTopics();
      if (response.success && response.data != null) {
        final topics = response.data!
            .map((t) => topic_model.Topic(
                  id: t.id,
                  title: t.title,
                  description: t.description,
                  content: t.content,
                  createdAt: t.createdAt,
                  updatedAt: t.updatedAt,
                ))
            .toList();
        return ApiResponse.success(topics);
      }
      return ApiResponse.error(response.message);
    } catch (e) {
      LoggerService.error('TopicRepositoryImpl.getTopics', e);
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<topic_model.TopicDetail>> getTopicById(
      String topicId) async {
    try {
      final response = await _topicService.getTopicById(topicId);
      if (response.success && response.data != null) {
        final legacyDetail = response.data!;
        return ApiResponse.success(topic_model.TopicDetail(
          topic: topic_model.Topic(
            id: legacyDetail.course.id,
            title: legacyDetail.course.title,
            description: legacyDetail.course.description,
            content: legacyDetail.course.content,
            createdAt: legacyDetail.course.createdAt,
            updatedAt: legacyDetail.course.updatedAt,
          ),
          questions: legacyDetail.questions
              .map((q) => ExamQuestion.fromJson(q as Map<String, dynamic>))
              .toList(),
        ));
      }
      return ApiResponse.error(response.message);
    } catch (e) {
      LoggerService.error('TopicRepositoryImpl.getTopicById', e);
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<sign_model.TrafficSignResponse>> getTrafficSigns(
      {int page = 1}) async {
    try {
      final response = await _trafficSignService.getSigns(page: page);
      if (response.success && response.data != null) {
        final legacyRes = response.data!;
        return ApiResponse.success(sign_model.TrafficSignResponse(
          signs: legacyRes.signs
              .map((s) => sign_model.TrafficSign(
                    id: s.id,
                    title: s.title,
                    slug: s.slug,
                    description: s.description,
                    imageUrl: s.imageUrl,
                  ))
              .toList(),
          pagination: sign_model.PaginationData(
            currentPage: legacyRes.pagination.currentPage,
            lastPage: legacyRes.pagination.lastPage,
            total: legacyRes.pagination.total,
          ),
        ));
      }
      return ApiResponse.error(response.message);
    } catch (e) {
      LoggerService.error('TopicRepositoryImpl.getTrafficSigns', e);
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<sign_model.TrafficSign>> getTrafficSignById(
      String id) async {
    try {
      final response = await _trafficSignService.getSignById(id);
      if (response.success && response.data != null) {
        final s = response.data!;
        return ApiResponse.success(sign_model.TrafficSign(
          id: s.id,
          title: s.title,
          slug: s.slug,
          description: s.description,
          imageUrl: s.imageUrl,
        ));
      }
      return ApiResponse.error(response.message);
    } catch (e) {
      LoggerService.error('TopicRepositoryImpl.getTrafficSignById', e);
      return ApiResponse.error(e.toString());
    }
  }
}
