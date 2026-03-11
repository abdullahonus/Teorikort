import 'package:flutter/material.dart';
import 'package:teorikort/core/localization/app_localization.dart';
import 'package:teorikort/core/widgets/app_bar_widget.dart';
import 'package:teorikort/core/widgets/app_loading_widget.dart';

import '../data/models/active_package.dart';
import '../data/models/package.dart';
import '../data/services/package_service.dart';

class PackagesScreen extends StatefulWidget {
  const PackagesScreen({super.key});

  @override
  State<PackagesScreen> createState() => _PackagesScreenState();
}

class _PackagesScreenState extends State<PackagesScreen> {
  final PackageService _packageService = PackageService();
  List<Package> _packages = [];
  ActivePackage? _activePackage;
  bool _isLoading = true;
  bool _isPurchasing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchPackages();
  }

  Future<void> _fetchPackages() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final responseFuture = _packageService.getPackages(context: context);
      final activeRespFuture =
          _packageService.getActivePackage(context: context);

      final results = await Future.wait([responseFuture, activeRespFuture]);

      if (mounted) {
        setState(() {
          _packages = (results[0].data as List<dynamic>?)
                  ?.map((e) => e as Package)
                  .toList() ??
              [];
          _activePackage = results[1].data as ActivePackage?;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalization.of(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppHeader(
        title: l10n.translate('packages.title'),
      ),
      body: Stack(
        children: [
          _buildBody(),
          if (_isPurchasing)
            Container(
              color: Colors.black45,
              child: const Center(
                child: AppLoadingWidget(size: 80),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const AppLoadingWidget.fullscreen();
    }

    if (_errorMessage != null) {
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
                _errorMessage!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _fetchPackages,
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

    if (_packages.isEmpty) {
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

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      children: [
        if (_activePackage != null) ...[
          _buildActivePackageCard(),
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
        ..._packages.map((package) => _buildPackageCard(package)),
      ],
    );
  }

  Widget _buildActivePackageCard() {
    if (_activePackage == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isActive = _activePackage!.status == 1;
    final isRejected = _activePackage!.status == 2;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(24),
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
                  _activePackage!.statusText,
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
          const SizedBox(height: 16),
          if (isActive || _activePackage!.status == 0) ...[
            Text(
              '${AppLocalization.of(context).translate('packages.remaining_use')}: ${_activePackage!.limitUse}',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '${AppLocalization.of(context).translate('packages.end_date')}: ${_activePackage!.expiresAt.toString().split(' ')[0]}',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            if (!_activePackage!.expired)
              Text(
                '${AppLocalization.of(context).translate('packages.remaining_time')}: ${_activePackage!.remainingDays.toInt()} ${AppLocalization.of(context).translate('packages.days')} ${_activePackage!.remainingHours} ${AppLocalization.of(context).translate('packages.hours')}',
                style: theme.textTheme.bodyMedium,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildPackageCard(Package package) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isPremium = package.price > 0;
    final canPurchase = package.canPurchase;
    final isActive = package.isActive;

    Widget card = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
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
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            if (isPremium) ...[
              Positioned(
                right: -30,
                top: -30,
                child: CircleAvatar(
                  radius: 80,
                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              Positioned(
                left: -20,
                bottom: -40,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ],
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: canPurchase ? () => _showPackageDetail(package) : null,
                child: Padding(
                  padding: const EdgeInsets.all(20),
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
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      'PREMIUM',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1),
                                    ),
                                  ),
                                Text(
                                  package.name,
                                  style:
                                      theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: isPremium
                                        ? Colors.white
                                        : colorScheme.onSurface,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isPremium
                                        ? Colors.white.withValues(alpha: 0.15)
                                        : colorScheme.primary
                                            .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    isPremium ? 'PREMIUM' : 'FREE',
                                    style:
                                        theme.textTheme.labelMedium?.copyWith(
                                      color: isPremium
                                          ? Colors.white
                                          : colorScheme.primary,
                                      fontWeight: FontWeight.w800,
                                    ),
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
                                    ? 'FREE'
                                    : '₺${package.price.toInt()}',
                                style: theme.textTheme.headlineLarge?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: isPremium
                                      ? Colors.white
                                      : colorScheme.primary,
                                  letterSpacing: -1,
                                ),
                              ),
                              if (package.price > 0)
                                Text(
                                  AppLocalization.of(context)
                                      .translate('packages.one_time_payment'),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: isPremium
                                        ? Colors.white70
                                        : colorScheme.onSurfaceVariant,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Divider(
                          color: isPremium
                              ? Colors.white24
                              : colorScheme.outline.withValues(alpha: 0.1)),
                      const SizedBox(height: 16),
                      Text(
                        '${package.durationMonth} ${AppLocalization.of(context).translate('packages.months_package_desc')}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isPremium
                              ? Colors.white.withValues(alpha: 0.9)
                              : colorScheme.onSurfaceVariant,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: (!canPurchase || _isPurchasing)
                              ? null
                              : () => _handlePurchase(package),
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
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            elevation: isPremium && canPurchase ? 0 : 2,
                            shadowColor:
                                colorScheme.primary.withValues(alpha: 0.3),
                          ),
                          child: Text(
                            isActive
                                ? AppLocalization.of(context)
                                    .translate('packages.current_plan')
                                : (package.price == 0
                                    ? 'START FOR FREE'
                                    : 'UPGRADE NOW'),
                            style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
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
      margin: const EdgeInsets.only(bottom: 16),
      child: Stack(
        children: [
          card,
          if (isActive)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.shade600,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle,
                        color: Colors.white, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      AppLocalization.of(context)
                          .translate('packages.active_package')
                          .toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
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

  Future<void> _handlePurchase(Package package) async {
    if (_isPurchasing) return;

    setState(() => _isPurchasing = true);

    try {
      final response = await _packageService.createPayment(package.id);
      if (mounted) {
        setState(() => _isPurchasing = false);
        if (response.success && response.data != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text(response.message ?? 'Ödeme başlatıldı')),
                ],
              ),
              backgroundColor: Colors.green.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.all(16),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Text(response.message ?? 'Ödeme başlatılamadı')),
                ],
              ),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isPurchasing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
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
        initialChildSize: 0.6,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
          ),
          padding: const EdgeInsets.fromLTRB(28, 12, 28, 28),
          child: ListView(
            controller: controller,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 6,
                  decoration: BoxDecoration(
                    color: colorScheme.outline.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          package.name,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isPremium ? 'PREMIUM' : 'FREE',
                          style: theme.textTheme.labelLarge?.copyWith(
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
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: isPremium
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                AppLocalization.of(context).translate('packages.features'),
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              Text(
                '${package.durationMonth} Aylık Eğitim Paketi',
                style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.6, color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              _buildFeatureItem(Icons.verified_user_rounded,
                  'Full access to all topics & subtopics'),
              _buildFeatureItem(
                  Icons.analytics_rounded, 'Detailed AI-powered statistics'),
              _buildFeatureItem(
                  Icons.offline_bolt_rounded, 'Offline study mode enabled'),
              _buildFeatureItem(
                  Icons.support_agent_rounded, 'Priority technical support'),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isPurchasing
                      ? null
                      : () {
                          Navigator.pop(context);
                          _handlePurchase(package);
                        },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text(
                    _isPurchasing
                        ? 'PROCESSING...'
                        : (package.price == 0
                            ? 'START NOW'
                            : 'GET PREMIUM ACCESS'),
                    style: const TextStyle(
                        fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  AppLocalization.of(context).translate('common.close'),
                  style: TextStyle(
                      color: colorScheme.outline, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon,
                color: Theme.of(context).colorScheme.primary, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
