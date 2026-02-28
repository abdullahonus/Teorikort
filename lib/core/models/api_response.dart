class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final int statusCode;
  final Map<String, dynamic>? pagination;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    required this.statusCode,
    this.pagination,
  });

  factory ApiResponse.success(T data, {String? message, Map<String, dynamic>? pagination}) {
    return ApiResponse(
      success: true,
      data: data,
      message: message,
      statusCode: 200,
      pagination: pagination,
    );
  }

  factory ApiResponse.error(String? message, {int statusCode = 500}) {
    return ApiResponse(
      success: false,
      message: message,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
    int statusCode,
  ) {
    final data = json['data'];
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message']?.toString(),
      data:
          data != null && data is Map<String, dynamic> ? fromJson(data) : null,
      statusCode: statusCode,
      pagination: json['pagination'] as Map<String, dynamic>?,
    );
  }

  bool get isSuccess =>
      success &&
      (statusCode == 100 || statusCode == 200) &&
      data != null;
}
