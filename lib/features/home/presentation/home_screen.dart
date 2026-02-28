import 'package:teorikort/features/exam/presentation/exam_list_screen.dart';
import 'package:teorikort/features/exam/presentation/mock_exam_difficulty_screen.dart';
import 'package:teorikort/features/quiz/presentation/quiz_screen.dart';
import 'package:flutter/material.dart';
import 'package:teorikort/core/theme/app_colors.dart';
import 'package:teorikort/core/localization/app_localization.dart';
import 'package:teorikort/core/services/user_service.dart';
import 'package:teorikort/features/home/data/services/daily_tip_service.dart';

import 'package:teorikort/features/home/data/services/home_service.dart';
import 'package:teorikort/core/models/api_response.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<ApiResponse<HomeData>> _homeDataFuture;

  @override
  void initState() {
    super.initState();
    _homeDataFuture = HomeService().getHomeData();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _homeDataFuture = HomeService().getHomeData();
        });
      },
      child: FutureBuilder<ApiResponse<HomeData>>(
        future: _homeDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final homeData = snapshot.data?.data;

          return ListView(
            padding: const EdgeInsets.all(16).copyWith(top: 0),
            children: [
              _buildWelcomeSection(context, homeData),
              const SizedBox(height: 24),
              _buildDailyTipSection(context, homeData?.dailyTip),
              const SizedBox(height: 24),
              _buildQuickStartSection(context),
              const SizedBox(height: 24),
              _buildProgressSection(context, homeData),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context, HomeData? homeData) {
    final userName = UserService().currentUserFirstName;

    // Yedeği tutalım, API'den gelmezse lokalizasyon dosyasını kullanır
    String welcomeMsg = AppLocalization.of(context)
        .translate('home.welcome_name')
        .replaceAll('%s', userName);

    String motivationMsg =
        AppLocalization.of(context).translate('home.motivation_message');

    if (homeData != null) {
      final lang = AppLocalization.of(context).locale.languageCode;
      welcomeMsg = homeData.welcomeMessage[lang] ??
          homeData.welcomeMessage['tr'] ??
          welcomeMsg;
      motivationMsg = homeData.motivationalQuote[lang] ??
          homeData.motivationalQuote['tr'] ??
          motivationMsg;

      // %s varsa kullanıcı ismiyle değiştir
      if (welcomeMsg.contains('%s')) {
        welcomeMsg = welcomeMsg.replaceAll('%s', userName);
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          welcomeMsg,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        /*     Text(
          motivationMsg,
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ), */
      ],
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
        Row(
          children: [
            Expanded(
              child: _buildQuickStartCard(
                context,
                'home.practice_exam',
                Icons.play_circle,
                Theme.of(context).colorScheme.primary,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MockExamDifficultyScreen(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildQuickStartCard(
                context,
                'home.mock_exam',
                Icons.assignment,
                Theme.of(context).colorScheme.primary,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ExamListScreen()),
                ),
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
    VoidCallback onTap, {
    bool fullWidth = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: fullWidth ? double.infinity : null,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
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
    final double successRate = homeData?.userProgress.averageScore ?? 0.0;
    final int completedTests = homeData?.userProgress.totalExams ?? 0;
    final int completedCategories =
        homeData?.userProgress.completedCategories ?? 0;
    final int totalCategories = homeData?.userProgress.totalCategories ?? 4;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
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
    Color color, {
    String? fallbackLabel,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            AppLocalization.of(context).translate(labelKey).isEmpty &&
                    fallbackLabel != null
                ? fallbackLabel
                : AppLocalization.of(context).translate(labelKey),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildDailyTipSection(BuildContext context, DailyTip? tip) {
    if (tip == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Text(
                  AppLocalization.of(context).translate('home.daily_tip'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalization.of(context).translate('home.no_tip_available'),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    final currentLanguage = AppLocalization.of(context).locale.languageCode;
    final tipTitle = tip.getTitle(currentLanguage);
    final tipContent = tip.getContent(currentLanguage);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb,
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tipTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            tipContent,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
