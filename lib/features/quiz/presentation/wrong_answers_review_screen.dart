import 'package:flutter/material.dart';
import 'package:teorikort/core/localization/app_localization.dart';
import 'package:teorikort/features/reports/data/services/report_service.dart';

import '../data/models/quiz_data.dart';

class WrongAnswersReviewScreen extends StatelessWidget {
  final List<QuizQuestion> questions;
  final Map<int, String> userAnswers;

  const WrongAnswersReviewScreen({
    super.key,
    required this.questions,
    required this.userAnswers,
  });

  // Helper method to get text in current language
  String _getLocalizedText(BuildContext context, Map<String, String> textMap) {
    final currentLanguage = AppLocalization.of(context).locale.languageCode;
    return textMap[currentLanguage] ?? textMap['tr'] ?? textMap.values.first;
  }

  Future<void> _showReportDialog(
      BuildContext context, String questionId) async {
    final TextEditingController reportController = TextEditingController();
    final l10n = AppLocalization.of(context);
    final reportService = ReportService();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.translate('report.title')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.translate('report.description')),
            const SizedBox(height: 16),
            TextField(
              controller: reportController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: l10n.translate('report.hint'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.translate('report.cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              if (reportController.text.trim().isEmpty) return;

              final response = await reportService.reportQuestion(
                questionId: questionId,
                description: reportController.text.trim(),
                context: context,
              );

              if (context.mounted) {
                Navigator.pop(context);
                if (response.success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.translate('report.success'))),
                  );
                }
              }
            },
            child: Text(l10n.translate('report.submit')),
          ),
        ],
      ),
    );
  }

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
          final isEmpty = userAnswerId == null;

          // Find the selected option text
          final userAnswerText = userAnswerId != null
              ? question.options
                  .firstWhere(
                    (option) => option.id == userAnswerId,
                    orElse: () => Option(
                      id: '',
                      text: {
                        'tr': AppLocalization.of(context)
                                    .translate('topics.no_answer') !=
                                'topics.no_answer'
                            ? AppLocalization.of(context)
                                .translate('topics.no_answer')
                            : 'Boş Bıraktın',
                        'en': 'No answer'
                      },
                    ),
                  )
                  .text
              : {
                  'tr': AppLocalization.of(context)
                              .translate('topics.no_answer') !=
                          'topics.no_answer'
                      ? AppLocalization.of(context)
                          .translate('topics.no_answer')
                      : 'Boş Bıraktın',
                  'en': 'No answer'
                };

          // Find the correct option text
          final correctAnswerText = question.options
              .firstWhere((option) => option.id == question.correctAnswer,
                  orElse: () => Option(
                        id: '',
                        text: {'tr': 'Bilinmiyor', 'en': 'Unknown'},
                      ))
              .text;

          return Container(
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isEmpty
                    ? Colors.orange.withOpacity(0.3)
                    : colorScheme.error.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.05),
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
                        ? Colors.orange.withOpacity(0.1)
                        : colorScheme.error.withOpacity(0.1),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(15)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isEmpty
                              ? Colors.orange.withOpacity(0.2)
                              : colorScheme.error.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          AppLocalization.of(context)
                                      .translate('quiz.question_number') !=
                                  'quiz.question_number'
                              ? AppLocalization.of(context)
                                  .translate('quiz.question_number')
                                  .replaceAll('%d', '${questionIndex + 1}')
                                  .replaceAll('%n', '${questions.length}')
                              : 'Soru ${questionIndex + 1}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: isEmpty
                                ? Colors.orange.shade800
                                : colorScheme.error,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        isEmpty
                            ? Icons.radio_button_unchecked
                            : Icons.cancel_outlined,
                        color: isEmpty ? Colors.orange : colorScheme.error,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isEmpty ? 'Boş Bırakıldı' : 'Yanlış Cevap',
                        style: TextStyle(
                          color: isEmpty ? Colors.orange : colorScheme.error,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(Icons.report_gmailerrorred,
                            color: colorScheme.error, size: 22),
                        onPressed: () =>
                            _showReportDialog(context, question.id),
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        tooltip: 'Soruyu Bildir',
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
                        _getLocalizedText(context, question.question),
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            height: 1.5),
                      ),
                      const SizedBox(height: 24),
                      if (!isEmpty) ...[
                        _buildAnswerRow(
                          context,
                          AppLocalization.of(context)
                                      .translate('topics.your_answer') !=
                                  'topics.your_answer'
                              ? AppLocalization.of(context)
                                  .translate('topics.your_answer')
                              : 'Senin Cevabın',
                          _getLocalizedText(context, userAnswerText),
                          colorScheme.error,
                          Icons.close_rounded,
                        ),
                        const SizedBox(height: 12),
                      ],
                      _buildAnswerRow(
                        context,
                        AppLocalization.of(context)
                                    .translate('topics.correct_answer') !=
                                'topics.correct_answer'
                            ? AppLocalization.of(context)
                                .translate('topics.correct_answer')
                            : 'Doğru Cevap',
                        _getLocalizedText(context, correctAnswerText),
                        Colors.green.shade600,
                        Icons.check_circle_rounded,
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
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
                  style: TextStyle(
                      fontSize: 12,
                      color: color.withOpacity(0.8),
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  answer,
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
