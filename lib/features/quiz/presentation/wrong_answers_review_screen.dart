import 'package:flutter/material.dart';
import '../data/models/quiz_data.dart';
import 'package:driving_license_exam/core/localization/app_localization.dart';

class WrongAnswersReviewScreen extends StatelessWidget {
  final List<QuizQuestion> questions;
  final Map<int, String> userAnswers;

  const WrongAnswersReviewScreen({
    super.key,
    required this.questions,
    required this.userAnswers,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Filter wrong answers
    final wrongAnswers = questions.asMap().entries.where((entry) {
      final index = entry.key;
      final question = entry.value;
      return userAnswers[index] != question.correctAnswer;
    }).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        title: Text(
          AppLocalization.of(context)
              .translate('quiz_result.review_wrong_answers'),
          style: theme.textTheme.titleLarge,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: wrongAnswers.length,
        itemBuilder: (context, index) {
          final entry = wrongAnswers[index];
          final question = entry.value;
          final questionIndex = entry.key;
          final userAnswerId = userAnswers[questionIndex];

          // Find the selected option text
          final userAnswerText = userAnswerId != null
              ? question.options
                  .firstWhere(
                    (option) => option.id == userAnswerId,
                    orElse: () => Option(
                      id: '',
                      text: AppLocalization.of(context)
                          .translate('topics.no_answer'),
                    ),
                  )
                  .text
              : AppLocalization.of(context).translate('topics.no_answer');

          // Find the correct option text
          final correctAnswerText = question.options
              .firstWhere((option) => option.id == question.correctAnswer)
              .text;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.outline,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          AppLocalization.of(context)
                              .translate('quiz.question_number')
                              .replaceAll('%d', '${questionIndex + 1}')
                              .replaceAll('%d', '${questions.length}'),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: colorScheme.outline,
                  height: 1,
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        question.question,
                        style: theme.textTheme.titleMedium?.copyWith(
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildAnswerRow(
                        context,
                        AppLocalization.of(context)
                            .translate('topics.your_answer'),
                        userAnswerText,
                        colorScheme.error,
                        Icons.close,
                      ),
                      const SizedBox(height: 16),
                      _buildAnswerRow(
                        context,
                        AppLocalization.of(context)
                            .translate('topics.correct_answer'),
                        correctAnswerText,
                        colorScheme.primary,
                        Icons.check_circle,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnswerRow(
    BuildContext context,
    String label,
    String answer,
    Color color,
    IconData icon,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  answer,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
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
