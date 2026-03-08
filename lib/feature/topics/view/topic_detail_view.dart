import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teorikort/core/localization/app_localization.dart';
import 'package:teorikort/core/widgets/app_html_text.dart';
import 'package:teorikort/core/widgets/app_loading_widget.dart';
import 'package:teorikort/features/reports/data/services/report_service.dart';
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

  static Future<void> showReportDialog(
      BuildContext context, String questionId) async {
    final TextEditingController reportController = TextEditingController();
    final l10n = AppLocalization.of(context);
    final reportService = ReportService();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(l10n.translate('report.title')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.translate('report.description')),
            const SizedBox(height: 16),
            TextField(
              controller: reportController,
              maxLines: 3,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: l10n.translate('report.hint'),
                hintStyle: const TextStyle(fontSize: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.translate('report.cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              if (reportController.text.trim().isEmpty) return;

              final response = await reportService.reportQuestion(
                questionId: questionId,
                description: reportController.text.trim(),
                context: context,
              );

              if (context.mounted) {
                Navigator.pop(context);
                if (response.success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.translate('report.success')),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                }
              }
            },
            child: Text(l10n.translate('report.submit')),
          ),
        ],
      ),
    );
  }
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

    final topic = detail?.topic ?? widget.initialTopic;

    if (topic == null) {
      return const Scaffold(
        body: AppLoadingWidget.fullscreen(),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(topicProvider.notifier).loadTopicDetail(widget.topicId),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 240,
              pinned: true,
              stretch: true,
              leading: Center(
                child: CircleAvatar(
                  backgroundColor: colorScheme.surface.withValues(alpha: 0.8),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_rounded,
                        color: colorScheme.onSurface),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  topic.title,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                centerTitle: true,
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
                      size: 100,
                      color: colorScheme.primary.withValues(alpha: 0.05),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (topic.description.isNotEmpty) ...[
                      _buildDescriptionCard(context, colorScheme, topic),
                      const SizedBox(height: 32),
                    ],
                    _buildSectionHeader(context, colorScheme, 'topics.content'),
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
                    _buildCompleteButton(context, topic),
                    if (detail != null && detail.questions.isNotEmpty) ...[
                      const SizedBox(height: 56),
                      const Divider(),
                      const SizedBox(height: 32),
                      _buildSectionHeader(
                        context,
                        colorScheme,
                        'topics.related_questions',
                        icon: Icons.quiz_outlined,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ],
                ),
              ),
            ),
            if (detail != null)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildQuestionItem(
                        context, colorScheme, detail.questions[index]),
                    childCount: detail.questions.length,
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionCard(
      BuildContext context, ColorScheme colorScheme, Topic topic) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_rounded,
                  color: colorScheme.primary, size: 20),
              const SizedBox(width: 10),
              Text(
                AppLocalization.of(context).translate('common.description'),
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
            htmlData: topic.description,
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.8),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, ColorScheme colorScheme, String key,
      {IconData? icon}) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, color: colorScheme.primary, size: 24),
          const SizedBox(width: 12),
        ] else ...[
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Text(
          AppLocalization.of(context).translate(key),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildCompleteButton(BuildContext context, Topic topic) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: FilledButton(
        onPressed: _isSaving ? null : () => _completeStudy(topic),
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 64),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
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
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionItem(
      BuildContext context, ColorScheme colorScheme, ExamQuestion q) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colorScheme.secondary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.help_outline_rounded,
              color: colorScheme.secondary, size: 20),
        ),
        title: AppHtmlText(
          htmlData: q.question,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Icon(Icons.chevron_right_rounded,
            color: colorScheme.outline.withValues(alpha: 0.5)),
        onTap: () => _showQuestionDetail(context, q),
      ),
    );
  }

  void _showQuestionDetail(BuildContext context, ExamQuestion question) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TopicQuestionDetailSheet(
        question: question,
        onReport: (qId) => TopicDetailView.showReportDialog(context, qId),
      ),
    );
  }
}

class _TopicQuestionDetailSheet extends StatelessWidget {
  final ExamQuestion question;
  final Function(String) onReport;

  const _TopicQuestionDetailSheet({
    required this.question,
    required this.onReport,
  });

  String _formatImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    return 'https://teorikort.artratechs.com/public/uploads/questions/$url';
  }

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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            _buildHandle(context, colorScheme, l10n),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
                children: [
                  if (question.imageUrl != null &&
                      question.imageUrl!.isNotEmpty) ...[
                    _buildQuestionImage(colorScheme),
                    const SizedBox(height: 32),
                  ],
                  AppHtmlText(
                    htmlData: question.question,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.5,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ...question.options.asMap().entries.map((entry) =>
                      _buildOptionItem(context, colorScheme, entry.key,
                          entry.value, question.correctAnswer)),
                  if (question.explanation.isNotEmpty)
                    _buildExplanationCard(colorScheme, l10n),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle(
      BuildContext context, ColorScheme colorScheme, AppLocalization l10n) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: colorScheme.outline.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Positioned(
          right: 8,
          top: 0,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.report_gmailerrorred_outlined,
                    color: colorScheme.error, size: 22),
                tooltip: l10n.translate('report.title'),
                onPressed: () {
                  Navigator.pop(context);
                  onReport(question.id);
                },
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 24),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionImage(ColorScheme colorScheme) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Image.network(
        _formatImageUrl(question.imageUrl),
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Container(
          height: 150,
          color: colorScheme.surfaceContainerHighest,
          child: Icon(Icons.broken_image_outlined, color: colorScheme.outline),
        ),
      ),
    );
  }

  Widget _buildOptionItem(BuildContext context, ColorScheme colorScheme,
      int index, ExamOption option, String correctAnswer) {
    final int? correctVal = int.tryParse(correctAnswer);
    final bool isCorrect = option.id == correctAnswer ||
        (correctVal != null &&
            (index + 1 == correctVal || index == correctVal));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isCorrect
            ? colorScheme.primary.withValues(alpha: 0.05)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
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
                color:
                    isCorrect ? colorScheme.onPrimary : colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: AppHtmlText(
              htmlData: option.text,
              style: TextStyle(
                color: isCorrect ? colorScheme.primary : colorScheme.onSurface,
                fontWeight: isCorrect ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
              ),
            ),
          ),
          if (isCorrect)
            const Icon(Icons.check_circle_rounded,
                color: Colors.green, size: 24),
        ],
      ),
    );
  }

  Widget _buildExplanationCard(ColorScheme colorScheme, AppLocalization l10n) {
    return Container(
      margin: const EdgeInsets.only(top: 32),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tips_and_updates_rounded,
                  color: colorScheme.primary, size: 20),
              const SizedBox(width: 10),
              Text(
                l10n.translate('quiz.explanation'),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppHtmlText(
            htmlData: question.explanation,
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
