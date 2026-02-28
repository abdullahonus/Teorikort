import 'package:equatable/equatable.dart';
import '../model/user_profile.dart';

class ProfileState extends Equatable {
  final UserProfile? profile;
  final bool isLoading;
  final String? error;
  final bool isUpdating;

  const ProfileState({
    this.profile,
    this.isLoading = false,
    this.error,
    this.isUpdating = false,
  });

  bool get hasProfile => profile != null;

  ProfileState copyWith({
    UserProfile? profile,
    bool? isLoading,
    String? error,
    bool? isUpdating,
    bool clearError = false,
  }) =>
      ProfileState(
        profile: profile ?? this.profile,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
        isUpdating: isUpdating ?? this.isUpdating,
      );

  @override
  List<Object?> get props => [profile, isLoading, error, isUpdating];
}
