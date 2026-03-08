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

    return InkWell(
      onTap: () => _showDetail(context, sign),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Image.network(
                  sign.imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.warning_amber_rounded,
                      color: colorScheme.primary.withValues(alpha: 0.2),
                      size: 40),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                sign.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
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
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.all(24),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: Image.network(sign.imageUrl,
                    height: 160, fit: BoxFit.contain),
              ),
              const SizedBox(height: 24),
              Text(sign.title,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                sign.slug,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              AppHtmlText(
                htmlData: sign.description,
                style: const TextStyle(fontSize: 15, height: 1.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
