import 'package:driving_license_exam/features/exam/presentation/exam_list_screen.dart';
import 'package:driving_license_exam/features/exam/presentation/mock_exam_difficulty_screen.dart';
import 'package:driving_license_exam/features/quiz/presentation/quiz_screen.dart';
import 'package:flutter/material.dart';
import 'package:driving_license_exam/core/theme/app_colors.dart';
import 'package:driving_license_exam/core/localization/app_localization.dart';
import 'package:driving_license_exam/core/services/user_service.dart';
import 'package:driving_license_exam/features/exam/data/services/mock_exam_service.dart';
import 'package:driving_license_exam/features/home/data/services/daily_tip_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16).copyWith(top: 0),
      children: [
        _buildWelcomeSection(context),
        const SizedBox(height: 24),
        _buildDailyTipSection(context),
        const SizedBox(height: 24),
        _buildQuickStartSection(context),
        const SizedBox(height: 24),
        _buildProgressSection(context),
      ],
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    final userName = UserService().currentUserFirstName;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalization.of(context)
              .translate('home.welcome_name')
              .replaceAll('%s', userName),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        Text(
          AppLocalization.of(context).translate('home.motivation_message'),
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
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
                    builder: (context) => const ExamListScreen(),
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
                    builder: (context) => const MockExamDifficultyScreen(),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildQuickStartCard(
          context,
          'home.random_questions',
          Icons.shuffle,
          Theme.of(context).colorScheme.tertiary,
          () async {
            // Yükleniyor göstergesi
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) =>
                  const Center(child: CircularProgressIndicator()),
            );

            try {
              // Rastgele soruları yükle
              final questions =
                  await MockExamService().getRandomQuestions(count: 5);

              if (questions.isEmpty) {
                Navigator.pop(context); // Yükleniyor göstergesini kapat
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        AppLocalization.of(context).translate('common.error')),
                  ),
                );
                return;
              }

              // Yükleniyor göstergesini kapat
              Navigator.pop(context);

              // Quiz ekranına git
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuizScreen(
                    examTitle: AppLocalization.of(context)
                        .translate('home.random_questions'),
                    questions: questions,
                  ),
                ),
              );
            } catch (e) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      AppLocalization.of(context).translate('common.error')),
                ),
              );
            }
          },
          fullWidth: true,
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

  Widget _buildProgressSection(BuildContext context) {
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
            '85%',
            Icons.trending_up,
            Colors.green,
          ),
          const SizedBox(height: 12),
          _buildProgressItem(
            context,
            'home.completed_tests',
            '12',
            Icons.assignment_turned_in,
            Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildProgressItem(
            context,
            'home.weak_topics',
            AppLocalization.of(context)
                .translate('search.exam_categories.traffic_signs'),
            Icons.warning,
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
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            AppLocalization.of(context).translate(labelKey),
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

  Widget _buildDailyTipSection(BuildContext context) {
    return FutureBuilder<DailyTip?>(
      future: DailyTipService().getDailyTip(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
              ),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.error.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.error,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalization.of(context)
                              .translate('home.daily_tip_error') ??
                          'Daily Tip Error',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalization.of(context)
                          .translate('home.tip_load_error') ??
                      'Unable to load daily tip. Please try again later.',
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
                ),
              ],
            ),
          );
        }

        final tip = snapshot.data;
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
                      AppLocalization.of(context).translate('home.daily_tip') ??
                          'Daily Tip',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalization.of(context)
                          .translate('home.no_tip_available') ??
                      'No tip available today. Check back later!',
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
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
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
