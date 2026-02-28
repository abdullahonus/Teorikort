import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/auth_service.dart';
import '../../../product/provider/service_providers.dart';

// ─── State ────────────────────────────────────────────────────────────────────

class ResetPasswordState extends Equatable {
  final bool isLoading;
  final String? error;
  final int strength;
  final bool isSuccess;

  const ResetPasswordState({
    this.isLoading = false,
    this.error,
    this.strength = 0,
    this.isSuccess = false,
  });

  ResetPasswordState copyWith({
    bool? isLoading,
    String? error,
    int? strength,
    bool? isSuccess,
    bool clearError = false,
  }) =>
      ResetPasswordState(
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
        strength: strength ?? this.strength,
        isSuccess: isSuccess ?? this.isSuccess,
      );

  @override
  List<Object?> get props => [isLoading, error, strength, isSuccess];
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class ResetPasswordNotifier extends Notifier<ResetPasswordState> {
  @override
  ResetPasswordState build() => const ResetPasswordState();

  AuthService get _authService => ref.read(authServiceProvider);

  Future<void> resetPassword(
      String email, String otp, String newPassword) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response =
          await _authService.resetPassword(email, otp, newPassword);
      if (response.success) {
        state = state.copyWith(isLoading: false, isSuccess: true);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message ?? 'Şifre sıfırlama başarısız',
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void validatePassword(String password) {
    state = state.copyWith(strength: _calculateStrength(password));
  }

  int _calculateStrength(String password) {
    if (password.isEmpty) return 0;
    int strength = 0;
    if (password.length >= 8) strength += 25;
    if (password.contains(RegExp(r'[A-Z]'))) strength += 25;
    if (password.contains(RegExp(r'[0-9]'))) strength += 25;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 25;
    return strength;
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final resetPasswordProvider =
    NotifierProvider<ResetPasswordNotifier, ResetPasswordState>(
  ResetPasswordNotifier.new,
);
