import 'package:flutter/material.dart';
import '../../../../core/services/base_api_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/models/api_response.dart';
import '../models/statistics_data.dart';

class StatisticsService extends BaseApiService {
  // GET /statistics
  Future<ApiResponse<StatisticsData>> getStatisticsData({
    BuildContext? context,
  }) async {
    final language = getCurrentLanguage(context);
    return await handleResponse<StatisticsData>(
      get(ApiConstants.statistics, language: language),
      StatisticsData.fromJson,
    );
  }

  // GET /statistics/categories/{id}
  Future<ApiResponse<CategoryStatisticsData>> getCategoryStatistics(
    String categoryId, {
    BuildContext? context,
  }) async {
    final language = getCurrentLanguage(context);
    return await handleResponse<CategoryStatisticsData>(
      get(ApiConstants.categoryStatistics(categoryId), language: language),
      CategoryStatisticsData.fromJson,
    );
  }

  // GET /statistics/analytics
  Future<ApiResponse<AppAnalyticsData>> getAppAnalytics({
    BuildContext? context,
  }) async {
    final language = getCurrentLanguage(context);
    return await handleResponse<AppAnalyticsData>(
      get(ApiConstants.analyticsAppStats, language: language),
      AppAnalyticsData.fromJson,
    );
  }
}
