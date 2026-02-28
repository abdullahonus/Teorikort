import 'package:flutter/material.dart';
import 'package:teorikort/core/localization/app_localization.dart';
import 'package:teorikort/core/presentation/widgets/app_scaffold.dart';
import '../model/exam_result.dart';

class ExamResultView extends StatelessWidget {
  final ExamResult result;

  const ExamResultView({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSuccess = result.score >= 70;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(AppLocalization.of(context).translate('quiz_result.screen_title')),
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
                color: (isSuccess ? Colors.green : Colors.red).withValues(alpha: 0.1),
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
                          ? AppLocalization.of(context).translate('quiz_result.success')
                          : AppLocalization.of(context).translate('quiz_result.fail'),
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
            ElevatedButton(
              onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const AppScaffold()),
                (route) => false,
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(AppLocalization.of(context).translate('quiz_result.back_to_home')),
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
        color: colorScheme.surfaceVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildResultItem(context, l10n.translate('quiz_result.correct_answers'), '${result.correctCount}', Icons.check_circle, Colors.green),
          const SizedBox(height: 12),
          _buildResultItem(context, l10n.translate('quiz_result.wrong_answers'), '${result.wrongCount}', Icons.cancel, Colors.red),
          const SizedBox(height: 12),
          _buildResultItem(context, l10n.translate('quiz_result.empty_answers'), '${result.emptyCount}', Icons.radio_button_unchecked, Colors.orange),
        ],
      ),
    );
  }

  Widget _buildResultItem(BuildContext context, String title, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Expanded(child: Text(title, style: const TextStyle(fontSize: 16))),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}
