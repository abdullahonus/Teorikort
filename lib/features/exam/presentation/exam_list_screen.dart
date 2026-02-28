import 'package:teorikort/features/quiz/presentation/quiz_screen.dart';

import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:teorikort/core/localization/app_localization.dart';
import 'package:teorikort/features/exam/data/services/exam_service.dart';
import 'package:teorikort/features/exam/data/models/exam_data.dart';
import 'package:teorikort/features/quiz/data/services/quiz_service.dart'
    hide ExamCategory;

class ExamListScreen extends StatefulWidget {
  const ExamListScreen({super.key});

  @override
  State<ExamListScreen> createState() => _ExamListScreenState();
}

class _ExamListScreenState extends State<ExamListScreen> {
  final ExamService _examService = ExamService();
  final QuizService _quizService = QuizService();
  List<ExamCategory>? _categories;
  List<ExamResultItem> _apiExamResults = [];

  @override
  void initState() {
    super.initState();
    _loadExamResults();
    _loadCategories();
  }

  Future<void> _loadExamResults() async {
    try {
      final response = await _quizService.getUserExamResults();
      if (response.success && response.data != null) {
        setState(() {
          _apiExamResults = response.data!;
        });
      }
    } catch (e) {
      print('Sınav sonuçları yüklenemedi: $e');
    }
  }

  Future<void> _loadCategories() async {
    try {
      final response = await _examService.getExamCategories(context: context);
      if (mounted) {
        setState(() {
          if (response.success && response.data != null) {
            _categories = response.data;
          } else {
            // If failed, set to empty list to stop loading but show "no data" if we want
            // Or keep as null and show error UI. Let's use empty list for now to stop spinner.
            _categories = [];
          }
        });
      }
    } catch (e) {
      print('Kategoriler yüklenirken hata oluştu: $e');
      if (mounted) {
        setState(() {
          _categories = [];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                if (_categories != null && _categories!.length > 1)
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
                child: Center(
                  child: _categories == null
                      ? CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : (_categories!.isEmpty
                          ? const Text('Kategori bulunamadı')
                          : _buildActiveExams(context).first),
                )),
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
    if (_categories == null || _categories!.isEmpty) {
      return [];
    }

    final List<Widget> examItems = _categories!.map((category) {
      final categoryId = category.id.toString();

      return _ExamItem(
        title: category.title,
        subtitle: AppLocalization.of(context).translate('exam_list.final_exam'),
        duration:
            '${category.timeSecound ~/ 60} ${AppLocalization.of(context).translate('exam_list.minutes')}',
        iconUrl: category.icon, // or category.image if icon acts as fallback
        isActive: true,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizScreen(
              category: categoryId,
              examTitle: category.title,
            ),
          ),
        ),
      );
    }).toList();

    return examItems;
  }

  List<Widget> _buildCompletedExams() {
    if (_apiExamResults.isEmpty) {
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

    // Group by category, take the latest per category
    final grouped =
        groupBy(_apiExamResults, (ExamResultItem r) => r.catId.toString());

    return grouped.entries.map((entry) {
      final categoryId = entry.key;
      final results = entry.value;
      // Sort by createdAt desc to get latest
      results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final latest = results.first;
      final categoryData =
          _categories?.firstWhereOrNull((c) => c.id.toString() == categoryId);

      return _ExamItem(
        title: categoryData?.title ?? latest.categoryTitle,
        subtitle:
            '${latest.correctAnswers}/${latest.totalQuestions} ${AppLocalization.of(context).translate('exam_list.correct')}',
        duration: '${latest.point.toStringAsFixed(0)}%',
        iconUrl: categoryData?.icon ?? '',
        isCompleted: true,
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
  const _ExamItem({
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.iconUrl,
    this.isActive = false,
    this.isCompleted = false,
    this.onTap,
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
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
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
                          Expanded(
                            child: Text(
                              duration,
                              style: TextStyle(
                                color: colorScheme.onSurface.withOpacity(0.6),
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
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
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        isCompleted ? Icons.check : Icons.play_arrow,
        color: colorScheme.primary,
        size: 20,
      ),
    );
  }
}
