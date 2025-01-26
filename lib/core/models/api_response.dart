class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final int statusCode;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    required this.statusCode,
  });

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
    );
  }

  bool get isSuccess => success && statusCode == 200 && data != null;
}
