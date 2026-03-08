import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teorikort/core/localization/app_localization.dart';
import 'package:teorikort/core/widgets/app_html_text.dart';
import 'package:teorikort/core/widgets/app_loading_widget.dart';

import '../../../../features/workbook/presentation/workbook_list_screen.dart';
import '../model/topic.dart';
import '../provider/topic_provider.dart';
import 'topic_detail_view.dart';

class TopicsView extends ConsumerStatefulWidget {
  const TopicsView({super.key});

  @override
  ConsumerState<TopicsView> createState() => _TopicsViewState();
}

class _TopicsViewState extends ConsumerState<TopicsView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(topicProvider.notifier).loadTopics());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(topicProvider);
    final colorScheme = Theme.of(context).colorScheme;

    if (state.isLoading && state.topics.isEmpty) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: const AppLoadingWidget.fullscreen(),
      );
    }

    if (state.error != null && state.topics.isEmpty) {
      return _buildErrorState(context, state.error!);
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              AppLocalization.of(context).translate('topics.subtitle'),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(topicProvider.notifier).refresh(),
              child: ListView.separated(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                itemCount: state.topics.length + 1,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  if (index == 0) return _buildWorkbookCard(context);
                  return _buildTopicCard(context, state.topics[index - 1]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkbookCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalization.of(context);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const WorkbookListScreen()),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.secondary,
                colorScheme.secondary.withValues(alpha: 0.85)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.menu_book_rounded,
                    color: Colors.white, size: 32),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.translate('workbook.title'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.translate('workbook.subtitle'),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.white, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopicCard(BuildContext context, Topic topic) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TopicDetailView(
                  topicId: topic.id.toString(), initialTopic: topic),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(Icons.menu_book_rounded,
                      color: colorScheme.primary, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topic.title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      AppHtmlText(
                        htmlData: topic.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: colorScheme.onSurface.withValues(alpha: 0.15),
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    final l10n = AppLocalization.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.menu_book_rounded, size: 64, color: Colors.grey),
            const SizedBox(height: 20),
            Text(error,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => ref.read(topicProvider.notifier).loadTopics(),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.translate('common.retry')),
            ),
          ],
        ),
      ),
    );
  }
}
