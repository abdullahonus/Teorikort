import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/auth_service.dart';
import '../../data/models/reset_password_state.dart';
import '../../../../core/providers/auth_provider.dart';

class ResetPasswordNotifier extends StateNotifier<ResetPasswordState> {
  final AuthService _authService;

  ResetPasswordNotifier(this._authService)
      : super(const ResetPasswordState.initial());

  Future<void> validatePassword(String password) async {
    try {
      final response = await _authService.validatePassword(password);
      state = ResetPasswordState(
        isValid: response.isValid,
        strength: response.strength,
        validationErrors: response.validationErrors,
      );
    } catch (e) {
      state = ResetPasswordState(error: e.toString());
    }
  }

  Future<void> resetPassword(String email, String otp, String password) async {
    try {
      state = const ResetPasswordState.loading();
      await _authService.resetPassword(email, otp, password);
      state = const ResetPasswordState.success();
    } catch (e) {
      state = ResetPasswordState(error: e.toString());
    }
    return;
  }
}

final resetPasswordProvider =
    StateNotifierProvider<ResetPasswordNotifier, ResetPasswordState>((ref) {
  return ResetPasswordNotifier(ref.read(authServiceProvider));
});
