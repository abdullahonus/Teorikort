import 'package:driving_license_exam/core/services/strings_service.dart';
import 'package:flutter/material.dart';
import '../../data/models/statistics_data.dart';
import '../../data/services/statistics_service.dart';
import 'package:driving_license_exam/core/localization/app_localization.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  StatisticsScreenState createState() => StatisticsScreenState();
}

class StatisticsScreenState extends State<StatisticsScreen> {
  final StatisticsService _statisticsService = StatisticsService();
  late Future<StatisticsData?> _statisticsDataFuture;
  late Future<Map<String, dynamic>> _stringsDataFuture;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() {
    setState(() {
      _statisticsDataFuture = _statisticsService
          .getStatisticsData()
          .then((response) => response.data);
      _stringsDataFuture = StringsService.getStatisticsStrings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: () async {
          loadData();
        },
        child: FutureBuilder<List<dynamic>>(
          future: Future.wait([_statisticsDataFuture, _stringsDataFuture]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: colorScheme.primary),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: colorScheme.error.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalization.of(context)
                              .translate('statistics.error_message') ??
                          'Unable to load statistics',
                      style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: loadData,
                      icon: Icon(Icons.refresh, color: colorScheme.primary),
                      label: Text(
                        AppLocalization.of(context).translate('common.retry') ??
                            'Retry',
                        style: TextStyle(color: colorScheme.primary),
                      ),
                    ),
                  ],
                ),
              );
            }

            final statistics = snapshot.data![0] as StatisticsData?;
            final strings = snapshot.data![1] as Map<String, dynamic>;

            if (statistics == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.analytics_outlined,
                      size: 64,
                      color: colorScheme.onSurface.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalization.of(context)
                              .translate('statistics.no_data') ??
                          'No statistics available',
                      style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalization.of(context)
                              .translate('statistics.take_exams_first') ??
                          'Take some exams to see your statistics',
                      style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.5),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              children: [
                _buildOverallStats(
                  statistics.overallStats,
                  AppLocalization.of(context)
                      .translate('statistics.cards.overall_performance.title'),
                  categories: statistics.categoryPerformance,
                ),
                const SizedBox(height: 24),
                _buildCategoryPerformance(
                  statistics.categoryPerformance,
                  AppLocalization.of(context)
                      .translate('statistics.cards.category_performance.title'),
                ),
                if (statistics.recentExams.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildRecentExams(
                    statistics.recentExams,
                    AppLocalization.of(context)
                        .translate('statistics.cards.recent_exams.title'),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOverallStats(
    OverallStats stats,
    String title, {
    List<CategoryPerformance>? categories,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          spacing: 10,
          children: [
            _buildStatItem(
              AppLocalization.of(context).translate(
                  'statistics.cards.overall_performance.total_exams'),
              '${categories?.length ?? 0}/${stats.totalAvailableExams}',
              Icons.assignment_outlined,
            ),
            _buildStatItem(
              AppLocalization.of(context).translate(
                  'statistics.cards.overall_performance.average_score'),
              '%${stats.averageScore}',
              Icons.analytics_outlined,
            ),
            _buildStatItem(
              AppLocalization.of(context)
                  .translate('statistics.cards.overall_performance.best_score'),
              '%${stats.bestScore}',
              Icons.emoji_events_outlined,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: colorScheme.primary, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPerformance(
    List<CategoryPerformance> categories,
    String title,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        ...categories.map((category) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildCategoryProgressBar(category),
            )),
      ],
    );
  }

  Widget _buildCategoryProgressBar(CategoryPerformance category) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = category.averageScore >= 80
        ? colorScheme.primary
        : category.averageScore >= 60
            ? colorScheme.secondary
            : colorScheme.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              category.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              '%${category.averageScore}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: colorScheme.surface,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: category.averageScore / 100,
              backgroundColor: colorScheme.surface,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentExams(List<RecentExam> exams, String title) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        ...exams.map((exam) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exam.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${exam.correctAnswers} ${AppLocalization.of(context).translate('statistics.cards.recent_exams.correct_answers')}',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: colorScheme.outline.withOpacity(0.2)),
                    ),
                    child: Text(
                      '%${exam.score}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}
