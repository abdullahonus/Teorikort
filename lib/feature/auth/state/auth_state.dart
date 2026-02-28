import 'package:equatable/equatable.dart';
import '../model/auth_user.dart';

/// Auth feature'ının tüm olası durumlarını taşır.
/// Equatable → gereksiz rebuild yok.
/// copyWith → immutable güncelleme.
class AuthState extends Equatable {
  final AuthUser? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  /// İlk açılış — token kontrol edilirken
  const AuthState.initial()
      : user = null,
        isLoading = true,
        error = null;

  /// Token geçerli, kullanıcı giriş yapmış
  const AuthState.authenticated(AuthUser this.user)
      : isLoading = false,
        error = null;

  /// Giriş yapılmamış
  const AuthState.unauthenticated()
      : user = null,
        isLoading = false,
        error = null;

  bool get isAuthenticated => user != null && !isLoading;

  AuthState copyWith({
    AuthUser? user,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool clearUser = false,
  }) =>
      AuthState(
        user: clearUser ? null : (user ?? this.user),
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
      );

  @override
  List<Object?> get props => [user, isLoading, error];
}
