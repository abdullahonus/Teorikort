import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teorikort/core/localization/app_localization.dart';
import 'package:teorikort/core/presentation/widgets/app_scaffold.dart';
import 'package:teorikort/core/widgets/app_loading_widget.dart';
import 'package:teorikort/feature/auth/provider/auth_provider.dart';
import 'package:teorikort/feature/auth/view/sign_in_view.dart';
import 'package:teorikort/feature/splash/notifier/splash_state.dart';
import 'package:teorikort/feature/splash/provider/splash_provider.dart';

class SplashView extends ConsumerStatefulWidget {
  const SplashView({super.key});

  @override
  ConsumerState<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends ConsumerState<SplashView> {
  @override
  void initState() {
    super.initState();
    // Initialize splash data (version, maintenance, etc.)
    Future.microtask(
        () => ref.read(splashNotifierProvider.notifier).initialize());
  }

  void _handleNavigation(SplashStatus status) async {
    if (status == SplashStatus.completed) {
      // 1. Splash data loaded successfully, now check auth
      final authState = ref.read(authProvider);

      // If auth check is still running, wait for it to finish.
      // The listener on `authProvider` below will handle it.
      if (authState.isLoading) return;

      if (!mounted) return;

      if (authState.isAuthenticated) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AppScaffold()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const SignInView()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to splash status changes
    ref.listen<SplashState>(splashNotifierProvider, (previous, next) {
      if (next.status == SplashStatus.completed) {
        _handleNavigation(next.status);
      }
    });

    // Listen to auth status changes in case auth finishes after splash
    ref.listen(authProvider, (previous, next) {
      final splashStatus = ref.read(splashNotifierProvider).status;
      if (splashStatus == SplashStatus.completed && !next.isLoading) {
        _handleNavigation(splashStatus);
      }
    });

    final splashState = ref.watch(splashNotifierProvider);

    return Scaffold(
      body: Center(
        child: _buildBody(splashState),
      ),
    );
  }

  Widget _buildBody(SplashState state) {
    switch (state.status) {
      case SplashStatus.maintenance:
        return _buildMaintenanceView(state);
      case SplashStatus.forceUpdate:
        return _buildForceUpdateView(state);
      case SplashStatus.error:
        return _buildErrorView(state);
      default:
        return const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppLoadingWidget(),
            SizedBox(height: 24),
            Text(
              'Teorikort',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
    }
  }

  Widget _buildMaintenanceView(SplashState state) {
    final maintenance = state.data?.maintenance;
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.build_circle_outlined,
              size: 80, color: Theme.of(context).colorScheme.secondary),
          const SizedBox(height: 24),
          Text(
            maintenance?.title ?? 'Bakım Çalışması',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            maintenance?.description ??
                'Size daha iyi hizmet verebilmek için çalışıyoruz. Lütfen daha sonra tekrar deneyiniz.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.color
                  ?.withOpacity(0.8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForceUpdateView(SplashState state) {
    final version = state.data?.version;
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.system_update_rounded,
              size: 80, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 24),
          Text(
            version?.title ?? 'Güncelleme Gerekli',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            version?.description ??
                'Uygulamanın yeni bir versiyonu mevcut. Devam etmek için lütfen güncelleyiniz.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.color
                  ?.withOpacity(0.8),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Redirect to store
              },
              child:
                  Text(AppLocalization.of(context).translate('common.confirm')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(SplashState state) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded,
              size: 80, color: Theme.of(context).colorScheme.error),
          const SizedBox(height: 24),
          const Text(
            'Bir Hata Oluştu',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            state.errorMessage ?? 'Bağlantı sırasında bir problem yaşandı.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.color
                  ?.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () =>
                  ref.read(splashNotifierProvider.notifier).initialize(),
              child: const Text('Tekrar Dene'),
            ),
          ),
        ],
      ),
    );
  }
}
