import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/repository/i_search_repository.dart';
import '../state/search_state.dart';

class SearchNotifier extends StateNotifier<SearchState> {
  final ISearchRepository _repository;
  Timer? _debounce;

  SearchNotifier(this._repository) : super(const SearchState());

  void onQueryChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (query.isEmpty) {
      state = state.copyWith(
          query: '', results: [], hasSearched: false, isLoading: false);
      return;
    }

    state = state.copyWith(query: query);

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    state = state.copyWith(isLoading: true, hasSearched: true);

    try {
      final response = await _repository.searchQuestions(query);
      if (response.success && response.data != null) {
        state = state.copyWith(
          results: response.data!,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message ?? 'Unknown error',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearSearch() {
    state = const SearchState();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
