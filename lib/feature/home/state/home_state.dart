import 'package:equatable/equatable.dart';
import '../../../features/home/data/services/home_service.dart';
import '../../../features/home/data/services/daily_tip_service.dart';

/// Home feature'ının tüm durumlarını taşır.
/// Equatable → gereksiz rebuild yok, copyWith → immutable güncelleme.
class HomeState extends Equatable {
  final HomeData? homeData;
  final DailyTip? dailyTip;
  final bool isLoading;
  final String? error;

  const HomeState({
    this.homeData,
    this.dailyTip,
    this.isLoading = false,
    this.error,
  });

  bool get hasData => homeData != null;

  HomeState copyWith({
    HomeData? homeData,
    DailyTip? dailyTip,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) =>
      HomeState(
        homeData: homeData ?? this.homeData,
        dailyTip: dailyTip ?? this.dailyTip,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
      );

  @override
  List<Object?> get props => [homeData, dailyTip, isLoading, error];
}
