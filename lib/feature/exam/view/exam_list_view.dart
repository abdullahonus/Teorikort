import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teorikort/core/localization/app_localization.dart';
import 'package:teorikort/core/widgets/app_loading_widget.dart';

import '../model/exam_category.dart';
import '../provider/exam_provider.dart';
import 'exam_session_view.dart';

class ExamListView extends ConsumerWidget {
  const ExamListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(examProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        title: Text(
          AppLocalization.of(context).translate('exam_list.screen_title'),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        foregroundColor: colorScheme.onSurface,
      ),
      body: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 60),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: RefreshIndicator(
              onRefresh: () => ref.read(examProvider.notifier).refresh(),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
                children: [
                  if (state.categories.length > 1)
                    _buildExamSection(
                      context,
                      AppLocalization.of(context)
                          .translate('exam_list.active_exams'),
                      _buildActiveExams(context, ref, state.categories)
                          .sublist(1),
                    ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: SizedBox(
              height: 140,
              child: Center(
                child: state.isLoading && state.categories.isEmpty
                    ? const AppLoadingWidget()
                    : (state.categories.isEmpty
                        ? Text(AppLocalization.of(context)
                            .translate('exam_list.no_data'))
                        : _buildActiveExams(context, ref, state.categories)
                            .first),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExamSection(
      BuildContext context, String title, List<Widget> items) {
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

  List<Widget> _buildActiveExams(
      BuildContext context, WidgetRef ref, List<ExamCategory> categories) {
    return categories.map((category) {
      return _ExamItem(
        title: category.title,
        subtitle: AppLocalization.of(context).translate('exam_list.final_exam'),
        duration:
            '${category.timeSeconds ~/ 60} ${AppLocalization.of(context).translate('exam_list.minutes')}',
        iconUrl: category.imageUrl,
        isActive: true,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ExamSessionView(
                categoryId: category.id.toString(),
                examTitle: category.title,
                initialSeconds: category.timeSeconds,
                examType: 'final',
              ),
            ),
          );
        },
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
  final VoidCallback? onTap;

  const _ExamItem({
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.iconUrl,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
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
              children: [
                _buildIcon(context),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.access_time,
                              size: 14,
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.6)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              duration,
                              style: TextStyle(
                                  color: colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                  fontSize: 14),
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
        color: colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: iconUrl.startsWith('http')
            ? Image.network(
                iconUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Icon(Icons.school, color: colorScheme.primary),
              )
            : Icon(Icons.school, color: colorScheme.primary),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.play_arrow,
        color: colorScheme.primary,
        size: 20,
      ),
    );
  }
}
