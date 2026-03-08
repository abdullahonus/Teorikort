import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teorikort/core/localization/app_localization.dart';
import 'package:teorikort/core/widgets/app_html_text.dart';
import 'package:teorikort/feature/exam/model/exam_question.dart';
import 'package:teorikort/features/reports/data/services/report_service.dart';

class SearchQuestionDetailView extends ConsumerWidget {
  final ExamQuestion question;

  const SearchQuestionDetailView({super.key, required this.question});

  Future<void> _showReportDialog(
      BuildContext context, String questionId) async {
    final TextEditingController reportController = TextEditingController();
    final l10n = AppLocalization.of(context);
    final reportService = ReportService();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
            AppLocalization.of(context).translate('search.question_detail')),
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question text
            AppHtmlText(
              htmlData: question.question,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            // Options
            ...question.options.asMap().entries.map((entry) {
              final int index = entry.key;
              final option = entry.value;

              final int? correctVal = int.tryParse(question.correctAnswer);
              final bool isCorrect = option.id == question.correctAnswer ||
                  (correctVal != null &&
                      (index + 1 == correctVal || index == correctVal));

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isCorrect
                      ? colorScheme.primary.withValues(alpha: 0.1)
                      : colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isCorrect
                        ? colorScheme.primary
                        : colorScheme.outline.withValues(alpha: 0.1),
                    width: isCorrect ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isCorrect
                            ? colorScheme.primary
                            : colorScheme.outline.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        option.id.toUpperCase(),
                        style: TextStyle(
                          color: isCorrect
                              ? colorScheme.onPrimary
                              : colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AppHtmlText(
                        htmlData: option.text,
                        style: TextStyle(
                          color: isCorrect
                              ? colorScheme.primary
                              : colorScheme.onSurface,
                          fontWeight:
                              isCorrect ? FontWeight.bold : FontWeight.normal,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    if (isCorrect)
                      Icon(Icons.check_circle_rounded,
                          color: colorScheme.primary, size: 24),
                  ],
                ),
              );
            }),

            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 32),

            // Explanation
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color:
                    colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: colorScheme.primary, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        AppLocalization.of(context)
                            .translate('quiz.explanation'),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AppHtmlText(
                    htmlData: question.explanation,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.6,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
