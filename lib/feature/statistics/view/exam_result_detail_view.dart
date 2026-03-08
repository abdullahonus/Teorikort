import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teorikort/core/localization/app_localization.dart';
import 'package:teorikort/core/widgets/app_loading_widget.dart';
import 'package:teorikort/features/quiz/data/services/quiz_service.dart';

import '../../../core/widgets/app_bar_widget.dart';

final examResultDetailProvider =
    FutureProvider.family<ExamResultItem, int>((ref, id) async {
  final service = QuizService();
  final response = await service.getExamResultDetail(id);
  if (response.success && response.data != null) {
    return response.data!;
  }
  throw Exception(response.message ?? 'Hata oluştu');
});

class ExamResultDetailView extends ConsumerWidget {
  final int resultId;

  const ExamResultDetailView({super.key, required this.resultId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(examResultDetailProvider(resultId));
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppHeader(
        title: AppLocalization.of(context)
            .translate('quiz_result.detailed_results'),
      ),
      body: asyncValue.when(
        loading: () => const AppLoadingWidget.fullscreen(),
        error: (err, stack) => Center(child: Text(err.toString())),
        data: (item) => _buildContent(context, item, colorScheme),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, ExamResultItem result, ColorScheme colorScheme) {
    final l10n = AppLocalization.of(context);
    final isPass = result.scorePercentage >= 70;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Category Header
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              result.categoryTitle.isEmpty
                  ? 'Kategori ${result.catId}'
                  : result.categoryTitle,
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(height: 32),
        // Score Circle
        Center(
          child: _buildScoreCircle(context, result, colorScheme),
        ),
        const SizedBox(height: 48),

        Text(
          l10n.translate('statistics.overall_performance'),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildStatCard(
                context,
                l10n.translate('quiz_result.correct_answers'),
                '${result.correctAnswers}',
                Colors.green,
                Icons.check_circle_outline),
            const SizedBox(width: 12),
            _buildStatCard(context, l10n.translate('quiz_result.wrong_answers'),
                '${result.wrongAnswers}', Colors.red, Icons.cancel_outlined),
            const SizedBox(width: 12),
            _buildStatCard(context, l10n.translate('quiz_result.empty_answers'),
                '${result.emptyAnswers}', Colors.orange, Icons.help_outline),
          ],
        ),
        const SizedBox(height: 32),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.translate('statistics.exams'),
                      style: TextStyle(
                          color: colorScheme.onSurface.withValues(alpha: 0.6))),
                  const SizedBox(height: 4),
                  Text(_formatDate(result.createdAt.toIso8601String()),
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              Icon(isPass ? Icons.emoji_events : Icons.sentiment_dissatisfied,
                  color: isPass ? Colors.amber : Colors.grey, size: 32),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScoreCircle(
      BuildContext context, ExamResultItem result, ColorScheme colorScheme) {
    final score = result.scorePercentage;
    final color = score >= 70 ? Colors.green : Colors.red;

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 150,
          height: 150,
          child: CircularProgressIndicator(
            value: score / 100,
            strokeWidth: 12,
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(color),
            strokeCap: StrokeCap.round,
          ),
        ),
        Column(
          children: [
            Text(
              '%${score.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              AppLocalization.of(context).translate('quiz_result.score_text'),
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value,
      Color color, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return isoDate;
    }
  }
}
