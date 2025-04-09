import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/models/api_response.dart';
import '../../../../core/services/logger_service.dart';
import '../models/welcome_message.dart';

class HomeRepository {
  final Dio _dio;

  HomeRepository(this._dio);

  Future<ApiResponse<WelcomeMessage>> getWelcomeMessage(String token) async {
    try {
      LoggerService.api('GET', '/home', 'Fetching welcome message...');

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
        final welcomeMessage = WelcomeMessage.fromJson(response.data);
        LoggerService.info(
            'Welcome message fetched successfully', welcomeMessage);

        return ApiResponse<WelcomeMessage>(
          success: true,
          statusCode: 200,
          data: welcomeMessage,
        );
      }

      return ApiResponse<WelcomeMessage>(
        success: false,
        message: response.data['error'] ?? 'Failed to fetch welcome message',
        statusCode: response.statusCode ?? 500,
      );
    } catch (e, stackTrace) {
      LoggerService.error(
        'Welcome Message Error',
        e,
        stackTrace,
      );
      return ApiResponse<WelcomeMessage>(
        success: false,
        message: 'Failed to fetch welcome message',
        statusCode: 500,
      );
    }
  }
}
