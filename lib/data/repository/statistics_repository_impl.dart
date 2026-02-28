import 'package:teorikort/core/models/api_response.dart';
import 'package:teorikort/core/services/logger_service.dart';
import 'package:teorikort/domain/repository/i_statistics_repository.dart';
import 'package:teorikort/feature/statistics/model/app_analytics.dart' as model;
import 'package:teorikort/feature/statistics/model/statistics_data.dart' as model;
import 'package:teorikort/feature/statistics/model/category_statistics.dart' as model;
import 'package:teorikort/features/statistics/data/services/statistics_service.dart';

class StatisticsRepositoryImpl implements IStatisticsRepository {
  final StatisticsService _service;

  StatisticsRepositoryImpl(this._service);

  @override
  Future<ApiResponse<model.AppAnalytics>> getAppAnalytics() async {
    try {
      final response = await _service.getAppAnalytics();
      if (response.success && response.data != null) {
        final legacy = response.data!;
        return ApiResponse.success(model.AppAnalytics(
          totalUsers: legacy.totalUsers,
          totalExams: legacy.totalExams,
          totalCategories: legacy.totalCategories,
          averageScore: legacy.averageScore,
        ));
      }
      return ApiResponse.error(response.message);
    } catch (e) {
      LoggerService.error('StatisticsRepositoryImpl.getAppAnalytics', e);
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<model.StatisticsData>> getStatistics() async {
    try {
      final response = await _service.getStatisticsData();
      if (response.success && response.data != null) {
        final legacy = response.data!;
        return ApiResponse.success(model.StatisticsData(
          totalExams: legacy.totalExams,
          averageScore: legacy.averageScore,
          highestScore: legacy.highestScore,
          categoryPerformance: legacy.categoryPerformance.map((c) => model.CategoryPerformance(
            categoryId: c.categoryId,
            categoryName: c.categoryName,
            averageScore: c.averageScore,
            totalExams: c.totalExams,
          )).toList(),
        ));
      }
      return ApiResponse.error(response.message);
    } catch (e) {
      LoggerService.error('StatisticsRepositoryImpl.getStatistics', e);
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<model.CategoryStatistics>> getCategoryStatistics(String categoryId) async {
    try {
      final response = await _service.getCategoryStatistics(categoryId);
      if (response.success && response.data != null) {
        final legacy = response.data!;
        return ApiResponse.success(model.CategoryStatistics(
          categoryId: legacy.categoryId,
          categoryTitle: legacy.categoryTitle,
          totalExams: legacy.totalExams,
          averageScore: legacy.averageScore,
          highestScore: legacy.highestScore,
          lowestScore: legacy.lowestScore,
          recentExams: legacy.recentExams.map((e) => model.RecentExamResult(
            id: e.id,
            point: e.point,
            createdAt: e.createdAt,
          )).toList(),
        ));
      }
      return ApiResponse.error(response.message);
    } catch (e) {
      LoggerService.error('StatisticsRepositoryImpl.getCategoryStatistics', e);
      return ApiResponse.error(e.toString());
    }
  }
}
