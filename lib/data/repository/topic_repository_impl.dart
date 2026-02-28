import '../../../core/models/api_response.dart';
import '../../../core/services/logger_service.dart';
import '../../../domain/repository/i_topic_repository.dart';
import '../../../feature/topics/model/topic.dart' as model;
import '../../../feature/topics/model/traffic_sign.dart' as model;
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
  Future<ApiResponse<List<model.Topic>>> getTopics() async {
    try {
      final response = await _topicService.getTopics();
      if (response.success && response.data != null) {
        final topics = response.data!
            .map((t) => model.Topic(
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
  Future<ApiResponse<model.TopicDetail>> getTopicById(String topicId) async {
    try {
      final response = await _topicService.getTopicById(topicId);
      if (response.success && response.data != null) {
        final legacyDetail = response.data!;
        return ApiResponse.success(model.TopicDetail(
          topic: model.Topic(
            id: legacyDetail.course.id,
            title: legacyDetail.course.title,
            description: legacyDetail.course.description,
            content: legacyDetail.course.content,
            createdAt: legacyDetail.course.createdAt,
            updatedAt: legacyDetail.course.updatedAt,
          ),
          questions: legacyDetail.questions,
        ));
      }
      return ApiResponse.error(response.message);
    } catch (e) {
      LoggerService.error('TopicRepositoryImpl.getTopicById', e);
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<model.TrafficSignResponse>> getTrafficSigns({int page = 1}) async {
    try {
      final response = await _trafficSignService.getSigns(page: page);
      if (response.success && response.data != null) {
        final legacyRes = response.data!;
        return ApiResponse.success(model.TrafficSignResponse(
          signs: legacyRes.signs
              .map((s) => model.TrafficSign(
                    id: s.id,
                    title: s.title,
                    slug: s.slug,
                    description: s.description,
                    imageUrl: s.imageUrl,
                  ))
              .toList(),
          pagination: model.PaginationData(
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
  Future<ApiResponse<model.TrafficSign>> getTrafficSignById(String id) async {
    try {
      final response = await _trafficSignService.getSignById(id);
      if (response.success && response.data != null) {
        final s = response.data!;
        return ApiResponse.success(model.TrafficSign(
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
