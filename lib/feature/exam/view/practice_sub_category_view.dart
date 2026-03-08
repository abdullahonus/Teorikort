import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teorikort/core/localization/app_localization.dart';
import 'package:teorikort/core/widgets/app_bar_widget.dart';
import 'package:teorikort/core/widgets/app_loading_widget.dart';

import '../model/exam_category.dart';
import '../provider/practice_provider.dart';
import 'practice_test_view.dart';

class PracticeSubCategoryView extends ConsumerWidget {
  final ExamCategory mainCategory;

  const PracticeSubCategoryView({
    super.key,
    required this.mainCategory,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subCategoriesAsync =
        ref.watch(practiceSubCategoriesProvider(mainCategory.id.toString()));
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppHeader(
        title: mainCategory.title,
      ),
      body: subCategoriesAsync.when(
        loading: () => const AppLoadingWidget.fullscreen(),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              err.toString(),
              style: TextStyle(color: colorScheme.error),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (subCategories) {
          if (subCategories.isEmpty) {
            return Center(
              child: Text(
                  AppLocalization.of(context).translate('exam_list.no_data')),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              return ref.refresh(
                  practiceSubCategoriesProvider(mainCategory.id.toString())
                      .future);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: subCategories.length,
              itemBuilder: (context, index) {
                final subCat = subCategories[index];
                return _buildSubCategoryCard(context, subCat, colorScheme);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubCategoryCard(
      BuildContext context, ExamCategory subCat, ColorScheme colorScheme) {
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
              builder: (_) => PracticeTestView(
                subCategory: subCat,
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
                  color: colorScheme.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.list_alt,
                    color: Colors.blue), // can be customized
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  subCat.title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
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
