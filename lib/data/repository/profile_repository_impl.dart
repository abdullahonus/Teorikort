import '../../core/models/api_response.dart';
import '../../core/services/logger_service.dart';
import '../../domain/repository/i_profile_repository.dart';
import '../../feature/profile/model/user_profile.dart';
import '../../features/user/data/repositories/user_repository.dart';

/// Concrete implementation of [IProfileRepository].
/// It uses the existing [UserRepository] (acting as a service) for network calls.
class ProfileRepositoryImpl implements IProfileRepository {
  final UserRepository _userRepository;

  ProfileRepositoryImpl(this._userRepository);

  @override
  Future<ApiResponse<UserProfile>> getUserProfile() async {
    try {
      final response = await _userRepository.getUserProfile();
      
      if (response.success && response.data != null) {
        // Map the legacy UserProfile to the new immutable one if they differ, 
        // but here they are designed to be compatible.
        return ApiResponse<UserProfile>(
          success: true,
          statusCode: response.statusCode,
          data: UserProfile.fromJson(response.data!.toJson()),
        );
      }
      
      return ApiResponse<UserProfile>(
        success: false,
        message: response.message,
        statusCode: response.statusCode,
      );
    } catch (e) {
      LoggerService.error('ProfileRepositoryImpl.getUserProfile', e);
      return ApiResponse<UserProfile>(
        success: false,
        message: e.toString(),
        statusCode: 500,
      );
    }
  }

  @override
  Future<ApiResponse<UserProfile>> updateUserProfile(String name) async {
    try {
      final response = await _userRepository.updateUserProfile(name);
      
      if (response.success && response.data != null) {
        return ApiResponse<UserProfile>(
          success: true,
          statusCode: response.statusCode,
          data: UserProfile.fromJson(response.data!.toJson()),
        );
      }
      
      return ApiResponse<UserProfile>(
        success: false,
        message: response.message,
        statusCode: response.statusCode,
      );
    } catch (e) {
      LoggerService.error('ProfileRepositoryImpl.updateUserProfile', e);
      return ApiResponse<UserProfile>(
        success: false,
        message: e.toString(),
        statusCode: 500,
      );
    }
  }
}
