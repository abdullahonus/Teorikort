import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/exceptions/api_exception.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/services/user_service.dart';
import '../../../domain/repository/i_auth_repository.dart';
import '../../../features/user/domain/models/user_profile.dart';
import '../../../product/provider/service_providers.dart';
import '../model/auth_user.dart';
import '../state/auth_state.dart';

/// Spec NOTIFIER PATTERN:
///   class XxxNotifier extends Notifier<XxxState>
///   Repo inject: ref.read(xxxRepositoryProvider)
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    // Uygulama açılışında token kontrolü yap
    _checkAuthStatus();
    return const AuthState.initial();
  }

  IAuthRepository get _repo => ref.read(authRepositoryProvider);
  UserService get _userService => ref.read(userServiceProvider);

  Future<void> _checkAuthStatus() async {
    try {
      final isAuth = await _repo.isAuthenticated();
      if (!isAuth) {
        state = const AuthState.unauthenticated();
        return;
      }

      final user = await _repo.getCurrentUser();
      if (user != null) {
        await _userService.updateUserFromApi(UserProfile(
          id: user.id.toString(),
          name: user.name,
          email: user.email,
          lastname: user.lastname,
          phone: user.phone,
          createdAt: user.createdAt?.toIso8601String(),
        ));
        state = AuthState.authenticated(user);
      } else {
        await signOut();
      }
    } catch (e) {
      // Sadece 401 veya yetkilendirme hatalarında oturumu sil,
      // Eğer geçici network hatası ise ve localde oturum açıksa koru.
      if (e is ApiException && (e.statusCode == 401 || e.statusCode == 403)) {
        await signOut();
      } else {
        final isAuth = await _repo.isAuthenticated();
        if (isAuth) {
          final cachedUser = AuthUser(
            id: int.tryParse(_userService.currentUserId) ?? 0,
            email: _userService.currentUser['email']?.toString() ?? '',
            name: _userService.currentUserName,
            isEmailVerified: true,
          );
          state = AuthState.authenticated(cachedUser);
        } else {
          await signOut();
        }
      }
    }
  }

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      // Email format kontrolü
      if (!email.contains('@') || !email.contains('.')) {
        throw 'Geçersiz e-posta formatı';
      }

      final user = await _repo.signIn(email, password);

      await _userService.updateUserFromApi(UserProfile(
        id: user.id.toString(),
        name: user.name,
        email: user.email,
        lastname: user.lastname,
        phone: user.phone,
        createdAt: user.createdAt?.toIso8601String(),
      ));

      LoggerService.info('AuthNotifier.signIn: success', user.email);
      state = AuthState.authenticated(user);
    } catch (e) {
      LoggerService.error('AuthNotifier.signIn: error', e);
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> signUp(
    String email,
    String password,
    String name, {
    String? lastname,
    String? phone,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      if (!email.contains('@') || !email.contains('.')) {
        throw 'Geçersiz e-posta formatı';
      }
      if (password.length < 6) {
        throw 'Şifre en az 6 karakter olmalıdır';
      }

      final user = await _repo.register(
        email,
        password,
        name,
        lastname: lastname,
        phone: phone,
      );

      await _userService.updateUserFromApi(UserProfile(
        id: user.id.toString(),
        name: user.name,
        email: user.email,
        lastname: user.lastname,
        phone: user.phone,
        createdAt: user.createdAt?.toIso8601String(),
      ));

      LoggerService.info('AuthNotifier.signUp: success', user.email);
      state = AuthState.authenticated(user);
    } catch (e) {
      LoggerService.error('AuthNotifier.signUp: error', e);
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> signOut() async {
    try {
      await _repo.logout();
      await _userService.clearUserData();
    } finally {
      state = const AuthState.unauthenticated();
    }
  }
}
