import 'package:equatable/equatable.dart';
import '../model/traffic_sign.dart';

/// Spec: STATE MODEL PATTERN — Equatable + copyWith
/// Yeni API yapısına göre categories (üst başlıklar) ve
/// seçili kategori desteği eklendi.
class TrafficSignState extends Equatable {
  final bool isLoading;
  final String? error;

  /// API'den gelen üst kategoriler (her birinin children'ında gerçek işaretler var)
  final List<TrafficSign> categories;

  /// Pagination bilgisi
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  /// UI'da seçili kategori (null = tüm kategoriler gösteriliyor)
  final TrafficSign? selectedCategory;

  const TrafficSignState({
    this.isLoading = false,
    this.error,
    this.categories = const [],
    this.currentPage = 1,
    this.lastPage = 1,
    this.perPage = 10,
    this.total = 0,
    this.selectedCategory,
  });

  /// Backwards-compat: tüm çocukları (gerçek işaretleri) düz liste döndürür
  List<TrafficSign> get signs =>
      categories.expand((cat) => cat.children).toList();

  /// Seçili kategorinin işaretleri — yoksa tüm işaretler
  List<TrafficSign> get visibleSigns =>
      selectedCategory != null ? selectedCategory!.children : signs;

  /// Sayfalama devam ediyor mu?
  bool get hasMore => currentPage < lastPage;

  TrafficSignState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    List<TrafficSign>? categories,
    int? currentPage,
    int? lastPage,
    int? perPage,
    int? total,
    TrafficSign? selectedCategory,
    bool clearSelectedCategory = false,
  }) =>
      TrafficSignState(
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
        categories: categories ?? this.categories,
        currentPage: currentPage ?? this.currentPage,
        lastPage: lastPage ?? this.lastPage,
        perPage: perPage ?? this.perPage,
        total: total ?? this.total,
        selectedCategory: clearSelectedCategory
            ? null
            : (selectedCategory ?? this.selectedCategory),
      );

  @override
  List<Object?> get props => [
        isLoading,
        error,
        categories,
        currentPage,
        lastPage,
        perPage,
        total,
        selectedCategory,
      ];
}
