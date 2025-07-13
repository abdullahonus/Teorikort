class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? errorCode;
  final Map<String, dynamic>? details;

  ApiException(
    this.message, {
    this.statusCode,
    this.errorCode,
    this.details,
  });

  @override
  String toString() => message;

  // Factory constructors for common error types
  factory ApiException.networkError() {
    return ApiException(
      'İnternet bağlantınızı kontrol edin.',
      statusCode: 0,
      errorCode: 'network_error',
    );
  }

  factory ApiException.timeoutError() {
    return ApiException(
      'İstek zaman aşımına uğradı. Lütfen tekrar deneyin.',
      statusCode: 0,
      errorCode: 'timeout_error',
    );
  }

  factory ApiException.unauthorized() {
    return ApiException(
      'Oturum süresi doldu. Lütfen tekrar giriş yapın.',
      statusCode: 401,
      errorCode: 'unauthorized',
    );
  }

  factory ApiException.forbidden() {
    return ApiException(
      'Bu işlem için yetkiniz bulunmamaktadır.',
      statusCode: 403,
      errorCode: 'forbidden',
    );
  }

  factory ApiException.notFound() {
    return ApiException(
      'İstenen kaynak bulunamadı.',
      statusCode: 404,
      errorCode: 'not_found',
    );
  }

  factory ApiException.serverError() {
    return ApiException(
      'Sunucu hatası oluştu. Lütfen daha sonra tekrar deneyin.',
      statusCode: 500,
      errorCode: 'server_error',
    );
  }

  factory ApiException.validationError(String message) {
    return ApiException(
      message,
      statusCode: 422,
      errorCode: 'validation_error',
    );
  }

  // Convert HTTP status codes to user-friendly messages
  factory ApiException.fromStatusCode(int statusCode, [String? message]) {
    switch (statusCode) {
      case 400:
        return ApiException(
          message ?? 'Geçersiz istek gönderildi.',
          statusCode: statusCode,
          errorCode: 'bad_request',
        );
      case 401:
        return ApiException.unauthorized();
      case 403:
        return ApiException.forbidden();
      case 404:
        return ApiException.notFound();
      case 422:
        return ApiException.validationError(
            message ?? 'Girilen bilgiler geçersiz.');
      case 500:
        return ApiException.serverError();
      default:
        return ApiException(
          message ?? 'Beklenmeyen bir hata oluştu.',
          statusCode: statusCode,
          errorCode: 'unknown_error',
        );
    }
  }
}
