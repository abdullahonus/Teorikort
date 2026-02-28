import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teorikort/core/localization/app_localization.dart';
import '../provider/statistics_provider.dart';
import '../model/app_analytics.dart';
import '../model/statistics_data.dart';
import 'category_statistics_view.dart';

class StatisticsView extends ConsumerStatefulWidget {
  const StatisticsView({super.key});

  @override
  ConsumerState<StatisticsView> createState() => _StatisticsViewState();
}

class _StatisticsViewState extends ConsumerState<StatisticsView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(statisticsProvider.notifier).refreshAll());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(statisticsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    if (state.isLoading && state.statistics == null) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: Center(child: CircularProgressIndicator(color: colorScheme.primary)),
      );
    }

    if (state.error != null && state.statistics == null) {
      return _buildErrorState(context, state.error!);
    }

    final statistics = state.statistics;
    if (statistics == null) {
      return _buildEmptyState(context);
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: () => ref.read(statisticsProvider.notifier).refreshAll(),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (state.analytics != null) ...[
              _buildAnalyticsBanner(context, state.analytics!),
              const SizedBox(height: 24),
            ],
            _buildOverallStats(context, statistics),
            const SizedBox(height: 24),
            if (statistics.categoryPerformance.isNotEmpty)
              _buildCategoryPerformance(context, statistics.categoryPerformance),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsBanner(BuildContext context, AppAnalytics data) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary.withValues(alpha: 0.1), colorScheme.secondary.withValues(alpha: 0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_graph, color: colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                AppLocalization.of(context).translate('statistics.platform_stats'),
                style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.primary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildAnalyticsItem(context, '${data.totalUsers}', 'statistics.users', Icons.people),
              _buildAnalyticsItem(context, '${data.totalExams}', 'statistics.exams', Icons.assignment),
              _buildAnalyticsItem(context, '${data.totalCategories}', 'statistics.categories', Icons.category),
              _buildAnalyticsItem(context, '${data.averageScore.toStringAsFixed(1)}%', 'statistics.avg_score', Icons.analytics),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsItem(BuildContext context, String value, String labelKey, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Icon(icon, size: 20, color: colorScheme.primary.withValues(alpha: 0.6)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(
          AppLocalization.of(context).translate(labelKey),
          style: TextStyle(fontSize: 10, color: colorScheme.onSurface.withValues(alpha: 0.5)),
        ),
      ],
    );
  }

  Widget _buildOverallStats(BuildContext context, StatisticsData stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalization.of(context).translate('statistics.overall_performance'),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildStatCard(context, stats.totalExams.toString(), 'statistics.total_exams', Icons.assignment),
            const SizedBox(width: 12),
            _buildStatCard(context, '${stats.averageScore.toStringAsFixed(1)}%', 'statistics.avg_score', Icons.analytics),
            const SizedBox(width: 12),
            _buildStatCard(context, '${stats.highestScore.toStringAsFixed(0)}%', 'statistics.best_score', Icons.emoji_events),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String value, String labelKey, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: colorScheme.primary),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            Text(
              AppLocalization.of(context).translate(labelKey),
              style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withValues(alpha: 0.6)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPerformance(BuildContext context, List<CategoryPerformance> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalization.of(context).translate('statistics.category_performance'),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...categories.map((category) => _CategoryPerformanceRow(category: category)),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 64, color: colorScheme.error),
              const SizedBox(height: 16),
              Text(error, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => ref.read(statisticsProvider.notifier).refreshAll(),
                child: Text(AppLocalization.of(context).translate('common.retry')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(AppLocalization.of(context).translate('statistics.no_data')),
      ),
    );
  }
}

class _CategoryPerformanceRow extends StatelessWidget {
  final CategoryPerformance category;

  const _CategoryPerformanceRow({required this.category});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final score = category.averageScore;
    final color = score >= 80 ? Colors.green : (score >= 60 ? Colors.orange : Colors.red);

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CategoryStatisticsView(
            categoryId: category.categoryId.toString(),
            categoryTitle: category.categoryName,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(category.categoryName, style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
                Text(
                  '%${score.toStringAsFixed(1)}',
                  style: TextStyle(fontWeight: FontWeight.bold, color: color),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: score / 100,
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(color),
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
