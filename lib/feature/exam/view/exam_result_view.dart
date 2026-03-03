import 'package:flutter/material.dart';
import 'package:teorikort/core/localization/app_localization.dart';
import 'package:teorikort/core/presentation/widgets/app_scaffold.dart';

import '../model/exam_question.dart';
import '../model/exam_result.dart';

class ExamResultView extends StatelessWidget {
  final ExamResult result;
  final List<ExamQuestion> questions;
  final Map<String, String?> userAnswers;

  const ExamResultView({
    super.key,
    required this.result,
    this.questions = const [],
    this.userAnswers = const {},
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSuccess = result.score >= 70;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
            AppLocalization.of(context).translate('quiz_result.screen_title')),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const AppScaffold()),
              (route) => false,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isSuccess ? Colors.green : Colors.red)
                    .withValues(alpha: 0.1),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${result.score.toStringAsFixed(0)}%',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        color: isSuccess ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      isSuccess
                          ? AppLocalization.of(context)
                              .translate('quiz_result.success')
                          : AppLocalization.of(context)
                              .translate('quiz_result.fail'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: isSuccess ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            _buildResultCard(context, result),
            const SizedBox(height: 32),
            _buildWrongAnswersContext(context),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const AppScaffold()),
                (route) => false,
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(AppLocalization.of(context)
                  .translate('quiz_result.back_to_home')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(BuildContext context, ExamResult result) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalization.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildResultItem(
              context,
              l10n.translate('quiz_result.correct_answers'),
              '${result.correctCount}',
              Icons.check_circle,
              Colors.green),
          const SizedBox(height: 12),
          _buildResultItem(context, l10n.translate('quiz_result.wrong_answers'),
              '${result.wrongCount}', Icons.cancel, Colors.red),
          const SizedBox(height: 12),
          _buildResultItem(
              context,
              l10n.translate('quiz_result.empty_answers'),
              '${result.emptyCount}',
              Icons.radio_button_unchecked,
              Colors.orange),
        ],
      ),
    );
  }

  Widget _buildResultItem(BuildContext context, String title, String value,
      IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Expanded(child: Text(title, style: const TextStyle(fontSize: 16))),
        Text(value,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildWrongAnswersContext(BuildContext context) {
    if (questions.isEmpty || userAnswers.isEmpty)
      return const SizedBox.shrink();

    final wrongQuestions = questions.where((q) {
      final ans = userAnswers[q.id];
      return ans != q.correctAnswer;
    }).toList();

    if (wrongQuestions.isEmpty) return const SizedBox.shrink();

    ThemeData theme = Theme.of(context);
    var colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.assignment_late_rounded,
                color: colorScheme.error, size: 28),
            const SizedBox(width: 8),
            Text(
              AppLocalization.of(context)
                  .translate('quiz_result.wrong_answers_review'),
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 24),
        ...wrongQuestions.map((q) {
          final userAnswerId = userAnswers[q.id];
          final isEmpty = userAnswerId == null;

          final userAnswerText = isEmpty
              ? AppLocalization.of(context)
                  .translate('quiz_result.empty_answer')
              : q.options
                  .firstWhere((o) => o.id == userAnswerId,
                      orElse: () =>
                          const ExamOption(id: '', text: 'Bilinmiyor'))
                  .text;

          final correctAnswerText = q.options
              .firstWhere((o) => o.id == q.correctAnswer,
                  orElse: () => const ExamOption(id: '', text: 'Bilinmiyor'))
              .text;

          return Container(
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isEmpty
                    ? Colors.orange.withValues(alpha: 0.3)
                    : colorScheme.error.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isEmpty
                        ? Colors.orange.withValues(alpha: 0.1)
                        : colorScheme.error.withValues(alpha: 0.1),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(15)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isEmpty
                            ? Icons.radio_button_unchecked
                            : Icons.cancel_outlined,
                        color: isEmpty ? Colors.orange : colorScheme.error,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isEmpty
                            ? AppLocalization.of(context)
                                .translate('quiz_result.empty_answer_title')
                            : AppLocalization.of(context)
                                .translate('quiz_result.wrong_answer_title'),
                        style: TextStyle(
                          color: isEmpty ? Colors.orange : colorScheme.error,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        q.question,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            height: 1.5),
                      ),
                      const SizedBox(height: 24),
                      if (!isEmpty) ...[
                        _buildAnswerRow(
                          context,
                          title: AppLocalization.of(context)
                              .translate('quiz.your_answer'),
                          text: userAnswerText,
                          icon: Icons.close_rounded,
                          color: colorScheme.error,
                          bgColor: colorScheme.error.withValues(alpha: 0.08),
                        ),
                        const SizedBox(height: 12),
                      ],
                      _buildAnswerRow(
                        context,
                        title: AppLocalization.of(context)
                            .translate('quiz.correct_answer'),
                        text: correctAnswerText,
                        icon: Icons.check_circle_rounded,
                        color: Colors.green.shade600,
                        bgColor: Colors.green.withValues(alpha: 0.08),
                      ),
                      if (q.explanation.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Divider(
                            color: colorScheme.outline.withValues(alpha: 0.2)),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color:
                                    colorScheme.primary.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.lightbulb_outline_rounded,
                                  color: colorScheme.primary, size: 22),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppLocalization.of(context)
                                          .translate('quiz.explanation'),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.primary,
                                          fontSize: 13),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      q.explanation,
                                      style: TextStyle(
                                          height: 1.5,
                                          color: theme
                                              .textTheme.bodyMedium?.color
                                              ?.withValues(alpha: 0.8)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAnswerRow(BuildContext context,
      {required String title,
      required String text,
      required IconData icon,
      required Color color,
      required Color bgColor}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
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
                  title,
                  style: TextStyle(
                      fontSize: 12,
                      color: color.withValues(alpha: 0.8),
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
