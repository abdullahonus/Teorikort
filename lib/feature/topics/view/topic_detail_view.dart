import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teorikort/core/localization/app_localization.dart';
import 'package:teorikort/core/widgets/app_html_text.dart';
import 'package:teorikort/core/widgets/app_loading_widget.dart';
import 'package:teorikort/product/provider/service_providers.dart';

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
      appBar: AppBar(
        title: Text(topic.title),
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
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(topicProvider.notifier).loadTopicDetail(widget.topicId),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.2)),
              ),
              child: AppHtmlText(
                htmlData: topic.description,
                style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: colorScheme.primary,
                    fontSize: 14),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              AppLocalization.of(context).translate('topics.content'),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            AppHtmlText(
              htmlData: topic.content,
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isSaving ? null : () => _completeStudy(topic),
                icon: _isSaving
                    ? const AppLoadingWidget.small()
                    : const Icon(Icons.check_circle_outline),
                label: Text(AppLocalization.of(context)
                    .translate('topics.complete_study')),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            if (detail != null && detail.questions.isNotEmpty) ...[
              const SizedBox(height: 40),
              const Divider(),
              const SizedBox(height: 20),
              Text(
                AppLocalization.of(context)
                    .translate('topics.related_questions'),
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...detail.questions.map((q) => ListTile(
                    leading: const Icon(Icons.help_outline),
                    title: Text(q['question']?.toString() ?? ''),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  )),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
