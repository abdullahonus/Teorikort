import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/services/base_api_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/models/api_response.dart';
import '../models/topic.dart';

class TopicService extends BaseApiService {
  // Get all topics with fallback to mock data
  Future<ApiResponse<List<Topic>>> getTopics({
    BuildContext? context,
  }) async {
    try {
      final language = getCurrentLanguage(context);

      // Try API first
      try {
        final response = await handleListResponse<Topic>(
          get(
            ApiConstants.topics,
            language: language,
          ),
          Topic.fromJson,
        );

        if (response.success && response.data != null) {
          return response;
        }
      } catch (apiError) {
        print(
            'Topics API çağrısı başarısız, mock verilere geçiliyor: $apiError');
      }

      // Fallback to mock data
      return await _loadMockTopics();
    } catch (e) {
      return await _loadMockTopics();
    }
  }

  // Load mock topics from assets
  Future<ApiResponse<List<Topic>>> _loadMockTopics() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/data/topics_data.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      final List<dynamic> topicsData = jsonData['topics'] ?? [];
      final List<Topic> topics =
          topicsData.map((topicJson) => Topic.fromJson(topicJson)).toList();

      return ApiResponse<List<Topic>>(
        success: true,
        statusCode: 100,
        message: 'Mock konular başarıyla yüklendi',
        data: topics,
      );
    } catch (e) {
      return ApiResponse<List<Topic>>(
        success: false,
        statusCode: 500,
        message: 'Mock konular yüklenemedi: $e',
        data: [],
      );
    }
  }

  // Get topic by ID with fallback
  Future<ApiResponse<Topic>> getTopicById(
    String topicId, {
    BuildContext? context,
  }) async {
    try {
      final language = getCurrentLanguage(context);

      // Try API first
      try {
        final response = await handleResponse<Topic>(
          get(
            ApiConstants.topicDetail(topicId),
            language: language,
          ),
          Topic.fromJson,
        );

        if (response.success && response.data != null) {
          return response;
        }
      } catch (apiError) {
        print(
            'Topic detail API çağrısı başarısız, mock verilere geçiliyor: $apiError');
      }

      // Fallback to mock data
      return await _loadMockTopicById(topicId);
    } catch (e) {
      return await _loadMockTopicById(topicId);
    }
  }

  // Load mock topic by ID
  Future<ApiResponse<Topic>> _loadMockTopicById(String topicId) async {
    try {
      final topicsResponse = await _loadMockTopics();
      if (topicsResponse.success && topicsResponse.data != null) {
        final topic = topicsResponse.data!.firstWhere(
          (t) => t.id == topicId,
          orElse: () => throw Exception('Topic not found'),
        );

        return ApiResponse<Topic>(
          success: true,
          statusCode: 100,
          message: 'Mock konu detayı yüklendi',
          data: topic,
        );
      }

      return ApiResponse<Topic>(
        success: false,
        statusCode: 404,
        message: 'Konu bulunamadı',
      );
    } catch (e) {
      return ApiResponse<Topic>(
        success: false,
        statusCode: 500,
        message: 'Mock konu detayı yüklenemedi: $e',
      );
    }
  }

  // Get subtopic by ID with fallback
  Future<ApiResponse<SubTopic>> getSubTopicById(
    String topicId,
    String subTopicId, {
    BuildContext? context,
  }) async {
    try {
      final language = getCurrentLanguage(context);

      // Try API first
      try {
        final response = await handleResponse<SubTopic>(
          get(
            ApiConstants.subtopicDetail(topicId, subTopicId),
            language: language,
          ),
          SubTopic.fromJson,
        );

        if (response.success && response.data != null) {
          return response;
        }
      } catch (apiError) {
        print(
            'SubTopic detail API çağrısı başarısız, mock verilere geçiliyor: $apiError');
      }

      // Fallback to mock data
      return await _loadMockSubTopicById(topicId, subTopicId);
    } catch (e) {
      return await _loadMockSubTopicById(topicId, subTopicId);
    }
  }

  // Load mock subtopic by ID
  Future<ApiResponse<SubTopic>> _loadMockSubTopicById(
      String topicId, String subTopicId) async {
    try {
      final topicResponse = await _loadMockTopicById(topicId);
      if (topicResponse.success && topicResponse.data != null) {
        final subTopic = topicResponse.data!.subTopics.firstWhere(
          (st) => st.id == subTopicId,
          orElse: () => throw Exception('SubTopic not found'),
        );

        return ApiResponse<SubTopic>(
          success: true,
          statusCode: 100,
          message: 'Mock alt konu detayı yüklendi',
          data: subTopic,
        );
      }

      return ApiResponse<SubTopic>(
        success: false,
        statusCode: 404,
        message: 'Alt konu bulunamadı',
      );
    } catch (e) {
      return ApiResponse<SubTopic>(
        success: false,
        statusCode: 500,
        message: 'Mock alt konu detayı yüklenemedi: $e',
      );
    }
  }
}
