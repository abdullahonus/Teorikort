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
                    if (tests.isNotEmpty) ...[
                      _buildExamInfoCard(context, tests.first, colorScheme),
                      const SizedBox(height: 24),
                    ],
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.rocket_launch, color: colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                AppLocalization.of(context)
                    .translate('mock_exam.confirm_start'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalization.of(context)
                .translate('mock_exam.confirm_description')),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                children: [
                  _buildDialogInfoRow(Icons.timer_outlined, AppLocalization.of(context).translate('exam.duration'), '${test.timeSeconds ~/ 60} ${AppLocalization.of(context).translate('exam.minute_short')}', colorScheme),
                  const SizedBox(height: 8),
                  _buildDialogInfoRow(Icons.help_outline, AppLocalization.of(context).translate('exam.question_count_label'), '${test.totalQuestions}', colorScheme),
                  const SizedBox(height: 8),
                  _buildDialogInfoRow(Icons.verified_outlined, AppLocalization.of(context).translate('exam.success_rate'), '%${test.successPoint}', colorScheme),
                ],
              ),
            ),
          ],
        ),
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

  Widget _buildDialogInfoRow(IconData icon, String label, String value, ColorScheme colorScheme) {
    return Row(
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: colorScheme.onSurfaceVariant)),
        const Spacer(),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
        ),
      ],
    );
  }

  Widget _buildExamInfoCard(BuildContext context, ExamCategory test, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: colorScheme.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                AppLocalization.of(context).translate('exam.exam_details'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildInfoStat(Icons.schedule, '${test.timeSeconds ~/ 60}', AppLocalization.of(context).translate('exam.minute'), colorScheme),
              _buildVerticalDivider(colorScheme),
              _buildInfoStat(Icons.help_outline, '${test.totalQuestions}', AppLocalization.of(context).translate('exam.question'), colorScheme),
              _buildVerticalDivider(colorScheme),
              _buildInfoStat(Icons.star_outline, '%${test.successPoint}', AppLocalization.of(context).translate('exam.success_rate'), colorScheme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoStat(IconData icon, String value, String label, ColorScheme colorScheme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: colorScheme.primary, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider(ColorScheme colorScheme) {
    return Container(
      height: 40,
      width: 1,
      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
    );
  }
}
