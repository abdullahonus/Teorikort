import 'package:dio/dio.dart';
import 'package:driving_license_exam/features/user/domain/models/user_profile.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/models/api_response.dart';
import '../../../../core/services/logger_service.dart';

class UserRepository {
  final Dio _dio;

  UserRepository(this._dio);

  Future<ApiResponse<UserProfile>> getUserProfile(String token) async {
    try {
      LoggerService.api('GET', '/home', 'Fetching user profile...');

      final response = await _dio.get(
        '${ApiConstants.baseUrl}/home',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            ...ApiConstants.headers,
          },
          validateStatus: (_) => true,
        ),
      );

      LoggerService.api(
          'RESPONSE', '/home', response.data, response.statusCode);

      if (response.statusCode == 200 && response.data['success'] == true) {
        final userInfo = response.data['info']['user_info'];
        if (userInfo != null) {
          final userProfile = UserProfile.fromJson(userInfo);
          LoggerService.info('User profile fetched successfully', userProfile);

          return ApiResponse<UserProfile>(
            success: true,
            statusCode: 200,
            data: userProfile,
          );
        }
      }

      return ApiResponse<UserProfile>(
        success: false,
        message: response.data['error'] ?? 'Failed to fetch user profile',
        statusCode: response.statusCode ?? 500,
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
}
