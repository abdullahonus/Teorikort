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
      statusCode == 100 &&
      data != null; // Updated to use 100 for backend compatibility
}
