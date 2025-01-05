import 'package:flutter/material.dart';
import 'package:driving_license_exam/core/localization/app_localization.dart';
import 'package:driving_license_exam/features/home/presentation/home_screen.dart';
import 'package:driving_license_exam/features/leaderboard/presentation/screens/leaderboard_screen.dart';
import 'package:driving_license_exam/features/profile/presentation/profile_screen.dart';
import 'package:driving_license_exam/features/statistics/presentation/screens/statistics_screen.dart';
import 'package:driving_license_exam/features/topics/presentation/topics_screen.dart';
import 'package:driving_license_exam/features/search/presentation/search_screen.dart';

class AppScaffold extends StatefulWidget {
  const AppScaffold({super.key});

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  int _currentIndex = 0;

  late final List<Widget> _screens = [
    const HomeScreen(),
    const TopicsScreen(),
    const StatisticsScreen(),
    const ProfileTab(),
  ];

  PreferredSizeWidget _buildAppBar() {
    if (_currentIndex == 0) {
      return AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        toolbarHeight: 160,
        flexibleSpace: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 40, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        AppLocalization.of(context).translate("app_name"),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppLocalization.of(context).translate("app_subtitle"),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.7),
                            ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.mail_outlined,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 16),
                      Icon(Icons.notifications_none_outlined,
                          color: Theme.of(context).colorScheme.primary),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SearchScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  height: 45,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          Theme.of(context).colorScheme.outline.withAlpha(60),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.5)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          AppLocalization.of(context)
                              .translate('app_bar.search'),
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.5),
                            fontSize: 16,
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
      );
    }

    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      title: Text(
        _buildTitle(),
        style: Theme.of(context).textTheme.titleLarge,
      ),
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back,
            color: Theme.of(context).colorScheme.primary),
        onPressed: () {
          setState(() {
            _currentIndex = 0;
          });
        },
        tooltip: AppLocalization.of(context).translate('app_bar.back'),
      ),
      actions: [
        if (_currentIndex == 2)
          IconButton(
            icon: Icon(Icons.leaderboard_outlined,
                color: Theme.of(context).colorScheme.primary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const LeaderboardScreen()),
              );
            },
          ),
      ],
    );
  }

  String _buildTitle() {
    switch (_currentIndex) {
      case 1:
        return AppLocalization.of(context).translate('topics.screen_title');
      case 2:
        return AppLocalization.of(context).translate('statistics.screen_title');
      case 3:
        return AppLocalization.of(context).translate('profile.title');
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Theme.of(context).colorScheme.surface,
        indicatorColor: Theme.of(context).colorScheme.primary,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: AppLocalization.of(context).translate('bottom_nav.home'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.menu_book_outlined),
            selectedIcon: const Icon(Icons.menu_book),
            label: AppLocalization.of(context).translate('bottom_nav.topics'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.bar_chart_outlined),
            selectedIcon: const Icon(Icons.bar_chart),
            label:
                AppLocalization.of(context).translate('bottom_nav.statistics'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: AppLocalization.of(context).translate('bottom_nav.settings'),
          ),
        ],
      ),
    );
  }
}
