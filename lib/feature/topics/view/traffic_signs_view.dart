import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teorikort/core/localization/app_localization.dart';
import 'package:teorikort/core/widgets/app_bar_widget.dart';
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
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(trafficSignProvider.notifier).loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(trafficSignProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalization.of(context);

    // Telefonun geri tuşu için mantık: Seçili kategori varsa listeye dön, yoksa sayfayı kapat.
    return PopScope(
      canPop: state.selectedCategory == null,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          ref.read(trafficSignProvider.notifier).selectCategory(null);
        }
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppHeader(
          title: state.selectedCategory != null
              ? state.selectedCategory!.title
              : l10n.translate('signs.title'),
          showBackButton: true,
          onBackPress: () {
            // Eğer bir kategori seçiliyse, ana kategori listesine dön
            if (state.selectedCategory != null) {
              ref.read(trafficSignProvider.notifier).selectCategory(null);
            } else {
              // Değilse normal şekilde önceki sayfaya (örneğin Home) git
              Navigator.pop(context);
            }
          },
        ),
        body: state.isLoading && state.categories.isEmpty
            ? const AppLoadingWidget.fullscreen()
            : RefreshIndicator(
                onRefresh: () =>
                    ref.read(trafficSignProvider.notifier).refresh(),
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    if (state.categories.isEmpty && !state.isLoading)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                            child: Text(l10n.translate('signs.no_data'))),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.85,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              if (state.selectedCategory == null) {
                                // 1) Ana Liste (Kategoriler) Modu
                                final cat = state.categories[index];
                                return _TrafficSignCard(
                                  sign: cat,
                                  onTapAction: () => ref
                                      .read(trafficSignProvider.notifier)
                                      .selectCategory(cat),
                                );
                              } else {
                                // 2) Seçili Kategori altındaki işaretleri gösterme (Detay Listesi) Modu
                                final sign =
                                    state.selectedCategory!.children[index];
                                return _TrafficSignCard(sign: sign);
                              }
                            },
                            childCount: state.selectedCategory == null
                                ? state.categories.length
                                : state.selectedCategory!.children.length,
                          ),
                        ),
                      ),

                    // Listenin en altına loading indikatörü
                    if (state.isLoading && state.categories.isNotEmpty)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: AppLoadingWidget.small(),
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Tekil Kart (Hem Ana Kategori hem de Alt İşaret için Dinamik)
// ─────────────────────────────────────────────────────────────
class _TrafficSignCard extends StatelessWidget {
  final TrafficSign sign;
  // onTapAction girilmişse (kategoriyse), yaprağı açmak yerine kategori içine girer
  final VoidCallback? onTapAction;

  const _TrafficSignCard({required this.sign, this.onTapAction});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: InkWell(
        onTap: onTapAction ?? () => _showDetail(context, sign),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.03),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.all(16),
                child: sign.imageUrl.isNotEmpty
                    ? Image.network(
                        sign.imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => _FallbackIcon(),
                      )
                    : _FallbackIcon(),
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
                  fontWeight: FontWeight.w600,
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

class _FallbackIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.image_not_supported_outlined,
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
      size: 40,
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Alt İşarete tıkıldığında açılan Pop-Up detay sayfası
// ─────────────────────────────────────────────────────────────
class _TrafficSignDetailSheet extends ConsumerWidget {
  final TrafficSign sign;

  const _TrafficSignDetailSheet({required this.sign});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

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
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
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
              child: _buildDetailContent(
                  context, sign, colorScheme, scrollController),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailContent(
    BuildContext context,
    TrafficSign data,
    ColorScheme colorScheme,
    ScrollController scrollController,
  ) {
    final description = data.descriptionText;

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 48),
      children: [
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(28),
          ),
          child: data.imageUrl.isNotEmpty
              ? Image.network(
                  data.imageUrl,
                  height: 160,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.image_not_supported_outlined,
                    size: 80,
                    color: colorScheme.primary.withValues(alpha: 0.1),
                  ),
                )
              : Icon(Icons.warning_amber_rounded,
                  size: 80, color: colorScheme.primary.withValues(alpha: 0.1)),
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
        const SizedBox(height: 12),
        if (data.slug.isNotEmpty)
          Wrap(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
            ],
          ),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 24),
        AppHtmlText(
          htmlData: description.isEmpty ? 'Açıklama bulunamadı.' : description,
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
