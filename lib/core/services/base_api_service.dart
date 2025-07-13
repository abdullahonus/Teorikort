import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';
import '../constants/app_config.dart';
import '../models/api_response.dart';
import '../exceptions/api_exception.dart';
import 'logger_service.dart';
import '../localization/app_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
      connectTimeout: Duration(seconds: AppConfig.apiTimeoutSeconds),
      receiveTimeout: Duration(seconds: AppConfig.apiTimeoutSeconds),
      sendTimeout: Duration(seconds: AppConfig.apiTimeoutSeconds),
    ));

    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Auto-add auth token if available
        final token = await getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        // Auto-add language parameter if not exists
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
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final response = await apiCall;

      // Backend uses statuscode field for success indication
      final responseData = response.data as Map<String, dynamic>;
      final statusCode = responseData['statuscode'] as int;
      final description = responseData['description'] as String;
      final data = responseData['data'];

      if (statusCode == ApiConstants.success) {
        return ApiResponse<T>(
          success: true,
          statusCode: statusCode,
          message: description,
          data: data != null ? fromJson(data) : null,
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

  // Generic API Response Handler for Lists
  Future<ApiResponse<List<T>>> handleListResponse<T>(
    Future<Response> apiCall,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final response = await apiCall;
      final responseData = response.data as Map<String, dynamic>;
      final statusCode = responseData['statuscode'] as int;
      final description = responseData['description'] as String;
      final data = responseData['data'];

      if (statusCode == ApiConstants.success && data != null) {
        // Handle different list structures from API
        List<dynamic> items = [];
        if (data is Map<String, dynamic>) {
          // If data contains a list field (e.g., categories, questions, results)
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

  ApiResponse<T> _handleDioError<T>(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return ApiResponse<T>(
          success: false,
          statusCode: 408,
          message: 'Bağlantı zaman aşımına uğradı',
        );
      case DioExceptionType.sendTimeout:
        return ApiResponse<T>(
          success: false,
          statusCode: 408,
          message: 'İstek gönderilirken zaman aşımı',
        );
      case DioExceptionType.receiveTimeout:
        return ApiResponse<T>(
          success: false,
          statusCode: 408,
          message: 'Yanıt alınırken zaman aşımı',
        );
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode ?? 500;
        return ApiResponse<T>(
          success: false,
          statusCode: statusCode,
          message: _getErrorMessage(statusCode),
        );
      case DioExceptionType.connectionError:
        return ApiResponse<T>(
          success: false,
          statusCode: 503,
          message: 'İnternet bağlantısını kontrol edin',
        );
      default:
        return ApiResponse<T>(
          success: false,
          statusCode: 500,
          message: 'Bilinmeyen bir hata oluştu',
        );
    }
  }

  String _getErrorMessage(int statusCode) {
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

  // Mock Data Fallback Methods
  Future<ApiResponse<T>> _getMockData<T>(
    String endpoint,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      // Map endpoints to mock data files
      String assetPath = _getMockAssetPath(endpoint);
      String jsonString = await rootBundle.loadString(assetPath);

      // Parse and return mock data
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      return ApiResponse<T>(
        success: true,
        statusCode: 100,
        message: 'Mock data loaded successfully',
        data: fromJson(jsonData),
      );
    } catch (e) {
      LoggerService.error('Mock data fallback failed:', e);
      throw ApiException('Mock data yüklenemedi.');
    }
  }

  Future<ApiResponse<List<T>>> _getMockListData<T>(
    String endpoint,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      String assetPath = _getMockAssetPath(endpoint);
      String jsonString = await rootBundle.loadString(assetPath);

      final dynamic jsonData = json.decode(jsonString);
      List<dynamic> items = [];

      if (jsonData is List) {
        items = jsonData;
      } else if (jsonData is Map<String, dynamic>) {
        // Handle different list structures
        if (jsonData.containsKey('categories')) {
          items = jsonData['categories'] as List<dynamic>;
        } else if (jsonData.containsKey('questions')) {
          items = jsonData['questions'] as List<dynamic>;
        } else if (jsonData.containsKey('topics')) {
          items = jsonData['topics'] as List<dynamic>;
        }
      }

      final parsedItems =
          items.map((item) => fromJson(item as Map<String, dynamic>)).toList();

      return ApiResponse<List<T>>(
        success: true,
        statusCode: 100,
        message: 'Mock data loaded successfully',
        data: parsedItems,
      );
    } catch (e) {
      LoggerService.error('Mock list data fallback failed:', e);
      throw ApiException('Mock data yüklenemedi.');
    }
  }

  String _getMockAssetPath(String endpoint) {
    // Map API endpoints to mock data files
    switch (endpoint) {
      case '/exam-categories':
        return 'assets/data/categories_data.json';
      case '/quiz/questions':
        return 'assets/data/quiz_questions.json';
      case '/mock-exams/questions':
        return 'assets/data/mock_exam_questions.json';
      case '/home':
        return 'assets/data/home_data.json';
      case '/daily-tips/today':
        return 'assets/data/daily_tips.json';
      case '/topics':
        return 'assets/data/topics_data.json';
      case '/statistics':
        return 'assets/data/statistics_data.json';
      case '/leaderboard':
        return 'assets/data/mock_users.json';
      default:
        throw Exception('No mock data available for endpoint: $endpoint');
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
        if (AppConfig.enableMockFallback) {
          if (AppConfig.enableApiLogging) {
            LoggerService.error('API failed, using mock data for: $path');
          }
          return await _getMockData<T>(path, fromJson);
        } else {
          throw ApiException.fromStatusCode(
              apiResponse.statusCode!, apiResponse.message);
        }
      }
    } on DioException catch (e) {
      if (AppConfig.enableMockFallback) {
        if (AppConfig.enableApiLogging) {
          LoggerService.error(
              'API error, using mock data for: $path - ${e.message}');
        }
        return await _getMockData<T>(path, fromJson);
      } else {
        throw _convertDioExceptionToApiException(e);
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }

      if (AppConfig.enableMockFallback) {
        if (AppConfig.enableApiLogging) {
          LoggerService.error(
              'Unexpected error, using mock data for: $path - $e');
        }
        return await _getMockData<T>(path, fromJson);
      } else {
        throw ApiException('Beklenmeyen bir hata oluştu: $e');
      }
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
        if (AppConfig.enableMockFallback) {
          if (AppConfig.enableApiLogging) {
            LoggerService.error('API failed, using mock data for: $path');
          }
          return await _getMockListData<T>(path, fromJson);
        } else {
          throw ApiException.fromStatusCode(
              apiResponse.statusCode!, apiResponse.message);
        }
      }
    } on DioException catch (e) {
      if (AppConfig.enableMockFallback) {
        if (AppConfig.enableApiLogging) {
          LoggerService.error(
              'API error, using mock data for: $path - ${e.message}');
        }
        return await _getMockListData<T>(path, fromJson);
      } else {
        throw _convertDioExceptionToApiException(e);
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }

      if (AppConfig.enableMockFallback) {
        if (AppConfig.enableApiLogging) {
          LoggerService.error(
              'Unexpected error, using mock data for: $path - $e');
        }
        return await _getMockListData<T>(path, fromJson);
      } else {
        throw ApiException('Beklenmeyen bir hata oluştu: $e');
      }
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
        return ApiException.fromStatusCode(statusCode);
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
