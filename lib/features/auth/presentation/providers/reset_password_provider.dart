import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/auth_service.dart';
import '../../data/models/reset_password_state.dart';
import '../../../../core/providers/auth_provider.dart';

class ResetPasswordNotifier extends StateNotifier<ResetPasswordState> {
  ResetPasswordNotifier() : super(const ResetPasswordState());

  Future<void> resetPassword(String email, String otp, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // API çağrısı burada
      await Future.delayed(const Duration(seconds: 2)); // Örnek gecikme
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> validatePassword(String password) async {
    // Şifre gücü hesaplama mantığı
    int strength = calculatePasswordStrength(password);
    state = state.copyWith(strength: strength);
  }

  int calculatePasswordStrength(String password) {
    // Şifre gücü hesaplama mantığı burada
    return 0; // Örnek dönüş
  }
}

final resetPasswordProvider =
    StateNotifierProvider<ResetPasswordNotifier, ResetPasswordState>((ref) {
  return ResetPasswordNotifier();
});
