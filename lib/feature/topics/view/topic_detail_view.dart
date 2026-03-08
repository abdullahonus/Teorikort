import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teorikort/core/localization/app_localization.dart';
import 'package:teorikort/core/widgets/app_html_text.dart';
import 'package:teorikort/core/widgets/app_loading_widget.dart';
import 'package:teorikort/product/provider/service_providers.dart';

import '../../exam/model/exam_question.dart';
import '../model/topic.dart';
import '../provider/topic_provider.dart';

class TopicDetailView extends ConsumerStatefulWidget {
  final String topicId;
  final Topic? initialTopic;

  const TopicDetailView({
    super.key,
    required this.topicId,
    this.initialTopic,
  });

  @override
  ConsumerState<TopicDetailView> createState() => _TopicDetailViewState();
}

class _TopicDetailViewState extends ConsumerState<TopicDetailView> {
  late Stopwatch _studyTimer;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _studyTimer = Stopwatch()..start();
    Future.microtask(() {
      ref.read(topicProvider.notifier).loadTopicDetail(widget.topicId);
    });
  }

  @override
  void dispose() {
    _studyTimer.stop();
    super.dispose();
  }

  Future<void> _completeStudy(Topic topic) async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final repository = ref.read(workbookRepositoryProvider);
      final response = await repository.saveProgress(
        courseId: topic.id,
        detail: 'Çalışma oturumu tamamlandı.',
        passed: true,
        timeSeconds: _studyTimer.elapsed.inSeconds,
      );

      if (mounted) {
        if (response.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(AppLocalization.of(context)
                    .translate('topics.progress_saved'))),
          );
          Navigator.pop(context);
        } else {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(response.message ??
                    AppLocalization.of(context).translate('common.error'))),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppLocalization.of(context)
                  .translate('topics.system_error'))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(topicProvider);
    final detail = state.topicDetails[widget.topicId];
    final colorScheme = Theme.of(context).colorScheme;

    // Fallback to initial topic if detail is pending
    final topic = detail?.topic ?? widget.initialTopic;

    if (topic == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const AppLoadingWidget.fullscreen(),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(topicProvider.notifier).loadTopicDetail(widget.topicId),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              stretch: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  topic.title,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primaryContainer,
                        colorScheme.surface,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.menu_book_rounded,
                      size: 80,
                      color: colorScheme.primary.withValues(alpha: 0.1),
                    ),
                  ),
                ),
              ),
              actions: [
                if (state.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: AppLoadingWidget.small(),
                    ),
                  ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (topic.description.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: colorScheme.outline.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline_rounded,
                                color: colorScheme.primary, size: 24),
                            const SizedBox(width: 16),
                            Expanded(
                              child: AppHtmlText(
                                htmlData: topic.description,
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 24,
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          AppLocalization.of(context)
                              .translate('topics.content'),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    AppHtmlText(
                      htmlData: topic.content,
                      style: TextStyle(
                        fontSize: 17,
                        height: 1.7,
                        color: colorScheme.onSurface.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 48),
                    FilledButton(
                      onPressed: _isSaving ? null : () => _completeStudy(topic),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 64),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isSaving)
                            const AppLoadingWidget.small()
                          else
                            const Icon(Icons.check_circle_rounded),
                          const SizedBox(width: 12),
                          Text(
                            AppLocalization.of(context)
                                .translate('topics.complete_study')
                                .toUpperCase(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (detail != null && detail.questions.isNotEmpty) ...[
                      const SizedBox(height: 56),
                      const Divider(),
                      const SizedBox(height: 32),
                      Text(
                        AppLocalization.of(context)
                            .translate('topics.related_questions'),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ],
                ),
              ),
            ),
            if (detail != null && detail.questions.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final q = detail.questions[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: colorScheme.outline.withValues(alpha: 0.1),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color:
                                  colorScheme.secondary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.quiz_rounded,
                              color: colorScheme.secondary,
                              size: 20,
                            ),
                          ),
                          title: AppHtmlText(
                            htmlData: q.question,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () => _showQuestionDetail(context, q),
                        ),
                      );
                    },
                    childCount: detail.questions.length,
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 64)),
          ],
        ),
      ),
    );
  }

  void _showQuestionDetail(BuildContext context, ExamQuestion question) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TopicQuestionDetailSheet(question: question),
    );
  }
}

class _TopicQuestionDetailSheet extends StatelessWidget {
  final ExamQuestion question;

  const _TopicQuestionDetailSheet({required this.question});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalization.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outline.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                children: [
                  if (question.imageUrl != null &&
                      question.imageUrl!.isNotEmpty) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        question.imageUrl!,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  AppHtmlText(
                    htmlData: question.question,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ...question.options.asMap().entries.map((entry) {
                    final int index = entry.key;
                    final option = entry.value;

                    // Match logic:
                    // 1. Exact ID match (e.g., 'a' == 'a')
                    // 2. 1-based index match (e.g., 3rd option == '3')
                    // 3. 0-based index match (e.g., 1st option == '0')
                    final int? correctVal =
                        int.tryParse(question.correctAnswer);
                    final bool isCorrect = option.id ==
                            question.correctAnswer ||
                        (correctVal != null &&
                            (index + 1 == correctVal || index == correctVal));

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isCorrect
                            ? colorScheme.primary.withValues(alpha: 0.05)
                            : colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isCorrect
                              ? colorScheme.primary
                              : colorScheme.outline.withValues(alpha: 0.1),
                          width: isCorrect ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isCorrect
                                  ? colorScheme.primary
                                  : colorScheme.outline.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              option.id.toUpperCase(),
                              style: TextStyle(
                                color: isCorrect
                                    ? colorScheme.onPrimary
                                    : colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: AppHtmlText(
                              htmlData: option.text,
                              style: TextStyle(
                                color: isCorrect
                                    ? colorScheme.primary
                                    : colorScheme.onSurface,
                                fontWeight: isCorrect
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                          if (isCorrect)
                            Icon(Icons.check_circle_rounded,
                                color: colorScheme.primary, size: 24),
                        ],
                      ),
                    );
                  }),
                  if (question.explanation.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: colorScheme.outline.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.lightbulb_outline_rounded,
                                  color: colorScheme.primary, size: 20),
                              const SizedBox(width: 10),
                              Text(
                                l10n.translate('quiz.explanation'),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          AppHtmlText(
                            htmlData: question.explanation,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.6,
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
