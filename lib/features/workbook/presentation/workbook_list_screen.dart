import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teorikort/core/localization/app_localization.dart';
import 'package:teorikort/core/widgets/app_html_text.dart';
import 'package:teorikort/core/widgets/app_loading_widget.dart';

import '../../../../feature/topics/view/topic_detail_view.dart';
import '../data/models/workbook_data.dart';
import 'provider/workbook_provider.dart';

class WorkbookListScreen extends ConsumerStatefulWidget {
  const WorkbookListScreen({super.key});

  @override
  ConsumerState<WorkbookListScreen> createState() => _WorkbookListScreenState();
}

class _WorkbookListScreenState extends ConsumerState<WorkbookListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(workbookListProvider.notifier).fetchWorkbooks());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workbookListProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalization.of(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.translate('workbook.title')),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        actions: [
          if (state.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(workbookListProvider.notifier).fetchWorkbooks(),
        child: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(WorkbookListState state) {
    if (state.isLoading && state.workbooks.isEmpty) {
      return const AppLoadingWidget.fullscreen();
    }

    if (state.error != null && state.workbooks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
                size: 48, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text(state.error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  ref.read(workbookListProvider.notifier).fetchWorkbooks(),
              child:
                  Text(AppLocalization.of(context).translate('common.retry')),
            ),
          ],
        ),
      );
    }

    if (state.workbooks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book_outlined,
                size: 64,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            Text(
                AppLocalization.of(context).translate('workbook.no_workbooks')),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.workbooks.length,
      itemBuilder: (context, index) {
        final workbook = state.workbooks[index];
        return _buildWorkbookCard(workbook);
      },
    );
  }

  Widget _buildWorkbookCard(Workbook workbook) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dismissible(
      key: Key(workbook.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: colorScheme.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title:
                Text(AppLocalization.of(context).translate('common.confirm')),
            content: Text(AppLocalization.of(context)
                .translate('workbook.delete_confirm')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                    AppLocalization.of(context).translate('common.cancel')),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  AppLocalization.of(context).translate('common.delete'),
                  style: TextStyle(color: colorScheme.error),
                ),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        ref.read(workbookListProvider.notifier).deleteWorkbook(workbook.id);
      },
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.1)),
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TopicDetailView(
                  topicId: workbook.course.id.toString(),
                  initialTopic: workbook.course,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.menu_book,
                          color: colorScheme.primary, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            workbook.course.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          AppHtmlText(
                            htmlData: workbook.course.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(workbook.passed),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoItem(Icons.timer_outlined,
                        '${(workbook.time / 60).floor()} ${AppLocalization.of(context).translate('workbook.minutes')}'),
                    _buildInfoItem(Icons.calendar_today_outlined,
                        '${workbook.updatedAt.day}.${workbook.updatedAt.month}.${workbook.updatedAt.year}'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool passed) {
    final color = passed ? Colors.green : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        passed
            ? AppLocalization.of(context).translate('workbook.completed')
            : AppLocalization.of(context).translate('workbook.in_progress'),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon,
            size: 14,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
