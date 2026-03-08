import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teorikort/core/localization/app_localization.dart';
import 'package:teorikort/core/widgets/app_bar_widget.dart';
import 'package:teorikort/core/widgets/app_loading_widget.dart';

import '../model/exam_category.dart';
import '../provider/practice_provider.dart';
import 'exam_session_view.dart';

class PracticeTestView extends ConsumerWidget {
  final ExamCategory subCategory;

  const PracticeTestView({
    super.key,
    required this.subCategory,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final testsAsync =
        ref.watch(practiceTestsProvider(subCategory.id.toString()));
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppHeader(
        title: subCategory.title,
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
              return ref.refresh(
                  practiceTestsProvider(subCategory.id.toString()).future);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tests.length,
              itemBuilder: (context, index) {
                final test = tests[index];
                return _buildTestCard(context, test, colorScheme);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildTestCard(
      BuildContext context, ExamCategory test, ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      color: colorScheme.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _confirmAndStart(context, test),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.tertiary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.assignment, color: Colors.orange),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      test.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.help_outline,
                            size: 14,
                            color:
                                colorScheme.onSurface.withValues(alpha: 0.6)),
                        const SizedBox(width: 4),
                        Text(
                          '${test.totalQuestions} Questions', // Better use localization here if available
                          style: TextStyle(
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.6),
                              fontSize: 12),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.timer_outlined,
                            size: 14,
                            color:
                                colorScheme.onSurface.withValues(alpha: 0.6)),
                        const SizedBox(width: 4),
                        Text(
                          '${test.timeSeconds ~/ 60}m',
                          style: TextStyle(
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.6),
                              fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.play_circle_fill,
                  color: colorScheme.primary, size: 28),
            ],
          ),
        ),
      ),
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
