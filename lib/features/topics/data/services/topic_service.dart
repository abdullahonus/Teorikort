import 'package:flutter/material.dart';
import '../../../../core/services/base_api_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/models/api_response.dart';
import '../models/topic.dart';

class TopicService extends BaseApiService {
  // GET /topics
  Future<ApiResponse<List<Topic>>> getTopics({
    BuildContext? context,
  }) async {
    final language = getCurrentLanguage(context);
    return await handleListResponse<Topic>(
      get(ApiConstants.topics, language: language),
      Topic.fromJson,
    );
  }

  // GET /topics/{id}
  Future<ApiResponse<TopicDetail>> getTopicById(
    String topicId, {
    BuildContext? context,
  }) async {
    final language = getCurrentLanguage(context);
    return await handleResponse<TopicDetail>(
      get(ApiConstants.topicDetail(topicId), language: language),
      TopicDetail.fromJson,
    );
  }
}
