import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teorikort/core/localization/app_localization.dart';
import 'package:teorikort/core/widgets/app_bar_widget.dart';
import 'package:teorikort/core/widgets/app_html_text.dart';
import 'package:teorikort/core/widgets/app_loading_widget.dart';

import '../model/exam_category.dart';
import '../provider/exam_provider.dart';
import 'practice_sub_category_view.dart';

class PracticeMainCategoryView extends ConsumerStatefulWidget {
  const PracticeMainCategoryView({super.key});

  @override
  ConsumerState<PracticeMainCategoryView> createState() =>
      _PracticeMainCategoryViewState();
}

class _PracticeMainCategoryViewState
    extends ConsumerState<PracticeMainCategoryView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(examProvider.notifier).loadExams());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(examProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppHeader(
        title: AppLocalization.of(context).translate('home.practice_exam'),
      ),
      body: state.isLoading && state.categories.isEmpty
          ? const AppLoadingWidget.fullscreen()
          : RefreshIndicator(
              onRefresh: () => ref.read(examProvider.notifier).refresh(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.categories.length,
                itemBuilder: (context, index) {
                  final category = state.categories[index];
                  return _buildCategoryCard(context, category);
                },
              ),
            ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, ExamCategory category) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      color: colorScheme.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PracticeSubCategoryView(
                mainCategory: category,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: category.imageUrl.isNotEmpty &&
                        category.imageUrl.startsWith('http')
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          category.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Icon(Icons.category, color: colorScheme.primary),
                        ),
                      )
                    : Icon(Icons.category, color: colorScheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    if (category.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      AppHtmlText(
                        htmlData: category.description,
                        style: TextStyle(
                            color:
                                colorScheme.onSurface.withValues(alpha: 0.7)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
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
}
