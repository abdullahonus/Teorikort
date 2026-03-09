class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final int statusCode;
  final Map<String, dynamic>? pagination;
  final Map<String, dynamic>? rawJson;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    required this.statusCode,
    this.pagination,
    this.rawJson,
  });

  factory ApiResponse.success(T data,
      {String? message, Map<String, dynamic>? pagination}) {
    return ApiResponse(
      success: true,
      data: data,
      message: message,
      statusCode: 200,
      pagination: pagination,
      rawJson: null,
    );
  }

  factory ApiResponse.error(String? message, {int statusCode = 500}) {
    return ApiResponse(
      success: false,
      message: message,
      statusCode: statusCode,
      rawJson: null,
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
      rawJson: json,
    );
  }

  bool get isSuccess =>
      success && (statusCode == 100 || statusCode == 200) && data != null;
}
