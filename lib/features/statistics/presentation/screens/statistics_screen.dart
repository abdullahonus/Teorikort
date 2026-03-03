import 'package:flutter/material.dart';
import 'package:teorikort/core/localization/app_localization.dart';

import '../../data/models/statistics_data.dart';
import '../../data/services/statistics_service.dart';
import 'category_statistics_screen.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  StatisticsScreenState createState() => StatisticsScreenState();
}

class StatisticsScreenState extends State<StatisticsScreen> {
  final StatisticsService _statisticsService = StatisticsService();
  Future<StatisticsData?>? _statisticsDataFuture;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_statisticsDataFuture == null) {
      loadData();
    }
  }

  void loadData() {
    setState(() {
      _statisticsDataFuture = _statisticsService
          .getStatisticsData(context: context)
          .then((r) => r.data);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: () async => loadData(),
        child: FutureBuilder<StatisticsData?>(
          future: _statisticsDataFuture,
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
                          .translate('statistics.error_message'),
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
                        AppLocalization.of(context).translate('common.retry'),
                        style: TextStyle(color: colorScheme.primary),
                      ),
                    ),
                  ],
                ),
              );
            }

            final statistics = snapshot.data;

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
                          .translate('statistics.no_data'),
                      style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalization.of(context)
                          .translate('statistics.take_exams_first'),
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
                // Uygulama geneli analitik banner (Kaldırıldı)
                _buildOverallStats(statistics),
                const SizedBox(height: 24),
                if (statistics.categoryPerformance.isNotEmpty) ...[
                  _buildCategoryPerformance(statistics.categoryPerformance),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOverallStats(StatisticsData stats) {
    final colorScheme = Theme.of(context).colorScheme;
    final title = AppLocalization.of(context)
        .translate('statistics.cards.overall_performance.title');

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
          children: [
            _buildStatItem(
              AppLocalization.of(context).translate(
                  'statistics.cards.overall_performance.total_exams'),
              '${stats.totalExams}',
              Icons.assignment_outlined,
            ),
            const SizedBox(width: 10),
            _buildStatItem(
              AppLocalization.of(context).translate(
                  'statistics.cards.overall_performance.average_score'),
              '%${stats.averageScore.toStringAsFixed(1)}',
              Icons.analytics_outlined,
            ),
            const SizedBox(width: 10),
            _buildStatItem(
              AppLocalization.of(context)
                  .translate('statistics.cards.overall_performance.best_score'),
              '%${stats.highestScore.toStringAsFixed(0)}',
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

  Widget _buildCategoryPerformance(List<CategoryPerformance> categories) {
    final colorScheme = Theme.of(context).colorScheme;
    final title = AppLocalization.of(context)
        .translate('statistics.cards.category_performance.title');

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
        ...categories.map((category) => GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CategoryStatisticsScreen(
                    categoryId: category.categoryId.toString(),
                    categoryTitle: category.categoryName,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildCategoryProgressBar(category),
              ),
            )),
      ],
    );
  }

  Widget _buildCategoryProgressBar(CategoryPerformance category) {
    final colorScheme = Theme.of(context).colorScheme;
    final score = category.averageScore;
    final color = score >= 80
        ? colorScheme.primary
        : score >= 60
            ? colorScheme.secondary
            : colorScheme.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                category.categoryName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '%${score.toStringAsFixed(1)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                Text(
                  '${category.totalExams} sınav',
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: (score / 100).clamp(0.0, 1.0),
            backgroundColor: colorScheme.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
