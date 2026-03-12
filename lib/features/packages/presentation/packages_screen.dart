import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teorikort/core/localization/app_localization.dart';
import 'package:teorikort/core/widgets/app_bar_widget.dart';
import 'package:teorikort/core/widgets/app_loading_widget.dart';

import '../data/models/package.dart';
import 'providers/packages_provider.dart';

class PackagesScreen extends ConsumerStatefulWidget {
  const PackagesScreen({super.key});

  @override
  ConsumerState<PackagesScreen> createState() => _PackagesScreenState();
}

class _PackagesScreenState extends ConsumerState<PackagesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(packagesProvider.notifier).fetchPackages();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalization.of(context);
    final state = ref.watch(packagesProvider);

    ref.listen(packagesProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        _showErrorSnackBar(next.error!);
        ref.read(packagesProvider.notifier).clearError();
      } else if (previous?.isPurchasing == true && next.isPurchasing == false) {
        if (next.purchasingStatus == 'PAID') {
          _showSuccessSnackBar(l10n.translate('packages.payment_success'));
        } else if (next.purchasingStatus == 'DECLINED') {
          _showErrorSnackBar(l10n.translate('packages.payment_declined'));
        } else if (next.purchasingStatus == 'ERROR' && next.error == null) {
          _showErrorSnackBar(l10n.translate('packages.payment_failed'));
        }
      }
    });

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppHeader(
        title: l10n.translate('packages.title'),
      ),
      body: Stack(
        children: [
          _buildBody(state),
          if (state.isPurchasing)
            Container(
              color: Colors.black.withValues(alpha: 0.85),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/loading/payment.gif',
                        width: 180,
                        height: 180,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        state.purchasingStatus ??
                            l10n.translate('packages.payment_processing'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.translate('packages.payment_waiting'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(PackagesState state) {
    if (state.isLoading) {
      return const AppLoadingWidget.fullscreen();
    }

    if (state.error != null && state.packages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .errorContainer
                      .withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.error_outline,
                    size: 64, color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: 24),
              Text(
                state.error!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () =>
                    ref.read(packagesProvider.notifier).fetchPackages(),
                icon: const Icon(Icons.refresh),
                label:
                    Text(AppLocalization.of(context).translate('common.retry')),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (state.packages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined,
                size: 64, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              AppLocalization.of(context).translate('common.no_data'),
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.outline),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(packagesProvider.notifier).fetchPackages(),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          if (state.activePackage != null) ...[
            _buildActivePackageCard(state),
            const SizedBox(height: 16),
            Text(
              AppLocalization.of(context).translate('packages.other_packages'),
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
          ],
          ...state.packages.map((package) => _buildPackageCard(package)),
        ],
      ),
    );
  }

  Widget _buildActivePackageCard(PackagesState state) {
    final activePackage = state.activePackage!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isActive = activePackage.status == 1;
    final isRejected = activePackage.status == 2;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isActive
                ? Colors.green.withValues(alpha: 0.5)
                : (isRejected
                    ? Colors.red.withValues(alpha: 0.5)
                    : Colors.orange.withValues(alpha: 0.5))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalization.of(context)
                    .translate('packages.active_package'),
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.green.withValues(alpha: 0.1)
                      : (isRejected
                          ? Colors.red.withValues(alpha: 0.1)
                          : Colors.orange.withValues(alpha: 0.1)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  activePackage.statusText,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: isActive
                        ? Colors.green
                        : (isRejected ? Colors.red : Colors.orange),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (isActive || activePackage.status == 0) ...[
            Text(
              '${AppLocalization.of(context).translate('packages.remaining_use')}: ${activePackage.limitUse}',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              '${AppLocalization.of(context).translate('packages.end_date')}: ${activePackage.expiresAt.toString().split(' ')[0]}',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            if (!activePackage.expired)
              Text(
                '${AppLocalization.of(context).translate('packages.remaining_time')}: ${activePackage.remainingDays.toInt()} ${AppLocalization.of(context).translate('packages.days')} ${activePackage.remainingHours} ${AppLocalization.of(context).translate('packages.hours')}',
                style: theme.textTheme.bodyMedium,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildPackageCard(Package package) {
    final l10n = AppLocalization.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isPremium = package.price > 0;
    final canPurchase = package.canPurchase;
    final isActive = package.isActive;
    final isPurchasing = ref.watch(packagesProvider).isPurchasing;

    Widget card = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: isPremium
            ? LinearGradient(
                colors: [
                  colorScheme.primary,
                  colorScheme.primary.withValues(alpha: 0.8),
                  colorScheme.secondary.withValues(alpha: 0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isPremium
            ? null
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        border: isPremium
            ? null
            : Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: (isPremium ? colorScheme.primary : colorScheme.shadow)
                .withValues(alpha: isPremium ? 0.3 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            if (isPremium) ...[
              Positioned(
                right: -40,
                top: -40,
                child: CircleAvatar(
                  radius: 70,
                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ],
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: canPurchase ? () => _showPackageDetail(package) : null,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (isPremium)
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 6),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      l10n.translate('packages.premium'),
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1),
                                    ),
                                  ),
                                Text(
                                  package.name,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: isPremium
                                        ? Colors.white
                                        : colorScheme.onSurface,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isPremium
                                      ? l10n.translate('packages.premium')
                                      : l10n.translate('packages.free_label'),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: isPremium
                                        ? Colors.white70
                                        : colorScheme.primary,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                package.price == 0
                                    ? l10n.translate('packages.free_label')
                                    : '₺${package.price.toInt()}',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: isPremium
                                      ? Colors.white
                                      : colorScheme.primary,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              if (package.price > 0)
                                Text(
                                  AppLocalization.of(context)
                                      .translate('packages.one_time_payment'),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontSize: 10,
                                    color: isPremium
                                        ? Colors.white70
                                        : colorScheme.onSurfaceVariant,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Divider(
                          height: 1,
                          color: isPremium
                              ? Colors.white24
                              : colorScheme.outline.withValues(alpha: 0.1)),
                      const SizedBox(height: 12),
                      Text(
                        '${package.durationMonth} ${AppLocalization.of(context).translate('packages.months_package_desc')}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isPremium
                              ? Colors.white.withValues(alpha: 0.9)
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: (!canPurchase || isPurchasing)
                              ? null
                              : () => ref
                                  .read(packagesProvider.notifier)
                                  .purchasePackage(
                                      package.id,
                                      AppLocalization.of(context).translate(
                                          'packages.payment_processing')),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isPremium ? Colors.white : colorScheme.primary,
                            foregroundColor:
                                isPremium ? colorScheme.primary : Colors.white,
                            disabledBackgroundColor: isPremium
                                ? Colors.white.withValues(alpha: 0.4)
                                : colorScheme.onSurface.withValues(alpha: 0.12),
                            disabledForegroundColor: isPremium
                                ? colorScheme.primary.withValues(alpha: 0.5)
                                : colorScheme.onSurface.withValues(alpha: 0.38),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            elevation: isPremium && canPurchase ? 0 : 1,
                          ),
                          child: Text(
                            isActive
                                ? l10n.translate('packages.current_plan')
                                : (package.price == 0
                                    ? l10n.translate('packages.start_free')
                                    : l10n.translate('packages.upgrade_now')),
                            style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                                letterSpacing: 0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (!canPurchase) {
      card = ColorFiltered(
        colorFilter: const ColorFilter.matrix(<double>[
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0,
          0,
          0,
          0.6,
          0,
        ]),
        child: card,
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Stack(
        children: [
          card,
          if (isActive)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade600,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle,
                        color: Colors.white, size: 10),
                    const SizedBox(width: 4),
                    Text(
                      AppLocalization.of(context)
                          .translate('packages.active_package')
                          .toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showPackageDetail(Package package) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isPremium = package.price > 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: ListView(
            controller: controller,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outline.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          package.name,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isPremium ? 'PREMIUM' : 'FREE',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: isPremium
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    package.price == 0 ? 'FREE' : '₺${package.price.toInt()}',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: isPremium
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Divider(color: colorScheme.outline.withValues(alpha: 0.1)),
              const SizedBox(height: 24),
              Text(
                '${package.durationMonth} ${AppLocalization.of(context).translate('packages.months_package_desc')}',
                style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.5, color: colorScheme.onSurfaceVariant),
              ),
              if (package.statusText != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: colorScheme.primary, size: 18),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          package.statusText!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: ref.watch(packagesProvider).isPurchasing
                      ? null
                      : () {
                          Navigator.pop(context);
                          ref.read(packagesProvider.notifier).purchasePackage(
                              package.id,
                              AppLocalization.of(context)
                                  .translate('packages.payment_processing'));
                        },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    ref.watch(packagesProvider).isPurchasing
                        ? 'PROCESSING...'
                        : (package.price == 0
                            ? 'START NOW'
                            : 'GET PREMIUM ACCESS'),
                    style: const TextStyle(
                        fontWeight: FontWeight.w900, fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  AppLocalization.of(context).translate('common.close'),
                  style: TextStyle(
                      color: colorScheme.outline,
                      fontWeight: FontWeight.bold,
                      fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
