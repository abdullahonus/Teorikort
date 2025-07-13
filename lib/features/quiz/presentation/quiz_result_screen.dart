import 'package:driving_license_exam/core/presentation/widgets/app_scaffold.dart';
import 'package:driving_license_exam/features/quiz/presentation/wrong_answers_review_screen.dart';
import 'package:flutter/material.dart';
import '../data/models/quiz_data.dart';
import 'package:driving_license_exam/core/localization/app_localization.dart';

class QuizResultScreen extends StatelessWidget {
  final int totalQuestions;
  final int correctAnswers;
  final Duration totalTime;
  final bool isTimeOut;
  final List<QuizQuestion> questions;
  final Map<int, String> userAnswers;

  const QuizResultScreen({
    super.key,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.totalTime,
    required this.questions,
    required this.userAnswers,
    this.isTimeOut = false,
  });

  String _formatDuration(BuildContext context, Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;

    if (minutes == 0) {
      return '$seconds ${AppLocalization.of(context).translate('quiz_result.seconds')}';
    } else if (seconds == 0) {
      return '$minutes ${AppLocalization.of(context).translate('quiz_result.minutes')}';
    } else {
      return '$minutes ${AppLocalization.of(context).translate('quiz_result.minutes')} '
          '$seconds ${AppLocalization.of(context).translate('quiz_result.seconds')}';
    }
  }

  int _getEmptyAnswersCount() {
    int emptyCount = 0;
    for (int i = 0; i < totalQuestions; i++) {
      if (!userAnswers.containsKey(i) || userAnswers[i] == null) {
        emptyCount++;
      }
    }
    return emptyCount;
  }

  @override
  Widget build(BuildContext context) {
    final percentage = (correctAnswers / totalQuestions * 100).round();
    final wrongAnswers =
        totalQuestions - correctAnswers - _getEmptyAnswersCount();
    final emptyAnswers = _getEmptyAnswersCount();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.popUntil(context, (route) => route.isFirst);
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Text(
              isTimeOut
                  ? AppLocalization.of(context)
                      .translate('quiz_result.time_up_message')
                  : AppLocalization.of(context)
                      .translate('quiz_result.completed_message'),
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: percentage >= 70
                              ? colorScheme.primary.withOpacity(0.1)
                              : colorScheme.error.withOpacity(0.1),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$percentage%',
                                style: theme.textTheme.headlineLarge?.copyWith(
                                  color: percentage >= 70
                                      ? colorScheme.primary
                                      : colorScheme.error,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                percentage >= 70
                                    ? AppLocalization.of(context)
                                        .translate('quiz_result.success')
                                    : AppLocalization.of(context)
                                        .translate('quiz_result.fail'),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: percentage >= 70
                                      ? colorScheme.primary
                                      : colorScheme.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Detailed Results Section
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceVariant.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Text(
                              AppLocalization.of(context)
                                  .translate('quiz_result.detailed_results'),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Correct Answers
                            _buildResultItem(
                              context,
                              AppLocalization.of(context)
                                  .translate('quiz_result.correct_answers'),
                              '$correctAnswers ${AppLocalization.of(context).translate('quiz_result.question_unit')}',
                              Icons.check_circle,
                              Colors.green,
                            ),
                            const SizedBox(height: 12),

                            // Wrong Answers
                            if (wrongAnswers > 0) ...[
                              _buildResultItem(
                                context,
                                AppLocalization.of(context)
                                    .translate('quiz_result.wrong_answers'),
                                '$wrongAnswers ${AppLocalization.of(context).translate('quiz_result.question_unit')}',
                                Icons.cancel,
                                Colors.red,
                              ),
                              const SizedBox(height: 12),
                            ],

                            // Empty Answers
                            if (emptyAnswers > 0) ...[
                              _buildResultItem(
                                context,
                                AppLocalization.of(context)
                                    .translate('quiz_result.empty_answers'),
                                '$emptyAnswers ${AppLocalization.of(context).translate('quiz_result.question_unit')}',
                                Icons.radio_button_unchecked,
                                Colors.orange,
                              ),
                              const SizedBox(height: 12),
                            ],

                            // Time Taken
                            _buildResultItem(
                              context,
                              AppLocalization.of(context)
                                  .translate('quiz_result.time_taken'),
                              _formatDuration(context, totalTime),
                              Icons.timer,
                              colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                      if (isTimeOut) ...[
                        const SizedBox(height: 16),
                        _buildResultItem(
                          context,
                          'Status',
                          AppLocalization.of(context)
                              .translate('quiz_result.time_up_message'),
                          Icons.timer_off,
                          colorScheme.error,
                        ),
                      ],
                      if (correctAnswers < totalQuestions) ...[
                        const SizedBox(height: 32),
                        FilledButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WrongAnswersReviewScreen(
                                  questions: questions,
                                  userAnswers: userAnswers,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.error_outline),
                          label: Text(
                            AppLocalization.of(context)
                                .translate('quiz_result.review_wrong_answers'),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: colorScheme.error,
                            foregroundColor: colorScheme.onError,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (_) => const AppScaffold()),
                              (route) => false);
                        },
                        icon: const Icon(Icons.home),
                        label: Text(
                          AppLocalization.of(context)
                              .translate('quiz_result.back_to_home'),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          foregroundColor: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultItem(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
