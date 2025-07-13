import 'package:driving_license_exam/features/auth/presentation/providers/auth_provider.dart';
import 'package:driving_license_exam/features/home/presentation/providers/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:driving_license_exam/core/localization/app_localization.dart';
import 'package:driving_license_exam/features/home/presentation/home_screen.dart';
import 'package:driving_license_exam/features/leaderboard/presentation/screens/leaderboard_screen.dart';
import 'package:driving_license_exam/features/profile/presentation/profile_screen.dart';
import 'package:driving_license_exam/features/statistics/presentation/screens/statistics_screen.dart';
import 'package:driving_license_exam/features/topics/presentation/topics_screen.dart';
import 'package:driving_license_exam/features/search/presentation/search_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:driving_license_exam/features/user/presentation/providers/user_provider.dart';

class AppScaffold extends ConsumerStatefulWidget {
  const AppScaffold({super.key});

  @override
  ConsumerState<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends ConsumerState<AppScaffold> {
  int _currentIndex = 0;
  final _refreshKey = GlobalKey<RefreshIndicatorState>();

  late final List<Widget> _screens = [
    const HomeScreen(),
    const TopicsScreen(),
    const StatisticsScreen(),
    const ProfileTab(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    final token = ref.read(authStateProvider).token;
    if (token != null) {
      await ref.read(homeStateProvider.notifier).fetchWelcomeMessage(token);
    }
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userStateProvider);

    if (_currentIndex == 0) {
      return AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        toolbarHeight: 180,
        flexibleSpace: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            Text(
                              userState.profile?.fullName ??
                                  AppLocalization.of(context)
                                      .translate("app_name"),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppLocalization.of(context)
                                  .translate("app_subtitle"),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.7),
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.notifications_none_outlined,
                          color: Theme.of(context).colorScheme.primary),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
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
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withAlpha(60),
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
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
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
        /*   IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () => _handleLogout(context, ref),
        ), */
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
    final homeState = ref.watch(homeStateProvider);
    final userState = ref.watch(userStateProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context, ref),
      body: Column(
        children: [
          if (homeState.isLoading) const LinearProgressIndicator(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              homeState.welcomeMessage?.message ?? "Welcome to the App",
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              key: _refreshKey,
              onRefresh: () async {
                final token = ref.read(authStateProvider).token;
                if (token != null) {
                  await ref
                      .read(homeStateProvider.notifier)
                      .fetchWelcomeMessage(token);
                }
              },
              child: _screens[_currentIndex],
            ),
          ),
        ],
      ),
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
