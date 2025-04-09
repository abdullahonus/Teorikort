import 'dart:developer' as developer;

class LoggerService {
  static void info(String message, [dynamic data]) {
    developer.log(
      '💡 $message ${data != null ? '\nData: $data' : ''}',
      name: 'INFO',
      time: DateTime.now(),
    );
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    developer.log(
      '⛔ $message ${error != null ? '\nError: $error' : ''} ${stackTrace != null ? '\nStackTrace: $stackTrace' : ''}',
      name: 'ERROR',
      time: DateTime.now(),
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void debug(String message, [dynamic data]) {
    developer.log(
      '🐛 $message ${data != null ? '\nData: $data' : ''}',
      name: 'DEBUG',
      time: DateTime.now(),
    );
  }

  static void api(String type, String endpoint, dynamic data,
      [int? statusCode]) {
    developer.log(
      '🌐 API $type: $endpoint\n'
      '${statusCode != null ? 'Status: $statusCode\n' : ''}'
      'Data: $data',
      name: 'API',
      time: DateTime.now(),
    );
  }
}
