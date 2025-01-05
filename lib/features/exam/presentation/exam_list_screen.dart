import 'package:driving_license_exam/features/quiz/presentation/quiz_screen.dart';

import 'package:flutter/material.dart';
import 'package:driving_license_exam/core/theme/app_colors.dart';
import 'package:driving_license_exam/features/exam/data/models/exam_result.dart';
import 'package:driving_license_exam/features/exam/data/services/exam_result_service.dart';
import 'package:collection/collection.dart';
import 'package:driving_license_exam/core/localization/app_localization.dart';
import 'package:driving_license_exam/features/exam/data/services/category_service.dart';

class ExamListScreen extends StatefulWidget {
  const ExamListScreen({super.key});

  @override
  State<ExamListScreen> createState() => _ExamListScreenState();
}

class _ExamListScreenState extends State<ExamListScreen> {
  final ExamResultService _resultService = ExamResultService();
  final CategoryService _categoryService = CategoryService();
  Map<String, List<ExamResult>> _examResults = {};
  Map<String, dynamic>? _categories;

  @override
  void initState() {
    super.initState();
    _loadExamResults();
    _loadCategories();
  }

  Future<void> _loadExamResults() async {
    final results = await _resultService.getExamResults();
    setState(() {
      _examResults = groupBy(results, (ExamResult r) => r.category);
    });
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _categoryService.getCategories();
      setState(() {
        _categories = categories;
      });
    } catch (e) {
      print('Kategoriler yüklenirken hata oluştu: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          AppLocalization.of(context).translate('exam_list.screen_title'),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 60),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
            ),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
              children: [
                _buildExamSection(
                    AppLocalization.of(context)
                        .translate('exam_list.active_exams'),
                    _buildActiveExams(context).sublist(1)),
                const SizedBox(height: 24),
                _buildExamSection(
                    AppLocalization.of(context)
                        .translate('exam_list.completed_exams'),
                    _buildCompletedExams()),
              ],
            ),
          ),
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: SizedBox(
                height: 140,
                child: Center(child: _buildActiveExams(context).first)),
          ),
        ],
      ),
    );
  }

  Widget _buildExamSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        ...items,
      ],
    );
  }

  List<Widget> _buildActiveExams(BuildContext context) {
    if (_categories == null) {
      return [
        Center(
            child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ))
      ];
    }

    final List<Widget> examItems = _categories!.entries.map((entry) {
      final categoryId = entry.key;
      final categoryData = entry.value as Map<String, dynamic>;
      final locale = AppLocalization.of(context).locale.languageCode;

      return _ExamItem(
        title: categoryData[locale],
        subtitle: AppLocalization.of(context).translate('exam_list.final_exam'),
        duration:
            '45 ${AppLocalization.of(context).translate('exam_list.minutes')}',
        iconUrl: categoryData['icon'],
        isActive: true,
        examResults: _examResults[categoryId],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizScreen(
              category: categoryId,
              examTitle: categoryData[locale],
            ),
          ),
        ),
      );
    }).toList();

    if (examItems.isNotEmpty) {
      final firstItem = examItems.removeAt(0);
      return [firstItem, ...examItems];
    }

    return examItems;
  }

  List<Widget> _buildCompletedExams() {
    if (_examResults.isEmpty) {
      return [
        Center(
          child: Text(
            AppLocalization.of(context)
                .translate('exam_list.no_completed_exams'),
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
      ];
    }

    return _examResults.entries.map((entry) {
      final categoryId = entry.key;
      final results = entry.value;
      final latestResult = results.last;
      final categoryData = _categories?[categoryId] as Map<String, dynamic>?;
      final locale = AppLocalization.of(context).locale.languageCode;

      return _ExamItem(
        title: categoryData?[locale] ?? '',
        subtitle:
            '${latestResult.correctAnswers}/${latestResult.totalQuestions} ${AppLocalization.of(context).translate('exam_list.correct')}',
        duration: latestResult.duration.inMinutes > 0
            ? '${latestResult.duration.inMinutes} ${AppLocalization.of(context).translate('exam_list.minutes')}'
            : '${latestResult.duration.inSeconds} ${AppLocalization.of(context).translate('quiz_result.seconds')}',
        iconUrl: categoryData?['icon'] ?? '',
        isCompleted: true,
        examResults: results,
      );
    }).toList();
  }
}

class _ExamItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String duration;
  final String iconUrl;
  final bool isActive;
  final bool isCompleted;
  final VoidCallback? onTap;
  final List<ExamResult>? examResults;

  const _ExamItem({
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.iconUrl,
    this.isActive = false,
    this.isCompleted = false,
    this.onTap,
    this.examResults,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildIcon(context),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            duration,
                            style: TextStyle(
                              color: colorScheme.onSurface.withOpacity(0.6),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _buildActionButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          iconUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.school,
            color: colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (examResults == null || examResults!.isEmpty) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: colorScheme.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.play_arrow,
          color: colorScheme.primary,
          size: 20,
        ),
      );
    }

    final latestResult = examResults!.last;
    final percentage = latestResult.scorePercentage.round();

    if (percentage <= 0) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getScoreColor(percentage).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '$percentage%',
        style: TextStyle(
          color: _getScoreColor(percentage),
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Color _getScoreColor(int percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }
}
