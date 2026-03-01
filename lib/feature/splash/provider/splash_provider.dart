import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teorikort/data/repository/version_repository_impl.dart';
import 'package:teorikort/domain/repository/version_repository.dart';
import '../notifier/splash_notifier.dart';
import '../notifier/splash_state.dart';
import '../service/version_service.dart';

final versionServiceProvider = Provider<VersionService>((ref) => VersionService());

final versionRepositoryProvider = Provider<IVersionRepository>((ref) {
  final service = ref.watch(versionServiceProvider);
  return VersionRepositoryImpl(service);
});

final splashNotifierProvider = StateNotifierProvider<SplashNotifier, SplashState>((ref) {
  final repository = ref.watch(versionRepositoryProvider);
  return SplashNotifier(repository);
});
