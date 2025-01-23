import 'package:freezed_annotation/freezed_annotation.dart';

class ResetPasswordState {
  final bool isLoading;
  final String? error;
  final int strength;

  const ResetPasswordState({
    this.isLoading = false,
    this.error,
    this.strength = 0,
  });

  ResetPasswordState copyWith({
    bool? isLoading,
    String? error,
    int? strength,
  }) {
    return ResetPasswordState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      strength: strength ?? this.strength,
    );
  }
}
