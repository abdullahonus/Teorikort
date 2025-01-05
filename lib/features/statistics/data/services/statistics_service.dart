import 'package:driving_license_exam/core/services/json_service.dart';
import 'package:driving_license_exam/features/exam/data/services/exam_result_service.dart';
import 'package:driving_license_exam/features/exam/data/models/exam_result.dart';
import '../models/statistics_data.dart';
import 'dart:convert';

class StatisticsService {
  final ExamResultService _examResultService = ExamResultService();

  Future<int> getTotalExamsCount() async {
    try {
      final Map<String, dynamic> data =
          await JsonService.loadJson('exams_data.json');
      final List<dynamic> categories = data['categories'];

      int totalExams = 0;
      for (var category in categories) {
        final List<dynamic> exams = category['exams'];
        totalExams += exams.length;
      }

      return totalExams;
    } catch (e) {
      print('Error getting total exams count: $e');
      return 0;
    }
  }

  Future<StatisticsData> getStatisticsData() async {
    try {
      // Get all exam results
      final examResults = await _examResultService.getExamResults();
      final totalAvailableExams = await getTotalExamsCount();

      if (examResults.isEmpty) {
        // Varsayılan kategorileri oluştur
        final defaultCategories = [
          'traffic_signs',
          'traffic_rules',
          'first_aid',
          'vehicle_tech'
        ];

        final defaultCategoryPerformance = defaultCategories.map((categoryId) {
          return CategoryPerformance(
            categoryId: categoryId,
            name: _getCategoryName(categoryId),
            examsTaken: 0,
            averageScore: 0,
            bestScore: 0,
            progress: 0,
            weakAreas: [],
            strongAreas: [],
          );
        }).toList();

        return StatisticsData(
          overallStats: OverallStats(
            totalExamsTaken: 0,
            totalAvailableExams: totalAvailableExams,
            averageScore: 0,
            bestScore: 0,
            totalStudyTime: 0,
            totalQuestionsAnswered: 0,
            correctAnswersRate: 0,
          ),
          categoryPerformance: defaultCategoryPerformance,
          recentExams: [],
        );
      }

      // Calculate overall stats
      final totalExams = examResults.length;
      final totalQuestions = examResults.fold<int>(
          0, (sum, result) => sum + result.totalQuestions);
      final totalCorrect = examResults.fold<int>(
          0, (sum, result) => sum + result.correctAnswers);
      final totalTime = examResults.fold<Duration>(
          Duration.zero, (sum, result) => sum + result.duration);

      final averageScore = (examResults.fold<double>(
                  0, (sum, result) => sum + result.scorePercentage) /
              totalExams)
          .round();

      final bestScore = examResults
          .map((result) => result.scorePercentage.round())
          .reduce((max, score) => score > max ? score : max);

      // Group results by category
      final resultsByCategory = <String, List<ExamResult>>{};
      for (final result in examResults) {
        resultsByCategory.putIfAbsent(result.category, () => []).add(result);
      }

      // Calculate category performance
      final categoryPerformance = resultsByCategory.entries.map((entry) {
        final categoryResults = entry.value;
        final categoryAverage = (categoryResults.fold<double>(
                    0, (sum, result) => sum + result.scorePercentage) /
                categoryResults.length)
            .round();
        final categoryBest = categoryResults
            .map((result) => result.scorePercentage.round())
            .reduce((max, score) => score > max ? score : max);

        return CategoryPerformance(
          categoryId: entry.key,
          name: _getCategoryName(entry.key),
          examsTaken: categoryResults.length,
          averageScore: categoryAverage,
          bestScore: categoryBest,
          progress: categoryAverage,
          weakAreas: [],
          strongAreas: [],
        );
      }).toList();

      // Get recent exams (last 5)
      final recentExams = examResults.reversed.take(5).map((result) {
        return RecentExam(
          id: result.completedAt.millisecondsSinceEpoch.toString(),
          title: _getCategoryName(result.category),
          category: result.category,
          completedAt: result.completedAt.toIso8601String(),
          score: result.scorePercentage.round(),
          durationMinutes: result.duration.inMinutes,
          correctAnswers: result.correctAnswers,
          totalQuestions: result.totalQuestions,
          improvement: '',
        );
      }).toList();

      return StatisticsData(
        overallStats: OverallStats(
          totalExamsTaken: totalExams,
          totalAvailableExams: totalAvailableExams,
          averageScore: averageScore,
          bestScore: bestScore,
          totalStudyTime: totalTime.inMinutes,
          totalQuestionsAnswered: totalQuestions,
          correctAnswersRate: totalQuestions > 0
              ? ((totalCorrect / totalQuestions) * 100).round()
              : 0,
        ),
        categoryPerformance: categoryPerformance,
        recentExams: recentExams,
      );
    } catch (e) {
      print('Error calculating statistics: $e');
      rethrow;
    }
  }

  String _getCategoryName(String categoryId) {
    switch (categoryId) {
      case 'traffic_signs':
        return 'Trafik İşaretleri';
      case 'traffic_rules':
        return 'Trafik Kuralları';
      case 'first_aid':
        return 'İlk Yardım';
      case 'vehicle_tech':
        return 'Araç Tekniği';
      default:
        return categoryId;
    }
  }
}
