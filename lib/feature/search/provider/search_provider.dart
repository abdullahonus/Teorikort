import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../product/provider/service_providers.dart';
import '../notifier/search_notifier.dart';
import '../state/search_state.dart';

/// Provider for search state
final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  final repository = ref.watch(searchRepositoryProvider);
  return SearchNotifier(repository);
});
