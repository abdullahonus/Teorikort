import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teorikort/core/localization/app_localization.dart';
import '../provider/statistics_provider.dart';
import '../model/category_statistics.dart' as model;
import 'package:teorikort/core/widgets/app_loading_widget.dart';

class CategoryStatisticsView extends ConsumerStatefulWidget {
  final String categoryId;
  final String categoryTitle;

  const CategoryStatisticsView({
    super.key,
    required this.categoryId,
    required this.categoryTitle,
  });

  @override
  ConsumerState<CategoryStatisticsView> createState() => _CategoryStatisticsViewState();
}

class _CategoryStatisticsViewState extends ConsumerState<CategoryStatisticsView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(statisticsProvider.notifier).loadCategoryStats(widget.categoryId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(statisticsProvider);
    final categoryData = state.categoryStats[widget.categoryId];
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        title: Text(widget.categoryTitle),
      ),
      body: state.isLoading && categoryData == null
          ? const AppLoadingWidget.fullscreen()
          : RefreshIndicator(
              onRefresh: () async => ref.read(statisticsProvider.notifier).loadCategoryStats(widget.categoryId),
              child: categoryData == null
                  ? _buildErrorState(context, state.error ?? 'Veri bulunamadı')
                  : _buildContent(context, categoryData),
            ),
    );
  }

  Widget _buildContent(BuildContext context, model.CategoryStatistics data) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            _statCard(context, Icons.assignment, 'statistics.total_exams', data.totalExams.toString()),
            const SizedBox(width: 12),
            _statCard(context, Icons.analytics, 'statistics.avg_score', '${data.averageScore.toStringAsFixed(1)}%'),
            const SizedBox(width: 12),
            _statCard(context, Icons.emoji_events, 'statistics.best_score', '${data.highestScore.toStringAsFixed(0)}%'),
          ],
        ),
        const SizedBox(height: 24),
        _buildScoreRangeCard(context, data),
        const SizedBox(height: 32),
        if (data.recentExams.isNotEmpty) ...[
          Text(
            AppLocalization.of(context).translate('statistics.recent_exams'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...data.recentExams.map((exam) => _buildRecentExamItem(context, exam)),
        ],
      ],
    );
  }

  Widget _statCard(BuildContext context, IconData icon, String labelKey, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        decoration: BoxDecoration(
          color: colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: colorScheme.primary, size: 24),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue)),
            const SizedBox(height: 4),
            Text(
              AppLocalization.of(context).translate(labelKey),
              style: TextStyle(fontSize: 11, color: colorScheme.onSurface.withValues(alpha: 0.6)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreRangeCard(BuildContext context, model.CategoryStatistics data) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalization.of(context).translate('statistics.score_range'),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _rangeItem(context, 'statistics.lowest', '${data.lowestScore.toStringAsFixed(0)}%', Colors.red),
              _rangeItem(context, 'statistics.average', '${data.averageScore.toStringAsFixed(1)}%', Colors.orange),
              _rangeItem(context, 'statistics.highest', '${data.highestScore.toStringAsFixed(0)}%', Colors.green),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: data.averageScore / 100,
              minHeight: 10,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(data.averageScore >= 70 ? Colors.green : Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rangeItem(BuildContext context, String labelKey, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color)),
        Text(
          AppLocalization.of(context).translate(labelKey),
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildRecentExamItem(BuildContext context, model.RecentExamResult exam) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = exam.point >= 70 ? Colors.green : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.history, color: Colors.grey),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              '${exam.createdAt.day}.${exam.createdAt.month}.${exam.createdAt.year}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '%${exam.point.toStringAsFixed(0)}',
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(error),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.read(statisticsProvider.notifier).loadCategoryStats(widget.categoryId),
            child: const Text('Tekrar Dene'),
          ),
        ],
      ),
    );
  }
}
