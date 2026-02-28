import 'package:flutter/material.dart';
import 'package:teorikort/features/quiz/data/models/quiz_data.dart';
import 'package:teorikort/core/localization/app_localization.dart';
import 'package:teorikort/features/reports/data/services/report_service.dart';

class SearchQuestionDetailScreen extends StatelessWidget {
  final QuizQuestion question;

  const SearchQuestionDetailScreen({super.key, required this.question});

  Future<void> _showReportDialog(BuildContext context, String questionId) async {
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
    final langCode = AppLocalization.of(context).locale.languageCode;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(AppLocalization.of(context).translate('search.question_detail')),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.report_gmailerrorred, color: colorScheme.error),
            onPressed: () => _showReportDialog(context, question.id),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question text
            Text(
              question.getQuestion(langCode),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            // Options
            ...question.options.map((option) {
              final bool isCorrect = option.id == question.correctAnswer;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isCorrect ? colorScheme.primary.withOpacity(0.08) : colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isCorrect ? colorScheme.primary : colorScheme.outline.withOpacity(0.2),
                    width: isCorrect ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isCorrect ? colorScheme.primary : colorScheme.outline.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        option.id.toUpperCase(),
                        style: TextStyle(
                          color: isCorrect ? colorScheme.onPrimary : colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        option.getText(langCode),
                        style: TextStyle(
                          color: isCorrect ? colorScheme.primary : colorScheme.onSurface,
                          fontWeight: isCorrect ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (isCorrect)
                      Icon(Icons.check_circle, color: colorScheme.primary, size: 20),
                  ],
                ),
              );
            }),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),

            // Explanation
            Text(
              AppLocalization.of(context).translate('quiz.explanation'),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                question.getExplanation(langCode),
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.6,
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
