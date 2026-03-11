import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teorikort/core/localization/app_localization.dart';
import 'package:teorikort/core/widgets/app_bar_widget.dart';
import 'package:teorikort/core/widgets/app_loading_widget.dart';
import 'package:teorikort/core/widgets/custom_elevated_button.dart';

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
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
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
              ],
            ),
          );
        },
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
