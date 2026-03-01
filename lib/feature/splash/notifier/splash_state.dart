import '../../../data/splash_response_model.dart';
import 'package:equatable/equatable.dart';

enum SplashStatus { initial, loading, maintenance, forceUpdate, completed, error }

class SplashState extends Equatable {
  final SplashStatus status;
  final SplashResponseModel? data;
  final String? errorMessage;

  const SplashState({
    this.status = SplashStatus.initial,
    this.data,
    this.errorMessage,
  });

  SplashState copyWith({
    SplashStatus? status,
    SplashResponseModel? data,
    String? errorMessage,
  }) {
    return SplashState(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, data, errorMessage];
}
