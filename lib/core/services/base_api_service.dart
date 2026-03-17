// ignore_for_file: use_build_context_synchronously

import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teorikort/core/localization/app_localization.dart';

import '../constants/api_constants.dart';
import '../constants/app_config.dart';
import '../exceptions/api_exception.dart';
import '../models/api_response.dart';
import 'logger_service.dart';
import 'navigation_service.dart';

class BaseApiService {
  late final Dio _dio;
  final FlutterSecureStorage _storage;
  static const String _tokenKey = 'auth_token';

  BaseApiService() : _storage = const FlutterSecureStorage() {
    _initializeDio();
  }

  void _initializeDio() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      headers: ApiConstants.headers,
      connectTimeout: const Duration(seconds: AppConfig.apiTimeoutSeconds),
      receiveTimeout: const Duration(seconds: AppConfig.apiTimeoutSeconds),
      sendTimeout: const Duration(seconds: AppConfig.apiTimeoutSeconds),
      validateStatus: (status) {
        return status != null && (status < 400 || status == 402 || status == 422);
      },
    ));

    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(ChuckerDioInterceptor());
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Auto-add auth token if available
        final token = await getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        // ─── Dynamic Language Configuration ───
        final prefs = await SharedPreferences.getInstance();
        final languageCode =
            prefs.getString('locale') ?? ApiConstants.defaultLanguage;

        options.headers['Accept-Language'] = languageCode;

        options.headers['Accept-Language'] = languageCode;

        if (AppConfig.enableApiLogging) {
          LoggerService.api('REQUEST', options.path, {
            'method': options.method,
            'headers': options.headers,
            'data': options.data,
            'queryParameters': options.queryParameters,
          });
        }

        return handler.next(options);
      },
      onResponse: (response, handler) {
        if (AppConfig.enableApiLogging) {
          LoggerService.api(
              'RESPONSE',
              response.requestOptions.path,
              {
                'statusCode': response.statusCode,
                'data': response.data,
              },
              response.statusCode);
        }

        return handler.next(response);
      },
      onError: (error, handler) {
        LoggerService.error('API Error:', {
          'url': error.requestOptions.path,
          'statusCode': error.response?.statusCode,
          'message': error.message,
          'data': error.response?.data,
        });

        return handler.next(error);
      },
    ));
  }

  // Token Management
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  // Generic API Response Handler
  Future<ApiResponse<T>> handleResponse<T>(
    Future<Response> apiCall,
    T Function(Map<String, dynamic>) fromJson, {
    VoidCallback? onConfirm,
    String? buttonText,
    bool barrierDismissible = true,
    bool showDialog = true,
  }) async {
    try {
      final response = await apiCall;

      Map<String, dynamic> responseData = response.data as Map<String, dynamic>;

      // If backend wrapped it in an outer object with statusCode and data
      if (responseData.containsKey('statusCode') &&
          responseData.containsKey('data') &&
          responseData['data'] is Map<String, dynamic>) {
        responseData = responseData['data'] as Map<String, dynamic>;
      }

      final statusCode = responseData['statuscode'] as int? ?? 0;
      final description = responseData['description']?.toString() ?? '';
      final data = responseData['data'];

      if (statusCode == 100 ||
          statusCode == 200 ||
          statusCode == 201 ||
          statusCode == 402 ||
          statusCode == ApiConstants.success) {
        return ApiResponse<T>(
          success: true,
          statusCode: statusCode,
          message: description,
          data: data != null ? fromJson(data) : null,
          rawJson: responseData,
        );
      } else {
        String? message = description;

        // Try to extract error message from data object as requested by user
        if (data is Map<String, dynamic> && data.containsKey('message')) {
          message = data['message']?.toString();
        } else if (responseData.containsKey('message')) {
          message = responseData['message']?.toString();
        }

        final errorMessage = message ?? description;

        // Build details string if available
        Map<String, dynamic>? details;
        if (data is Map<String, dynamic> && data.containsKey('details')) {
          details = data['details'] as Map<String, dynamic>;
        }

        if (showDialog) {
          NavigationService.showAlertDialog(
            title: 'Hata ($statusCode)',
            message: errorMessage,
            details: details,
            onConfirm: onConfirm,
            buttonText: buttonText,
            barrierDismissible: barrierDismissible,
          );
        }

        return ApiResponse<T>(
          success: false,
          statusCode: statusCode,
          message: errorMessage,
          rawJson: responseData,
        );
      }
    } on DioException catch (e) {
      final dioError = _handleDioError<T>(e);
      final ctx = NavigationService.context;
      final title = ctx != null
          ? AppLocalization.of(ctx).translate('error.error_title')
          : 'Hata';
      final fallbackMsg = ctx != null
          ? AppLocalization.of(ctx).translate('error.unknown_exception')
          : 'Bilinmeyen bir hata oluştu';
      final message = dioError.message ?? fallbackMsg;

      if (showDialog) {
        NavigationService.showAlertDialog(
          title: title,
          message: message,
          onConfirm: onConfirm,
          buttonText: buttonText,
          barrierDismissible: barrierDismissible,
        );
      }
      return dioError;
    } catch (e) {
      LoggerService.error('Unexpected API Error:', e);
      final ctx = NavigationService.context;
      final title = ctx != null
          ? '${AppLocalization.of(ctx).translate('error.error_title')} (500)'
          : 'Hata (500)';
      final message = ctx != null
          ? AppLocalization.of(ctx).translate('error.unexpected_exception')
          : 'Beklenmeyen bir hata oluştu';

      if (showDialog) {
        NavigationService.showAlertDialog(
          title: title,
          message: message,
          onConfirm: onConfirm,
          buttonText: buttonText,
          barrierDismissible: barrierDismissible,
        );
      }
      return ApiResponse<T>(
        success: false,
        statusCode: 500,
        message: message,
      );
    }
  }

  // Generic API Response Handler for Lists
  Future<ApiResponse<List<T>>> handleListResponse<T>(
    Future<Response> apiCall,
    T Function(Map<String, dynamic>) fromJson, {
    VoidCallback? onConfirm,
    String? buttonText,
    bool barrierDismissible = true,
    bool showDialog = true,
  }) async {
    try {
      final response = await apiCall;
      Map<String, dynamic> responseData = response.data as Map<String, dynamic>;

      // If backend wrapped it in an outer object with statusCode and data
      if (responseData.containsKey('statusCode') &&
          responseData.containsKey('data') &&
          responseData['data'] is Map<String, dynamic>) {
        responseData = responseData['data'] as Map<String, dynamic>;
      }

      final statusCode = responseData['statuscode'] as int? ?? 0;
      final description = responseData['description']?.toString() ?? '';
      final data = responseData['data'];

      if ((statusCode == 100 ||
                  statusCode == 200 ||
                  statusCode == 201 ||
                  statusCode == 402 ||
                  statusCode == ApiConstants.success) &&
              data != null) {
        // ... list parsing logic (unchanged)
        List<dynamic> items = [];
        if (data is Map<String, dynamic>) {
          if (data.containsKey('categories')) {
            items = data['categories'] as List<dynamic>;
          } else if (data.containsKey('questions')) {
            items = data['questions'] as List<dynamic>;
          } else if (data.containsKey('results')) {
            items = data['results'] as List<dynamic>;
          } else if (data.containsKey('topics')) {
            items = data['topics'] as List<dynamic>;
          } else if (data.containsKey('leaderboard')) {
            items = data['leaderboard'] as List<dynamic>;
          } else if (data.containsKey('data')) {
            items = data['data'] as List<dynamic>;
          } else if (data.containsKey('items')) {
            items = data['items'] as List<dynamic>;
          }
        } else if (data is List<dynamic>) {
          items = data;
        }

        final parsedItems = items
            .map((item) => fromJson(item as Map<String, dynamic>))
            .toList();

        return ApiResponse<List<T>>(
          success: true,
          statusCode: statusCode,
          message: description,
          data: parsedItems,
          pagination: data is Map<String, dynamic> ? data['pagination'] : null,
          rawJson: responseData,
        );
      } else {
        String? message = description;

        // Try to extract error message from data object
        if (data is Map<String, dynamic> && data.containsKey('message')) {
          message = data['message']?.toString();
        } else if (responseData.containsKey('message')) {
          message = responseData['message']?.toString();
        }

        final errorMessage = message ?? description;

        // Build details string if available
        Map<String, dynamic>? details;
        if (data is Map<String, dynamic> && data.containsKey('details')) {
          details = data['details'] as Map<String, dynamic>;
        }

        if (showDialog) {
          NavigationService.showAlertDialog(
            title: 'Hata ($statusCode)',
            message: errorMessage,
            details: details,
            onConfirm: onConfirm,
            buttonText: buttonText,
            barrierDismissible: barrierDismissible,
          );
        }

        return ApiResponse<List<T>>(
          success: false,
          statusCode: statusCode,
          message: errorMessage,
          rawJson: responseData,
        );
      }
    } on DioException catch (e) {
      final dioError = _handleDioError<List<T>>(e);
      final ctx = NavigationService.context;
      final title = ctx != null
          ? '${AppLocalization.of(ctx).translate('error.error_title')} (${dioError.statusCode})'
          : 'Hata (${dioError.statusCode})';
      final message = dioError.message ??
          (ctx != null
              ? AppLocalization.of(ctx).translate('error.unknown_exception')
              : 'Bilinmeyen bir hata oluştu');

      if (showDialog) {
        NavigationService.showAlertDialog(
          title: title,
          message: message,
          onConfirm: onConfirm,
          buttonText: buttonText,
          barrierDismissible: barrierDismissible,
        );
      }
      return dioError;
    } catch (e) {
      LoggerService.error('Unexpected API Error:', e);
      final ctx = NavigationService.context;
      final title = ctx != null
          ? '${AppLocalization.of(ctx).translate('error.error_title')} (500)'
          : 'Hata (500)';
      final message = ctx != null
          ? AppLocalization.of(ctx).translate('error.unexpected_exception')
          : 'Beklenmeyen bir hata oluştu';

      if (showDialog) {
        NavigationService.showAlertDialog(
          title: title,
          message: message,
          onConfirm: onConfirm,
          buttonText: buttonText,
          barrierDismissible: barrierDismissible,
        );
      }
      return ApiResponse<List<T>>(
        success: false,
        statusCode: 500,
        message: message,
      );
    }
  }

  ApiResponse<T> _handleDioError<T>(DioException error) {
    final ctx = NavigationService.context;
    final l10n = ctx != null ? AppLocalization.of(ctx) : null;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return ApiResponse<T>(
          success: false,
          statusCode: 408,
          message: l10n?.translate('error.connection_timeout') ??
              'Bağlantı zaman aşımına uğradı',
        );
      case DioExceptionType.sendTimeout:
        return ApiResponse<T>(
          success: false,
          statusCode: 408,
          message: l10n?.translate('error.send_timeout') ??
              'İstek gönderilirken zaman aşımı',
        );
      case DioExceptionType.receiveTimeout:
        return ApiResponse<T>(
          success: false,
          statusCode: 408,
          message: l10n?.translate('error.receive_timeout') ??
              'Yanıt alınırken zaman aşımı',
        );
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode ?? 500;
        String? message;

        // Try to extract message from response body
        if (error.response?.data != null &&
            error.response?.data is Map<String, dynamic>) {
          final responseBody = error.response!.data as Map<String, dynamic>;
          final data = responseBody['data'];

          if (data is Map<String, dynamic> && data.containsKey('message')) {
            message = data['message']?.toString();
          } else if (responseBody.containsKey('message')) {
            message = responseBody['message']?.toString();
          } else if (responseBody.containsKey('description')) {
            message = responseBody['description']?.toString();
          }
        }

        return ApiResponse<T>(
          success: false,
          statusCode: statusCode,
          message: message ?? _getErrorMessage(statusCode),
        );
      case DioExceptionType.connectionError:
        return ApiResponse<T>(
          success: false,
          statusCode: 503,
          message: l10n?.translate('error.no_internet') ??
              'İnternet bağlantısını kontrol edin',
        );
      default:
        return ApiResponse<T>(
          success: false,
          statusCode: 500,
          message: l10n?.translate('error.unknown_exception') ??
              'Bilinmeyen bir hata oluştu',
        );
    }
  }

  String _getErrorMessage(int statusCode) {
    final ctx = NavigationService.context;
    final l10n = ctx != null ? AppLocalization.of(ctx) : null;

    switch (statusCode) {
      case 400:
        return l10n?.translate('error.bad_request') ?? 'Geçersiz istek';
      case 401:
        return l10n?.translate('error.unauthorized') ??
            'Oturum süreniz dolmuş. Lütfen tekrar giriş yapın';
      case 403:
        return l10n?.translate('error.unauthorized') ??
            'Bu işlem için yetkiniz yok';
      case 404:
        return l10n?.translate('error.not_found') ??
            'İstenen kaynak bulunamadı';
      case 409:
        return l10n?.translate('error.conflict') ?? 'Çakışma oluştu';
      case 422:
        return l10n?.translate('error.unprocessable') ?? 'Geçersiz veri girişi';
      case 429:
        return l10n?.translate('error.too_many_requests') ??
            'Çok fazla istek. Lütfen bekleyin';
      case 500:
        return l10n?.translate('error.server_error') ?? 'Sunucu hatası oluştu';
      case 503:
        return l10n?.translate('error.service_unavailable') ??
            'Servis geçici olarak kullanılamıyor';
      default:
        return l10n?.translate('error.unknown_exception') ?? 'Bir hata oluştu';
    }
  }

  // Enhanced HTTP Methods with Smart Error Handling
  Future<ApiResponse<T>> smartGet<T>(
    String path,
    T Function(Map<String, dynamic>) fromJson, {
    Map<String, dynamic>? queryParameters,
    String? language,
  }) async {
    try {
      final params = queryParameters ?? {};
      if (language != null) {
        params['language'] = language;
      }

      final response = await _dio.get(path, queryParameters: params);
      final apiResponse = await handleResponse<T>(
        Future.value(response),
        fromJson,
      );

      if (apiResponse.success) {
        if (AppConfig.enableApiLogging) {
          LoggerService.info('✅ Using API data for: $path');
        }
        return apiResponse;
      } else {
        throw ApiException.fromStatusCode(
            apiResponse.statusCode, apiResponse.message);
      }
    } on DioException catch (e) {
      throw _convertDioExceptionToApiException(e);
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Beklenmeyen bir hata oluştu: $e');
    }
  }

  Future<ApiResponse<List<T>>> smartGetList<T>(
    String path,
    T Function(Map<String, dynamic>) fromJson, {
    Map<String, dynamic>? queryParameters,
    String? language,
  }) async {
    try {
      final params = queryParameters ?? {};
      if (language != null) {
        params['language'] = language;
      }

      final response = await _dio.get(path, queryParameters: params);
      final apiResponse = await handleListResponse<T>(
        Future.value(response),
        fromJson,
      );

      if (apiResponse.success) {
        if (AppConfig.enableApiLogging) {
          LoggerService.info('✅ Using API data for: $path');
        }
        return apiResponse;
      } else {
        throw ApiException.fromStatusCode(
            apiResponse.statusCode, apiResponse.message);
      }
    } on DioException catch (e) {
      throw _convertDioExceptionToApiException(e);
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Beklenmeyen bir hata oluştu: $e');
    }
  }

  ApiException _convertDioExceptionToApiException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException.timeoutError();
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode ?? 500;
        String? message;

        // Try to extract message from response body
        if (error.response?.data != null &&
            error.response?.data is Map<String, dynamic>) {
          final responseBody = error.response!.data as Map<String, dynamic>;
          final data = responseBody['data'];

          if (data is Map<String, dynamic> && data.containsKey('message')) {
            message = data['message']?.toString();
          } else if (responseBody.containsKey('message')) {
            message = responseBody['message']?.toString();
          } else if (responseBody.containsKey('description')) {
            message = responseBody['description']?.toString();
          }
        }
        return ApiException.fromStatusCode(statusCode, message);
      case DioExceptionType.connectionError:
        return ApiException.networkError();
      default:
        return ApiException('Bilinmeyen bir hata oluştu');
    }
  }

  // Common HTTP Methods
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    String? language,
  }) {
    final params = queryParameters ?? {};
    if (language != null) {
      params['language'] = language;
    }

    return _dio.get(path, queryParameters: params);
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    String? language,
  }) {
    final params = queryParameters ?? {};
    if (language != null) {
      params['language'] = language;
    }

    return _dio.post(
      path,
      data: data,
      queryParameters: params,
    );
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
    );
  }

  Future<Response> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.delete(
      path,
      queryParameters: queryParameters,
    );
  }

  // File Upload
  Future<Response> uploadFile(
    String path,
    String filePath, {
    String fieldName = 'file',
    Map<String, dynamic>? additionalData,
  }) async {
    final formData = FormData.fromMap({
      fieldName: await MultipartFile.fromFile(filePath),
      if (additionalData != null) ...additionalData,
    });

    return _dio.post(
      path,
      data: formData,
      options: Options(
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      ),
    );
  }

  // Get current language from context (fallback to default)
  String getCurrentLanguage([BuildContext? context]) {
    if (context != null) {
      return AppLocalization.of(context).locale.languageCode;
    }
    return ApiConstants.defaultLanguage;
  }

  void dispose() {
    _dio.close();
  }
}
