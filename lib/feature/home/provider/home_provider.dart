import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notifier/home_notifier.dart';
import '../state/home_state.dart';

// ──────────────────────────────────────────────────────────────────────────────
// HOME PROVIDER
// Spec: NotifierProvider<XxxNotifier, XxxState>(XxxNotifier.new)
// Widget kullanımı:
//   ref.watch(homeProvider)                             → HomeState
//   ref.watch(homeProvider.select((s) => s.homeData))  → sadece homeData
//   ref.read(homeProvider.notifier).refresh()           → yenile
// ──────────────────────────────────────────────────────────────────────────────

final homeProvider = NotifierProvider<HomeNotifier, HomeState>(
  HomeNotifier.new,
);
