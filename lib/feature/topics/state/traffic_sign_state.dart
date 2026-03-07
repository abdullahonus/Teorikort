import 'package:equatable/equatable.dart';
import '../model/traffic_sign.dart';

/// Spec: STATE MODEL PATTERN — Equatable + copyWith
class TrafficSignState extends Equatable {
  final bool isLoading;
  final String? error;
  final List<TrafficSign> signs;
  final int currentPage;
  final int lastPage;
  final int total;

  const TrafficSignState({
    this.isLoading = false,
    this.error,
    this.signs = const [],
    this.currentPage = 1,
    this.lastPage = 1,
    this.total = 0,
  });

  TrafficSignState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    List<TrafficSign>? signs,
    int? currentPage,
    int? lastPage,
    int? total,
  }) =>
      TrafficSignState(
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
        signs: signs ?? this.signs,
        currentPage: currentPage ?? this.currentPage,
        lastPage: lastPage ?? this.lastPage,
        total: total ?? this.total,
      );

  @override
  List<Object?> get props =>
      [isLoading, error, signs, currentPage, lastPage, total];
}
