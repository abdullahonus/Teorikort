import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teorikort/core/localization/app_localization.dart';
import 'package:teorikort/core/widgets/app_html_text.dart';
import 'package:teorikort/core/widgets/app_loading_widget.dart';

import '../model/traffic_sign.dart';
import '../provider/topic_provider.dart';

class TrafficSignsView extends ConsumerStatefulWidget {
  const TrafficSignsView({super.key});

  @override
  ConsumerState<TrafficSignsView> createState() => _TrafficSignsViewState();
}

class _TrafficSignsViewState extends ConsumerState<TrafficSignsView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(trafficSignProvider.notifier).loadSigns());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      ref.read(trafficSignProvider.notifier).loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(trafficSignProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalization.of(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.translate('signs.title')),
        actions: [
          if (state.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: AppLoadingWidget.small(),
              ),
            ),
        ],
      ),
      body: state.isLoading && state.signs.isEmpty
          ? const AppLoadingWidget.fullscreen()
          : RefreshIndicator(
              onRefresh: () => ref.read(trafficSignProvider.notifier).refresh(),
              child: state.signs.isEmpty
                  ? Center(child: Text(l10n.translate('signs.no_data')))
                  : GridView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.82,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: state.signs.length,
                      itemBuilder: (context, index) =>
                          _TrafficSignCard(sign: state.signs[index]),
                    ),
            ),
    );
  }
}

class _TrafficSignCard extends StatelessWidget {
  final TrafficSign sign;

  const _TrafficSignCard({required this.sign});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: InkWell(
        onTap: () => _showDetail(context, sign),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                color:
                    colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                padding: const EdgeInsets.all(16),
                child: sign.imageUrl.isNotEmpty
                    ? Image.network(
                        sign.imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.warning_amber_rounded,
                            color: colorScheme.primary.withValues(alpha: 0.2),
                            size: 48),
                      )
                    : Icon(Icons.warning_amber_rounded,
                        color: colorScheme.primary.withValues(alpha: 0.2),
                        size: 48),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                sign.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context, TrafficSign sign) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TrafficSignDetailSheet(sign: sign),
    );
  }
}

class _TrafficSignDetailSheet extends ConsumerWidget {
  final TrafficSign sign;

  const _TrafficSignDetailSheet({required this.sign});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync =
        ref.watch(trafficSignDetailProvider(sign.id.toString()));
    final colorScheme = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24),
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
            const SizedBox(height: 24),
            Expanded(
              child: detailAsync.when(
                loading: () => const Center(child: AppLoadingWidget.small()),
                error: (err, stack) => _buildDetailContent(
                    context, sign, colorScheme, scrollController),
                data: (detail) => _buildDetailContent(
                    context, detail, colorScheme, scrollController),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailContent(BuildContext context, TrafficSign data,
      ColorScheme colorScheme, ScrollController scrollController) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(24),
            ),
            child: data.imageUrl.isNotEmpty
                ? Image.network(
                    data.imageUrl,
                    height: 180,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.warning_amber_rounded,
                      size: 80,
                      color: colorScheme.primary.withValues(alpha: 0.1),
                    ),
                  )
                : Icon(
                    Icons.warning_amber_rounded,
                    size: 80,
                    color: colorScheme.primary.withValues(alpha: 0.1),
                  ),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          data.title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        if (data.slug.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              data.slug,
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 24),
        AppHtmlText(
          htmlData: data.description.isEmpty
              ? 'Bu işaret için henüz detaylı bir açıklama bulunmamaktadır.'
              : data.description,
          style: TextStyle(
            fontSize: 16,
            height: 1.6,
            color: colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}
