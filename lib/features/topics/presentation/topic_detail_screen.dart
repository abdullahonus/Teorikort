import 'package:flutter/material.dart';
import 'package:teorikort/core/localization/app_localization.dart';
import 'package:teorikort/core/widgets/app_loading_widget.dart';

import '../../workbook/data/services/workbook_service.dart';
import '../data/models/topic.dart';
import '../data/services/topic_service.dart';

class TopicDetailScreen extends StatefulWidget {
  final Topic topic;

  const TopicDetailScreen({super.key, required this.topic});

  @override
  State<TopicDetailScreen> createState() => _TopicDetailScreenState();
}

class _TopicDetailScreenState extends State<TopicDetailScreen> {
  final TopicService _service = TopicService();
  final WorkbookService _workbookService = WorkbookService();
  late Topic _topic;
  List<dynamic> _questions = [];
  bool _isLoading = true;
  bool _isSaving = false;
  late Stopwatch _studyTimer;

  @override
  void initState() {
    super.initState();
    _topic = widget.topic;
    _studyTimer = Stopwatch()..start();
    _loadDetail();
  }

  @override
  void dispose() {
    _studyTimer.stop();
    super.dispose();
  }

  Future<void> _loadDetail() async {
    try {
      final response =
          await _service.getTopicById(_topic.id.toString(), context: context);
      if (mounted && response.data != null) {
        setState(() {
          _topic = response.data!.course;
          _questions = response.data!.questions;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error loading topic detail: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveStudyProgress() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);
    try {
      final studySeconds = _studyTimer.elapsed.inSeconds;
      await _workbookService.saveWorkbook(
        courseId: _topic.id,
        detail: 'Konu çalışma oturumu tamamlandı.',
        passed: true,
        time: studySeconds,
        context: context,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppLocalization.of(context)
                  .translate('topics.progress_saved'))),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Error saving study progress: $e');
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppLocalization.of(context)
                  .translate('topics.progress_save_error'))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return PopScope(
      canPop: !_isSaving,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        // Optionally auto-save on back, but for now we have an explicit button
        // and we prevent pop if saving.
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          backgroundColor: colorScheme.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            _topic.title,
            style: theme.textTheme.titleLarge,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            if (_isLoading || _isSaving)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: AppLoadingWidget.small(),
                ),
              ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _loadDetail,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Description badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: colorScheme.primary.withOpacity(0.15)),
                ),
                child: Text(
                  _topic.description,
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Content
              Text(
                AppLocalization.of(context).translate('topics.content'),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _topic.content,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.85),
                  height: 1.7,
                ),
              ),
              const SizedBox(height: 24),

              // Date info
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 14, color: colorScheme.onSurface.withOpacity(0.4)),
                  const SizedBox(width: 4),
                  Text(
                    '${_topic.updatedAt.day}.${_topic.updatedAt.month}.${_topic.updatedAt.year}',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Save Progress Button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed:
                      _isLoading || _isSaving ? null : _saveStudyProgress,
                  icon: _isSaving
                      ? const AppLoadingWidget.small()
                      : const Icon(Icons.check_circle_outline),
                  label: const Text('Çalışmayı Tamamla ve Kaydet'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),

              // Related Questions section (if any)
              if (_questions.isNotEmpty) ...[
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  'İlgili Sorular',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                ..._questions.map((q) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.help_outline),
                      title: Text(q['question']?.toString() ?? 'Soru'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // Navigate to question detail if needed
                      },
                    )),
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
