import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teorikort/core/localization/app_localization.dart';
import 'package:teorikort/core/widgets/app_bar_widget.dart';
import 'package:teorikort/core/widgets/app_loading_widget.dart';
import 'package:teorikort/feature/exam/model/exam_result.dart';
import 'package:teorikort/feature/exam/provider/exam_provider.dart';

import 'exam_result_detail_view.dart';

class ExamResultsView extends ConsumerStatefulWidget {
  const ExamResultsView({super.key});

  @override
  ConsumerState<ExamResultsView> createState() => _ExamResultsViewState();
}

class _ExamResultsViewState extends ConsumerState<ExamResultsView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(examProvider.notifier).refresh());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(examProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalization.of(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppHeader(
        title: l10n.translate('statistics.exam_results'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(examProvider.notifier).refresh(),
        child: state.isLoading && state.history.isEmpty
            ? const AppLoadingWidget.fullscreen()
            : _buildContent(context, state.history, colorScheme),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, List<ExamResult> history, ColorScheme colorScheme) {
    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_turned_in_outlined,
                size: 64, color: colorScheme.onSurface.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            Text(AppLocalization.of(context)
                .translate('exam_list.no_completed_exams')),
          ],
        ),
      );
    }

    final grouped = groupBy(
        history,
        (ExamResult r) => r.categoryTitle.isNotEmpty
            ? r.categoryTitle
            : 'Kategori ${r.categoryId}');
    final categoryNames = grouped.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: categoryNames.length,
      itemBuilder: (context, index) {
        final catName = categoryNames[index];
        final results = grouped[catName]!;
        results.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        return _buildCategorySection(context, catName, results, colorScheme);
      },
    );
  }

  Widget _buildCategorySection(BuildContext context, String categoryName,
      List<ExamResult> results, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            categoryName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ...results.map((result) {
          final isPass = result.score >= 70;
          final color = isPass ? Colors.green : Colors.red;

          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ExamResultDetailView(resultId: result.id),
                ),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.1)),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isPass ? Icons.check : Icons.close,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${result.correctCount} Doğru / ${result.wrongCount} Yanlış',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(result.createdAt),
                          style: TextStyle(
                              fontSize: 12,
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.6)),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '%${result.score.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 16),
      ],
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
