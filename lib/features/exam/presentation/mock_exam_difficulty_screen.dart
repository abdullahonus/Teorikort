import 'package:flutter/material.dart';
import 'package:teorikort/core/localization/app_localization.dart';
import 'package:teorikort/features/quiz/presentation/quiz_screen.dart';
import 'package:teorikort/features/quiz/data/services/quiz_service.dart';
import 'package:teorikort/features/exam/data/models/exam_data.dart';
import 'package:teorikort/features/exam/data/services/exam_service.dart';
import 'package:teorikort/features/statistics/data/models/statistics_data.dart';
import 'package:teorikort/features/statistics/data/services/statistics_service.dart';

class MockExamDifficultyScreen extends StatefulWidget {
  const MockExamDifficultyScreen({super.key});

  @override
  State<MockExamDifficultyScreen> createState() =>
      _MockExamDifficultyScreenState();
}

class _MockExamDifficultyScreenState extends State<MockExamDifficultyScreen> {
  final ExamService _examService = ExamService();
  final StatisticsService _statisticsService = StatisticsService();

  ExamCategory? _category;
  CategoryStatisticsData? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      // Load categories to find the "Top" one or just use ID 1
      final categoriesRes =
          await _examService.getExamCategories(context: context);
      if (categoriesRes.success &&
          categoriesRes.data != null &&
          categoriesRes.data!.isNotEmpty) {
        // Use the first category or the one with ID 1
        _category = categoriesRes.data!.firstWhere(
          (c) => c.id == 1,
          orElse: () => categoriesRes.data!.first,
        );

        // Load stats for this category
        final statsRes = await _statisticsService.getCategoryStatistics(
          _category!.id.toString(),
          context: context,
        );
        if (statsRes.success) {
          _stats = statsRes.data;
        }
      }
    } catch (e) {
      debugPrint('Error loading exam data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        title: Text(
          AppLocalization.of(context).translate('mock_exam.select_difficulty'),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_category != null) _buildExamHeader(context),
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
                      () => _confirmAndStart(context, 'easy'),
                    ),
                    const SizedBox(height: 16),
                    _buildDifficultyCard(
                      context,
                      'difficulty_levels.medium',
                      'mock_exam.medium_description',
                      Icons.sentiment_neutral,
                      Colors.orange,
                      () => _confirmAndStart(context, 'medium'),
                    ),
                    const SizedBox(height: 16),
                    _buildDifficultyCard(
                      context,
                      'difficulty_levels.hard',
                      'mock_exam.hard_description',
                      Icons.sentiment_dissatisfied,
                      Colors.red,
                      () => _confirmAndStart(context, 'hard'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildExamHeader(BuildContext context) {
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
                      _category?.title ?? '',
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
                    .replaceFirst('%d', '${_category?.totalQuestions ?? 0}'),
              ),
              _buildHeaderStat(
                context,
                Icons.timer_outlined,
                AppLocalization.of(context)
                    .translate('mock_exam.time_limit')
                    .replaceFirst(
                        '%d', '${(_category?.timeSecound ?? 2700) ~/ 60}'),
              ),
              _buildHeaderStat(
                context,
                Icons.emoji_events_outlined,
                '${_stats?.highestScore.toStringAsFixed(0) ?? '0'}%',
              ),
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
        side: BorderSide(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
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
                  shape: BoxShape.circle,
                ),
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalization.of(context).translate(descriptionKey),
                      style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmAndStart(BuildContext context, String difficulty) async {
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
      _startExam(difficulty);
    }
  }

  Future<void> _startExam(String difficulty) async {
    try {
      // Yükleniyor göstergesi
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // API'den mock sınav sorularını yükle
      final response = await QuizService().getMockExamQuestions(
        categoryId: _category?.id.toString(),
        difficulty: difficulty,
        count: _category?.totalQuestions ?? 50,
      );

      if (!mounted) return;
      Navigator.pop(context); // Yükleniyor göstergesini kapat

      if (response.success &&
          response.data != null &&
          response.data!.questions.isNotEmpty) {
        // Sınav başlığını oluştur
        String examTitle =
            '${AppLocalization.of(context).translate('exam_types.mock')} - ${AppLocalization.of(context).translate('difficulty_levels.$difficulty')}';

        // Quiz ekranına git
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizScreen(
              examTitle: examTitle,
              quizQuestions: response.data!.questions,
              category: _category?.id.toString() ?? '1',
              difficulty: difficulty,
              examType: 'mock',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalization.of(context)
                .translate('mock_exam.loading_error')),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Yükleniyor göstergesini kapat
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(AppLocalization.of(context).translate('common.error')),
          ),
        );
      }
    }
  }
}
