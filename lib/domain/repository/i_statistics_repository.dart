import 'package:teorikort/core/models/api_response.dart';
import 'package:teorikort/feature/statistics/model/app_analytics.dart';
import 'package:teorikort/feature/statistics/model/statistics_data.dart';
import 'package:teorikort/feature/statistics/model/category_statistics.dart';

abstract class IStatisticsRepository {
  /// Fetches global app analytics.
  Future<ApiResponse<AppAnalytics>> getAppAnalytics();

  /// Fetches user-specific statistics.
  Future<ApiResponse<StatisticsData>> getStatistics();

  /// Fetches detailed statistics for a specific category.
  Future<ApiResponse<CategoryStatistics>> getCategoryStatistics(String categoryId);
}
