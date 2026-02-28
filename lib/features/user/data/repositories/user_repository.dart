// Removed dio import
import 'package:teorikort/features/user/domain/models/user_profile.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/models/api_response.dart';
import '../../../../core/services/logger_service.dart';

import '../../../../core/services/base_api_service.dart';

class UserRepository extends BaseApiService {
  UserRepository();

  Future<ApiResponse<UserProfile>> getUserProfile() async {
    try {
      LoggerService.api('GET', ApiConstants.userProfile, 'Fetching user profile...');

      final response = await handleResponse<UserProfile>(
        get(ApiConstants.userProfile),
        UserProfile.fromJson,
      );

      if (response.success && response.data != null) {
        LoggerService.info('User profile fetched successfully', response.data!);
        return response;
      }

      return ApiResponse<UserProfile>(
        success: false,
        message: response.message ?? 'Failed to fetch user profile',
        statusCode: response.statusCode,
      );
    } catch (e, stackTrace) {
      LoggerService.error(
        'User Profile Error',
        e,
        stackTrace,
      );
      return ApiResponse<UserProfile>(
        success: false,
        message: 'Failed to fetch user profile',
        statusCode: 500,
      );
    }
  }

  Future<ApiResponse<UserProfile>> updateUserProfile(String name) async {
    try {
      LoggerService.api('PUT', ApiConstants.userProfile, 'Updating user profile...');

      final response = await handleResponse<UserProfile>(
        put(ApiConstants.userProfile, data: {'name': name}),
        UserProfile.fromJson,
      );

      if (response.success && response.data != null) {
        LoggerService.info('User profile updated successfully', response.data!);
        return response;
      }

      return ApiResponse<UserProfile>(
        success: false,
        message: response.message ?? 'Failed to update user profile',
        statusCode: response.statusCode,
      );
    } catch (e, stackTrace) {
      LoggerService.error(
        'Update Profile Error',
        e,
        stackTrace,
      );
      return ApiResponse<UserProfile>(
        success: false,
        message: 'Failed to update user profile',
        statusCode: 500,
      );
    }
  }
}
