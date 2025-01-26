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
      Map<String, dynamic> json, T? Function(Map<String, dynamic>)? fromJson) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null && fromJson != null
          ? fromJson(json['data'])
          : null,
      statusCode: json['statusCode'] ?? 500,
    );
  }
}
