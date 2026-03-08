import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teorikort/core/localization/app_localization.dart';
import 'package:teorikort/core/widgets/app_loading_widget.dart';
import 'package:teorikort/feature/exam/view/practice_main_category_view.dart';
import 'package:teorikort/feature/topics/view/traffic_signs_view.dart';

import '../../../features/home/data/services/daily_tip_service.dart';
import '../../../features/home/data/services/home_service.dart';
import '../provider/home_provider.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeProvider);

    return RefreshIndicator(
      onRefresh: () => ref.read(homeProvider.notifier).refresh(),
      child: state.isLoading && !state.hasData
          ? const AppLoadingWidget.fullscreen()
          : ListView(
              padding: const EdgeInsets.all(16).copyWith(top: 0),
              children: [
                _buildWelcomeSection(context, ref, state.homeData),
                const SizedBox(height: 24),
                _buildDailyTipSection(context, state.dailyTip),
                const SizedBox(height: 24),
                _buildQuickStartSection(context),
                const SizedBox(height: 24),
                _buildProgressSection(context, state.homeData),
                if (state.error != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .error
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      state.error!,
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                ],
              ],
            ),
    );
  }

  Widget _buildWelcomeSection(
      BuildContext context, WidgetRef ref, HomeData? homeData) {
    final userName = ref.read(homeProvider.notifier).currentUserFirstName;
    String welcomeMsg = AppLocalization.of(context)
        .translate('home.welcome_name')
        .replaceAll('%s', userName);

    if (homeData != null) {
      final lang = AppLocalization.of(context).locale.languageCode;
      final apiMsg = homeData.welcomeMessage[lang] ??
          homeData.welcomeMessage['tr'] ??
          welcomeMsg;
      welcomeMsg =
          apiMsg.contains('%s') ? apiMsg.replaceAll('%s', userName) : apiMsg;
    }

    return Text(
      welcomeMsg,
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _buildQuickStartSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalization.of(context).translate('home.quick_start'),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildQuickStartCard(
              context,
              'home.practice_exam',
              Icons.play_circle,
              Theme.of(context).colorScheme.primary,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const PracticeMainCategoryView()),
              ),
            ),
            const SizedBox(height: 16),
            _buildQuickStartCard(
              context,
              'signs.title',
              Icons.warning_amber_rounded,
              Theme.of(context).colorScheme.primary,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TrafficSignsView()),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickStartCard(
    BuildContext context,
    String titleKey,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              AppLocalization.of(context).translate(titleKey),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection(BuildContext context, HomeData? homeData) {
    final successRate = homeData?.userProgress.averageScore ?? 0.0;
    final completedTests = homeData?.userProgress.totalExams ?? 0;
    final completedCategories = homeData?.userProgress.completedCategories ?? 0;
    final totalCategories = homeData?.userProgress.totalCategories ?? 4;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalization.of(context).translate('home.your_progress'),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          _buildProgressItem(
            context,
            'home.success_rate',
            '${successRate.toInt()}%',
            Icons.trending_up,
            Colors.green,
          ),
          const SizedBox(height: 12),
          _buildProgressItem(
            context,
            'home.completed_tests',
            completedTests.toString(),
            Icons.assignment_turned_in,
            Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildProgressItem(
            context,
            'home.completed_categories',
            '$completedCategories / $totalCategories',
            Icons.category,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem(
    BuildContext context,
    String labelKey,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            AppLocalization.of(context).translate(labelKey),
            style: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.7),
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildDailyTipSection(BuildContext context, DailyTip? tip) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.secondary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: colorScheme.secondary),
              const SizedBox(width: 8),
              if (tip != null)
                Expanded(
                  child: Text(
                    tip.getTitle(
                        AppLocalization.of(context).locale.languageCode),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                )
              else
                Text(
                  AppLocalization.of(context).translate('home.daily_tip'),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            tip?.getContent(AppLocalization.of(context).locale.languageCode) ??
                AppLocalization.of(context).translate('home.no_tip_available'),
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
