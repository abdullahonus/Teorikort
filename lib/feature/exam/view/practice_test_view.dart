import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teorikort/core/localization/app_localization.dart';
import 'package:teorikort/core/widgets/app_bar_widget.dart';
import 'package:teorikort/core/widgets/app_loading_widget.dart';
import 'package:teorikort/core/widgets/custom_elevated_button.dart';

import '../model/exam_category.dart';
import '../provider/practice_provider.dart';
import 'exam_session_view.dart';
import '../../statistics/provider/statistics_provider.dart';

class PracticeTestView extends ConsumerStatefulWidget {
  final ExamCategory subCategory;

  const PracticeTestView({
    super.key,
    required this.subCategory,
  });

  @override
  ConsumerState<PracticeTestView> createState() => _PracticeTestViewState();
}

class _PracticeTestViewState extends ConsumerState<PracticeTestView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(statisticsProvider.notifier).loadUserStatistics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final testsAsync =
        ref.watch(practiceTestsProvider(widget.subCategory.id.toString()));
    final stats = ref.watch(userStatisticsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppHeader(
        title: widget.subCategory.title,
      ),
      body: testsAsync.when(
        loading: () => const AppLoadingWidget.fullscreen(),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              err.toString(),
              style: TextStyle(color: colorScheme.error),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (tests) {
          if (tests.isEmpty) {
            return Center(
              child: Text(
                  AppLocalization.of(context).translate('exam_list.no_data')),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.read(statisticsProvider.notifier).loadUserStatistics();
              return ref.refresh(
                  practiceTestsProvider(widget.subCategory.id.toString())
                      .future);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: CustomElevatedButton(
                        onPressed: () {
                          final randomOptions = tests.toList();
                          randomOptions.shuffle();
                          final randomTest = randomOptions.first;
                          _confirmAndStart(context, randomTest);
                        },
                        text: AppLocalization.of(context)
                            .translate('exam.start_new_test'),
                        icon: Icons.play_arrow_rounded,
                        borderRadius: 16.0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (stats != null && stats.categoryPerformance.isNotEmpty)
                      _buildStatisticsSection(
                          context, stats, tests, colorScheme),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatisticsSection(BuildContext context, dynamic stats,
      List<ExamCategory> tests, ColorScheme colorScheme) {
    // Filter the overall statistics to only include performance of the tests in this subCategory
    final testIds = tests.map((t) => t.id).toSet();
    final relevantStats = stats.categoryPerformance
        .where((perf) => testIds.contains(perf.categoryId))
        .toList();

    if (relevantStats.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalization.of(context)
              .translate('statistics.category_performance'),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...relevantStats.map((perf) {
          final score = perf.averageScore;
          final color = score >= 80
              ? Colors.green
              : (score >= 60 ? Colors.orange : Colors.red);
          final testInfo = tests
              .cast<ExamCategory?>()
              .firstWhere((t) => t?.id == perf.categoryId, orElse: () => null);

          final displayTitle = (testInfo?.title.isNotEmpty == true)
              ? testInfo!.title
              : perf.categoryName;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        displayTitle,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '%${score.toStringAsFixed(1)}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: color,
                          fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: score / 100,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation(color),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${perf.totalExams} ${AppLocalization.of(context).translate('statistics.exams').toLowerCase()}',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Future<void> _confirmAndStart(BuildContext context, ExamCategory test) async {
    final colorScheme = Theme.of(context).colorScheme;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            AppLocalization.of(context).translate('mock_exam.confirm_start')),
        content: Text(AppLocalization.of(context)
            .translate('mock_exam.confirm_description')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
                AppLocalization.of(context).translate('mock_exam.confirm_no')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
            child: Text(
                AppLocalization.of(context).translate('mock_exam.confirm_yes')),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ExamSessionView(
            // Passing the TEST ID as categoryId because ExamSessionView uses categoryId to fetch questions
            categoryId: test.id.toString(),
            examTitle: test.title,
            examType:
                'practice', // Define exam type to load from different endpoint
            initialSeconds: test.timeSeconds,
          ),
        ),
      );
    }
  }
}
