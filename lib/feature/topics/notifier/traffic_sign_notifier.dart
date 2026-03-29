import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/logger_service.dart';
import '../../../domain/repository/i_topic_repository.dart';
import '../../../product/provider/service_providers.dart';
import '../model/traffic_sign.dart';
import '../state/traffic_sign_state.dart';

class TrafficSignNotifier extends Notifier<TrafficSignState> {
  @override
  TrafficSignState build() {
    return const TrafficSignState();
  }

  ITopicRepository get _repository => ref.read(topicRepositoryProvider);

  /// Sayfa bazlı yükleme — her sayfa bir üst kategori döndürür
  Future<void> loadSigns({int page = 1}) async {
    if (page == 1) {
      state = state.copyWith(isLoading: true, clearError: true, categories: []);
    } else {
      state = state.copyWith(isLoading: true);
    }

    try {
      final response = await _repository.getTrafficSigns(page: page);
      if (response.success && response.data != null) {
        final newData = response.data!;
        final merged = page == 1
            ? newData.signs
            : [...state.categories, ...newData.signs];

        state = state.copyWith(
          categories: merged,
          currentPage: newData.pagination.currentPage,
          lastPage: newData.pagination.lastPage,
          perPage: newData.pagination.perPage,
          total: newData.pagination.total,
          isLoading: false,
        );
      } else {
        state = state.copyWith(error: response.message, isLoading: false);
      }
    } catch (e) {
      LoggerService.error('TrafficSignNotifier.loadSigns', e);
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  /// Tüm sayfaları yükler (toplam 19 sayfa, her sayfa 1 kategori)
  Future<void> loadAll() async {
    await loadSigns(page: 1);
    // Sonraki sayfaları sırayla çek
    for (int p = 2; p <= state.lastPage; p++) {
      if (!state.isLoading) {
        await loadSigns(page: p);
      }
    }
  }

  /// Bir sonraki sayfayı yükle (infinite scroll)
  Future<void> loadNextPage() async {
    if (state.hasMore && !state.isLoading) {
      await loadSigns(page: state.currentPage + 1);
    }
  }

  /// İlk sayfadan yenile
  Future<void> refresh() async {
    await loadSigns(page: 1);
  }

  /// Kategori filtrele — null ise tüm kategoriler
  void selectCategory(TrafficSign? category) {
    if (category == null) {
      state = state.copyWith(clearSelectedCategory: true);
    } else {
      state = state.copyWith(selectedCategory: category);
    }
  }
}
