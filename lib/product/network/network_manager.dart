import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/app_config.dart';
import '../../core/exceptions/api_exception.dart';
import '../../core/models/api_response.dart';
import '../../core/services/logger_service.dart';
import '../../core/localization/app_localization.dart';

/// Spec'teki `NetworkManager` karşılığı.
/// Tüm servisler bu sınıftan extend eder veya inject alır.
/// BaseApiService ile birebir aynı API'yi korur —
/// servisler import değiştirmeden çalışmaya devam eder.
class NetworkManager {
  late final Dio _dio;
  final FlutterSecureStorage _storage;
  static const String _tokenKey = 'auth_token';

  NetworkManager({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage() {
    _initializeDio();
  }

  void _initializeDio() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      headers: ApiConstants.headers,
      connectTimeout: const Duration(seconds: AppConfig.apiTimeoutSeconds),
      receiveTimeout: const Duration(seconds: AppConfig.apiTimeoutSeconds),
      sendTimeout: const Duration(seconds: AppConfig.apiTimeoutSeconds),
    ));
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(ChuckerDioInterceptor());
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        if (!options.queryParameters.containsKey('language')) {
          options.queryParameters['language'] = ApiConstants.defaultLanguage;
        }
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
            {'statusCode': response.statusCode, 'data': response.data},
            response.statusCode,
          );
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

  // ─── Token Management ───────────────────────────────────────────────────────

  Future<String?> getToken() async => _storage.read(key: _tokenKey);

  Future<void> saveToken(String token) async =>
      _storage.write(key: _tokenKey, value: token);

  Future<void> deleteToken() async => _storage.delete(key: _tokenKey);

  // ─── Response Handlers ──────────────────────────────────────────────────────

  Future<ApiResponse<T>> handleResponse<T>(
    Future<Response> apiCall,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final response = await apiCall;
      Map<String, dynamic> responseData =
          response.data as Map<String, dynamic>;

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
          statusCode == ApiConstants.success) {
        return ApiResponse<T>(
          success: true,
          statusCode: statusCode,
          message: description,
          data: data != null ? fromJson(data as Map<String, dynamic>) : null,
        );
      } else {
        return ApiResponse<T>(
          success: false,
          statusCode: statusCode,
          message: description,
        );
      }
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    } catch (e) {
      LoggerService.error('Unexpected API Error:', e);
      return ApiResponse<T>(
        success: false,
        statusCode: 500,
        message: 'Beklenmeyen bir hata oluştu',
      );
    }
  }

  Future<ApiResponse<List<T>>> handleListResponse<T>(
    Future<Response> apiCall,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final response = await apiCall;
      Map<String, dynamic> responseData =
          response.data as Map<String, dynamic>;

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
              statusCode == ApiConstants.success) &&
          data != null) {
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
          pagination:
              data is Map<String, dynamic> ? data['pagination'] : null,
        );
      } else {
        return ApiResponse<List<T>>(
          success: false,
          statusCode: statusCode,
          message: description,
        );
      }
    } on DioException catch (e) {
      return _handleDioError<List<T>>(e);
    } catch (e) {
      LoggerService.error('Unexpected API Error:', e);
      return ApiResponse<List<T>>(
        success: false,
        statusCode: 500,
        message: 'Beklenmeyen bir hata oluştu',
      );
    }
  }

  // ─── Smart Methods (throw ApiException on failure) ────────────────────────

  Future<ApiResponse<T>> smartGet<T>(
    String path,
    T Function(Map<String, dynamic>) fromJson, {
    Map<String, dynamic>? queryParameters,
    String? language,
  }) async {
    try {
      final params = queryParameters ?? {};
      if (language != null) params['language'] = language;

      final response = await _dio.get(path, queryParameters: params);
      final apiResponse =
          await handleResponse<T>(Future.value(response), fromJson);

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
      throw _convertDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;
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
      if (language != null) params['language'] = language;

      final response = await _dio.get(path, queryParameters: params);
      final apiResponse = await handleListResponse<T>(
          Future.value(response), fromJson);

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
      throw _convertDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Beklenmeyen bir hata oluştu: $e');
    }
  }

  // ─── HTTP Methods ──────────────────────────────────────────────────────────

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    String? language,
  }) {
    final params = queryParameters ?? {};
    if (language != null) params['language'] = language;
    return _dio.get(path, queryParameters: params);
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    String? language,
  }) {
    final params = queryParameters ?? {};
    if (language != null) params['language'] = language;
    return _dio.post(path, data: data, queryParameters: params);
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) =>
      _dio.put(path, data: data, queryParameters: queryParameters);

  Future<Response> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) =>
      _dio.delete(path, queryParameters: queryParameters);

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
      options: Options(headers: {'Content-Type': 'multipart/form-data'}),
    );
  }

  String getCurrentLanguage([BuildContext? context]) {
    if (context != null) {
      return AppLocalization.of(context).locale.languageCode;
    }
    return ApiConstants.defaultLanguage;
  }

  void dispose() => _dio.close();

  // ─── Private Helpers ────────────────────────────────────────────────────────

  ApiResponse<T> _handleDioError<T>(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return ApiResponse<T>(
            success: false,
            statusCode: 408,
            message: 'Bağlantı zaman aşımına uğradı');
      case DioExceptionType.sendTimeout:
        return ApiResponse<T>(
            success: false,
            statusCode: 408,
            message: 'İstek gönderilirken zaman aşımı');
      case DioExceptionType.receiveTimeout:
        return ApiResponse<T>(
            success: false,
            statusCode: 408,
            message: 'Yanıt alınırken zaman aşımı');
      case DioExceptionType.badResponse:
        final sc = error.response?.statusCode ?? 500;
        return ApiResponse<T>(
            success: false,
            statusCode: sc,
            message: _errorMessage(sc));
      case DioExceptionType.connectionError:
        return ApiResponse<T>(
            success: false,
            statusCode: 503,
            message: 'İnternet bağlantısını kontrol edin');
      default:
        return ApiResponse<T>(
            success: false,
            statusCode: 500,
            message: 'Bilinmeyen bir hata oluştu');
    }
  }

  ApiException _convertDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException.timeoutError();
      case DioExceptionType.badResponse:
        return ApiException.fromStatusCode(
            error.response?.statusCode ?? 500);
      case DioExceptionType.connectionError:
        return ApiException.networkError();
      default:
        return ApiException('Bilinmeyen bir hata oluştu');
    }
  }

  String _errorMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Geçersiz istek';
      case 401:
        return 'Oturum süreniz dolmuş. Lütfen tekrar giriş yapın';
      case 403:
        return 'Bu işlem için yetkiniz yok';
      case 404:
        return 'İstenen kaynak bulunamadı';
      case 409:
        return 'Çakışma oluştu';
      case 422:
        return 'Geçersiz veri girişi';
      case 429:
        return 'Çok fazla istek. Lütfen bekleyin';
      case 500:
        return 'Sunucu hatası oluştu';
      case 503:
        return 'Servis geçici olarak kullanılamıyor';
      default:
        return 'Bir hata oluştu';
    }
  }
}
