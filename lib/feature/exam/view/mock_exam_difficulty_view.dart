import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teorikort/core/localization/app_localization.dart';
import '../provider/exam_provider.dart';
import '../model/exam_category.dart';
import 'exam_session_view.dart';

class MockExamDifficultyView extends ConsumerStatefulWidget {
  const MockExamDifficultyView({super.key});

  @override
  ConsumerState<MockExamDifficultyView> createState() =>
      _MockExamDifficultyViewState();
}

class _MockExamDifficultyViewState
    extends ConsumerState<MockExamDifficultyView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(examProvider.notifier).loadExams());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(examProvider);
    final colorScheme = Theme.of(context).colorScheme;

    final category = state.categories.firstWhere(
      (c) => c.id == 1,
      orElse: () => state.categories.isNotEmpty
          ? state.categories.first
          : const ExamCategory(
              id: 1,
              title: 'Genel Sınav',
              description: '',
              timeSeconds: 2700,
              successPoint: 70,
              imageUrl: '',
              totalQuestions: 50),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        title: Text(AppLocalization.of(context)
            .translate('mock_exam.select_difficulty')),
      ),
      body: state.isLoading && state.categories.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => ref.read(examProvider.notifier).refresh(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildExamHeader(context, category),
                    const SizedBox(height: 24),
                    Text(
                      AppLocalization.of(context)
                          .translate('mock_exam.description'),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                    ),
                    const SizedBox(height: 24),
                    _buildDifficultyCard(
                      context,
                      'difficulty_levels.easy',
                      'mock_exam.easy_description',
                      Icons.sentiment_satisfied,
                      Colors.green,
                      () => _confirmAndStart(context, category, 'easy'),
                    ),
                    const SizedBox(height: 16),
                    _buildDifficultyCard(
                      context,
                      'difficulty_levels.medium',
                      'mock_exam.medium_description',
                      Icons.sentiment_neutral,
                      Colors.orange,
                      () => _confirmAndStart(context, category, 'medium'),
                    ),
                    const SizedBox(height: 16),
                    _buildDifficultyCard(
                      context,
                      'difficulty_levels.hard',
                      'mock_exam.hard_description',
                      Icons.sentiment_dissatisfied,
                      Colors.red,
                      () => _confirmAndStart(context, category, 'hard'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildExamHeader(BuildContext context, ExamCategory category) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.8)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.description,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      AppLocalization.of(context).translate('exam_types.mock'),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildHeaderStat(
                context,
                Icons.help_outline,
                AppLocalization.of(context)
                    .translate('mock_exam.question_count')
                    .replaceFirst('%d', '${category.totalQuestions}'),
              ),
              _buildHeaderStat(
                context,
                Icons.timer_outlined,
                AppLocalization.of(context)
                    .translate('mock_exam.time_limit')
                    .replaceFirst('%d', '${category.timeSeconds ~/ 60}'),
              ),
              _buildHeaderStat(context, Icons.emoji_events_outlined, '100%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(BuildContext context, IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 16),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildDifficultyCard(
    BuildContext context,
    String titleKey,
    String descriptionKey,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalization.of(context).translate(titleKey),
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalization.of(context).translate(descriptionKey),
                      style: TextStyle(
                          color: colorScheme.onSurface.withValues(alpha: 0.7)),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right,
                  color: colorScheme.onSurface.withValues(alpha: 0.5)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmAndStart(
      BuildContext context, ExamCategory category, String difficulty) async {
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

    if (confirmed == true && mounted) {
      final l10n = AppLocalization.of(context);
      final examTitle =
          '${l10n.translate('exam_types.mock')} - ${l10n.translate('difficulty_levels.$difficulty')}';

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ExamSessionView(
            categoryId: category.id.toString(),
            examTitle: examTitle,
            difficulty: difficulty,
            examType: 'mock',
            initialSeconds: category.timeSeconds,
          ),
        ),
      );
    }
  }
}
